pragma solidity ^0.8.4;

// SPDX-License-Identifier: MIT


// Imports
import { Math } from "./Math.sol";
import { GameOption, GameOptions } from "./GameOptions.sol";
import { PackedBet, PackedBets } from "./PackedBets.sol";

/**
 * The library provides abstractions to manage contract's bets storage in a code-friendly way.
 *
 * The main idea behind the routines is to abuse the fact that a single PackedBet occupies 32 bytes, meaining
 * that the contract can store 8 of those in a single storage slot. Squeezing multiple bets into a single slots
 * allows to save on gas tremendeously and requires just a handful of helper routines to make it transparent to the
 * outer contract.
 *
 * The library exports a struct called Bets that is designed to keep track of players' bets – an instance of this structre,
 * along with "storage" modifier, is required to invoke libraries' functions.
 */
library BetStorage {
  // Extension functions
  using PackedBets for PackedBet;

  /**
   * The structure defining mappings to keep track of players' bets.
   * it keeps two separate mappings, one for tracking player nonces (seq numbers of bets being placed),
   * the other holds the data itself.
   */
  struct Bets {
    mapping (address => uint) playerNoncesBy8;
    mapping (address => mapping (uint => uint)) playerBets;
  }

  // The bit to be set in playerNoncesBy8 mapping to disable accepting bets from an address
  uint constant internal PLAYER_NONCE_ACCOUNT_BANNED_BIT = 1;
  // The bit mask selecting the bits so that the number would turn into number mod 8
  uint constant internal PLAYER_NONCE_MOD8_MASK = uint(0x7);
  // The number of bits to shift the number to divide or multiply by 32 (log2(32))
  uint constant internal MULTIPLY_BY_32_BIT_SHIFT = 5;
  // The bit mask selecting exactly PackedBets.PACKED_BET_LENGTH bits
  uint constant internal PACKED_BET_MASK = 2 ** PackedBets.PACKED_BET_LENGTH - 1;
  // The bit mask selecting the bits so that the number would turn into number div 8
  uint constant internal PLAYER_NONCE_DIV8_MASK = ~PLAYER_NONCE_MOD8_MASK;
  // The number of packed bets stored in a single storage slot
  uint constant internal PACKED_BETS_PER_SLOT = 8;

  // The bit mask selecting bits from 8 possible PackedBets stored in a single slot. ANDing the slot value with
  // this constant allows for quick checks of whether there any PackedBets with non-zero amounts in this slot.
  uint constant internal ALL_QUANT_AMOUNTS_MASK =
    PackedBets.QUANT_AMOUNT_MASK |
    PackedBets.QUANT_AMOUNT_MASK << (PackedBets.PACKED_BET_LENGTH * 1) |
    PackedBets.QUANT_AMOUNT_MASK << (PackedBets.PACKED_BET_LENGTH * 2) |
    PackedBets.QUANT_AMOUNT_MASK << (PackedBets.PACKED_BET_LENGTH * 3) |
    PackedBets.QUANT_AMOUNT_MASK << (PackedBets.PACKED_BET_LENGTH * 4) |
    PackedBets.QUANT_AMOUNT_MASK << (PackedBets.PACKED_BET_LENGTH * 5) |
    PackedBets.QUANT_AMOUNT_MASK << (PackedBets.PACKED_BET_LENGTH * 6) |
    PackedBets.QUANT_AMOUNT_MASK << (PackedBets.PACKED_BET_LENGTH * 7);

  // The number indicating the slot is full with bets, i.e. all 8 spots are occupied by instances of PackedBet. The check is based
  // on the fact that we fill up the slot from left to right, meaning that placing the 8th PackedBet into a slot will set some bits higher than 224th one.
  uint constant internal FULL_SLOT_THRESHOLD = PackedBets.QUANT_AMOUNT_THRESHOLD << (PackedBets.PACKED_BET_LENGTH * 7);

  // An error indicating the player's address is not allowed to place the bets
  error AccountSuspended();

  /**
   * Being given the storage-located struct, the routine places PackedBet instance made by a player into a spare slot
   * and returns this bet's playerNonce - a seq number of the bet made by the player against this instance of the contract.
   *
   * @param bets the instance of Bets struct to manipulate.
   * @param player the address of the player placing the bet.
   * @param packedBet the instance of the PackedBet to place.
   *
   * @return playerNonce the seq number of the bet made by this player.
   */
  function storePackedBet(Bets storage bets, address player, PackedBet packedBet) internal returns (uint playerNonce) {
    // first off, read the current player's nonce. We are storing the nonces in 8 increments to avoid
    // unneccessary storage operations – in any case, each storage slot contains 8 bets, so we only need to know
    // the number / 8 to operate.
    uint playerNonceBy8 = bets.playerNoncesBy8[player];

    // if the PLAYER_NONCE_ACCOUNT_BANNED_BIT bit is set, it means we do not want to accept the bets from this player's address
    if (playerNonceBy8 & PLAYER_NONCE_ACCOUNT_BANNED_BIT != 0) {
      revert AccountSuspended();
    }

    // read the current slot being
    uint slot = bets.playerBets[player][playerNonceBy8];

    // identify how many 32 bit chunks (i.e. PackedBet) are already stored there
    uint betOffsetInSlot = Math.getBitLength32(slot);
    // divide this number by 32 (to get from bit offsets to actual number)
    uint playerNonceMod8 = betOffsetInSlot >> MULTIPLY_BY_32_BIT_SHIFT;

    // modify the slot by placing the current bet into the spare space – shift the data by freeShift value to achieve this
    slot |= (packedBet.toUint() << betOffsetInSlot);

    // update the slot in the storage
    bets.playerBets[player][playerNonceBy8] = slot;

    // IMPORTANT: did we just take the last available spot in the slot?
    if (playerNonceMod8 == (PACKED_BETS_PER_SLOT - 1)) {
      // if we did, update the player's nonce so that next bets would write to the new slot
      bets.playerNoncesBy8[player] = playerNonceBy8 + PACKED_BETS_PER_SLOT;
    }

    // return full value of player's nonce
    playerNonce = playerNonceBy8 + playerNonceMod8;
  }

  /**
   * Being given the storage-located struct, the routine extracts a bet from the storage.
   *
   * Extracting the bet means the corresponding part of the storage slot is modified so that the amount kept in
   * corresponding PackedBet entry is reset to 0 to indicate the bet has been proccessed.
   *
   * Once ALL of the bets in a slot are marked as processed, the slot is cleared to become 0, allowing us to reclaim a
   * bit of gas.
   *
   * @param bets the instance of Bets struct to manipulate.
   * @param player the address of the player placing the bet.
   * @param playerNonce the playerNonce to read from the storage.
   *
   * @return the instance of the PackedBet found in the corresponding slot; might be 0x0 if missing.
   */
  function ejectPackedBet(Bets storage bets, address player, uint playerNonce) internal returns (PackedBet) {
    // compute the playerNonce div 8 – that's the nonce value we use in the store (see storePackedBet)
    uint playerNonceBy8 = playerNonce & PLAYER_NONCE_DIV8_MASK;
    // compute the position of the bet in the slot – it's offset by N PackedBet places, where N = playerNonce mod 8
    uint betOffsetInSlot = (playerNonce & PLAYER_NONCE_MOD8_MASK) << MULTIPLY_BY_32_BIT_SHIFT;

    // read the current slot's value
    uint slot = bets.playerBets[player][playerNonceBy8];

    // read the specific PackedBet, ANDing with PACKED_BET_MASK to avoid integer overflows
    uint data = (slot >> betOffsetInSlot) & PACKED_BET_MASK;

    // compute the positions of the bits where the amount value for the current bet is stored – it is simply
    // QUANT_AMOUNT_MASK shifted into the position of the PackedBet instance within the slot.
    uint amountZeroMask = ~(PackedBets.QUANT_AMOUNT_MASK << betOffsetInSlot);

    // clear up the bits corresponding to amount of our packed bet, essentially clearing the amount down to 0
    slot &= amountZeroMask;

    // check if all the spots in the slot contain 0s in amount AND if the slot is full...
    if (((slot & ALL_QUANT_AMOUNTS_MASK) == 0) && (slot >= FULL_SLOT_THRESHOLD)) {
      // delete the slot's data to get some gas refunded
      slot = 0;
    }

    // update the storage
    bets.playerBets[player][playerNonceBy8] = slot;

    // produce a PackedBet instance by wrapping the data. Since the data comes from the contract storage, and this library is the
    // only one that writes it, we do not need to perform additional validations here
    return PackedBet.wrap(data);
  }

  /**
   * Marks the entry in playerNonce with a flag indicating this player address should not be allowed to place new bets.
   *
   * @param bets the instance of Bets struct to manipulate.
   * @param player the address of the player placing the bet.
   * @param suspend whether to suspend or un-suspend the player.
   */
  function suspendPlayer(Bets storage bets, address player, bool suspend) internal {
    if (suspend) {
      // set 1st bit on the nonce counter
      bets.playerNoncesBy8[player] |= PLAYER_NONCE_ACCOUNT_BANNED_BIT;
    } else {
      // clear 1st bit from the nonce counter
      bets.playerNoncesBy8[player] &= ~PLAYER_NONCE_ACCOUNT_BANNED_BIT;
    }
  }
}
pragma solidity ^0.8.4;

// SPDX-License-Identifier: MIT


// Imports
import { Math } from "./Math.sol";

/**
 * The library provides an abstraction to maintain the summary state of the contract.
 *
 * The main idea is to aggregate all frequently accessed parameters into a structure called State
 * which occupies a single 256-bit slot. Frequent mutations on it are performed in memory and only the
 * final result is committed to storage.
 *
 * State also conveniently packs almost all information that is needed to compute locked amounts.
 */
library ContractState {
  // Extension functions.
  using Math for bool;

  // A single 256-bit slot summary state structure. Custom sizes of the member fields are required for packing.
  struct State {
    // The total number of funds potentially due to be paid if all pending bets win
    uint96 lockedInBets;
    // The number of not-yet-settled bets that are playing for jackpot
    uint48 jackpotBetCount;
    // The value indicating the maximum potential win a bet is allowed to make. We have to cap that value to avoid
    // draining the contract in a single bet by whales who put huge bets for high odds.
    uint80 maxProfit;
    // The multiplier of the jackpot payment, set by the house.
    uint32 jackpotMultiplier;
  }

  // The maximum number of jackpot bets to consider when testing for locked funds.
  uint constant internal JACKPOT_LOCK_COUNT_CAP = 5;

  /**
   * Adding a new lock to prevent overcommitting to what the contract can't settle in worst case.
   *
   * @param lockedAmount newly locked amount.
   * @param playsForJackpot whether to account for a potential jackpot win.
   */
  function lockFunds(State memory self, uint lockedAmount, bool playsForJackpot) internal pure {
    // add the potential win to lockedInBets so that the contract always knows how much it owns in the worst case
    self.lockedInBets += uint96(lockedAmount);
    // increment the number of bets playing for a Jackpot to keep track of those too
    self.jackpotBetCount += uint48(playsForJackpot.toUint());
  }

  /**
   * Remove the lock after the bet have been processed (settled/refunded).
   *
   * @param lockedAmount locked amount.
   * @param playsForJackpot whether it was a potential jackpot win.
   */
  function unlockFunds(State memory self, uint lockedAmount, bool playsForJackpot) internal pure {
    // remove the potential win from jackpot
    self.lockedInBets -= uint96(lockedAmount);
    // ... and decrease the jackpot bet count to reduce the jackpot locked amount as well
    self.jackpotBetCount -= uint48(playsForJackpot.toUint());
  }

  /**
   * Remove the lock after the bet have been processed (settled/refunded). Direct storage access.
   *
   * @param lockedAmount locked amount.
   * @param playsForJackpot whether it was a potential jackpot win.
   */
  function unlockFundsStorage(State storage self, uint lockedAmount, bool playsForJackpot) internal {
    self.lockedInBets -= uint96(lockedAmount);
    self.jackpotBetCount -= uint48(playsForJackpot.toUint());
  }

  /**
   * Computes the total value the contract currently owes to players in case all the pending bets resolve as winning ones.
   *
   * The value is composed primarily from the sum of possible wins from every bet and further increased by the current maximum
   * Jackpot payout value for every bet playing for Jackpot (capped at 5 since Jackpots are very rare).
   *
   * Note re lock multiplier: the value should result in the locked amount conforming to the logic of computeJackpotAmount in Dice9.sol.
   * This would mean it needs to equal product JACKPOT_FEE and JACK_MODULO and maximum winning per paytable (4) divided
   * by the fixed point base of the jackpot multiplier (8).
   *
   * @param maxJackpotPayment maximum jackpot win amount according to the paytable.
   * @param jackpotMultiplierBase the denominator of the jackpotMultiplier value.
   *
   * @return the total number of funds required to cover the most extreme resolution of pending bets (everything wins everything).
   */
  function totalLockedInBets(State memory self, uint maxJackpotPayment, uint jackpotMultiplierBase) internal pure returns (uint) {
    // cap the amount of jackpot locks as those are rare and locks are too conservative as a result
    uint jackpotLocks = Math.min(self.jackpotBetCount, JACKPOT_LOCK_COUNT_CAP);
    uint jackpotLockedAmount = jackpotLocks * self.jackpotMultiplier * maxJackpotPayment / jackpotMultiplierBase;

    // compute total locked amount (regular bet winnings + jackpot winnings)
    return self.lockedInBets + jackpotLockedAmount;
  }
}
pragma solidity ^0.8.4;

// SPDX-License-Identifier: MIT


// Imports
import { TinyStrings, TinyString } from "./TinyStrings.sol";
import { Math } from "./Math.sol";
import { Options } from "./Options.sol";
import { BetStorage } from "./BetStorage.sol";
import { GameOptions, GameOption } from "./GameOptions.sol";
import { PackedBets, PackedBet } from "./PackedBets.sol";
import { ContractState } from "./ContractState.sol";
import { VRF } from "./VRF.sol";

