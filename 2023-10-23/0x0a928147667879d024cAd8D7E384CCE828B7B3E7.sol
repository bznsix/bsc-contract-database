// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
*******************************
**                                                                                              
▀████▀  ▀████▀▀ ▄▄█▀▀██▄   ▄▄█▀▀▀█▄█▀████▀     █     ▀███▀     ██     ▀███▀▀▀██▄ ▀███▀▀▀██▄  ▄█▀▀▀█▄█
  ██      ██  ▄██▀    ▀██▄██▀     ▀█  ▀██     ▄██     ▄█      ▄██▄      ██   ▀██▄  ██    ▀██▄██    ▀█
  ██      ██  ██▀      ▀███▀       ▀   ██▄   ▄███▄   ▄█      ▄█▀██▓     ██   ▄██   ██     ▀█████▄    
  ██████████  ██        ██▓             ██▄  █▀ ██▄  █▀     ▄█  ▀██     ▓██████    ██      ██ ▀█████▄
  ▓█      █▓  ██        ██▓▄    ▀████   ▓██ █▀  ▀██ █▀      ███▓█▓██    ▓█  ██▄    █▓     ▄██     ▀██
  ▓█      █▓  ▀██      ██▀▓█▄     ██     ▓██▄    ▓██▄      ▓▀      ██   ▓█   ▀▓█   █▓    ▄█▓▀█     ██
  ▒▓      ▓▓  ▓██      ▓█▓▓▓    ▀▓█▓▓    ▓▓█▓▀   ▓▓█▓▀      ▓▓▓▓█▓▓█    ▓█  ▓ ▓▓   ▓▓     ▓▓▓     ▀█▓
  ▒▓      ▒▓  ▀█▓▓▓    ▓▓▓▒▓▓     ▓▓     ▓▓▓▓    ▓▓▓▓      ▓▀      ▓▓   ▓▓   ▀▓▓▓  ▓▒    ▓▓▒▀▓     ▓▓
