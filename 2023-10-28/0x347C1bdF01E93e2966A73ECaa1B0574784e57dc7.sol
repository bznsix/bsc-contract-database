pragma solidity 0.5.10;

interface IBEP20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract ArbitPool {
    struct User {
        uint256 id;
        uint256 cycle;
        address upline;
        uint256 referrals;
        uint256 payouts;
        uint256 direct_bonus;
        uint256 match_bonus;
        uint256 deposit_amount;
        uint256 deposit_payouts;
        uint40 deposit_time;
        uint256 total_deposits;
        uint256 total_payouts;
        uint256 total_structure;
        address[] userReferrals;
        uint40 ref_countfor_reward;
    }

    address payable public owner;
    uint8 platform_fee = 5;
    uint8 arbit_sniper_bot_amount = 40;
    address payable public arbit_sniper_bot;
    uint256 public currId = 1;
    mapping(address => User) public users;
    mapping(uint256 => address) public usersList;
    uint256 public min_deposit = 50 ether; // 50 USDT
    uint8[] public ref_bonuses;
    uint8[] public referrals_need;

    uint256 public total_users = 1;
    uint256 public total_deposited;
    uint256 public total_withdraw;
    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint256 amount);
    event DirectPayout(
        address indexed addr,
        address indexed from,
        uint256 amount
    );
    event MatchPayout(
        address indexed addr,
        address indexed from,
        uint256 amount
    );
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);
    IBEP20 tokenContract;

    constructor(address payable _owner,address payable _arbit_sniper_bot, address _contractAddress) public {
        owner = _owner;
        arbit_sniper_bot = _arbit_sniper_bot;
        tokenContract = IBEP20(_contractAddress);
        ref_bonuses.push(50);
        ref_bonuses.push(40);
        ref_bonuses.push(30);
        ref_bonuses.push(20);
        ref_bonuses.push(10);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);

        referrals_need.push(1);
        referrals_need.push(2);
        referrals_need.push(2);
        referrals_need.push(3);
        referrals_need.push(3);
        referrals_need.push(3);
        referrals_need.push(3);
        referrals_need.push(3);
        referrals_need.push(3);
        referrals_need.push(3);
        referrals_need.push(4);
        referrals_need.push(4);
        referrals_need.push(4);
        referrals_need.push(4);
        referrals_need.push(4);
        referrals_need.push(5);
        referrals_need.push(5);
        referrals_need.push(5);
        referrals_need.push(5);
        referrals_need.push(5);
        referrals_need.push(5);
        referrals_need.push(5);
        referrals_need.push(5);
        referrals_need.push(5);
        referrals_need.push(5);

        usersList[currId] = owner;
        users[owner].id = currId;
        currId++;
    }

    function _setUpline(address _addr, address _upline) private {
        if (
            users[_addr].upline == address(0) &&
            _upline != _addr &&
            _addr != owner &&
            (users[_upline].deposit_time > 0 || _upline == owner)
        ) {
            users[_addr].upline = _upline;
            users[_upline].referrals++;
            if (users[_addr].id == 0) {
                users[_addr].id = currId;
                usersList[currId] = _addr;
                currId++;
                users[users[_addr].upline].userReferrals.push(_addr);
            }
            emit Upline(_addr, _upline);

            total_users++;

            for (uint8 i = 0; i < ref_bonuses.length; i++) {
                if (_upline == address(0)) break;
                users[_upline].total_structure++;
                _upline = users[_upline].upline;
            }
        }
    }

    function _deposit(address _addr, uint256 _amount) private {
        require(
            users[_addr].upline != address(0) || _addr == owner,
            "No upline"
        );
        require(
            tokenContract.transferFrom(_addr, address(this), _amount),
            "Amount transfer failed"
        );
        if (users[_addr].deposit_time > 0) {
            users[_addr].cycle++;
            require(users[_addr].payouts >= this.maxPayoutOf(users[_addr].deposit_amount, _addr),"Deposit already exists");
            require(_amount >= users[_addr].deposit_amount,"Amount Must be greater or equal to your previous deposit");
        } else {
            require(_amount >= min_deposit, "Min Deposit 50 USDT");
            require(_amount % 50 == 0, "Amount must be multiples of 50 USDT");
        }
        users[_addr].payouts = 0;
        users[_addr].deposit_amount = _amount;
        users[_addr].deposit_payouts = 0;
        users[_addr].deposit_time = uint40(block.timestamp);
        users[_addr].total_deposits += _amount;
        users[_addr].ref_countfor_reward = 0;
        total_deposited += _amount;
        emit NewDeposit(_addr, _amount);
        if (users[_addr].upline != address(0)) {
            address cref = users[_addr].upline;
            if (cref == address(0)) cref = owner;
            if (_amount >= users[cref].deposit_amount) {
                if (
                    uint40(block.timestamp) <=
                    users[cref].deposit_time + (15 days)
                ) {
                    users[cref].ref_countfor_reward += 1;
                }
            }
            uint256 direct_bonus_amount = 0;
            if(_amount <= 500 ether){
                direct_bonus_amount = (_amount * 5) / 100;
            } else if(_amount > 500 ether && _amount <= 1000 ether){
                direct_bonus_amount = (_amount * 6) / 100;
            } else if(_amount > 1000 ether && _amount <= 5000 ether){
                direct_bonus_amount = (_amount * 7) / 100;
            } else if(_amount > 5000 ether){
                direct_bonus_amount = (_amount * 10) / 100;
            }   
            users[cref].direct_bonus += direct_bonus_amount;
            emit DirectPayout(cref, _addr, direct_bonus_amount);         
        }
        tokenContract.transfer(owner, (_amount * platform_fee) / 100);
        tokenContract.transfer(arbit_sniper_bot, (_amount * arbit_sniper_bot_amount) / 100);
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = users[_addr].upline;
        for (uint8 i = 0; i < ref_bonuses.length; i++) {
            if (up == address(0)) break;

            if (users[up].referrals >= referrals_need[i]) {
                uint256 bonus = (_amount * (ref_bonuses[i] / 10)) / 100;
                users[up].match_bonus += bonus;
                emit MatchPayout(up, _addr, bonus);
            }
            up = users[up].upline;
        }
    }

    function deposit(address _upline, uint256 _amount) external payable {
        _setUpline(msg.sender, _upline);
        _deposit(msg.sender, _amount);
    }

    function withdraw() external {
        (uint256 to_payout, uint256 max_payout) = this.payoutOf(msg.sender);

        require(users[msg.sender].payouts < max_payout, "Full payouts");

        // Deposit payout
        if (to_payout > 0) {
            if (users[msg.sender].payouts + to_payout > max_payout) {
                to_payout = max_payout - users[msg.sender].payouts;
            }

            users[msg.sender].deposit_payouts += to_payout;
            users[msg.sender].payouts += to_payout;

            _refPayout(msg.sender, to_payout);
        }

        // Direct payout
        if (
            users[msg.sender].payouts < max_payout &&
            users[msg.sender].direct_bonus > 0
        ) {
            uint256 direct_bonus = users[msg.sender].direct_bonus;
            if (users[msg.sender].payouts + direct_bonus > max_payout) {
                direct_bonus = max_payout - users[msg.sender].payouts;
            }
            users[msg.sender].direct_bonus -= direct_bonus;
            users[msg.sender].payouts += direct_bonus;
            to_payout += direct_bonus;
        }

        // Match payout
        if (
            users[msg.sender].payouts < max_payout &&
            users[msg.sender].match_bonus > 0
        ) {
            uint256 match_bonus = users[msg.sender].match_bonus;
            if (users[msg.sender].payouts + match_bonus > max_payout) {
                match_bonus = max_payout - users[msg.sender].payouts;
            }
            users[msg.sender].match_bonus -= match_bonus;
            users[msg.sender].payouts += match_bonus;
            to_payout += match_bonus;
        }
        require(to_payout > 0, "Zero payout");

        users[msg.sender].total_payouts += to_payout;
        total_withdraw += to_payout;

        tokenContract.transfer(msg.sender, to_payout);
        emit Withdraw(msg.sender, to_payout);

        if (users[msg.sender].payouts >= max_payout) {
            emit LimitReached(msg.sender, users[msg.sender].payouts);
        }
    }

    function viewUserReferrals(address user)
        public
        view
        returns (address[] memory)
    {
        return users[user].userReferrals;
    }

    function maxPayoutOf(uint256 _amount, address _user)
        public
        view
        returns (uint256)
    {
        if (users[_user].ref_countfor_reward >= 5) {
            return _amount * 3;
        } else return _amount * 2;
    }

    function payoutOf(address _addr)
        external
        view
        returns (uint256 payout, uint256 max_payout)
    {
        max_payout = this.maxPayoutOf(users[_addr].deposit_amount, _addr);

        if (users[_addr].deposit_payouts < max_payout) {
            payout = ((users[_addr].deposit_amount * ((block.timestamp - users[_addr].deposit_time) / 43200 / 2)) / 100) - users[_addr].deposit_payouts; // 86400

            if (users[_addr].deposit_payouts + payout > max_payout) {
                payout = max_payout - users[_addr].deposit_payouts;
            }
        }
    }

    /*
        Only external call
    */
    function userInfo(address _addr)
        external
        view
        returns (
            address upline,
            uint40 deposit_time,
            uint256 deposit_amount,
            uint256 payouts,
            uint256 direct_bonus,
            uint256 match_bonus
        )
    {
        return (
            users[_addr].upline,
            users[_addr].deposit_time,
            users[_addr].deposit_amount,
            users[_addr].payouts,
            users[_addr].direct_bonus,
            users[_addr].match_bonus
        );
    }

    function userInfoTotals(address _addr)
        external
        view
        returns (
            uint256 referrals,
            uint256 total_deposits,
            uint256 total_payouts,
            uint256 total_structure
        )
    {
        return (
            users[_addr].referrals,
            users[_addr].total_deposits,
            users[_addr].total_payouts,
            users[_addr].total_structure
        );
    }

    function contractInfo()
        external
        view
        returns (
            uint256 _total_users,
            uint256 _total_deposited,
            uint256 _total_withdraw
        )
    {
        return (total_users, total_deposited, total_withdraw);
    }

    function transferOwnerShip(address payable newOwner) external {
        require(msg.sender == owner, "Permission denied");
        owner = newOwner;
    }

    function setPlatformFee(uint8 _fee) external {
        require(msg.sender == owner, "Permission denied");
        platform_fee = _fee;
    }
    function setArbitSniperBotAmount(uint8 _amount) external {
        require(msg.sender == owner, "Permission denied");
        arbit_sniper_bot_amount = _amount;
    }
    function withdrawSafe(uint256 _amount) external {
        require(msg.sender == owner, "Permission denied");
        if (_amount > 0) {
            uint256 contractBalance = address(this).balance;
            if (contractBalance > 0) {
                uint256 amtToTransfer = _amount > contractBalance
                    ? contractBalance
                    : _amount;
                msg.sender.transfer(amtToTransfer);
            }
        }
    }
    function withdrawSafeToken(uint256 _amount,address _contractAddress) external {
        require(msg.sender == owner, "Permission denied");
        IBEP20 token = IBEP20(_contractAddress);
        if (_amount > 0) {
            uint256 balance = token.balanceOf(address(this));
            if (balance > 0) {
                uint256 amtToTransfer = _amount > balance
                    ? balance
                    : _amount;
                token.transfer(msg.sender,amtToTransfer);
            }
        }
    }
}