/**
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * *                                                                                                                                   * *
 * *                                                      Welcome to dice9.win!                                                        * *
 * *                                                                                                                                   * *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * Summary
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Inspired by many projects in the Ethereum ecosystem, this smart contract implements a set of robust, provably fair games of chance.
 * The users can play one of four available games, wagering cryptocurrency at the odds they choose and even take part in Jackpot rolls!
 *
 * Coin Flip
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * This game allows to choose a side of the coin – heads or tails – and bet on it. Once the bet settles, the winning amount is paid if the
 * side matches the one chosen by the player.
 *
 * Dice
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * This game allows to choose 1 to 5 numbers of a dice cube and wins if a dice roll ends up with one of those numbers. The more numbers
 * are chosen the higher is the chance of winning, but the multiplier is less.
 *
 * Two Dice
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * This game allows to choose 1 to 11 numbers representing the sum of two dice. Similar to Dice game, if two dice add up to one of the
 * numbers chosen, the winnings are paid back.
 *
 * Etheroll
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * This game allows to place a bet on a number in 3 to 97 range, and if the random number produced (from 1..100 range) is less or equal
 * than the chosen one, the bet is considered a win.
 *
 * Winnings
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * If a bet wins, all the funds (including Jackpot payment, if it was eligible and won the Jackpot) are paid back to the address which
 * made the bet. Due to legal aspects, we do not distribute the winnings to other address(es), other currencies and so on.
 *
 * Jackpots
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * If a bet exceeds a certain amount (the UI will display that), a tiny Jackpot fee is taken on top of default House commission and the
 * bet automatically plays for Jackpot. Jackpots are events that have 0.1% chance of happening, but if they do, the bet gets an extra
 * portion of the winnings determined by Jackpot logic. The Jackpot rolls are completely independent from the games themselves, meaning
 * if a bet that lost a game can still get a Jackpot win.
 *
 * Commisions
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * In order to maintain the game, which includes paying for bet resolution transactions, servers for the website, our support engineers
 * and developers, the smart contract takes a fee from every bet. The specific amounts can be seen below in the constants named
 * HOUSE_EDGE_PERCENT, HOUSE_EDGE_MINIMUM_AMOUNT and JACKPOT_FEE.
 *
 * Questions?
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Please feel free to refer to our website at https://dice9.win for instructions on how to play, support channel, legal documents
 * and other helpful things.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * *                                                                                                                                   * *
 * *                                               Good luck and see you at the tables!                                                * *
 * *                                                                                                                                   * *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 */