▒▒▒ ▒   ▒ ▒▓▒▒  ▒ ▒ ▒ ▒    ▒▒▒ ▒ ▒▒       ▒       ▒      ▒ ▒ ▒   ▒ ▒▒▒▒ ▒▓▒  ▒ ▒ ▒ ▒ ▒ ▒ ▒  ▒▓▒ ▒ ▒▓ 
**
**
**  WEB: https://hogwards.online/
**
**  MIRROR: https://hogwards-online.com/
**
*******************************
*/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract HogwardsOnline is Ownable, ReentrancyGuard 
{
    address public PairAddress = address(0); // Token Pair Address
    address internal BNBAddress = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE; // BNB/USD Mainnet 
    AggregatorV3Interface internal BNBprice;
    IERC20 internal currentToken;

    // FEE ADDRESSES
    address internal Owner1_receiver = 0x797878AD12bcE357b853E8E499dD68D4D883283b;
    address internal Owner2_receiver = 0xD60673A98F2424C315a40c3cEC6e4Ff5dcB74eb9;
    address internal Marketing_receiver = 0xC1EBd9c4B4F7762e630795f339A6066330c5AAf4;
    address internal Verifier = 0x06154188D91892Fac94cA793525A6514f467F65B;

    uint8 internal _decimals = 18;
    uint256 internal MIN_DEPOSIT = 1 * 10**_decimals;
    uint256 internal MIN_REPLENISH = 1 * 10**_decimals;
    uint256 public MAX_DEPOSIT = 150 * 10**_decimals;
    uint256 internal MIN_WITHDRAWAL = 1 * 10**_decimals;
    uint256 internal MIN_BID = 10 * 10**_decimals;

    uint256 internal PERCENT = 120;
    uint256[2] internal AFFILIATE_PERCENTS_1 = [30, 10];
    uint256[2] internal AFFILIATE_PERCENTS_2 = [40, 15];
    uint256[2] internal AFFILIATE_PERCENTS_3 = [50, 20];
    uint256[2] internal AFFILIATE_PERCENTS_4 = [70, 25];
    uint256[2] internal AFFILIATE_PERCENTS_5 = [100, 30];

    uint256 public totalInvested;
    uint256 public totalInvestors;
    uint256 public totalBattles;
    uint256 internal daysWork;
    uint32 public LastHeroId = 1;
    uint32 public Bids = 0;
    address[] public Heroes;
    uint256 public PHASE_1 = 1696410000;
    uint256 public PHASE_2 = 1698829200;

    modifier checkSender {
        require(_msgSender() == tx.origin, "Function can only be called by a user account");
        _;
    }

    struct User 
    {
        uint8 character;
        uint256 money;
        uint256 frozen;
        uint256 token_hold;
        uint256 elixir;
        uint256 deposit;
        uint256 earned;
        uint256 total_earned;
        uint256 withdrawn;
        uint256 timestamp;
        uint256 percentage;
        address partner;
        bytes32 keccak;
    }

    struct UserStats
    {
        uint128 skill;
        uint256 skill_timestamp;
        uint256 replenished;
        uint256 refsTotal;
        uint256 refs1level;
        uint256 turnover;
        uint256 turnover_total;
        uint256 refearnUSDT;
        uint8 status;
    }

    struct allowedTokens 
    {
        address addr;
        uint8 decimals;
    }

    struct Battles 
    {
        uint256 wins;
        uint256 loses;
    }

    struct Forest 
    {
        address player1;
        address player2;
        uint256 money;
        uint256 timestamp;
        address winner;
        uint256 roll;
    }

    struct TheLastHero 
    {
        uint256 bid;
        uint256 bank;
        uint256 timestamp;
        address winner;
        bool status;
    }

    mapping(address => User) public user;
    mapping(address => UserStats) public user_stats;
    mapping(uint => allowedTokens) public AllowedTokens;
    mapping(address => Battles) public battles;
    mapping(address => mapping(uint256 => Forest)) public forest;
    mapping(uint256 => address) public waitingBattles;
    mapping(uint256 => TheLastHero) public LastHero;

    constructor() 
    {
        BNBprice = AggregatorV3Interface(BNBAddress);

        AllowedTokens[0].addr = 0x55d398326f99059fF775485246999027B3197955; // USDT-BEP20
        AllowedTokens[0].decimals = 18;

        PairAddress = 0x204fEEeE77c50C433E6579486D40381787108181; 
        AllowedTokens[1].addr = 0xCD99e5420226ad4031Bf3322FdeB5F2e91Dfc820;  // ELIXIR
        AllowedTokens[1].decimals = 18;

        currentToken = IERC20(AllowedTokens[0].addr); // INIT USDT
    }

    receive() external payable onlyOwner {}

    function BuyCharacter(uint8 character, address partner, bytes memory signature, uint256 deadline) external nonReentrant checkSender
    {
        uint256 priceCharacter = 10 * 10**_decimals; // 10 GOLD
        require(block.timestamp >= PHASE_1, "Phase 1 has not started yet");
        require(character >= 11 && character <= 44, "Parse character error");
        require(user[_msgSender()].character == 0, "Character has already been purchased");
        require(partner != _msgSender(), "Cannot set your own address as partner");
        address sign = _verifySignature(signature, deadline, 84998, priceCharacter);
        require(sign == Verifier, "It is possible to call only through the website");
        
        // First free 888 adresses
        if(totalInvestors >= 888)
        {
            require(priceCharacter <= user[_msgSender()].money, "Insufficient funds");
            user[_msgSender()].money -= priceCharacter;
            uint256 updateFrozen = (user[_msgSender()].frozen <= priceCharacter) ? 0 : (user[_msgSender()].frozen - priceCharacter);
            user[_msgSender()].frozen = updateFrozen;
        }
    
        user[_msgSender()].character = character;
        address ref = user_stats[partner].status == 0 ? address(0) : partner;
        user[_msgSender()].partner = ref;
        user_stats[ref].refs1level++;
        user_stats[ref].refsTotal++;
        if(user[ref].partner != address(0))
            user_stats[user[ref].partner].refsTotal++;
        totalInvestors += 1;
    }

    function ReplenishBalance(uint amount, uint tokenIndex, bytes memory signature, uint256 deadline) external nonReentrant checkSender
    {
        require(block.timestamp >= PHASE_1, "Phase 1 has not started yet");
        require(tokenIndex <= 1, "Index not found");
        require(amount >= MIN_REPLENISH, "Min replenishment limit");
        address sign = _verifySignature(signature, deadline, 39573, amount);
        require(sign == Verifier, "It is possible to call only through the website");
 
        if(tokenIndex == 0) // USDT
        {
            require((user_stats[_msgSender()].replenished + amount) <= MAX_DEPOSIT, "Max limit has been exceeded");
            user_stats[_msgSender()].replenished += amount;
            user[_msgSender()].money += amount;
            user[_msgSender()].frozen += amount;
            totalInvested += amount;
        }
        else // ELIXIR
        {
            require(block.timestamp >= PHASE_2, "Phase 2 has not started yet");
            user[_msgSender()].elixir += amount;
            user[_msgSender()].token_hold = block.timestamp + (86400 * 7); // Hold 7 days
            _updatePercentage(_msgSender());
        }

        currentToken = IERC20(AllowedTokens[tokenIndex].addr);
        currentToken.transferFrom(_msgSender(), address(this), amount);
        
        // Owner-Fee for USDT
        if(tokenIndex == 0)
        {
            uint256 feeUSDT_owner1 = (amount * 3) / 100;
            uint256 feeUSDT_owner2 = (amount * 2) / 100;
            uint256 feeUSDT_marketing = (amount * 15) / 1000;
            currentToken.transfer(Owner1_receiver, feeUSDT_owner1);
            currentToken.transfer(Owner2_receiver, feeUSDT_owner2);
            currentToken.transfer(Marketing_receiver, feeUSDT_marketing);
        }
    }

    function Deposit(uint amount) external nonReentrant checkSender
    {
        require(amount >= MIN_DEPOSIT, "Min deposit limit");
        require(amount <= user[_msgSender()].money, "Insufficient funds");
        require(user[_msgSender()].character > 0, "Need buy character");

        uint256 updateFrozen = (user[_msgSender()].frozen <= amount) ? 0 : (user[_msgSender()].frozen - amount);
        user[_msgSender()].frozen = updateFrozen;
        user[_msgSender()].money -= amount;
        user[_msgSender()].deposit += amount;
        user[_msgSender()].timestamp = block.timestamp;

        if(user[_msgSender()].percentage == 0)
        {
            user[_msgSender()].percentage = PERCENT;
            user_stats[_msgSender()].status = 1; // REF STATUS
        }
        
        _referralAccrual(user[_msgSender()].partner, amount);
    }

    function Withdraw(uint256 amount) external nonReentrant checkSender
    {
        require(amount >= MIN_WITHDRAWAL, "Min withdrawal limit");
        require(amount <= (user[_msgSender()].money - user[_msgSender()].frozen), "Insufficient funds");
        user[_msgSender()].money -= amount;
        user[_msgSender()].withdrawn += amount;

        uint8 tokenIndex = 0; // USDT
        currentToken = IERC20(AllowedTokens[tokenIndex].addr);

        // Owner-Fee
        uint256 feeUSDT_owner1 = (amount * 3) / 100;
        uint256 feeUSDT_owner2 = (amount * 2) / 100;

        currentToken.transfer(_msgSender(), (amount-feeUSDT_owner1-feeUSDT_owner2));
        currentToken.transfer(Owner1_receiver, feeUSDT_owner1);
        currentToken.transfer(Owner2_receiver, feeUSDT_owner2);
    }

    function WithdrawElixir(uint amount) external nonReentrant checkSender
    {
        require(amount <= user[_msgSender()].elixir, "Insufficient funds");
        require(block.timestamp >= user[_msgSender()].token_hold, "Token hold");
        user[_msgSender()].elixir -= amount;
        _updatePercentage(_msgSender());

        uint8 tokenIndex = 1; // ELIXIR
        uint256 feeMarketing = (amount * 1) / 100;
        currentToken = IERC20(AllowedTokens[tokenIndex].addr);
        currentToken.transfer(_msgSender(), amount - feeMarketing);
        currentToken.transfer(Marketing_receiver, feeMarketing);
    }

    function BankDividends() external nonReentrant checkSender
    {
        require(user[_msgSender()].deposit > 0, "Insufficient deposit");
        _updateprePayment(_msgSender());
    }

    function WitchCraft() external nonReentrant checkSender
    {
        require(user[_msgSender()].character > 0, "Need buy character");
        require(block.timestamp >= user_stats[_msgSender()].skill_timestamp, "Impossible");
        user_stats[_msgSender()].skill_timestamp = block.timestamp + 86400;
        user_stats[_msgSender()].skill += 1;
    }

    // The Last Hero :: Mini game
    function MakeBid(uint256 amount, uint32 round, bytes memory signature, uint256 deadline) external nonReentrant checkSender
    {
        require(user[_msgSender()].character > 0, "Need buy character");
        require(amount >= MIN_BID, "Min bid is 10 Tokens");
        require(round == LastHeroId, "The round is already over");
        address sign = _verifySignature(signature, deadline, 62294, amount);
        require(sign == Verifier, "It is possible to call only through the website");
        uint8 tokenIndex = 1; // ELIXIR

        if(LastHero[LastHeroId].timestamp == 0)
        {
            // start ROUND
            Heroes.push(_msgSender());
            LastHero[LastHeroId].timestamp = block.timestamp + 60;
            LastHero[LastHeroId].bid = amount;
            LastHero[LastHeroId].bank += amount;
            LastHero[LastHeroId].winner = _msgSender();
            Bids++;
        }
        else
        {
            require(!_checkLastHero(), "Round the end");
            require(amount > LastHero[LastHeroId].bid, "The new bid must be higher than the current one");
            LastHero[LastHeroId].timestamp += 60;
            LastHero[LastHeroId].bid = amount;
            LastHero[LastHeroId].bank += amount;
            LastHero[LastHeroId].winner = _msgSender();
            Heroes.push(_msgSender());
            Bids++;
        }

        currentToken = IERC20(AllowedTokens[tokenIndex].addr);
        currentToken.transferFrom(_msgSender(), address(this), amount);
    }

    function StartNewRound() external nonReentrant checkSender
    {
        require(_checkLastHero(), "Round is running");
        require(LastHero[LastHeroId].timestamp > 0, "No active rounds");

        uint8 tokenIndex = 1; // ELIXIR
        address WinnerAccount = LastHero[LastHeroId].winner;
        LastHero[LastHeroId].status = true;
        
        // send bank - fee
        uint256 bank = LastHero[LastHeroId].bank;
        uint256 adminFee = bank * 10 / 100;
        currentToken = IERC20(AllowedTokens[tokenIndex].addr);
        currentToken.transfer(WinnerAccount, bank - adminFee);
        currentToken.transfer(Owner1_receiver, adminFee / 2);
        currentToken.transfer(Owner2_receiver, adminFee / 2);
        LastHeroId++;
        delete Heroes;
        Bids = 0;
    }

    function _checkLastHero() internal view returns(bool)
    {
        return (LastHero[LastHeroId].timestamp <= block.timestamp) ? true : false;
    }

    function pendingReward(address account) public view returns(uint256) 
    {
        uint256 DiffUnix = (block.timestamp - user[account].timestamp) / 60;
        uint256 IncomePerMinute = user[account].percentage * 10**18 / 1440;
        uint256 Reward = 0;

        if(DiffUnix > 0)
        {
            // if the deposit is less than 84 usdt then we do not stop the reward
            if(user[account].deposit < (84 * 10**_decimals))
            {
                Reward = (user[account].deposit * IncomePerMinute) * DiffUnix / 10**22;
                Reward = (Reward >= (1 * 10**_decimals)) ? (1 * 10**_decimals) : Reward;
            }
            else // default reward with only 1 day
            {
                DiffUnix = (DiffUnix > 1440) ? 1440 : DiffUnix;
                Reward = (user[account].deposit * IncomePerMinute) * DiffUnix / 10**22;
            }
        }

        return Reward;
    }

    function _updateprePayment(address account) internal 
    {
        uint256 pending = pendingReward(account);
        uint256 depo_end = (user[account].deposit * 222 / 100);

        if(pending > 0)
        {
            user[account].timestamp = block.timestamp;
            user[account].money += pending;
            user[account].total_earned += pending;
            user[account].earned += pending;
        }

        if(user[account].earned >= depo_end)
        {
            user[account].deposit = 0;
            user[account].earned = 0;
            user[account].timestamp = 0;
        }

        uint256 newCounter = (block.timestamp >= PHASE_1) ? (block.timestamp - PHASE_1) / 86400 : 0;

        // update daily limits
        if(newCounter > daysWork)
        {
            daysWork++;
            uint256 LimitMaxDepo = 1000000*10**18;
            MAX_DEPOSIT = MAX_DEPOSIT * 1128 / 1000;
            if(MAX_DEPOSIT >= LimitMaxDepo)
                MAX_DEPOSIT = LimitMaxDepo;
        }
    }

    function _referralAccrual(address account, uint256 value) internal 
    {
        if (value > 0 && account != address(0)) 
        {
            for (uint8 i; i < 2; i++) 
            {
                uint256 affPercent = AFFILIATE_PERCENTS_1[i];

                if(user_stats[account].status == 2)
                    affPercent = AFFILIATE_PERCENTS_2[i];
                else if(user_stats[account].status == 3)
                    affPercent = AFFILIATE_PERCENTS_3[i];
                else if(user_stats[account].status == 4)
                    affPercent = AFFILIATE_PERCENTS_4[i];
                else if(user_stats[account].status == 5)
                    affPercent = AFFILIATE_PERCENTS_5[i];

                uint256 feeUSDT = ((value * affPercent) / 1000);
                user[account].money += feeUSDT;
                user_stats[account].refearnUSDT += feeUSDT;
                user_stats[account].turnover_total += value;

                if(i == 0) 
                {
                    user_stats[account].turnover += value;
                    _updateRefStatus(account, user_stats[account].turnover);
                }
                
                account = user[account].partner;
                if(account == address(0)) break;
            }
        }
    }

    function _updateRefStatus(address account, uint256 turnover) internal
    {
        uint8 refStatus;
        uint256 decimalsMod = 10**_decimals;

             if(turnover >= 0 && turnover < 2500*decimalsMod) refStatus = 1;
        else if(turnover >= 2500*decimalsMod && turnover < 10000*decimalsMod) refStatus = 2;
        else if(turnover >= 10000*decimalsMod && turnover < 50000*decimalsMod) refStatus = 3;
        else if(turnover >= 50000*decimalsMod && turnover < 100000*decimalsMod) refStatus = 4;
        else if(turnover >= 100000*decimalsMod) refStatus = 5;

        if(user_stats[account].status != refStatus)
        {
            user_stats[account].status = refStatus;
            _updatePercentage(account);
        }
    }

    function _updatePercentage(address account) internal 
    {
        uint256 updPercentage = PERCENT;
        uint256 tokenBalance = (user[account].elixir >= 1000) ? 
            user[account].elixir / 10**_decimals : 0;

        uint256 additionalPerc = 1; // +0.01%
        uint256 TOKENLIMIT = 50000*10**_decimals; // 50,000 ELIXIR LIMIT
        if(tokenBalance <= TOKENLIMIT)
        {
            updPercentage += (tokenBalance >= 1000) ? 
                tokenBalance / 1000 * additionalPerc : 0;
        }
        else updPercentage += 50;  // MAX INCREASE +0.5%

             if(user_stats[account].status == 1) updPercentage += 0;
        else if(user_stats[account].status == 2) updPercentage += 10;
        else if(user_stats[account].status == 3) updPercentage += 20;
        else if(user_stats[account].status == 4) updPercentage += 50;
        else if(user_stats[account].status == 5) updPercentage += 100;
            
        if(user[account].percentage != updPercentage)
            user[account].percentage = updPercentage;
    }

    function createBattle(uint256 battleType, bytes memory signature, uint256 deadline) external nonReentrant checkSender
    {
        require(block.timestamp >= PHASE_2, "Phase 2 has not started yet");
        require(battleType < 3, "Incorrect type");
        address sign = _verifySignature(signature, deadline, 48395, getBattleType(battleType));
        require(sign == Verifier, "It is possible to call only through the website");

        address Creator = waitingBattles[battleType];
        require(_msgSender() != Creator, "You are already in forest");

        if (Creator == address(0)) 
        {
            _createBattle(battleType);
        } 
        else 
        {
            _joinBattle(battleType, Creator);
            _fightBattle(battleType, Creator);
        }
    }

    function getBattleType(uint256 battleType) internal pure returns (uint256) 
    {
        return [10000000000000000000, 50000000000000000000, 100000000000000000000][battleType];
    }

    function _randomNumber() internal view returns (uint256) 
    {
        uint256 randomnumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.prevrandao +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(_msgSender())))) /
                            (block.timestamp)) +
                        block.number
                )
            )
        );

        return randomnumber % 100;
    }

    function _createBattle(uint256 battleType) internal 
    {
        forest[_msgSender()][battleType].timestamp = block.timestamp;
        forest[_msgSender()][battleType].player1 = _msgSender();
        forest[_msgSender()][battleType].player2 = address(0);
        forest[_msgSender()][battleType].winner = address(0);
        forest[_msgSender()][battleType].money = getBattleType(battleType);
        forest[_msgSender()][battleType].roll = 0;
        uint256 priceBattle = forest[_msgSender()][battleType].money;
        require(user[_msgSender()].money >= priceBattle, "Insufficient funds");
        uint256 updateFrozen = (user[_msgSender()].frozen <= priceBattle) ? 0 : (user[_msgSender()].frozen - priceBattle);
        user[_msgSender()].frozen = updateFrozen;
        user[_msgSender()].money -= priceBattle;
        waitingBattles[battleType] = _msgSender();
    }

    function _joinBattle(uint256 battleType, address Creator) internal 
    {
        forest[Creator][battleType].timestamp = block.timestamp;
        forest[Creator][battleType].player2 = _msgSender();
        uint256 priceBattle = forest[Creator][battleType].money;
        require(user[_msgSender()].money >= priceBattle, "Insufficient funds");
        uint256 updateFrozen = (user[_msgSender()].frozen <= priceBattle) ? 0 : (user[_msgSender()].frozen - priceBattle);
        user[_msgSender()].frozen = updateFrozen;
        user[_msgSender()].money -= priceBattle;
        waitingBattles[battleType] = address(0);
    }

    function _fightBattle(uint256 battleType, address Creator) internal 
    {
        uint256 random = _randomNumber();
        uint256 wAmount = forest[Creator][battleType].money * 2;
        uint256 fee = (wAmount * 10) / 100;

        uint128 skill1 = user_stats[forest[Creator][battleType].player1].skill;
        uint128 skill2 = user_stats[forest[Creator][battleType].player2].skill;
        uint128 diff = 0;
        uint8 chance = 50;

        if(skill1 > skill2)
        {
            diff = skill1 - skill2;
            chance = (diff <= 20) ? 60 : 75;
        }
        else if(skill1 < skill2)
        {
            diff = skill2 - skill1;
            chance = (diff <= 20) ? 40 : 25;
        }

        address winner = random < chance
            ? forest[Creator][battleType].player1
            : forest[Creator][battleType].player2;
        address loser = random >= chance
            ? forest[Creator][battleType].player1
            : forest[Creator][battleType].player2;

        user[winner].money += wAmount - fee;
        forest[Creator][battleType].winner = winner;
        forest[Creator][battleType].roll = random;

        battles[winner].wins++;
        battles[loser].loses++;
        totalBattles++;

        user[Owner1_receiver].money += fee / 2;
        user[Owner2_receiver].money += fee / 2;
    }
    
    function _getLatestPrice() internal view returns (uint) 
    { 
        (,int price,,uint timeStamp,)= BNBprice.latestRoundData();
        require(timeStamp > 0, "Round not complete");
        return (uint)(price * 10000000000); 
    }

    function _getTokenPrice(uint256 decimals) public view returns(uint)
    {
        IPancakePair pair = IPancakePair(PairAddress);
        (uint Res0, uint Res1,) = pair.getReserves();
        uint BNB_Price = _getLatestPrice();
        uint divider1 = (Res0 > Res1) ? Res1 : Res0;
        uint divider2 = (Res0 > Res1) ? Res0 : Res1;
        return((divider1*(10**decimals) / divider2) * BNB_Price / 10**decimals);
    }

    function _verifySignature(bytes memory signature, uint256 deadline, uint32 func, uint256 amount) internal returns (address) 
    {
        require(block.timestamp < deadline, "Deadline has expired");
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature");

        address caller = _msgSender();
        
        bytes32 digest = keccak256(abi.encode(
            caller,
            deadline,
            func,
            amount
        ));

        require(user[_msgSender()].keccak != digest, "Only 1 activation of the impotence key");
        address signer = ecrecover(digest, v, r, s);
        require(signer != address(0), "Invalid signer address");
        user[_msgSender()].keccak = digest;
        return signer;
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

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
