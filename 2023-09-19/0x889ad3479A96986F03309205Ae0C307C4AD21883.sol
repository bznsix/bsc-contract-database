// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

library Percent {
    struct percent {
        uint256 num;
        uint256 den;
    }

    function mul(percent storage p, uint256 a) internal view returns (uint256) {
        if (a == 0) {
            return 0;
        }
        return (a * p.num) / p.den;
    }

    function div(percent storage p, uint256 a) internal view returns (uint256) {
        return (a / p.num) * p.den;
    }

    function sub(percent storage p, uint256 a) internal view returns (uint256) {
        uint256 b = mul(p, a);
        if (b >= a) return 0;
        return a - b;
    }

    function add(percent storage p, uint256 a) internal view returns (uint256) {
        return a + mul(p, a);
    }
}

contract BNBMario is ReentrancyGuard {
    using SafeMath for uint256;
    using Percent for Percent.percent;

    struct Plan {
        Percent.percent daily;
        Percent.percent max_payout;
        Percent.percent additional;
        uint256 max_additional;
        bool reqiure_previous;
        uint256 require_total_invested;
        uint256 min_deposit;
        uint256 max_deposit;
        uint256 min_withdraw;
        uint256 daily_coins;
    }

    struct User {
        address sponsor;
        uint256 coins;
        uint256 bonus;
        uint256 deposited;
        uint256 reinvested;
        uint256 turnover_bonus;
        uint256 turnover;
        uint256 withdrawn;
        uint256 withdraw_ref_date;
        mapping(uint256 => uint256) referrals;
    }

    struct UserPlan {
        uint256 pending;
        uint256 pending_payout;
        uint256 deposited;
        uint256 withdrawn_payout;
        uint256 withdraw_date;
        uint256 claim_coins_date;
        uint256 last_date;
    }

    struct Wars {
        uint256 wins;
        uint256 loses;
        uint256 minted;
    }

    struct Arena {
        address player;
        uint256 coins;
        uint256 timestamp;
        address winner;
        uint256 roll;
    }

    uint256 private ONE_DAY = 1 days;
    uint256 private MIN_BONUS_WITHDRAWAL = 5e16; // 0.05 BNB
    uint256 private TURNOVER_BONUS_EVERY = 200e18; // 200 BNB
    uint256 private TURNOVER_BONUS_AMOUNT = 20e18; // 20 BNB
    uint256 private COIN_RATE = 1e15; // 1 BNB = 1000 coins
    uint256 private DAILY_PLAN_WITHDRAWAL_LIMIT = 5e18; // 5 BNB

    address payable private owner;
    address payable private promote1;
    address payable private promote2;

    Percent.percent private ADMIN_FEE = Percent.percent(8, 100);
    Percent.percent private WITHDRAW_REINVEST = Percent.percent(20, 100);

    Percent.percent[5] private PERCENT_REFERRAL;
    Plan[6] private PLANS;

    mapping(address => User) public users;
    mapping(address => mapping(uint256 => UserPlan)) public user_plans;

    mapping(address => mapping(uint256 => Arena)) public arenas;
    mapping(address => Wars) public wars;
    mapping(address => mapping(uint256 => mapping(uint256 => uint256)))
        public arenas_counter;

    uint256 public total_withdrawn;
    uint256 public total_deposited;
    uint256 public total_rewards;
    uint256 public total_reinvested;
    uint256 public total_wars;
    uint256 public total_users;

    event Sponsor(address indexed addr, address indexed sponsor);
    event Deposit(address indexed addr, uint256 plan, uint256 amount);
    event Reinvest(address indexed addr, uint256 plan, uint256 amount);
    event Payout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 plan, uint256 amount);

    constructor(address _promote1, address _promote2) {
        promote1 = payable(_promote1);
        promote2 = payable(_promote2);

        owner = payable(_promote1);

        // Set referral levels
        PERCENT_REFERRAL[0] = Percent.percent(7, 100);
        PERCENT_REFERRAL[1] = Percent.percent(3, 100);
        PERCENT_REFERRAL[2] = Percent.percent(2, 100);
        PERCENT_REFERRAL[3] = Percent.percent(2, 100);
        PERCENT_REFERRAL[4] = Percent.percent(1, 100);

        // Mario
        PLANS[0] = Plan(
            Percent.percent(12, 1000), // Daily ROI - 1.2%
            Percent.percent(140, 100), // Full ROI - 140%
            Percent.percent(1, 1000), // Daily Hold - 0.1%
            10, // Max Hold - 10 days (1%)
            true, // Require previous plan
            0, // Require total invested
            5e16, // Min deposit - 0.05 BNB
            4e18, // Max deposit - 4 BNB
            1e16, // Min withdraw - 0.01 BNB
            1 // Daily coins - 1
        );

        // Big Mario
        PLANS[1] = Plan(
            Percent.percent(14, 1000), // Daily ROI - 1.4%
            Percent.percent(200, 100), // Full ROI - 200%
            Percent.percent(1, 1000), // Daily Hold - 0.1%
            10, // Max Hold - 10 days (1%)
            true, // Require previous plan
            0, // Require total invested
            4e18, // Min deposit - 4 BNB
            10e18, // Max deposit - 10 BNB
            1e16, // Min withdraw - 0.01 BNB
            2 // Daily coins - 2
        );

        // Fire Mario
        PLANS[2] = Plan(
            Percent.percent(16, 1000), // Daily ROI - 1.6%
            Percent.percent(250, 100), // Full ROI - 250%
            Percent.percent(1, 1000), // Daily Hold - 0.1%
            10, // Max Hold - 10 days (1%)
            true, // Require previous plan
            0, // Require total invested
            10e18, // Min deposit - 10 BNB
            20e18, // Max deposit - 20 BNB
            1e16, // Min withdraw - 0.01 BNB
            3 // Daily coins - 3
        );

        // Mario & Yoshi
        PLANS[3] = Plan(
            Percent.percent(18, 1000), // Daily ROI - 1.8%
            Percent.percent(300, 100), // Full ROI - 300%
            Percent.percent(1, 1000), // Daily Hold - 0.1%
            10, // Max Hold - 10 days (1%)
            true, // Require previous plan
            0, // Require total invested
            20e18, // Min deposit - 20 BNB
            50e18, // Max deposit - 50 BNB
            1e16, // Min withdraw - 0.01 BNB
            5 // Daily coins - 5
        );

        // Luigi
        PLANS[4] = Plan(
            Percent.percent(2, 100), // Daily ROI - 2%
            Percent.percent(300, 100), // Full ROI - 300%
            Percent.percent(1, 1000), // Daily Hold - 0.1%
            10, // Max Hold - 10 days (1%)
            false, // Require previous plan
            2000e18, // Require total invested - 2000 BNB
            20e18, // Min deposit - 20 BNB
            70e18, // Max deposit - 70 BNB
            1e16, // Min withdraw - 0.01 BNB
            5 // Daily coins - 5
        );

        // Rosalina
        PLANS[5] = Plan(
            Percent.percent(25, 1000), // Daily ROI - 2.5%
            Percent.percent(350, 100), // Full ROI - 350%
            Percent.percent(1, 1000), // Daily Hold - 0.1%
            10, // Max Hold - 10 days (1%)
            false, // Require previous plan
            5000e18, // Require total invested - 5000 BNB
            50e18, // Min deposit - 50 BNB
            100e18, // Max deposit - 100 BNB
            1e16, // Min withdraw - 0.01 BNB
            5 // Daily coins - 5
        );
    }

    receive() external payable {
        _deposit(0, msg.sender, msg.value);
    }

    function _setSponsor(address _addr, address _sponsor) private {
        if (
            users[_addr].sponsor == address(0) &&
            _sponsor != _addr &&
            _addr != owner &&
            (user_plans[_sponsor][0].last_date > 0 || _sponsor == owner)
        ) {
            users[_addr].sponsor = _sponsor;

            emit Sponsor(_addr, _sponsor);

            for (uint8 i = 0; i < PERCENT_REFERRAL.length; i++) {
                if (_sponsor == address(0)) break;
                users[_sponsor].referrals[i]++;
                _sponsor = users[_sponsor].sponsor;
            }
        }
    }

    function _deposit(uint256 _plan, address _addr, uint256 _amount) private {
        require(_plan >= 0 && _plan < PLANS.length, "Bad plan");
        require(_amount > 0, "Zero amount");
        require(
            user_plans[_addr][_plan].deposited + _amount >=
                PLANS[_plan].min_deposit,
            "Wrong min amount"
        );
        if (PLANS[_plan].max_deposit > 0)
            require(
                user_plans[_addr][_plan].deposited + _amount <=
                    PLANS[_plan].max_deposit,
                "Wrong max amount"
            );
        if (_plan != 0 && PLANS[_plan].reqiure_previous)
            require(
                user_plans[_addr][_plan - 1].deposited > 0,
                "Previous plan not activated"
            );
        if (PLANS[_plan].require_total_invested > 0)
            require(
                total_deposited >= PLANS[_plan].require_total_invested,
                "Total deposited not reached"
            );

        if (users[_addr].deposited == 0) total_users++;

        uint256 pending = this.payoutOf(_plan, _addr);
        if (pending > 0) user_plans[_addr][_plan].pending += pending;

        user_plans[_addr][_plan].claim_coins_date = block.timestamp;
        user_plans[_addr][_plan].last_date = block.timestamp;
        user_plans[_addr][_plan].deposited += _amount;
        users[_addr].deposited += _amount;
        total_deposited += _amount;

        _refPayout(_addr, _amount);

        (bool successPromote1Fee, ) = promote1.call{
            value: ADMIN_FEE.mul(_amount) / 2
        }("");
        require(successPromote1Fee, "Transfer failed.");

        (bool successPromote2Fee, ) = promote2.call{
            value: ADMIN_FEE.mul(_amount) / 2
        }("");
        require(successPromote2Fee, "Transfer failed.");

        emit Deposit(_addr, _plan, _amount);
    }

    function _reinvest(uint256 _plan, address _addr, uint256 _amount) private {
        uint256 pending = this.payoutOf(_plan, _addr);
        if (pending > 0) user_plans[_addr][_plan].pending += pending;

        user_plans[_addr][_plan].last_date = block.timestamp;
        user_plans[_addr][_plan].deposited += _amount;
        users[_addr].reinvested += _amount;
        total_reinvested += _amount;

        emit Reinvest(_addr, _plan, _amount);
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = users[_addr].sponsor;

        for (uint256 i = 0; i <= PERCENT_REFERRAL.length; i++) {
            if (up == address(0)) break;
            uint256 bonus = PERCENT_REFERRAL[i].mul(_amount);

            if (i == 0) {
                users[up].turnover_bonus += _amount;

                if (users[up].turnover_bonus >= TURNOVER_BONUS_EVERY) {
                    bonus += TURNOVER_BONUS_AMOUNT;
                }
            }

            users[up].turnover += _amount;
            users[up].bonus += bonus;
            total_rewards += bonus;
            emit Payout(up, _addr, bonus);
            up = users[up].sponsor;
        }
    }

    function deposit(
        uint256 _plan,
        address _sponsor
    ) external payable nonReentrant {
        _setSponsor(msg.sender, _sponsor);
        _deposit(_plan, msg.sender, msg.value);
    }

    function claim(uint256 _plan) external nonReentrant {
        require(_plan < PLANS.length, "Invalid plan");

        uint256 payout = this.payoutCoinsOf(_plan, msg.sender);
        require(payout > 0, "Zero payout");

        user_plans[msg.sender][_plan].claim_coins_date = block.timestamp;
        users[msg.sender].coins += payout;
    }

    function withdraw(uint256 _plan) external nonReentrant {
        require(_plan <= PLANS.length, "Invalid plan");

        uint256 payout = 0;
        uint256 payoutFull = 0;
        if (_plan == PLANS.length) {
            payoutFull = users[msg.sender].bonus;
            require(payoutFull > 0, "Zero payout");
            require(
                payoutFull >= MIN_BONUS_WITHDRAWAL,
                "Minimum withdrawal amount is 0.05 BNB"
            );

            uint256 diff = (block.timestamp -
                users[msg.sender].withdraw_ref_date) / ONE_DAY;
            require(diff > 0, "One withdrawal per day is allowed");

            users[msg.sender].bonus = 0;
            users[msg.sender].withdraw_ref_date = block.timestamp;

            payout = payoutFull;
        } else {
            payoutFull = this.payoutOf(_plan, msg.sender);
            require(payoutFull > 0, "Zero payout");

            Plan storage plan = PLANS[_plan];
            require(
                payoutFull >= plan.min_withdraw,
                "Wrong minimum withdrawal amount"
            );

            uint256 diff = (block.timestamp -
                user_plans[msg.sender][_plan].withdraw_date) / ONE_DAY;
            require(diff > 0, "One withdrawal per day is allowed");

            uint256 payoutWithLimits = 0;
            if (payoutFull > DAILY_PLAN_WITHDRAWAL_LIMIT) {
                payoutWithLimits = DAILY_PLAN_WITHDRAWAL_LIMIT;
            } else {
                payoutWithLimits = payoutFull;
            }

            uint256 reinvest = WITHDRAW_REINVEST.mul(payoutWithLimits);
            payout = payoutWithLimits - reinvest;

            user_plans[msg.sender][_plan].pending = 0;
            user_plans[msg.sender][_plan].pending_payout = 0;
            user_plans[msg.sender][_plan].last_date = block.timestamp;
            user_plans[msg.sender][_plan].withdraw_date = block.timestamp;
            user_plans[msg.sender][_plan].withdrawn_payout += payout;

            _reinvest(_plan, msg.sender, reinvest);

            if (payoutFull > payoutWithLimits) {
                user_plans[msg.sender][_plan].pending =
                    payoutFull -
                    payoutWithLimits;
            }

            payoutFull = payoutWithLimits;
        }

        users[msg.sender].withdrawn += payoutFull;
        total_withdrawn += payoutFull;

        (bool successWithdraw, ) = msg.sender.call{value: payout}("");
        require(successWithdraw, "Transfer failed.");

        emit Withdraw(msg.sender, _plan, payoutFull);
    }

    function maxPayoutOf(
        uint256 _plan,
        uint256 _amount
    ) internal view returns (uint256) {
        return PLANS[_plan].max_payout.mul(_amount);
    }

    function payoutOf(
        uint256 _plan,
        address _addr
    ) external view returns (uint256 payout) {
        uint256 max_payout = maxPayoutOf(
            _plan,
            user_plans[_addr][_plan].deposited
        );
        if (user_plans[_addr][_plan].withdrawn_payout >= max_payout) return 0;
        payout =
            (dailyBonus(_plan, _addr) + holdBonus(_plan, _addr)) +
            user_plans[_addr][_plan].pending +
            user_plans[_addr][_plan].pending_payout;
        if (user_plans[_addr][_plan].withdrawn_payout + payout >= max_payout)
            return max_payout - user_plans[_addr][_plan].withdrawn_payout;
        return payout;
    }

    function payoutCoinsOf(
        uint256 _plan,
        address _addr
    ) external view returns (uint256 payout) {
        uint256 ldays = block.timestamp.sub(
            user_plans[_addr][_plan].claim_coins_date
        ) / ONE_DAY;
        return ldays.mul(PLANS[_plan].daily_coins);
    }

    function dailyBonus(
        uint256 _plan,
        address _addr
    ) internal view returns (uint256 percent) {
        if (user_plans[_addr][_plan].last_date == 0) return 0;
        return
            (PLANS[_plan].daily.mul(user_plans[_addr][_plan].deposited) *
                (block.timestamp - user_plans[_addr][_plan].last_date)) /
            ONE_DAY;
    }

    function getHoldBonus(
        uint256 _plan,
        address _addr
    ) public view returns (uint256 percent) {
        if (user_plans[_addr][_plan].last_date == 0) return 0;
        uint256 ldays = block
            .timestamp
            .sub(user_plans[_addr][_plan].last_date)
            .div(ONE_DAY);
        return
            ldays > PLANS[_plan].max_additional
                ? PLANS[_plan].max_additional
                : ldays;
    }

    function holdBonus(
        uint256 _plan,
        address _addr
    ) internal view returns (uint256 percent) {
        if (user_plans[_addr][_plan].last_date == 0) return 0;
        uint256 ldays = block
            .timestamp
            .sub(user_plans[_addr][_plan].last_date)
            .div(ONE_DAY);
        if (ldays == 0) return 0;

        uint256 bonus = 0;
        uint256 holdBonusMultiplier = getHoldBonus(_plan, _addr);

        for (uint256 i = 1; i <= holdBonusMultiplier; i++) {
            if (i == 10)
                bonus +=
                    ((user_plans[_addr][_plan].deposited *
                        (PLANS[_plan].additional.num * i)) /
                        PLANS[_plan].additional.den) *
                    (ldays - 9);
            else
                bonus +=
                    (user_plans[_addr][_plan].deposited *
                        (PLANS[_plan].additional.num * i)) /
                    PLANS[_plan].additional.den;
        }

        return bonus;
    }

    function referralsCount(
        address _addr,
        uint256 _level
    ) external view returns (uint256 referrals) {
        return users[_addr].referrals[_level];
    }

    // Arena:
    function buy() external payable nonReentrant {
        require(msg.value >= 1e16, "Minimum buy is 0.01 BNB");
        users[msg.sender].coins += msg.value / COIN_RATE;
    }

    function sell(uint256 amount) external payable nonReentrant {
        require(amount > 0, "Zero amount");
        require(
            users[msg.sender].coins >= amount,
            "Insufficient coins balance"
        );

        users[msg.sender].coins -= amount;

        uint256 payout = amount * COIN_RATE;
        (bool successWithdraw, ) = msg.sender.call{value: payout}("");
        require(successWithdraw, "Transfer failed.");
    }

    function createArena(uint256 arena_type) public nonReentrant {
        require(arena_type < 5, "Incorrect type");

        uint256 timestamp = getStartOfDayTimestamp();
        require(
            arenas_counter[msg.sender][timestamp][arena_type] <
                getArenaCount(arena_type),
            "You have reached the limit of arenas"
        );

        _createArena(arena_type);
        _fightArena(timestamp, arena_type, msg.sender);
    }

    function getStartOfDayTimestamp() public view returns (uint256) {
        return block.timestamp - (block.timestamp % ONE_DAY);
    }

    function getArenaType(uint256 arena_type) internal pure returns (uint256) {
        return [40, 200, 400, 2000, 5000][arena_type];
    }

    function getArenaCount(uint256 arena_type) internal pure returns (uint256) {
        return [10, 10, 10, 2, 2][arena_type];
    }

    function _randomNumber() internal view returns (uint256) {
        uint256 randomnumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                            (block.timestamp)) +
                        block.number
                )
            )
        );

        return randomnumber % 100;
    }

    function _createArena(uint256 arena_type) internal {
        uint256 price = getArenaType(arena_type);
        require(users[msg.sender].coins >= price, "Not enough coins");

        arenas[msg.sender][arena_type].timestamp = block.timestamp;
        arenas[msg.sender][arena_type].player = msg.sender;
        arenas[msg.sender][arena_type].winner = address(0);
        arenas[msg.sender][arena_type].coins = price;
        arenas[msg.sender][arena_type].roll = 0;
        users[msg.sender].coins -= price;
    }

    function _fightArena(
        uint256 timestamp,
        uint256 arena_type,
        address creator
    ) internal {
        uint256 random = _randomNumber();
        uint256 wAmount = arenas[creator][arena_type].coins * 2;
        uint256 fee = (wAmount * 10) / 100;

        address winner = random < 50
            ? arenas[creator][arena_type].player
            : address(0);

        if (winner == address(0)) {
            wars[creator].loses++;
        } else {
            wars[creator].wins++;
            wars[creator].minted +=
                wAmount -
                fee -
                arenas[creator][arena_type].coins;
            users[winner].coins += wAmount - fee;
        }

        total_wars++;
        arenas[creator][arena_type].winner = winner;
        arenas_counter[creator][timestamp][arena_type]++;

        users[promote1].coins += fee / 2;
        users[promote2].coins += fee / 2;
    }
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