contract Dice9 {
  // Extension functions
  using TinyStrings for TinyString;
  using TinyStrings for string;
  using GameOptions for GameOption;
  using PackedBets for PackedBet;
  using ContractState for ContractState.State;
  using Math for bool;

  // The minimum amount of the fee the contract takes (this is required to support small bets)
  uint constant internal HOUSE_EDGE_MINIMUM_AMOUNT = 0.01 ether;
  // The minimum amount wagered that makes the bet play for Jackpot
  uint constant internal MIN_JACKPOT_BET = 1 ether;
  // The fee taken from player's bet as a contribution to Jackpot fund
  uint constant internal JACKPOT_FEE = 0.01 ether;
  // The probability of any eligible bet to win a Jackpot
  uint constant internal JACKPOT_MODULO = 1000;
  // The target number to be rolled to win the jackpot
  uint constant internal JACKPOT_WINNING_OUTCOME = 888;
  // What percentage does the smart conract take as a processing fee
  uint constant internal HOUSE_EDGE_PERCENT = 1;
  // The denominator of jackpotMultiplier value
  uint constant internal JACKPOT_MULTIPLIER_BASE = 8;
  // The paytable of the jackpot: each 2 octets specify the multiplier of the base jackpot to be paid
  uint constant internal JACKPOT_PAYTABLE = 0x0000000000000000000000000404040408080808101010101010101010202040;
  // The base Jackpot value used for calculations
  uint constant internal BASE_JACKPOT_PAYMENT = JACKPOT_MODULO * JACKPOT_FEE;
  // The maximum Jackpot payment before applying the multplier (max value from JACKPOT_PAYTABLE is 4).
  uint constant internal MAX_JACKPOT_PAYMENT = BASE_JACKPOT_PAYMENT * 4;
  // The number of slots in the Jackpot paytable.
  uint constant internal JACKPOT_PAYTABLE_SLOTS_COUNT = 20;
  // The denominator of the values from JACKPOT_PAYTABLE
  uint constant internal JACKPOT_PAYTABLE_BASE = 16;
  // The number of epochs to pass before the bet becomes refundable
  uint constant internal REFUNDABLE_BET_EPOCHS_DISTANCE = 2;
  // The RSA modulus values as 4 uint256 integers.
  uint constant internal MODULUS0 = 0xdc4e445b69fe9483216d0fa85492b4656287bfb2fb4da5b65f0b86cc2c073f3e;
  uint constant internal MODULUS1 = 0xe24a038d3d0e88c78b722b466c5ca1c89792c368ed182a5a13df919cac7fe335;
  uint constant internal MODULUS2 = 0x173cd04f23769d5ef027290f34a86e8fcab014f1a19d395b0662c5c52424a387;
  uint constant internal MODULUS3 = 0x96dd6f2394047d716abb6f48cc46abee6e2be3168348b456d5878cbec0b57d0f;

  /* A non-interactive zero knowledge proof of the fact that RSA modulus above creates a permutation (see https://github.com/dice9win/ for further details):
   *  nizk:16:0:0:qx2I2DmybcKkb8frFiyj2tTQ+lJVOuD8c+XFPt8+StnITfi69W176aOyWoc8TwvSeouW5ToEobg6Ayh/cUOGsA==
   *  nizk:16:0:1:puTlB/XckREdSt/Htm3Y985gjqRDxtkJS3omdLtb8ABjTgZjuldKjmUEILDpbrNyyxhkF6O2ZIWM186fqe3yHA==
   *  nizk:16:1:0:1X5oKWJW25ais7+6h2mDxXpLPObA62wf6qOyKDa7uNJM2CA5bmfyQ2OpKwK4WrR1a9rJm2d+rIGuVyP8EXitzg==
   *  nizk:16:1:1:oYTMV5PWPRRAx2WjZ55k7ozGMqDYmD9LgQ3PDlUswwhRWMn5M8/1SdHVIPTcl8EGXc935ZCRBEFC/lhaesNZuQ==
   *  nizk:16:2:0:cqNvz84MEzg/gCLg3V4YvrQNfuHMFg9fNj1FLPCpG4BLAnApX3aI+rcydhhCOv4/p2YCfx8tTVihCaFVRhZ8bw==
   *  nizk:16:2:1:Ch/aDozeRnNB+v+GkrvmSnX0MpfMbM+e0lNIu0UPh/9hZSVPA3aNEgVeJLgWO7SACguc1u378t3gpJjHIqbm5A==
   *  nizk:16:3:0:Vq1TLzGeSjXpXeNe33oNuwerZAVtHIgo3VSC75IHaKbL7teo7ya/0oCi9jEdrTV69C/NIHqFRb5THQsSohfCxw==
   *  nizk:16:3:1:WQMIwOm3QY63OwgpF5HOEUhIaAmPzM9slLt8V671KFlguZyFmPIhUtKqkGEQE1yiA7QKYZiUBU5My7mYyKlQKQ==
   *  nizk:16:4:0:REHNNKr9aqzeXDCdZQWY67k2/csHWfz/EYowq3FlKhQXN25tORK+S26IA8daiubaEu9BOsiSulFJVOlJjUAiTQ==
   *  nizk:16:4:1:MKMf19Gxpj11NGwA028DTICk03FYBmvTAYS5uu1EyAsTvaa4luoYelxTrD6hKYtoJCyDcVQon+2S3CyEklX0eA==
   *  nizk:16:5:0:ElT8FTZYGu8fh/uI9BrBiHg4IWZjTCPTV73JnnbZEyR5FQF9HZ1qelEp0WL6pUjtPEZKP7IRtln/D8boJGOeeg==
   *  nizk:16:5:1:wU8JVEVjcyGGaO5dTXn9oN0K9NRWS4KUOe1WKFkmdqc1JU5vdo1/FffGFgEMjBfSj+dC6a1fXBuMvl58rIBGYg==
   *  nizk:16:6:0:/kQ1Hfl/2kY2cuMt99u2FPffQAl1MgyMBs1C/n6AGVVHtPtUT4WccH/wBgHpVXb2UZ3msYq1+R9qDMGPSD2Eng==
   *  nizk:16:6:1:tkSkTxxNmX668/0yWGbu3sKgqgVmPHQFQrHkGHwWigaJZuFa7rbG9z/CD49S5+vxdokBkIUGeK42GUz5h/d/FA==
   *  nizk:16:7:0:IykfdQY54UxeNn6960Rw8O5ybQBVCfzUvkgW5OopOBEsyH2La/0rbf5CLjWoZi3fey6usNia862fn5D4yQaCEQ==
   *  nizk:16:7:1:R057pV5wIwP19KFckIGyQLdzY6Lb1bm750PcQYMGTwd74Y8t2GWhDpFkqDGR6ZT1kcQ6HGH8d3jj20ZyF641hg==
   *  nizk:16:8:0:VFJuyxTXWPZujSXIlynzaC2eUIN/H46uNnu8azp15PtWJX7q2aPsqPDSsTtRdnAl58Bc5L79YqOYosR33y9o1w==
   *  nizk:16:8:1:jreh3aw0b2kYuIeX/Nv2ang+kMxySuaszGElcoAukITLlpFKYNY8jy0wonqQdZvQNETrq3PvjXhiRYB79bMOig==
   *  nizk:16:9:0:Sp0Ox/35yyiSQjdQcm5Z3EppHrIzrdwHXWBlDwKVaq40pf6WoPt1w23mGoLrOBafD8GkCN4YKY+VCIdpW64Irg==
   *  nizk:16:9:1:yuu7tan1SN/Q6IDQgeQmxTMFprNAjip0WWY76tXcrEruWPJju4YvUFvtqM2td0UdPWzqQcuDJJqdRfVh9KaHQw==
   *  nizk:16:10:0:IaHL12ncD2DEDZ87i8avQfPm8sa6qWk8n5wrMeLT2E1gCAeuWcWbhuTEAXYsEBs1xHoIaU87ptPkfbNL2fp0vg==
   *  nizk:16:10:1:DRBmcHhlnVJBPpaKXrcUGDPAhaV+UCPHg5L+j/KE4ZwZeIRCGk+dGzx8MkNIHreFTpRnaQSl4CDqAqX7tI9xFg==
   *  nizk:16:11:0:pjFp+zzhPnrBLBVM6pso+LW39PV8u0ky0XDR8a4qQfcTcdORmA6GLF+i+8/oQYrEX33F+dj/bn8V2avQyKK0eA==
   *  nizk:16:11:1:UBg0xBIdZhi6C8x+tjPcin9m8po9qvbKgO8Uxg3jv4kmAvN3Wwsp4zuvGesPXn41a7mf1Scv1feTcD0aKWf67A==
   *  nizk:16:12:0:lvlxBCvQS6phdwk8u6DItmxRBTAZEueOEVdsoktXcI/GgDahCz0PzmUaLVg4jl1bK0Pw7hEqlAeD6UlpZi+0gg==
   *  nizk:16:12:1:H3r423sHaGBrh3d1WYw2pwTXGcvF8qFZ3uWPUm59SYVbgtI1aCVsTPIzbxekOfOQYx8n8SSRHeVAFVB+5VawmA==
   *  nizk:16:13:0:Mx3DpVcClkSgnji639D2cRs2qJbSJL+TfKtOASmPDjV1ZSvgUpnx81Dv/+ZbmzJABo4Y3WzXEcB1FRRtlVbmzg==
   *  nizk:16:13:1:EwctZ/Q9VB9938qQ2g8o2/7ciQRpIM1201sxiP5s5mUaC2sK5bbAbnuWb8iPgf8vdH0TG49ak5D62QvEIdH8Mw==
   *  nizk:16:14:0:lIJSHAAdbkwt+kMB8zHdLGTe30l8eJ/K3VOMUN72TcuuZAJiEKFmf525G9UyjsTf8cX/EXQfBCqG8VfgwURA/A==
   *  nizk:16:14:1:nm+axBlCArLcWzWZ252x5HFCInzYkxCjTWb6Q2XJF73GUCDGHO4Y5579DGACTvOUlS5UPHVT7CILnDHAQlv0HA==
   *  nizk:16:15:0:132GIf2lNI1uefbLherj9qWcmEE2TW2uSzKzxvifV9D/BgnOwDHLUoWFWondrrVX6xand8h3l68F6pXF9XICvQ==
   *  nizk:16:15:1:s6hdZjJZPR/P1pUJxmGkfnUYmderRkAhx+F8GxK9l3LRzeuzr73jmfiE4S6dlawVpvBY3mga1QeKv7HeKCz1jw==
   */

  // A structure containing the frequently accessed state of the contract packed into a single 256-bit slot
  // to save on storage gas costs.
  ContractState.State contractState;

  // The address allowed to tweak system settings of the contract.
  address payable public owner;

  // The to-be-promoted address that would become owner upon approval.
  address payable internal nextOwner;

  // The bets placed by the players that are kept in contract's storage.
  BetStorage.Bets internal bets;

  /**
   * The event that gets logged when a bet is placed.
   *
   * @param vrfInputHash the hash of bet attributes (see VRF.sol).
   * @param player the address that placed the bet.
   * @param playerNonce the seq number of the player's bet against this contract.
   * @param amount the amount of bet wagered.
   * @param packedBet the game and options chosen (see PackedBet.sol)
   * @param humanReadable a human-readable description of bet (e.g. "CoinFlip heads")
   */
  event Placed(bytes32 indexed vrfInputHash, address player, uint playerNonce, uint amount, uint packedBet, string humanReadable);

  /**
   * The event that gets logged when a bet is won.
   *
   * @param vrfInputHash the hash of bet attributes (see VRF.sol).
   * @param player the address that placed the bet.
   * @param playerNonce the seq number of the player's bet against this contract.
   * @param payment the amount the bet pays as winnings.
   * @param jackpotPayment the amount the bet pays as jackpot winnings.
   * @param humanReadable a human-readable description of outcome (e.g. "CoinFlip heads heads 888")
   */
  event Won(bytes32 indexed vrfInputHash, address player, uint playerNonce, uint payment, uint jackpotPayment, string humanReadable);

  /**
   * The event that gets logged when a bet is lost.
   *
   * @param vrfInputHash the hash of bet attributes (see VRF.sol).
   * @param player the address that placed the bet.
   * @param playerNonce the seq number of the player's bet against this contract.
   * @param payment the amount the bet pays as a consolation.
   * @param jackpotPayment the amount the bet pays as jackpot winnings.
   * @param humanReadable a human-readable description of outcome (e.g. "CoinFlip heads tails 887")
   */
  event Lost(bytes32 indexed vrfInputHash, address player, uint playerNonce, uint payment, uint jackpotPayment, string humanReadable);

  /**
   * The event that gets logged when somebody attemps to settle the same bet twice.
   *
   * @param player the address that placed the bet.
   * @param playerNonce the seq number of the player's bet against this contract.
   */
  event Duplicate(address player, uint playerNonce);

  /**
   * The event that gets logged when somebody attemps to settle non-existed (already removed?) bet.
   *
   * @param player the address that placed the bet.
   * @param playerNonce the seq number of the player's bet against this contract.
   */
  event Nonexistent(address player, uint playerNonce);

  /**
   * The event that gets logged when the House updates the maxProfit cap.
   *
   * @param value the new maxProfit value.
   */
  event MaxProfitUpdated(uint value);

  /**
   * The event that gets logged when the House updates the Jackpot multiplier.
   *
   * @param value the new jackpotMultiplier value.
   */
  event JackpotMultiplierUpdated(uint value);

  // The error logged when a player attempts to bet on both CoinFlip outcomes at the same time.
  error CoinFlipSingleOption();
  // The error logged when a player attempts to bet on multiple outcomes in Etheroll.
  error EtherollSingleOption();
  // The error logged when the contract receives the bet it might be unable to pay out.
  error CannotAffordToLoseThisBet();
  // The error logged when the contract receives the bet that can win more than maxProfit amount.
  error MaxProfitExceeded();
  // The error logged when the contract receives malformed batch of ecrypted bets to settle.
  error NonFullVRFs();
  // The error logged when the contract receives malformed encrypted bet.
  error StorageSignatureMismatch(address player, uint playerNonce);
  // The error logged when the contract receives a bet with 0 or 100+ winning probability (e.g. betting on all dice outcomes at once)
  error WinProbabilityOutOfRange(uint numerator, uint denominator);
  // The error logged when somebody attempts to refund the bet at the wrong time.
  error RefundEpochMismatch(address player, uint playerNonce, uint betEpoch, uint currentEpoch);

  /**
   * The modifier checking that the transaction was signed by the creator of the contract.
   */
  modifier onlyOwner {
    require(msg.sender == owner, "Only owner can do this");
    _;
  }

  /**
   * The modifier checking that the transaction originates from the EOA (externally owned account).
   */
  modifier onlyEOA {
      require(tx.origin == msg.sender, "Only externally owned account (EOA) can do this");
      _;
  }

  /**
   * Constructs the new instance of the contract by setting the default values for contract settings.
   */
  constructor() payable {
    owner = payable(msg.sender);
    nextOwner = payable(0x0);

    contractState.maxProfit = 100 ether;
    contractState.jackpotMultiplier = 8;
  }

  /**
   * The entry point function to place a bet in a CoinFlip game.
   *
   * The first parameter is not used in any way by the smart contract and can be ignored – it's sole purpose
   * is to make Dice9 frontend find player's bets faster; it does not affect the logic in any way.
   *
   * The second parameter is a string containing "heads", "tails", "0" or "1" - indicating the side of the coin
   * the player is willing to put a bet on.
   *
   * @param options human-readable string of options to lace a bet on.
   */
  function playCoinFlip(uint /* unusedBetId */, string calldata options) external onlyEOA payable {
    (uint mask,) = Options.parseOptions(options.toTinyString(), 0, 1);

    // make sure there is a single option selected
    if (!Math.isPowerOf2(mask)) {
      revert CoinFlipSingleOption();
    }

    placeBet(msg.sender, msg.value, GameOptions.toCoinFlipOptions(mask));
  }

  /**
   * The entry point function to place a bet in a Dice game.
   *
   * The first parameter is not used in any way by the smart contract and can be ignored – it's sole purpose
   * is to make Dice9 frontend find player's bets faster; it does not affect the logic in any way.
   *
   * The second parameter is a string containing number(s) in the range of 1..6, e.g. "1" or "4,5,6" indicating
   * the dice outcome(s) the user is willing to place a bet on.
   *
   * @param options human-readable string of options to lace a bet on.
   */
  function playDice(uint /* unusedBetId */, string calldata options) external onlyEOA payable {
    (uint mask,) = Options.parseOptions(options.toTinyString(), 1, 6);
    placeBet(msg.sender, msg.value, GameOptions.toDiceOptions(mask));
  }

  /**
   * The entry point function to place a bet in a TwoDice game.
   *
   * The first parameter is not used in any way by the smart contract and can be ignored – it's sole purpose
   * is to make Dice9 frontend find player's bets faster; it does not affect the logic in any way.
   *
   * The second parameter is a string containing number(s) in the range of 2..12, e.g. "2" or "8,12" indicating
   * the sum of two dice roll(s) the user is willing to place a bet on.
   *
   * @param options human-readable string of options to lace a bet on.
   */
  function playTwoDice(uint /* unusedBetId */, string calldata options) external onlyEOA payable {
    (uint mask,) = Options.parseOptions(options.toTinyString(), 2, 12);
    placeBet(msg.sender, msg.value, GameOptions.toTwoDiceOptions(mask));
  }

  /**
   * The entry point function to place a bet in a Etheroll game.
   *
   * The first parameter is not used in any way by the smart contract and can be ignored – it's sole purpose
   * is to make Dice9 frontend find player's bets faster; it does not affect the logic in any way.
   *
   * The second parameter is a string containing number(s) in the range of 3..97, e.g. "5" or "95" indicating
   * the number the user is willing to place a bet on.
   *
   * @param options human-readable string of options to lace a bet on.
   */
  function playEtheroll(uint /* unusedBetId */, string calldata options) external onlyEOA payable {
    (uint mask, uint option) = Options.parseOptions(options.toTinyString(), 3, 97);

    // make sure there is a single option selected
    if (!Math.isPowerOf2(mask)) {
      revert EtherollSingleOption();
    }

    placeBet(msg.sender, msg.value, GameOptions.toEtherollOptions(option));
  }

  /**
   * The generic all-mighty function processing all the games once the input parameters have been read and validated
   * by corresponding playXXX public methods.
   *
   * Accepting player's address, bet amount and GameOption instance describing the game being played, the function
   * stores the bet information in the contract's storage so that it can be settled by a Croupier later down the road.
   *
   * The function performs a few boring, but very important checks:
   *  1. It makes sure that all the bets currently accepted will be payable, even if all of them win (since we do not know upfront).
   *     If the contract sees that the potential winnings from pending bets exceed contract's balance, it would refrain from accepting the bet.
   *  2. If checks that the current bet will not win "too much" – a value depicted by maxProfit - a fair limitation kept in place to avoid
   *     situations when a single whale drains the contract in one lucky bet and everyone else has to wait until the House tops the contract up.
   *     Please mind this value is kept reasonably high so you should rarely run into such a limitation.
   *  3. It makes sure the player does not place "non-sensial" bets, like all Dice numbers or no sides in CoinFlip.
   *
   * If everything goes well, the contract storage is updated with the new bet and a log entry is recorded on the blockchain so that the
   * player can validate the parameters of the bet accepted.
   *
   * @param player the address of the player placing a bit.
   * @param amount the amount of the bet the player wagers.
   * @param gameOptions the choice(s) and the game type selected by the player.
   */
  function placeBet(address player, uint amount, GameOption gameOptions) internal {
    // check if the bet plays for jackpot
    bool playsForJackpot = amount >= MIN_JACKPOT_BET;

    // pack the bet into an instance of PackedBet
    PackedBet packedBet = PackedBets.pack(amount, gameOptions, playsForJackpot);

    // extract the bet information with regards to ods to compute the winAmount
    (uint numerator, uint denominator,, TinyString humanReadable) = gameOptions.describe();
    // consider this bet wins: how big the win is going to be?
    uint winAmount = computeWinAmount(amount, numerator, denominator, playsForJackpot);

    // add locks on contract funds arising from having to process this bet
    ContractState.State memory updatedContractState = contractState;
    updatedContractState.lockFunds(winAmount, playsForJackpot);

    // compute the amount the contract has to have available to pay if everyone wins and compare that to the current balance
    if (updatedContractState.totalLockedInBets(MAX_JACKPOT_PAYMENT, JACKPOT_MULTIPLIER_BASE) > address(this).balance) {
      // ok, we potentially owe too much and cannot accept this bet
      revert CannotAffordToLoseThisBet();
    }

    // check if the winning amount of the bet sans the amount wagered exceeds the maxProfit limit
    if (winAmount > amount + updatedContractState.maxProfit) {
      // ok, the win seems to be too big - crash away
      revert MaxProfitExceeded();
    }

    // all seems good - just store the bet in contract's storage
    uint playerNonce = BetStorage.storePackedBet(bets, player, packedBet);

    // append "jckpt" string if the bet plays for jackpot
    if (playsForJackpot) {
      humanReadable = humanReadable.append(TinyStrings.SPACE).append(GameOptions.JCKPT_STR);
    }

    // compute VRF input hash - a hash of all bet attributes that would uniquely identify this bet
    bytes32 vrfInputHash = VRF.computeVrfInputHash(player, playerNonce, packedBet.withoutEpoch());

    // commit fund locks to storage
    contractState = updatedContractState;

    // log the bet being placed successfully
    emit Placed(vrfInputHash, player, playerNonce, amount, packedBet.toUint(), humanReadable.toString());
  }

  /**
   * This is main workhorse of the contract: the routine that settles the bets previously placed by the players.
   *
   * It is expected that a Croupier (i.e. our software having access to the secret encryption key) would invoke this function,
   * passing some number of ecnrypted bets. The RSA VRF utilities (see VRF.sol) would validate the authenticity of the ecrypted data
   * received (e.g. check that the bets are encrypted with the specific secret key).
   *
   * If the authencity is confirmed, the routine would use the encrypted text as the source of entropy – essentially, treat
   * the encrypted bet data as a huge number. Since the contract uses pretty strong and battle-tested encryption (RSA 1024 bits), this
   * number is guaranteed to be unpredictable and uniformely distributed. The only party which can produce this number is, of course,
   * the Croupier – the possession of the secret key is required to calculate the number. The Croupier, in its turn, cannot tamper
   * with the bet attributes (since the contract keeps track of what players bet on) and has to create a number for every bet submitted.
   * Since the key is fixed, every bet attributes get a single, unique number from the croupier.
   *
   * More technical details are available in VRF.sol.
   *
   * @param vrfs the blob of VRF(s) chunks to use for bet settlement.
   */
  function settleBet(bytes calldata vrfs) external {
    // first and foremost, make sure there is a whole number of VRF chunks in the calldata
    if (vrfs.length % VRF.RSA_CIPHER_TEXT_BYTES != 0) {
      // there is not – just revert, no way to even try, it is coming from a malicious actor
      revert NonFullVRFs();
    }

    // move contract summary state to memory, as it will be updated several times (especially if batching)
    ContractState.State memory updatedContractState = contractState;

    // iterate over callback bytes in chunks of RSA_CIPHER_TEXT_BYTES size
    for (uint start = 0; start < vrfs.length; start += VRF.RSA_CIPHER_TEXT_BYTES) {
      // get the current slice of VRF.RSA_CIPHER_TEXT_BYTES bytes
      bytes calldata slice = vrfs[start:start+VRF.RSA_CIPHER_TEXT_BYTES];

      // use VRF.decrypt library to decrypt, validate and decode bet structure encoded in this particular chunk of calldata
      // unless the function reverts (which it would do shall there be anything wrong), it would return a fully decoded bet along
      // with vrfHash parameter – this is going to act as out entropy source
      (bytes32 vrfHash, bytes32 vrfInputHash, address player, uint playerNonce, PackedBet packedBet) = VRF.decrypt(MODULUS0, MODULUS1, MODULUS2, MODULUS3, slice);

      // get the (supposedly the same) bet from bet storage – it is trivial since we have both player and playerNonce values
      PackedBet ejectedPackedBet = BetStorage.ejectPackedBet(bets, player, playerNonce);

      // check if the bet is not blank
      if (ejectedPackedBet.isEmpty()) {
        // it is blank – probably already settled, so just carry on
        emit Nonexistent(player, playerNonce);
        continue;
      }

      // check if the bet's amount is set to zero – we are using this trick (see BetStorage.sol) to mark bets
      // which have already been handled
      if (ejectedPackedBet.hasZeroAmount()) {
        // it has been settled already, so just carry on
        emit Duplicate(player, playerNonce);
        continue;
      }

      // at this point it looks like the bet is fully valid – let's make sure the contract storage contains
      // exactly the same attributes as the decrypted data; we just need to be mindful that decrypted bets don't
      // contain any epoch information, so we ignore it for comparisons
      if (!ejectedPackedBet.withoutEpoch().equals(packedBet)) {
        // this is a pretty suspicious situation: the decrypted attributes do not match the data in the storage, as if
        // someone would try to settle a bet and alter its parameters at the same time. we don't like this and we crash
        revert StorageSignatureMismatch(player, playerNonce);
      }

      // at this point the bet seems valid, matches it decrypted counterpart and is ready to be settled

      // first of all, decode the bet into its attributes...
      (uint winAmount, bool playsForJackpot, uint betDenominator, uint betMask, TinyString betDescription) = describePackedBet(packedBet);
      // ...and pass those attributes to compute the actual outcome
      (bool isWin, uint payment, uint jackpotPayment, TinyString outcomeDescription) = computeBetOutcomes(uint(vrfHash), winAmount, playsForJackpot, betDenominator, betMask, betDescription);

      // remove fund locks (since we are processing the bet now)
      updatedContractState.unlockFunds(winAmount, playsForJackpot);

      // did the bet win?
      if (isWin) {
        // yes! congratulations, log the information onto the blockchain
        emit Won(vrfInputHash, player, playerNonce, payment, jackpotPayment, outcomeDescription.toString());
      } else {
        // nope :( it is ok, you can try again – log the information onto the blockchain
        emit Lost(vrfInputHash, player, playerNonce, payment, jackpotPayment, outcomeDescription.toString());
      }

      // compute the total payment
      uint totalPayment = payment + jackpotPayment;

      // invoke the actual funds transfer and revert if it fails for a winning bet
      (bool transferSuccess,) = player.call{value: totalPayment + Math.toUint(totalPayment == 0)}("");
      require(transferSuccess || totalPayment == 0, "Transfer failed!");
    }

    // commit summary state to storage
    contractState = updatedContractState;
  }

  /**
   * A publicly available function used to request a refund on a bet if it was not processed.
   *
   * The player or the House can refund any unprocessed bet during every other 8-hour window following
   * the bet.
   *
   * The logic of the time constraint is as follows:
   *  1. The day is split into 4 hour windows, i.e. 00:00-08:00, 08:00-16:00, 16:00-24:00 etc
   *  2. The smart contract keeps track of the window number the bet was placed in. For example, if
   *     the bet is placed at 02:15, it will be attributed to 00:00-08:00 window.
   *  3. The player can request the refund during every other 8-hour window following the bet.
   *     For example, if the bet is placed at 02:15, one can refund it during 16:00-20:00, or
   *     during 04:00-12:00 (next day), but not at 12:00 the same day.
   *
   * The refund window logic is a bit convoluted, but it is kept this way to minimise the gas requirements
   * imposed on all the bets going through the system. It is in House's best interests to make sure
   * this function is never needed – if all the bets are processed in a timely manner, noone would ever
   * invoke this. We decided to keep this in, however, to assure the players the funds will never end up
   * locked up in the contract, even if the Croupier stops revealing all the bets forever.
   *
   * @param player the address of the player that made the bet. Must match the sender's address or the contract owner.
   * @param playerNonce the playerNonce of the bet to refund
   */
  function refundBet(address player, uint playerNonce) external {
    // make sure a legit party is asking for a refund
    require(((msg.sender == player) || (msg.sender == owner)), "Only the player or the House can do this.");

    // extract the bet from the storage
    PackedBet ejectedPackedBet = BetStorage.ejectPackedBet(bets, player, playerNonce);

    // check if the bet is not blank
    if (ejectedPackedBet.isEmpty()) {
      // it is blank – probably already settled, so just carry on
      emit Nonexistent(player, playerNonce);
      return;
    }

    // check if the bet's amount is set to zero – we are using this trick (see BetStorage.sol) to mark bets
    // which have already been handled
    if (ejectedPackedBet.hasZeroAmount()) {
      // it has been settled already, so just carry on
      emit Duplicate(player, playerNonce);
      return;
    }

    // get the bet's and current epochs – those would be integers from 0..3 range denoting the number of
    // the 4 hour windows corresponding to the epochs
    (uint betEpoch, uint currentEpoch) = ejectedPackedBet.extractEpochs();
    // compute the distance between two epochs mod 4
    uint epochDistance = (currentEpoch + PackedBets.EPOCH_NUMBER_MODULO - betEpoch) & PackedBets.EPOCH_NUMBER_MODULO_MASK;

    // check if bet's epoch is good for refund
    if (epochDistance < REFUNDABLE_BET_EPOCHS_DISTANCE) {
      // we actually have to revert here since we have just modified the storage and are no taking any action
      revert RefundEpochMismatch(player, playerNonce, betEpoch, currentEpoch & PackedBets.EPOCH_NUMBER_MODULO_MASK);
    }

    // unlock the funds since the bet is getting refunded
    (uint winAmount, bool playsForJackpot,,,) = describePackedBet(ejectedPackedBet);
    contractState.unlockFundsStorage(winAmount, playsForJackpot);

    // send the funds back
    (,uint amount,) = ejectedPackedBet.unpack();
    (bool transferSuccess,) = player.call{value: amount}("");
    require(transferSuccess, "Transfer failed!");
  }

  /**
   * Being given an instance of PackedBet, decodes it into a set of parameters, specifically:
   *  1. What would the payment amount to if the bet wins.
   *  2. Whether the bet should play for Jackpot.
   *  3. What is the bet's game's denominator (2 for Coin Flip, 6 for Dice etc).
   *  4. What were the options chosen by the user (a.k.a. bet mask).
   *  5. What is the human-readable description of this bet.
   *
   * These parameters can further be utilised during processing or refunding of the bet.
   *
   * @param packedBet an instance of PackedBet to decode.
   *
   * @return winAmount how much the bet should pay back if it wins.
   *         playsForJackpot whether the bet should take part in a Jackpot roll.
   *         betDenominator the denominator of the game described by this bet.
   *         betMask the options the user chose in a form of a bitmask.
   *         betDescription the human-readable description of the bet.
   */
  function describePackedBet(PackedBet packedBet) internal pure returns (uint winAmount, bool playsForJackpot, uint betDenominator, uint betMask, TinyString betDescription) {
    // unpack the packed bet to get to know its amount, options chosen and whether it should play for Jackpot
    (GameOption gameOptions, uint amount, bool isJackpot) = packedBet.unpack();
    // unpack the GameOption instance into bet attributes and gather human-readable wager description at the same time
    (uint numerator, uint denominator, uint mask, TinyString description) = gameOptions.describe();

    // compute the amount of money this bet would pay if it is winning
    winAmount = computeWinAmount(amount, numerator, denominator, isJackpot);
    // return true if the bet plays for jackpot
    playsForJackpot = isJackpot;
    // transfer other attributes to the result
    betDenominator = denominator;
    betMask = mask;
    betDescription = description;
  }

  /**
   * Being given the entropy value and bet parameters, computes all the outcomes of the bet, speficically:
   *  1. The amount won, if the bet wins
   *  2. The amount of Jackpot payment, if the bet wins the jackpot
   *  3. The human-readable representation of the outcome (e.g. "Dice 1,2,3 2 888" or "CoinFlip tails heads 555")
   *
   * The incoming entropy integer is split into 3 chunks: game-dependent entropy, jackpot-dependent entropy and jackpot payment entropy.
   * All these values are taken from different parts of the combined entropy to make sure there is no implicit dependency between
   * out come values.
   *
   * @param entropy the RNG value to use for deciding the bet.
   * @param winAmount how much the bet should pay back if it wins.
   * @param playsForJackpot whether the bet should take part in Jackpot roll.
   * @param denominator the denominator of the game described by this bet.
   * @param mask the options the user chose in a form of a bitmask.
   * @param description the human-readable description of the bet.
   *
   * @return isWin the flag indicating whether the bet won on the primary wager.
   *         payment the amount of the winnings the bet has to pay the player.
   *         jackpotPayment the amount of the Jackpot winnings paid by this bet.
   *         outcomeDescription the human-readable description of the bet's result.
   */
  function computeBetOutcomes(uint entropy, uint winAmount, bool playsForJackpot, uint denominator, uint mask, TinyString description) internal view returns (bool isWin, uint payment, uint jackpotPayment, TinyString outcomeDescription) {
    // compute game specific entropy
    uint gameOutcome = entropy % denominator;

    // decide on the game type being played
    if (denominator == GameOptions.GAME_OPTIONS_ETHEROLL_MODULO) {
      // it is an Etheroll bet; the bet wins if the mask value (which simply holds the number for Etheroll, see GameOption.sol)
      // does not exceed the gameOutcome number
      isWin = gameOutcome < mask;

      // append the actual number (+1 to make it start from 1 instead of 0)
      outcomeDescription = description.append(TinyStrings.SPACE).appendNumber(gameOutcome + 1);
    } else if (denominator == GameOptions.GAME_OPTIONS_TWO_DICE_MODULO) {
      // it is a TwoDice bet; the bet wins if the user has chosen a sum of two dice that we got
      // first off, compute the dice outcomes by splitting the game outcome into 2 parts, with 6 possible values in each one
      uint firstDice = gameOutcome / GameOptions.GAME_OPTIONS_DICE_MODULO;
      uint secondDice = gameOutcome % GameOptions.GAME_OPTIONS_DICE_MODULO;

      // compute the sum of two dice
      uint twoDiceSum = firstDice + secondDice;
      // check if the mask contains the bit set at that position
      isWin = (mask >> twoDiceSum) & 1 != 0;

      // append the value of the first dice to the human-readable description (+1 to make it start from 1 instead of 0)
      outcomeDescription = description.append(TinyStrings.SPACE).appendNumber(firstDice + 1);
      // append the value of the second dice to the human-readable description (+1 to make it start from 1 instead of 0)
      outcomeDescription = outcomeDescription.append(TinyStrings.PLUS).appendNumber(secondDice + 1);
    } else if (denominator == GameOptions.GAME_OPTIONS_DICE_MODULO) {
      // it is a dice game – all is very simple, to win the user should bet on a particular number, thus
      // check if the mask has the bit set at the position corresponding to the dice roll
      isWin = (mask >> gameOutcome) & 1 != 0;

      // append the value of the dice to the human-readable description (+1 to make it start from 1 instead of 0)
      outcomeDescription = description.append(TinyStrings.SPACE).appendNumber(gameOutcome + 1);
    } else if (denominator == GameOptions.GAME_OPTIONS_COIN_FLIP_MODULO) {
      // it is a CoinFlip game - similar to Dice, the player should bet on the correct side to win
      isWin = (mask >> gameOutcome) & 1 != 0;

      // append the space to the description of the outcome
      outcomeDescription = description.append(TinyStrings.SPACE);

      // append heads or tails to the description, based on the result
      if (gameOutcome == 0) {
        outcomeDescription = outcomeDescription.append(GameOptions.HEADS_STR);
      } else {
        outcomeDescription = outcomeDescription.append(GameOptions.TAILS_STR);
      }
    }

    // now, the payment amount would equal to the winAmount if bet wins, 0 otherwise
    payment = isWin.toUint() * winAmount;

    // the last bit to check for is the jackpot
    if (playsForJackpot) {
      // first of all, get a separate chunk of entropy and compute the Jackpot Outcome number, adding
      // +1 to convert from 0..999 range to 1..1000
      uint jackpotOutcome = (entropy / denominator) % JACKPOT_MODULO + 1;

      // append Jackpot Number to the human-readable description of the bet
      outcomeDescription = outcomeDescription.append(TinyStrings.SPACE).appendNumber(jackpotOutcome);

      // check the Jackpot Number matches the lucky outcome
      if (jackpotOutcome == JACKPOT_WINNING_OUTCOME) {
        // it does – compute the jackpot payment entropy chunk
        uint jackpotPaymentOutcome = entropy / denominator / JACKPOT_MODULO;
        // set the jackpotPayment to the value computed by a dedicated function
        jackpotPayment = computeJackpotAmount(jackpotPaymentOutcome);
      }
    }
  }

  /**
   * Computes the amount a bet should pay to the user based on the odds the bet has and whether the bet plays for Jackpot.
   *
   * The logic of this method is based on the core principle of this smart contract: be fair. The bet ALWAYS pays the amount
   * decided by the odds (after the House fees are taken out). If the bet has 1 in 3 chances, the winning amount would be 3x;
   * if the bet has 1 in 16 chances of winning, the amount would be 16x.
   *
   * Running the contract is prety labour-intensive and requires constant investment of both labour and money (to settle the bets,
   * pay increased Jackpots and so on), that is why the contract always deducts the fees, calculated as follows:
   *  1. The House takes HOUSE_EDGE_PERCENT (1%) from every bet
   *  2. The House always takes at least HOUSE_EDGE_MINIMUM_AMOUNT (0.001 Ether) fee - roughly how much it costs to settle the bet.
   *  3. If the bet plays for Jackpot, a fixed Jackpot fee is taken to contribute towards the Jackpot payments.
   *
   * @param amount the amount being wagered in this bet.
   * @param numerator the number of possible outcomes chosen by the user.
   * @param denominator the total number of possible outcomes
   * @param isJackpot the flag indicating whether the bet takes part in Jackpot games.
   *
   * @return the amount the bet would pay as a win if it settles so.
   */
  function computeWinAmount(uint amount, uint numerator, uint denominator, bool isJackpot) internal pure returns (uint) {
    // range check
    if (numerator == 0 || numerator > denominator) {
      revert WinProbabilityOutOfRange(numerator, denominator);
    }

    // house edge clamping
    uint houseEdge = amount * HOUSE_EDGE_PERCENT / 100;

    if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
      houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
    }

    // jackpot fee
    uint jackpotFee = isJackpot.toUint() * JACKPOT_FEE;

    return (amount - houseEdge - jackpotFee) * denominator / numerator;
  }

  /**
   * Computes the amount the bet would pay as the Jackpot if the user wins the Jackpot.
   *
   * The value is computed in the following way:
   *  1. Base Jackpot value is computed by multiplying Jackpot Odds by Jackpot fee.
   *  2. A random number is sampled from JACKPOT_PAYTABLE, providing a number between 0.25 and 4.
   *  3. A current jackpotMultiplier value is read, providing another mutlplier.
   *  4. Everything is multipled together, providing the final Jackpot value.
   *
   * If the House keeps jackpotMultiplier at a default value (1), the Jackpot would pay between 0.25x and 4x
   * of base Jackpot value. During the happy hours this number can go up significantly.
   *
   * @param jackpotPaymentOutcome the Jackpot payment entropy value to use to sample a slot from the paytable.
   *
   * @return the jackpot payment value decided by all the attributes.
   */
  function computeJackpotAmount(uint jackpotPaymentOutcome) internal view returns (uint) {
    // compute base jackpot value that would be paid if the paytable was flat and pre-multply it by current
    // jackpotMultiplier; we will have to divide by JACKPOT_MULTIPLIER_BASE later.
    uint baseJackpotValue = BASE_JACKPOT_PAYMENT * contractState.jackpotMultiplier;
    // get random slot from the paytable
    uint paytableSlotIndex = jackpotPaymentOutcome % JACKPOT_PAYTABLE_SLOTS_COUNT;
    // compute the paytable multiplier based on the slot index
    uint paytableMultiplier = ((JACKPOT_PAYTABLE >> (paytableSlotIndex << 3)) & 0xFF);

    // the result would be base value times paytable multiplier OVER multipler denominators since
    // both paytable and jackpotMultiplier store integers assuming a certain divisor to be applied
    return baseJackpotValue * paytableMultiplier / JACKPOT_MULTIPLIER_BASE / JACKPOT_PAYTABLE_BASE;
  }

  /**
   * The total number of funds potentially due to be paid if all pending bets win (sans jackpots).
   *
   * @return the locked amount.
   */
  function lockedInBets() public view returns (uint) {
    return contractState.lockedInBets;
  }

  /**
   * The total number of funds potentially due to be paid if all pending bets win (including jackpots).
   *
   * @return the locked amount.
   */
  function lockedInBetsWithJackpots() public view returns (uint) {
    return contractState.totalLockedInBets(MAX_JACKPOT_PAYMENT, JACKPOT_MULTIPLIER_BASE);
  }

  /**
   * The number of not-yet-settled bets that are playing for jackpot.
   *
   * @return number of bets playing for jackpot.
   */
  function jackpotBetCount() public view returns (uint) {
    return contractState.jackpotBetCount;
  }

  /**
   * The multiplier of the jackpot payment, set by the house.
   *
   * @return jackpot multiplier.
   */
  function jackpotMultiplier() public view returns (uint) {
    return contractState.jackpotMultiplier;
  }

  /**
   * The value indicating the maximum potential win a bet is allowed to make. We have to cap that value to avoid
   * draining the contract in a single bet by whales who put huge bets for high odds.
   *
   * @return jackpot multiplier.
   */
  function maxProfit() public view returns (uint) {
    return contractState.maxProfit;
  }

  /**
   * A House-controlled function used to modify maxProfit value – the maximum amount of winnings
   * a single bet can take from the contract.
   *
   * Bets potentially exceedign this value will not be allowed to be placed.
   *
   * @param newMaxProfit the updated maxProfit value to set.
   */
  function setMaxProfit(uint newMaxProfit) external onlyOwner {
    contractState.maxProfit = uint72(newMaxProfit);
    emit MaxProfitUpdated(newMaxProfit);
  }

  /**
   * A House-controlled function used to modify jackpotMultiplier value – the scale factor
   * of the Jackpot payment paid out on Jackpot wins.
   *
   * The House reserves the right to tweak this value for marketing purposes.
   *
   * @param newJackpotMultiplier the updated maxProfit value to set.
   */
  function setJackpotMultiplier(uint newJackpotMultiplier) external onlyOwner  {
    contractState.jackpotMultiplier = uint32(newJackpotMultiplier);
    emit JackpotMultiplierUpdated(newJackpotMultiplier);
  }

  /**
   * A House-controlled function used to send a portion of contract's balance to an external
   * address – primarily used for bankroll management.
   *
   * The function DOES NOT allow withdrawing funds from the bets that are currently being
   * processed to make sure the house cannot do a bank run.
   *
   * @param to the address to withdraw the funds to.
   * @param amount the amount of funds to withdraw.
   */
  function withdrawFunds(address to, uint amount) external onlyOwner  {
    // make sure there will be at least lockedInBets funds after the withdrawal
    require (amount + contractState.lockedInBets <= address(this).balance, "Cannot withdraw funds - pending bets might need the money.");
    // transfer the money out
    (bool transferSuccess,) = to.call{value: amount}("");
    require (transferSuccess, "Transfer failed!");
  }

  /**
   * A House-controlled function used block a specific address from placing any new bets.
   *
   * The already-placed bets can still be processed or refunded.
   *
   * The primary use of this function is to block addresses containing funds associated with
   * illegal activity (such as stolen or otherwise acquired in an illegal way).
   *
   * This is a legal requirement to have this function.
   *
   * @param player the address of the player to suspend.
   * @param suspend whether to suspend or un-suspend the player.
   */
  function suspendPlayer(address player, bool suspend) external onlyOwner {
    BetStorage.suspendPlayer(bets, player, suspend);
  }

  /**
   * A House-controlled function used to destroy the contract.
   *
   * It would only work if the value of lockedInBets is 0, meaning there are no pending bets
   * and the contract destruction would not take any player's money.
   */
  function destroy() external onlyOwner {
    require(contractState.lockedInBets == 0, "There are pending bets");
    selfdestruct(owner);
  }

  /**
   * A function used to add funds to the contract.
   */
  function topUpContract() external payable {
  }

  /**
   * Approves nextOwner address allowing transfer of contract's ownership
   * to a new address.
   */
  function approveNextOwner(address _nextOwner) external onlyOwner {
    nextOwner = payable(_nextOwner);
  }

  /**
   * Accepts ownership transfer to the nextOwner address making it the new owner.
   * The signer should seek approval from the current owner before calling this method.
   */
  function acceptNextOwner() external {
    require(msg.sender == nextOwner, "nextOwner does not match transaction signer.");
    owner = nextOwner;
  }
}

/* RSA permutation NIZK:
 *    nizk:8:0:ow7gON+Eb+e/r5XB9aWrVMc6TVtdG9+39gWGrGw30Hd/Aj4z5Pj3dhh1QllYgOCFTiI0a23lwf/PFYWQ3+4rUYsUFtjkx82NkLQLLYC6WBzbg2kuhvdE1/0BL6teTjjFV1SNkU9OGbV5MVQX7aE6nWdO/fqyxWf+eh0abaNg6XM=
 *    nizk:8:1:QGSackZNonPtwVDhLWRjGhq3ROEJA1/ko7ZofC34eQGZ429glcIHlkN47HlCwhK1ewXDy1R6w566iW+xU1Kn8FOQG1sRA+r1op0xa4uXnsz+j9JVmiiNgz5407vq+lALjGWEr5Y0w8q0JBBHAwKoYRG8viDSsovmFcuNVGQVyEE=
 *    nizk:8:2:e23Td+FPMDKb2BQkaXrS2M66Enf2mUkHXa61gXv/d5bE9Tm7VtDEL2/Te/4oug6bGLSmmL3aY0qFY7eOLRCA87+sAqc3a+KRSd8vvvupqykbwpsLXFjbD1srrNl/q5FCnUILOqpTterSuyl/Di1cKZ1RJ94lIcmF9ld/yTw9fm8=
 *    nizk:8:3:BF6ScEDU+6dMknR45fxuwLxMIXDILb9WOzzOfc1bJLt9pq8HWfMGXzcL7RNEpZHpFsXL88J9dSygCzy/VliWGTF5MhlmAvn/8VV2fwut9WLKcDjTHspChS5MtT+sAF7kqTUgmF7aSWa+2v5Km4dOtyG6773LejJ3YxXSAB5yWgs=
 *    nizk:8:4:hZnWtDxEFFveo5nzs20FfcCrg4zCsDyHqmMhlY3SZGNVLgL9qvwnVRBMdSn4DyT7LH6SGVSLnABOe4mkI8yuaPS9jDAG/d1uxVKzd5p/bitGOryv1ePDHLYZHeJMMEMT+ZGG7P799tiFqZ1zbjij7MCqtI9qU4YqZ+Sup99ZP4Y=
 *    nizk:8:5:bkratF6TVVbLObR2h3xUfr/DkBw++1OhmuQ3XTbebpxVnna2od/hOWCA4B1Gz6+w+GWo9uSI0lVTT37dWnkT1BUILryhdqGE0H9vpBzbL/BJxIcSltM4N8Sm+np0VCw7yQGeYuyK20qJj392mI/zLmtJZX4Xiho7KWNcXjCEzvI=
 *    nizk:8:6:dvrldgSHZAUT6wn1IOLZsloht+nWhW70+mTTnH2sdz4lofZR9aX6wV9hGqLYgLwVN/EIrswc0gOzCmIAXnyrwRqkBEcGaYlSuiQ9v2DahXRJzBJjD2hs+7Ce8m700tdv8syKLvMgm1pFzTkY4CXfUihDivDNm59sH9a9+M7L3Ts=
 *    nizk:8:7:YazoLkX8tk63ehhbU/+kOpC2dI0LCM4m2gVIEMX9haGt8WHFFPOp762HbkQRLgkg8cFQfPihumPYnEmwPiQ57REM5Wq9zwU5+sNv2ncTi+maG79eDnJw22Q2hqkapEtPQSW/CV4CESiUncoNC7WLAv6dYUZIhZkdYQZLKMQpk3M=
 */
pragma solidity ^0.8.4;

// SPDX-License-Identifier: MIT


// Imports
import { TinyStrings, TinyString, TinyString5 } from "./TinyStrings.sol";
import { Math } from "./Math.sol";

/* GameOption is a custom type that represents a bit mask holding the outcome(s) the player has made a bet on.
 * The encoding scheme is using lower 12 bits of the integer to keep the flag indicating the
 * type of bet used along with the options chosen by the user.
 *
 * Having this as a separate type allows us to clearly bear the meaining of variables holding game options data
 * and also be less error-prone to things like implicit casts done by Solidity.
 *
 * The type's constructors defined in the library below also perform sanity checks on the values provided;
 * this way, if there is an instance of GameOptions somewhere, it is guaranteed to be valid and it is not neccessary to
 * re-validate it on the spot.
 *
 * Examples:
 *  1. Coin Flip bet on tails: 0b000000000010
 *  2. Dice bet on 1, 2 and 3: 0b010000000111
 *  3. TwoDice bet on 8 and 9: 0b100011000000
 *  4. Etheroll bet on <= 55:  0b001000110111
 */
type GameOption is uint256;

/**
 * This library provides a set of constants (like human-readable strings used for logging) along with
 * utility methods to abstract away the manipulation of GameOption custom type.
 */
library GameOptions {
  // Extension methods
  using TinyStrings for TinyString;

  // Human-readable representation of "heads" option for CoinFlip game
  TinyString5 constant internal HEADS_STR     = TinyString5.wrap(uint40(bytes5("heads")));
  // Human-readable representation of "tails" option for CoinFlip game
  TinyString5 constant internal TAILS_STR     = TinyString5.wrap(uint40(bytes5("tails")));
  // Human-readable representation of "jackpot" string
  TinyString5 constant internal JCKPT_STR     = TinyString5.wrap(uint40(bytes5("jckpt")));
  // Prefix for logging description of CoinFlip games
  TinyString constant internal COINFLIP_STR   = TinyString.wrap(uint72(bytes9("CoinFlip ")));
  // Prefix for logging description of Dice games
  TinyString constant internal DICE_STR       = TinyString.wrap(uint40(bytes5("Dice ")));
  // Prefix for logging description of TwoDice games
  TinyString constant internal TWODICE_STR    = TinyString.wrap(uint24(bytes3("2D ")));
  // Prefix for logging description of Etheroll games
  TinyString constant internal ETHEROLL_STR   = TinyString.wrap(uint88(bytes11("Etheroll <=")));

  // The mask selecting bits of GameOption containing CoinFlip choices – lower 2 bits
  uint constant internal GAME_OPTIONS_COIN_FLIP_MASK_BITS = (1 << 2) - 1;
  // The mask selecting bits of GameOption containing Dice choices – lower 6 bits
  uint constant internal GAME_OPTIONS_DICE_MASK_BITS      = (1 << 6) - 1;
  // The mask selecting bits of GameOption containing TwoDice choices – lower 11 bits
  uint constant internal GAME_OPTIONS_TWO_DICE_MASK_BITS  = (1 << 11) - 1;
  // The mask selecting bits of GameOption containing Etheroll number – lower 8 bits
  uint constant internal GAME_OPTIONS_ETHEROLL_MASK_BITS  = (1 << 8) - 1;
  // The maximum number allowed for an Etheroll game
  uint constant internal GAME_OPTIONS_ETHEROLL_MASK_MAX   = 99;

  // The flag indicating the GameOption describes a Dice game – 10th bit set
  uint constant internal GAME_OPTIONS_DICE_FLAG = (1 << 10);
  // The flag indicating the GameOption describes a TwoDice game – 11th bit set
  uint constant internal GAME_OPTIONS_TWO_DICE_FLAG = (1 << 11);
  // The flag indicating the GameOption describes an Etheroll game – 9th bit set
  uint constant internal GAME_OPTIONS_ETHEROLL_FLAG = (1 << 9);
  // The maximum value of GameOption as an integer – having higher bits set would mean there was on overflow
  uint constant internal GAME_OPTIONS_THRESHOLD = 2 ** 12;

  // The number of combinations in CoinFlip game
  uint constant internal GAME_OPTIONS_COIN_FLIP_MODULO = 2;
  // The number of combinations in Dice game
  uint constant internal GAME_OPTIONS_DICE_MODULO = 6;
  // The number of combinations in TwoDice game
  uint constant internal GAME_OPTIONS_TWO_DICE_MODULO = 36;
  // The number of combinations in Etheroll game
  uint constant internal GAME_OPTIONS_ETHEROLL_MODULO = 100;

  // The number where each hex digit represents the number of 2 dice combinations summing to a specific number
  uint constant internal GAME_OPTIONS_TWO_DICE_SUMS = 0x12345654321;
  // The number where each hex digit represents the number of dice outcomes representing a specific number (trivial)
  uint constant internal GAME_OPTIONS_DICE_SUMS = 0x111111;

  /**
   * Converts a given mask into a CoinFlip GameOption instance.
   *
   * @param mask CoinFlip choice(s) to encode.
   *
   * @return GameOption representing the passed mask.
   */
  function toCoinFlipOptions(uint mask) internal pure returns (GameOption) {
    require(mask > 0 && mask <= GAME_OPTIONS_COIN_FLIP_MASK_BITS, "CoinFlip mask is not valid");
    // CoinFlip does not have any dedicated flag set – thus simply wrap the mask
    return GameOption.wrap(mask);
  }

  /**
   * Converts a given mask into a Dice GameOption instance.
   *
   * @param mask Dice choice(s) to encode.
   *
   * @return GameOption representing the passed mask.
   */
  function toDiceOptions(uint mask) internal pure returns (GameOption) {
    require(mask > 0 && mask <= GAME_OPTIONS_DICE_MASK_BITS, "Dice mask is not valid");
    return GameOption.wrap(GAME_OPTIONS_DICE_FLAG | mask);
  }

  /**
   * Converts a given mask into a TwoDice GameOption instance.
   *
   * @param mask TwoDice choice(s) to encode.
   *
   * @return GameOption representing the passed mask.
   */
  function toTwoDiceOptions(uint mask) internal pure returns (GameOption) {
    require(mask > 0 && mask <= GAME_OPTIONS_TWO_DICE_MASK_BITS, "Dice mask is not valid");
    return GameOption.wrap(GAME_OPTIONS_TWO_DICE_FLAG | mask);
  }

  /**
   * Converts a given mask into a TwoDice Etheroll instance.
   *
   * @param option Etheroll choice to encode.
   *
   * @return GameOption representing the passed mask.
   */
  function toEtherollOptions(uint option) internal pure returns (GameOption) {
    require(option > 0 && option <= GAME_OPTIONS_ETHEROLL_MASK_MAX, "Etheroll mask is not valid");
    return GameOption.wrap(GAME_OPTIONS_ETHEROLL_FLAG | option);
  }

  /**
   * As the name suggests, the routine parses the instance of GameOption type and returns a description of what
   * kind of bet it represents.
   *
   * @param self GameOption instance to describe.
   *
   * @return numerator containing the number of choices selected in this GameOption
   *         denominator containing the total number of choices available in the game this GameOption describes
   *         bitMask containing bits set at positions where game options were selected by the player
   *         humanReadable containing an instance of TinyString describing the bet, e.g. "CoinFlip heads"
   */
  function describe(GameOption self) internal pure returns (uint numerator, uint denominator, uint mask, TinyString betDescription) {
    // we need bare underlying bits, so have to unwrap the GameOption
    uint gameOptions = GameOption.unwrap(self);

    // check if the game described in TwoDice
    if ((gameOptions & GAME_OPTIONS_TWO_DICE_FLAG) != 0) {
      // mask out the bit relevant for TwoDice game
      mask = gameOptions & GAME_OPTIONS_TWO_DICE_MASK_BITS;
      // each bit in the mask can correspond to different number of outcomes: e.g. you can 5 by rolling 1 and 4, or 4 and 1, or 3 and 2 etc.
      // to calculate the total number of rolls matching the mask, we simply multiply positions of bits set in the mask with a constant
      // containing how many combinations of 2 dice would yield a particular number
      numerator = Math.weightedPopCnt(mask, GAME_OPTIONS_TWO_DICE_SUMS);
      // denomination is always the same, 36
      denominator = GAME_OPTIONS_TWO_DICE_MODULO;
      // prepare human-readable string composed of a prefix and numbers of bits set up, with the lowest corresponding
      // to 2 (the minimum sum of 2 dice is 2), e.g. "2D 5,6,12"
      betDescription = TWODICE_STR.appendBitNumbers(mask, 2);

    // check if the game described in Dice
    } else if ((gameOptions & GAME_OPTIONS_DICE_FLAG) != 0) {
      // mask out the bit relevant for Dice game
      mask = gameOptions & GAME_OPTIONS_DICE_MASK_BITS;
      // similar to Two Dice game above, but every bit corresponding to a single option
      numerator = Math.weightedPopCnt(mask, GAME_OPTIONS_DICE_SUMS);
      // denomination is always the same, 6
      denominator = GAME_OPTIONS_DICE_MODULO;
      // prepare human-readable string composed of a prefix and numbers of bits set up, with the lowest corresponding
      // to 1 (the minimum sum of a single dice is 1), e.g. "Dice 1,2,3"
      betDescription = DICE_STR.appendBitNumbers(mask, 1);

    // check if the game described in Etheroll
    } else if ((gameOptions & GAME_OPTIONS_ETHEROLL_FLAG) != 0) {
      // mask out the bit relevant for Etheroll game
      mask = gameOptions & GAME_OPTIONS_ETHEROLL_MASK_BITS;
      // Etheroll lets players bet on a single number, stored "as in" in the mask
      numerator = mask;
      // denomination is always the same, 100
      denominator = GAME_OPTIONS_ETHEROLL_MODULO;
      // prepare human-readable string composed of a prefix and the number the player bets on, e.g. "Etheroll <=55"
      betDescription = ETHEROLL_STR.appendNumber(mask);

    // if none bits match, we are describing a CoinFlip game
    } else {
      // mask out the bit relevant for CoinFlip game
      mask = gameOptions & GAME_OPTIONS_COIN_FLIP_MASK_BITS;
      // we only let players bet on a single option in CoinFlip
      numerator = 1;
      // denomination is always the same, 2
      denominator = GAME_OPTIONS_COIN_FLIP_MODULO;
      // prepare human-readable string composed of a prefix and the side the player bets on, e.g. "CoinFlip tails"
      betDescription = COINFLIP_STR.append(mask == 1 ? HEADS_STR : TAILS_STR);
    }
  }
}
pragma solidity ^0.8.4;

// SPDX-License-Identifier: MIT


/**
 * Tiny library containing bespoke mathematical functions allowing us to express contract's logic
 * in a more clear and gas efficient way.
 */
library Math {
  // Maximum number represented by 128 bit uint
  uint constant internal MAX128 = 2**128 - 1;
  // Maximum number represented by 64 bit uint
  uint constant internal MAX64  = 2**64  - 1;
  // Maximum number represented by 32 bit uint
  uint constant internal MAX32  = 2**32  - 1;
  // Maximum number represented by 16 bit uint
  uint constant internal MAX16  = 2**16  - 1;
  // Maximum number represented by 8 bit uint
  uint constant internal MAX8   = 2**8   - 1;

  /**
   * Returns the number of bits set rounded up to the nearest multiple of 32 – essentially,
   * how many whole 4 byte words are required to "fit" the number.
   *
   * @param number the number to compute the bit length for.
   *
   * @return length the bit length, rounded up to 32.
   */
  function getBitLength32(uint number) internal pure returns (uint length) {
    // if the number is greater than 2^128, then it is at least 128 bits long
    length  = toUint(number > MAX128) << 7;
    // if the left-most remaining part is greater than 2^64, then it's at least 64 bits longer
    length |= toUint((number >> length) > MAX64) << 6;
    // if the left-most remaining part is greater than 2^32, then it's at least 32 bits longer
    length |= toUint((number >> length) > MAX32) << 5;

    unchecked {
      // if there are more bits remaining, then it's at least another 32 bits longer (effectively, ceil())
      length += toUint((number >> length) > 0) << 5;
    }
  }

  /**
   * Returns the number of bits set rounded up to the nearest multiple of 8 – essentially,
   * how many whole 8-bit bytes are required to "fit" the number.
   *
   * @param number the number to compute the bit length for.
   *
   * @return length the bit length, rounded to 8.
   */
  function getBitLength8(uint number) internal pure returns (uint length) {
    // please refer to the explanation of getBitLength32() - the below is similar,
    // it just operates in 8 bit increments instead of 32, resulting in two extra steps.
    length  = toUint(number > MAX128) << 7;
    length |= toUint((number >> length) > MAX64) << 6;
    length |= toUint((number >> length) > MAX32) << 5;
    length |= toUint((number >> length) > MAX16) << 4;
    length |= toUint((number >> length) >  MAX8) << 3;

    unchecked {
      length += toUint((number >> length) > 0) << 3;
    }
  }

  /**
   * Returns 1 for true and 0 for false, as simle as that.
   *
   * @param boolean the bool to convert into an integer.
   * @return integer an integer of 0 or 1.
   */
  function toUint(bool boolean) internal pure returns (uint integer) {
    // As of Solidity 0.8.14, conditionals like (boolean ? 1 : 0) are not
    // optimized away, thus inline assembly forced cast is needed to save gas.
    assembly {
      integer := boolean
    }
  }

  /**
   * Returns true if a number is an exact power of 2.
   *
   * @param number the number to test for 2^N
   *
   * @return true if the number is an exact power of 2 and is not 0.
   */
  function isPowerOf2(uint number) internal pure returns (bool) {
    unchecked {
      return ((number & (number - 1)) == 0) && (number != 0);
    }
  }

  /**
   * Returns the minimum of 2 numbers.
   *
   * @param a the first number.
   * @param b the second number.
   *
   * @return a if it's not greater than b, b otherwise.
   */
  function min(uint a, uint b) internal pure returns (uint) {
    return a < b ? a : b;
  }

  /**
   * Returns the maximum of 2 numbers.
   *
   * @param a the first number.
   * @param b the second number.
   *
   * @return a if it's not greater than b, b otherwise.
   */
  function max(uint a, uint b) internal pure returns (uint) {
    return a < b ? b : a;
  }

  /**
   * Multiplies every set bit's number from mask with a hex digit of the second parameter.
   * This allows us to easily count the number of bits set (by providing weightNibbles of 0x1111...)
   * or to perform a "weighted" population count, where each bit has its own bespoke contribution.
   *
   * A real-life example would be to count how many combinations of 2 dice would yield one of
   * chosen in the mask. Consider the mask of 0b1011 (we bet on 2, 3 and 5) and the weightNibbles
   * set to be 0x12345654321 (2 is only 1+1, 3 is either 1+2 or 2+1 and so on). Calling this function
   * with the above arguments would return 7 - as there 7 combinations of 2 dice outcomes that would
   * yield either 1, 2 or 4.
   *
   * @param mask the number to get set bits from.
   * @param weightNibbles the number to get multiplier from.
   *
   * @return result the sum of bit position multiplied by custom weight.
   */
  function weightedPopCnt(uint mask, uint weightNibbles) internal pure returns (uint result) {
    result = 0;

    // we stop as soon as weightNibbles is zeroed out
    while (weightNibbles != 0) {
      // check if the lowest bit is set
      if ((mask & 1) != 0) {
        // it is – add the lowest hex octet from the nibbles
        result += weightNibbles & 0xF;
      }

      // shift the mask to consider the next bit
      mask >>= 1;
      // shift the nibbles to consider the next octet
      weightNibbles >>= 4;
    }
  }
}
pragma solidity ^0.8.4;

// SPDX-License-Identifier: MIT


// Imports
import { Math } from "./Math.sol";
import { TinyStrings, TinyString } from "./TinyStrings.sol";
import { GameOptions } from "./GameOptions.sol";

/**
 * The library providing helper method to parse user input from a TinyString instance.
 */
library Options {
  // Extension functions
  using TinyStrings for TinyString;

  // The error indicating the option found within a string falls out of min...max range.
  error OptionNotInRange(uint option, uint min, uint max);

  /**
   * Being given an instance of TinyString and min/max constraints, parses the string returning
   * the last found option as an integer as well as bit mask with bits set at places corresponding
   * to the numbers found in the string.
   *
   * If the string is "heads" or "tails", it is instantly considered a CoinFlip option description,
   * returning hardcoded values for the mask and option parameters.
   *
   * The string is considered to consist of digits separated by non-digits characters. To save the gas,
   * the function does not distinguish between the types of separators; any non-digit character is considered
   * a separator.
   *
   * Examples:
   *  1. "heads" -> (1, 0)
   *  2. "tails" -> (2, 1)
   *  3. "1" -> (0b1, 1)
   *  4. "1,2,3" -> (0b111, 3)
   *
   * @param tinyString an instance of TinyString to parse.
   * @param min the minimum allowed number.
   * @param max the maximum allowed number.
   *
   * @return mask the bit mask where the bit is set if the string contains such a number
   *         lastOption the last found number.
   */
  function parseOptions(TinyString tinyString, uint min, uint max) internal pure returns (uint mask, uint lastOption) {
    // fast track: is the string "heads"?
    if (tinyString.equals(GameOptions.HEADS_STR)) {
      return (1, 0);
    }

    // fast track: is the string "tails"?
    if (tinyString.equals(GameOptions.TAILS_STR)) {
      return (2, 1);
    }

    // we parse the string left-to-right, meaning the first digit of a number has to be multipled by 1, the second by 10 etc
    uint digitMultiplier = 1;

    // we run the whole loop without arithmetic checks since we only use
    // functions operating on heavily constrained values
    unchecked {
      // repeat until stopped explicitly
      while (true) {
        // classify the last character.
        // IMPORTANT: empty string would return isDigit = false
        (bool isDigit, uint digit) = tinyString.getLastChar();

        // is the last character a digit?
        if (isDigit) {
          // is it the first digit of a new number? if so, reset the lastOption to 0
          lastOption = digitMultiplier == 1 ? 0 : lastOption;
          // add the digit multiplied by current multiplier to the lastOption value
          lastOption += digitMultiplier * digit;
          // the next digit would be 10x
          digitMultiplier *= 10;
        } else {
          // we stumbled upon a separator OR an empty string – let's validate the computed number
          if (lastOption < min || lastOption > max) {
            // the number falls out of min..max range, we have to crash
            revert OptionNotInRange(lastOption, min, max);
          }

          // set the bit corresponding to the last found number
          mask |= 1 << (lastOption - min);
          // reset the digit multiplier to 1 (since the next number will be a new number)
          digitMultiplier = 1;
        }

        // is the string empty?
        if (tinyString.isEmpty()) {
          // it is – stop the loop, we are done
          break;
        }

        // remove the last character from the string and repeat
        tinyString = tinyString.chop();
      }
    }
  }
}
pragma solidity ^0.8.4;

// SPDX-License-Identifier: MIT


// Imports
import { Math } from "./Math.sol";
import { GameOption, GameOptions } from "./GameOptions.sol";

/**
 * PackedBet is a custom type that represents a single bet placed by a player. It encodes the bet amount
 * (quantized down to a specific increment to save space), the GameOption instance (see ./GameOptions.sol) and
 * the bit indicating whether the bet was nominated to play for a jackpot.
 *
 * The memory layout of the type if pretty straightforward:
 * 1. Lowest 16 bits hold bet amount (divided by quant constant)
 * 2. Bit #17 is set to 1 if the bet plays for a jackpot
 * 3. Bits #18-29 hold GameOption data
 * 4. Bits #30-32 hold bet time (mod 4 hours).
 *
 * The type's constructors defined in the library below also perform sanity checks on the values provided;
 * this way, if there is an instance of PackedBet somewhere, it is guaranteed to be valid and it is not neccessary to
 * re-validate it on the spot.
 */
type PackedBet is uint256;

/**
 * The library containing conversion routines (to pack and unpack bet data into an instance of PackedBet),
 * as well as basic utilities to compute certain attributes of a PackedBet.
 */
library PackedBets {
  // Extension functions
  using Math for bool;

  // The byte length of the PackedBet type
  uint constant internal PACKED_BET_LENGTH = 32;
  // The length of the epoch for our contract (4 hours)
  uint constant internal EPOCH_LENGTH = 4 * 3600;
  // The bit mask selecting the bits allocated to hold quantified amount of the bet
  uint constant internal QUANT_AMOUNT_MASK = QUANT_AMOUNT_THRESHOLD - 1;
  // The bit mask selecting the bits allocated to hold GameOption data (not shifted)
  uint constant internal GAME_OPTIONS_MASK = GameOptions.GAME_OPTIONS_THRESHOLD - 1;
  // The maximum amount after quanitification (to avoid bit overflow)
  uint constant internal QUANT_AMOUNT_THRESHOLD = 2 ** 17;
  // The bit mask selecting all the data but epoch number
  uint constant internal ALL_BUT_EPOCH_BITS = 2 ** 30 - 1;
  // The value by which we quantify the bets
  uint constant internal QUANT_STEP = 0.001 ether;
  // The bit number where isJackpot flag is stored
  uint constant internal JACKPOT_BIT_OFFSET = 17;
  // The bit mask selecting bit representing isJackpot flag (shifted).
  uint constant internal JACKPOT_MASK = 1 << JACKPOT_BIT_OFFSET;
  // The bit number where GameOption data starts
  uint constant internal GAME_OPTIONS_BIT_OFFSET = 18;
  // The bit number where epoch number data starts
  uint constant internal EPOCH_BIT_OFFSET = 30;
  // The modulo of the epoch number – we only keep 3 bits of epoch number along with the bets
  uint constant internal EPOCH_NUMBER_MODULO = 4;
  // The bit mask selecting bits for epoch number
  uint constant internal EPOCH_NUMBER_MODULO_MASK = 3;

  /**
   * Packs the given amount (in wei), GameOption instance and a jackpot flag into a instance of a PackedBet.
   *
   * The routine assumes GameOption passed to it is valid and does not perform any additional checks.
   *
   * The routine checks that amount does not exceed maximum allowed one and is also an exact multiple of QUANT_STEP,
   * to avoid situations where 0.0011 Ethers are wagered and trimmed down to 0.001 in further calculations – it would
   * crash otherwise.
   *
   * @param amount the amount of wei being wagered.
   * @param gameOptions the instance of GameOption to encode.
   * @param isJackpot the flag inidicating the jackpot participation.
   *
   * @return an instance of PackedBet representing all the data passed.
   */
  function pack(uint amount, GameOption gameOptions, bool isJackpot) internal view returns (PackedBet) {
    // calculate quantified amount and the reminder
    uint quantAmount = amount / QUANT_STEP;
    uint quantReminder = amount % QUANT_STEP;

    // make sure the quantAmount does not overflow allowed size and that the reminder is 0
    require(quantAmount != 0 && quantAmount < QUANT_AMOUNT_THRESHOLD && quantReminder == 0, "Bet amount not quantifiable");

    // take 3 lowest of the current epoch number to keep it along with the PackedBet
    uint epochMod4 = getCurrentEpoch() & EPOCH_NUMBER_MODULO_MASK;

    // construct the packed bet by:
    // 1. Storing the epoch number in bits 30..32
    // 2. Storing GameOption in bits 18...29
    // 3. Storing isJackpot in bit 17
    // 4. Storing quantAmount in bits 0..16
    uint packedBet =  epochMod4 << EPOCH_BIT_OFFSET |
                      GameOption.unwrap(gameOptions) << GAME_OPTIONS_BIT_OFFSET |
                      isJackpot.toUint() << JACKPOT_BIT_OFFSET |
                      quantAmount;

    return PackedBet.wrap(packedBet);
  }

  /**
   * Checks if the PackedBet instance is empty (does not contain anything).
   *
   * @param self PackedBet instance to check.
   *
   * @return true if the PackedBet instance is empty.
   */
  function isEmpty(PackedBet self) internal pure returns (bool) {
    return PackedBet.unwrap(self) == 0;
  }

  /**
   * Converts the PackedBet to an integer representation.
   *
   * @param self PackedBet instance to convert into an integer.
   *
   * @return the number representing the PackedBet instance.
   */
  function toUint(PackedBet self) internal pure returns (uint256) {
    return PackedBet.unwrap(self);
  }

  /**
   * Removes all the bits encoding epoch number from the instance of the PackedBet.
   * This routine is helpful when two PackedBets need to be checked for equality.
   *
   * @param self the instance of the PackedBet to remove epoch number from.
   *
   * @return an instance of the PackedBet with epoch bits set to 0.
   */
  function withoutEpoch(PackedBet self) internal pure returns (PackedBet) {
    return PackedBet.wrap(PackedBet.unwrap(self) & ALL_BUT_EPOCH_BITS);
  }

  /**
   * Returns the number of the current and bet's epochs mod 4.
   *
   * @param self PackedBet instance to check.
   *
   * @return betEpoch the bet's epoch mod 4
   *         currentEpoch the current epoch mod 4
   */
  function extractEpochs(PackedBet self) internal view returns (uint betEpoch, uint currentEpoch) {
    // get current epoch % 4 value
    currentEpoch = getCurrentEpoch() & EPOCH_NUMBER_MODULO_MASK;
    // get bet's epoch % 4 value
    betEpoch = (PackedBet.unwrap(self) >> EPOCH_BIT_OFFSET) & EPOCH_NUMBER_MODULO_MASK;
  }

  /**
   * Checks if two PackedBet instances are exactly equal.
   *
   * @param self first instance of the PackedBet.
   * @param other second instance of the PackedBet.
   *
   * @return true if the instances are exactly the same.
   */
  function equals(PackedBet self, PackedBet other) internal pure returns (bool) {
    return PackedBet.unwrap(self) == PackedBet.unwrap(other);
  }

  /**
   * Checks if the PackedBet instance has 0 in the amount portion. This is needed to make
   * sure we don't settle the same bet twice (upon resolving a bet we clear the amount bits).
   *
   * @param self the instance of the PackedBet to check.
   *
   * @return true if the amount portion of the PackedBet is zero.
   */
  function hasZeroAmount(PackedBet self) internal pure returns (bool) {
    return (PackedBet.unwrap(self) & QUANT_AMOUNT_MASK) == 0;
  }

  /**
   * Unpacks the PackedBet instance into separate values of GameOption, amount used and isJackpot flag.
   *
   * @param self PackedBet to unpack.
   *
   * @return gameOptions the instance of GameOption encoded in this packed bet.
   *         amount the amount encoded, multiplied by quantification coefficient.
   *         isJackpot the flag indicating whether the bet plays for jackpot.
   */
  function unpack(PackedBet self) internal pure returns (GameOption gameOptions, uint amount, bool isJackpot) {
    // we need raw bits, so have to unwrap the bet into an integer
    uint data = PackedBet.unwrap(self);

    // the amount is essentially quantAmount times QUANT_STEP
    amount = (data & QUANT_AMOUNT_MASK) * QUANT_STEP;
    isJackpot = (data & JACKPOT_MASK) != 0;
    gameOptions = GameOption.wrap((data >> GAME_OPTIONS_BIT_OFFSET) & GAME_OPTIONS_MASK);
  }

  /**
   * Returns the number of the current epoch, expressed as the number of 4 hour interval since the beginning of times.
   *
   * @return the number of the curret epoch.
   */
  function getCurrentEpoch() private view returns (uint) {
    return block.timestamp / EPOCH_LENGTH;
  }
}
pragma solidity ^0.8.4;

// SPDX-License-Identifier: MIT


// Imports
import { Math } from "./Math.sol";

/**
 * TinyString is a custom type providing an alternative representation of short (up to 32 chars) strings containing
 * ASCII characters.
 *
 * We heavily use this primitive in the contract to keep human-readable logs and input parameters yet avoid overspending
 * tremendeous amount on gas.
 */
type TinyString  is uint256;

/**
 * A special case of TinyString - a string that contains a single ASCII character.
 */
type TinyString1 is uint8;

/**
 * A special case of TinyString - a string that contains 5 ASCII characters.
 */
type TinyString5 is uint40;

/**
 * The library providing functions for manipulating TinyString instances in a nice and readable way.
 */
library TinyStrings {
  // Extension functions
  using TinyStrings for TinyString;

  // The constant holding "," character
  TinyString1 constant internal COMMA = TinyString1.wrap(uint8(bytes1(",")));
  // The constant holding "+" character
  TinyString1 constant internal PLUS  = TinyString1.wrap(uint8(bytes1("+")));
  // The constant holding " " character
  TinyString1 constant internal SPACE = TinyString1.wrap(uint8(bytes1(" ")));

  // The bit mask selecting 8th bit from every byte of 32 byte integer - used to check whether a string
  // contains any characters > 128
  uint constant internal MSB_BYTES = 0x8080808080808080808080808080808080808080808080808080808080808080;
  // The code of "0" in ASCII – allows us to do super-cheap parsing by subtracting this from the charCode (1 = 49, 2 = 50 etc)
  uint constant internal ZERO_ASCII_CODE = 48;
  // How many bit there are in a single ASCII character.
  uint constant internal BITS_PER_CHARACTER = 8;
  // How many bit there are in 5 ASCII characters.
  uint constant internal BITS_PER_FIVE_CHARACTERS = BITS_PER_CHARACTER * 5;
  // The maximum possible length in bits of TinyString
  uint constant internal TINY_STRING_MAX_LENGTH = 32;
  // The maximum possible length of TinyString in bits.
  uint constant internal TINY_STRING_MAX_LENGTH_BITS = TINY_STRING_MAX_LENGTH * BITS_PER_CHARACTER;
  // Contains the bit mask selecting bits of the very last character in the TinyString - simply the lowest byte
  uint constant internal LAST_CHARACTER_MASK_BITS = 0xFF;

  // The error indicating a native string passed to the library exceeds 32 characts and cannot be manipulated.
  error StringTooLong();
  // The error indicating a string contains non-ASCII charactes and cannot be manipulated by the library.
  error NotAscii();

  /**
   * Converts an instance of TinyString into a native string placed in memory so that it can be used in
   * logs and other places requiring native string instances.
   *
   * @param self the instance of TinyString to convert into a native one.
   *
   * @return result the native string instance containing all characters from the TinyString instance.
   */
  function toString(TinyString self) internal pure returns (string memory result) {
    // convert the string into an integer
    uint tinyString = TinyString.unwrap(self);
    // calculate the length of the string using the Math library: the length of the string would be
    // equivalent to the number of highest bit set divied by 8 (since every character occupy 8 bits) and
    // rounded up to nearest multiple of 8.
    uint length = Math.getBitLength8(tinyString);

    // Allocate a string in memory (divide the length by 8 since it is in bits and we need bytes)
    result = new string(length >> 3);

    // Copy over character data (situated right after a 32-bit length prefix)
    assembly {
      // we need to shift the bytes so that the characters reside in the higher bits, with lower set to 0
      length := sub(256, length)
      tinyString := shl(length, tinyString)
      // once we shifted the characters, simply copy the memory over
      mstore(add(result, 32), tinyString)
    }
  }

  /**
   * Converts a native string into a TinyString instance, performing all required validity checks
   * along the way.
   *
   * @param self a native string instance to convert into TinyString.
   *
   * @return tinyString an instance of the TinyString type.
   */
  function toTinyString(string calldata self) internal pure returns (TinyString tinyString) {
    // first off, make sure the length does not exceed 32 bytes, since it is the maximum length a
    // TinyString can store being backed by uint256
    uint length = bytes(self).length;
    if (length > TINY_STRING_MAX_LENGTH) {
      // the string is too long, we have to crash.
      revert StringTooLong();
    }

    // start unchecked block since we know that length is within [0..32] range
    unchecked {
      // copying the memory from native string would fill higher bits first, but we want
      // TinyString to contain characters in the lowest bits; thus, we need to compute the number
      // of bits to shift the data so that bytes like 0xa000 end up 0xa.
      uint shift = TINY_STRING_MAX_LENGTH_BITS - (length << 3);

      // Using inline assembly to efficiently fetch character data in one go.
      assembly {
        // simply copy the memory over (we have validated the length already, so all is good)
        tinyString := calldataload(self.offset)
        // shift the bytes to make sure the data sits in lower bits
        tinyString := shr(shift, tinyString)
      }
    }

    // Check that string contains ASCII characters only - i.e. there are no bytes with the value of 128+
    if (TinyString.unwrap(tinyString) & MSB_BYTES != 0) {
      // there are non-ascii characters – we have to crash
      revert NotAscii();
    }
  }

  /**
   * Reads the last character of the string and classifies it as a digit or a non-digit one.
   *
   * If the string is empty, it would return a tuple of (false, -48).
   *
   * @param self an instance of TinyString to get the last character from.
   *
   * @return isDigit flag set to true if the character is a digit (0..9).
   *         digit the actual digit value of the charact (valid only is isDigit is true).
   */
  function getLastChar(TinyString self) internal pure returns (bool isDigit, uint digit) {
    // we are operating on a single-byte level and thus do not need integer overflow checks
    unchecked {
      // get the lowest byte of the string
      uint charCode = TinyString.unwrap(self) & LAST_CHARACTER_MASK_BITS;

      // compute the digit value, which is simply charCode - 48
      digit = charCode - ZERO_ASCII_CODE;
      // indicate whether the character is a digit (falls into 0..9 range)
      isDigit = digit >= 0 && digit < 10;
    }
  }

  /**
   * Checks whether the string contains any characters.
   *
   * @param self an instance of TinyString to check for emptiness.
   *
   * @return true if the string is empty.
   */
  function isEmpty(TinyString self) internal pure returns (bool) {
    // as simple as it gets: if there are no characters, the string will be 0x0
    return TinyString.unwrap(self) == 0;
  }

  /**
   * Returns a copy of TinyString instance without the last character.
   *
   * @param self an instance of TinyString to remove the last character from.
   *
   * @return a new instance of TinyString.
   */
  function chop(TinyString self) internal pure returns (TinyString) {
    // we simply right-shift all the bytes by 8 bits – and that effectively deletes the last character.
    return TinyString.wrap(TinyString.unwrap(self) >> BITS_PER_CHARACTER);
  }

  /**
   * Returns a copy of TinyString instance with TinyString1 attached at the end.
   *
   * @param self an instance of TinyString to append the TinyString1 to.
   * @param chunk an instance of TinyString1 to append.
   *
   * @return a new instance of TinyString.
   */
  function append(TinyString self, TinyString1 chunk) internal pure returns (TinyString) {
    // we just left-shift the string and OR with the TinyString1 chunk to copy its character over into the lowest byte.
    return TinyString.wrap((TinyString.unwrap(self) << BITS_PER_CHARACTER) | TinyString1.unwrap(chunk));
  }

  /**
   * Returns a copy of TinyString instance with TinyString1 attached at the end.
   *
   * @param self an instance of TinyString to append the TinyString1 to.
   * @param chunk an instance of TinyString1 to append.
   *
   * @return a new instance of TinyString.
   */
  function append(TinyString self, TinyString5 chunk) internal pure returns (TinyString) {
    // we just left-shift the string and OR with the TinyString5 chunk to copy its characters over into the lowest bytes.
    return TinyString.wrap((TinyString.unwrap(self) << BITS_PER_FIVE_CHARACTERS) | TinyString5.unwrap(chunk));
  }

  /**
   * Checks whether TinyString contains the same characters as TinyString5.
   *
   * @param self an instance of TinyString to check.
   * @param other an instance of TinyString5 to check.
   *
   * @return true if the strings are the same.
   */
  function equals(TinyString self, TinyString5 other) internal pure returns (bool) {
    return TinyString.unwrap(self) == TinyString5.unwrap(other);
  }

  /**
   * Appends a number to an instance of a TinyString: "1 + 2 = ".toTinyString().append(3) => "1 + 2 = 3".
   *
   * @param self an instance of TinyString to append the number to.
   * @param number the number to append.
   *
   * @return a new instance of TinyString.
   */
  function appendNumber(TinyString self, uint number) internal pure returns (TinyString) {
    // since we work on character level, we don't need range checks.
    unchecked {
      uint str = TinyString.unwrap(self);

      if (number >= 100) {
        // if number is > 100, append number of hundreds
        str = (str << BITS_PER_CHARACTER) | (ZERO_ASCII_CODE + number / 100);
      }

      if (number >= 10) {
        // if number is > 100, append number of tens
        str = (str << BITS_PER_CHARACTER) | (ZERO_ASCII_CODE + number / 10 % 10);
      }

      // append any remainder (0..9) to the string
      return TinyString.wrap((str << BITS_PER_CHARACTER) | (ZERO_ASCII_CODE + number % 10));
    }
  }

  /**
   * Appends the numbers of bits set in the mask, naming them from startNumber.
   *
   * This is a very specific method that allows us to easily compose strings like "Dice 1,2,5", where 1,2,5 portion
   * is coming from a bit mask.
   *
   * startNumber parameter is required so that every bit of the mask is named properly (i.e. in Dice game the lowest
   * bit represents an outcome of 1, whereas in TwoDice game the lowest bit means 2).
   *
   * @param self an instance of TinyString to append the bit numbers to.
   * @param mask the mask to extract bits from to append to the string.
   * @param startNumber the value of the lowest bit in the mask.
   *
   * @return a new instance of TinyString.
   */
  function appendBitNumbers(TinyString self, uint mask, uint startNumber) internal pure returns (TinyString) {
    // repeat while the mask is not empty
    while (mask != 0) {
      // check if the lowest bit is set
      if (mask & 1 != 0) {
        // it is set – append current value of startNumber to the string and add a ","
        self = self.appendNumber(startNumber).append(TinyStrings.COMMA);
      }

      // right-shift the mask to start considering the next bit
      mask >>= 1;
      // increment the number since the next bit is one higher than the previous one. we don't check for overflows here
      // since the loop is guaranteed to end in at most 256 iterations anyway
      unchecked {
        startNumber++;
      }
    }

    // remove the last character since every bit appends "," after its number
    return self.chop();
  }
}
pragma solidity ^0.8.4;

// SPDX-License-Identifier: MIT


// Imports
import { Math } from "./Math.sol";
import { PackedBets, PackedBet } from "./PackedBets.sol";

/**
 * The library providing RSA-based Verifiable Random Function utilities.
 *
 * The main workhorse of our VRF generation is decrypt() function. Being given RSA modulus chunks and the memory slice
 * of 256 bytes containing encrypted VRF, it attemps to decrypt the data and expand it into a tuple of bet properties.
 *
 * The calling contract can then validate that the bet described by the returned tuple is active and proceed with settling it.
 *
 * The random number source is the hash of encrypted data chunk. The players cannot predict that value since they do not know
 * the secret key corresponding to the RSA modulus hardcoded in the contract; the house cannot tamper with player's bets since
 * the VRF value that passes all the checks is unique due to RSA being a permutation (see Dice9.sol for the proof).
 *
 * The distribution is uniform due to RSA ciphertext being hashed.
 *
 * The above properties allow Dice9 to perform robust and verifiable random number generation using a seed value consisting of bet
 * information such as player address, bet amount, bet options and bet nonce.
 */
library VRF {
  // Extension functions
  using PackedBets for PackedBet;

  // The byte length of the RSA modulus (1024 bits)
  uint constant internal RSA_MODULUS_BYTES = 128;
  // The byte length of the RSA ciphertext (1024 bits)
  uint constant internal RSA_CIPHER_TEXT_BYTES = 128;
  // The byte length of the RSA exponent (we use a hardcoded value of 65537)
  uint constant internal RSA_EXPONENT_BYTES = 32;
  // The RSA exponent value
  uint constant internal RSA_EXPONENT = 65537;
  // The address of EIP-198 modExp precompile contract, which makes RSA decryption gas cost feasible.
  address constant internal EIP198_MODEXP = 0x0000000000000000000000000000000000000005;
  // The value that the first 256 bits of the decrypted text must have (254 ones).
  uint constant internal P0_PADDING_VALUE = 2 ** 254 - 1;
  // The bit number where the contract address value starts in the first 256 bit decoded chunk
  uint constant internal P1_CONTRACT_ADDRESS_BIT_OFFSET = 96;
  // The bit number where the 30 bit (without 2 epoch bits) packed bet data starts in the first 256 bit decoded chunk
  uint constant internal P1_PACKED_BET_BIT_OFFSET = 160;
  // The bit number where the player nonce data starts in the first 256 bit decoded chunk
  uint constant internal P1_PLAYER_NONCE_BIT_OFFSET = 160 + 30;

  // The error indicating that the ciphertext was decrypted into something invalid (e.g. random bytes were submitted to reveal a bet)
  error InvalidSignature();

  /**
   * Being given all the bet attributes, computes a hash sum of the bet, allowing the contract to quickly verify the equivalence
   * of the bets being considered as well as providing a unique identifier for any bet ever placed.
   *
   * @param player the address of the player placing the bet.
   * @param playerNonce the seq number of the bet played by this player against this instance of the contract.
   * @param packedBet an instance of PackedBet representing a bet placed by the player.
   *
   * @return the keccak256 hash of all the parameters prefixed by the chain id and contract address to avoid replay and Bleichenbacher-like attacks.
   */
  function computeVrfInputHash(address player, uint playerNonce, PackedBet packedBet) internal view returns (bytes32) {
    return keccak256(abi.encode(block.chainid, address(this), player, playerNonce, packedBet.toUint()));
  }

  /**
   * Performs RSA "decryption" procedure using BigModExp (https://eips.ethereum.org/EIPS/eip-198) to remain gas-efficient.
   *
   * If the cipherText was produced by a legic signatory (i.e. a party possessing the secret key that corresponds to the hardcoded modulus and exponent),
   * the plaintext produced can further be decoded into a set of bet attributes and a number of checksum-like fields, which get validated as well
   * to make sure the bet attributes descibed are accurate, have not been taken from previous bets and so on.
   *
   * As mentioned above, cipherText gets hashed using keccak256 hash function to further be used as a source of entropy by the smart contract
   * to determine the outcome of the bet, the amount to be paid out, the jackpot roll value and so on.
   *
   * Assuming the hardcoded modulus corresponds to a set of valid RSA parameters (see Dice9.sol for the proof), every set of bet attributes would
   * produce a single cipherText decrypting into that same bet attributes, meaning that any bet a player places would get a single random number
   * associated.
   *
   * @param modulus0 first 32 bytes of the modulus
   * @param modulus1 second 32 bytes of the modulus
   * @param modulus2 third 32 bytes of the modulus
   * @param modulus3 fourth 32 bytes of the modulus
   * @param cipherText the ciphertext received from a Croupier to decrypt.
   *
   * @return vrfHash the hash of cipherText which can be used as the entropy source
   *         vrfInputHash the hash of bet attributes (see computeVrfInputHash() above)
   *         player the address of the player of the bet represented by given ciphertext
   *         playerNonce the player nonce of the bet represented by given ciphertext
   *         packedBet an instance of PackedBet of the bet represented by given ciphertext.
   */
  function decrypt(uint modulus0, uint modulus1, uint modulus2, uint modulus3, bytes calldata cipherText) internal view returns (bytes32 vrfHash, bytes32 vrfInputHash, address player, uint playerNonce, PackedBet packedBet)  {
    vrfHash = keccak256(cipherText);

    // RSA decryption
    bytes memory precompileParams = abi.encodePacked(
      // byte length of the ciphertext
      RSA_CIPHER_TEXT_BYTES,
      // byte length of the exponent value
      RSA_EXPONENT_BYTES,
      // byte length of the modulus
      RSA_MODULUS_BYTES,
      // the ciphertext to decrypt
      cipherText,
      // exponent value
      RSA_EXPONENT,
      // modulus values
      modulus0,
      modulus1,
      modulus2,
      modulus3
    );

    // EIP-198 places BigModExp precompile at 0x5
    (bool modExpSuccess, bytes memory plainText) = EIP198_MODEXP.staticcall(precompileParams);

    // make sure the decryption succeeds
    require(modExpSuccess, "EIP-198 precompile failed!");

    // unpack the bet attributes from the decrypted text
    (player, playerNonce, packedBet, vrfInputHash) = unpack(plainText);
  }

  /**
   * Unpacks the bet attributes from the plaintext (decrypted bytes) presented as an argument.
   *
   * The routine checks that the leading padding is set to a specific value - to make sure the ciphertext produced was actually created with
   * a valid secret key correponding to the contract's public key (RSA modulus).
   *
   * An additional check tests that the ciphertext was produced for this particular contract on this particular chain by checking decoded
   * data – otherwise it is considered a replay attack with data taken from another chain.
   * 
   * Last but not least, decoded parameters are equality tested against the corresponding vrfInputHash in the lowest 256 bits of the plaintext
   * to prevent Bleichenbacher style attacks (bruteforcing the plaintext to obtain a perfect power).
   *
   * @param plainText the decoded array of bytes as returned during the decryption stage.
   *
   * @return player the address of the player placing the bet.
   *         playerNonce the seq number of the player's bet against this instance of the contract.
   *         packedBet the instance of PackedBet describing the bet the player placed.
   *         vrfInputHash the hash of the input parameters of the bet prior to encoding.
   */
  function unpack(bytes memory plainText) private view returns (address player, uint playerNonce, PackedBet packedBet, bytes32 vrfInputHash) {
    uint p0;
    uint p1;
    uint p2;

    // decode the plaintext into 4 uint256 chunks
    (p0, p1, p2, vrfInputHash) = abi.decode(plainText, (uint, uint, uint, bytes32));

    // the first 32 bytes should be equal to a hardcoded value to guarantee the ciphertext was produced by a legit signatory
    if (p0 != P0_PADDING_VALUE) {
      revert InvalidSignature();
    }

    // the second 32 bytes should contain the contract's address (bits 96..256) and chain id (bits 0..96)
    if (p1 != uint(uint160(address(this))) << P1_CONTRACT_ADDRESS_BIT_OFFSET | block.chainid) {
      revert InvalidSignature();
    }

    // the player address is going to be kept in lowest 160 bits of the next 32 bytes
    player = address(uint160(p2));
    // the packed bet occupies 30 bits in positions 161..190, the remaining 2 bits are supposed to store epoch value which we simply discard
    // by masking the value against PackedBets.ALL_BUT_EPOCH_BITS
    packedBet = PackedBet.wrap((p2 >> P1_PACKED_BET_BIT_OFFSET) & PackedBets.ALL_BUT_EPOCH_BITS);
    // the player nonce is the easiest, it takes bites 191..256, so just transfer it over
    playerNonce = p2 >> P1_PLAYER_NONCE_BIT_OFFSET;

    // the last but not least: verify that the ciphertext contained an ecrypted bet attributes for the encoded
    // bet attributes – this disallows the signatory to craft multiple ciphertexts per bet attributes by tampering with vrfInputHash bytes
    if (vrfInputHash != VRF.computeVrfInputHash(player, playerNonce, packedBet)) {
      revert InvalidSignature();
    }
  }
}
