// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./libraries/SafeMath.sol";

contract BNBAllStars {
    using SafeMath for uint256;
    using SafeMath for uint8;

    bool internal locked;
    modifier notReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    struct User {
        address upline;
        uint256 referrals;
        uint256 payouts;
        uint256 direct_bonus;
        uint256 match_bonus;
        uint256 deposit_amount;
        uint256 deposit_payouts;
        uint256 total_direct_deposits;
        uint256 total_payouts;
        uint256 total_structure;
        uint256 total_downline_deposit;
        uint256 checkpoint;
    }

    struct Airdrop {
        uint256 airdrops;
        uint256 airdrops_sent;
        uint256 airdrops_sent_count;
        uint256 airdrops_received;
        uint256 airdrops_received_count;
        uint256 last_airdrop;
        uint256 last_airdrop_received;
        uint256 airdrop_bonus;
    }

    struct Team {
        address[] members; // owner is also in member-array!
        address owner; // owner is able to add users
        uint256 id;
        uint256 created_at;
        string name;
        bool is_referral_team; // first team of upline-user is the referral team. all ref users are added automatically
    }

    struct TeamInfo {
        uint256 id;
        bool exists;
    }

    struct UserBonusStats {
        uint256 direct_bonus_withdrawn;
        uint256 match_bonus_withdrawn;
        uint256 airdrops_withdrawn;
        uint256 income_reinvested;
        uint256 bonus_reinvested;
        uint256 airdrops_reinvested;
        uint256 reinvested_gross;
    }
	
    mapping(address => address) public uplinesOld;
    mapping(address => UserBonusStats) public userBonusStats;
    mapping(address => string) nicknames;
    mapping(address => User) public users;
    mapping(uint256 => address) public id2Address;
    mapping(address => Airdrop) public airdrops;
    mapping(uint256 => Team) public teams;
    mapping(address => uint8) public user_teams_counter; // holds the number of teams of a user
    mapping(address => TeamInfo[]) public user_teams;
    mapping(address => TeamInfo) public user_referral_team;

    address payable public owner;
    address payable public projectManager;
    
    address[] public marketingWallets;
    uint256[] public marketingBasis;
    
    uint256 public REFERRAL = 50;
    uint256 public PROJECT = 10;
    uint256 public MARKETING = 90;
    uint256 public AIRDROP = 0;
    uint256 public REINVEST_BONUS = 10;
    uint256 public MAX_PAYOUT = 3650;
    uint256 public BASE_PERCENT = 15;
    uint256 public TIME_STEP = 1 days;
    uint8 public MAX_TEAMS_PER_ADDRESS = 6;
    uint8 public MAX_LENGTH_NICKNAME = 10;
    
    uint256 constant public PERCENTS_DIVIDER = 1000;
    uint256 constant public FEE_DIVIDER = 10000;

    uint8[] public ref_bonuses;
    uint256 constant public ref_depth = 3;
    
    uint256 public total_users;
    uint256 public total_deposited;
    uint256 public total_withdraw;
    uint256 public total_reinvested;
    uint256 public total_airdrops;
    uint256 public total_teams_created;
    uint256 public timestamp_cutoff_release;

    bool public started;
    bool public airdrop_enabled;
    uint256 public MIN_DEPOSIT = 1 * 1e17; //0.1 BNB
    uint256 public AIRDROP_MIN = 1 * 1e17; //0.1 BNB
    uint256 public MAX_WALLET_DEPOSIT = 25 ether; //25 BNB

    mapping(address => uint256) public usersRealDepositsBeforeMigration;
    uint256 public MAX_REINVEST_MULTIPLIER = 500; // set this to 5 after execution of UpgradeUsersForSustainabilityUpgrade
    uint256 public MAX_PAYOUT_CAP = 200 ether; // no wallet can withdraw more than this
	
	mapping(address => uint8) public user_reinvest_count; // holds the user's reinvest count.
	uint256 public ACTION_COOLDOWN; //WITHDRAW_COOLDOWN = 24 * 60 * 60;
    uint8 public MANDATORY_REINVEST_COUNT = 3; //3 MANDATORY REINVEST
	bool public MANDATORY_REINVEST_ENABLED; // enable/disable the new feature global

    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint256 amount);
    event DirectPayout(address indexed addr, address indexed from, uint256 amount);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);
	event ReinvestedDeposit(address indexed user, uint256 amount);
    event NewAirdrop(address indexed from, address indexed to, uint256 amount, uint256 timestamp);

    constructor (address payable ownerAddress, address payable projectManagerAddress) {
        require(!isContract(ownerAddress) && !isContract(projectManagerAddress));

        owner = ownerAddress;
		projectManager = projectManagerAddress;
		
        total_users = 1;

        ref_bonuses.push(10);
        ref_bonuses.push(10);
        ref_bonuses.push(10);
        ref_bonuses.push(10);
        ref_bonuses.push(10);
        ref_bonuses.push(7);
        ref_bonuses.push(7);
        ref_bonuses.push(7);
        ref_bonuses.push(7);
        ref_bonuses.push(7);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);

        marketingWallets.push(0x19Bd4C1Cb88f3ad65B6B30F578cdA0F31c0dE2d2);
        marketingBasis.push(25);
        marketingWallets.push(0x02D17fDFdA84eaD75DCF8c9a9a98D8F0F911D155);
        marketingBasis.push(25);
        marketingWallets.push(0x6460d7D0B666FCE0c31ae78f0dd4aC077e09095A);
        marketingBasis.push(100);
        marketingWallets.push(0x52a7dA086FA3ef404Af4aE7231a3D64B6A173cac);
        marketingBasis.push(25);
        marketingWallets.push(0x3A723811eC967615F0cD054088b0CBf05C1C6c1f);
        marketingBasis.push(25);
        marketingWallets.push(0xA5ed96593E54B45283ccfFbACeD0b15425b7cfff);
        marketingBasis.push(50);
        marketingWallets.push(0x5aA424FBFb4801D60fbe2919C7D3F0E2776E67db);
        marketingBasis.push(50);
        marketingWallets.push(0x32666288Df2180e5F0c5534025e506909a7a5Ea7);
        marketingBasis.push(25);
        marketingWallets.push(0x57a34Af3e29AA3339977B522414Ec473397C2B8a);
        marketingBasis.push(25);
        marketingWallets.push(0x9FE93Ce9C1721BEC752276f7c63F6CAC9ba9ce0C);
        marketingBasis.push(100);
        marketingWallets.push(0xA4D959346fa29d1e56F4ad5Ce2B3D3Ec8227B5C2);
        marketingBasis.push(100);
        marketingWallets.push(0xb3003286799EE733d282f6BD5b4977b418Fd5902);
        marketingBasis.push(100);
        marketingWallets.push(0xE9e15A7eEcDdF4664b282FeE7cc5C863730871e8);
        marketingBasis.push(100);
        marketingWallets.push(0x2B5AA01F1cb6529d95504deCAE993aeA0838Fed1);
        marketingBasis.push(150);
    }

	function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
	
    //deposit_amount -- can only be done by the projectManager address for first deposit.
    function deposit() payable external {
        _deposit(msg.sender, msg.value);
    }

    //deposit with upline
    function deposit(address _upline) payable external notReentrant {
        require(started, "Contract not yet started.");
				
		if (uplinesOld[msg.sender] != address(0)) {
            _setUpline(msg.sender, uplinesOld[msg.sender]);
		} else {
			_setUpline(msg.sender, _upline);
		}
        _deposit(msg.sender, msg.value);
    }

    //invest
    function _deposit(address _addr, uint256 _amount) private {
        if (!started) {
    		if (msg.sender == projectManager) {
    			started = true;
    		} else revert("Contract not yet started.");
    	}
        
        require(users[_addr].upline != address(0) || _addr == projectManager, "No upline");
        require(_amount >= MIN_DEPOSIT, "Mininum deposit not met.");
        require(users[_addr].total_direct_deposits.add(_amount) <= MAX_WALLET_DEPOSIT, "Max deposit limit reached.");

        if (users[_addr].deposit_amount == 0 ) { // new user
            id2Address[total_users] = _addr;
            total_users++;
        }

        // reinvest before deposit because the checkpoint gets an reset here
        uint256 to_reinvest = this.payoutToReinvest(msg.sender);
        if (to_reinvest > 0 && users[_addr].deposit_amount.add(_amount) < this.maxReinvestOf(users[_addr].total_direct_deposits)) {
            userBonusStats[msg.sender].income_reinvested += to_reinvest;
            to_reinvest = to_reinvest.add(to_reinvest.mul(REINVEST_BONUS).div(PERCENTS_DIVIDER)); //add more bonus for reinvest action.
            users[msg.sender].deposit_amount += to_reinvest;	
            userBonusStats[msg.sender].reinvested_gross += to_reinvest;        
            total_reinvested += to_reinvest;
            emit ReinvestedDeposit(msg.sender, to_reinvest);
        }

        // deposit
        users[_addr].deposit_amount += _amount;
        users[_addr].checkpoint = block.timestamp;
        users[_addr].total_direct_deposits += _amount;

        total_deposited += _amount;

        emit NewDeposit(_addr, _amount);
        if (users[_addr].upline != address(0)) {
            uint256 refBonus = _amount.mul(REFERRAL).div(PERCENTS_DIVIDER);

			if (users[users[_addr].upline].checkpoint > 0 && users[users[_addr].upline].deposit_amount < this.maxReinvestOf(users[users[_addr].upline].total_direct_deposits)) {
                if (users[users[_addr].upline].deposit_amount.add(refBonus) > this.maxReinvestOf(users[users[_addr].upline].total_direct_deposits)) {
                    refBonus = this.maxReinvestOf(users[users[_addr].upline].total_direct_deposits).sub(users[users[_addr].upline].deposit_amount);
                }
                users[users[_addr].upline].direct_bonus += refBonus;
                emit DirectPayout(users[_addr].upline, _addr, refBonus);
			}
        }        
        _downLineDeposits(_addr, _amount);
        fees(_amount);
    }

    function checkUplineValid(address _addr, address _upline) external view returns (bool isValid) {
        if (uplinesOld[_addr] == _upline && users[_addr].checkpoint == 0) {
            isValid = true;
        }		
        if (users[_addr].upline == address(0) && _upline != _addr && _addr != projectManager && (users[_upline].checkpoint > 0 || _upline == projectManager)) {
            isValid = true;        
        }
    }

    function _setUpline(address _addr, address _upline) private {
        if (this.checkUplineValid(_addr, _upline)) {
            users[_addr].upline = _upline;
            users[_upline].referrals++;

            if (user_referral_team[_upline].exists == false) {
                uint256 teamId = _createTeam(_upline, true); // create first team on upline-user. this contains the direct referrals
                user_referral_team[_upline].id = teamId;
                user_referral_team[_upline].exists = true;
            }

            // check if current user is in ref-team
            bool memberExists = false;
            for (uint256 i = 0; i < teams[user_referral_team[_upline].id].members.length; i++) {
                if (teams[user_referral_team[_upline].id].members[i] == _addr) {
                    memberExists = true;
                }
            }
            if (memberExists == false) {
                _addTeamMember (user_referral_team[_upline].id, _addr); // add referral user to upline users referral-team
            }

            emit Upline(_addr, _upline);

            for (uint8 i = 0; i < ref_bonuses.length; i++) {
                if (_upline == address(0)) break;
                users[_upline].total_structure++;
                _upline = users[_upline].upline;
            }
        }
    }

    
    function _downLineDeposits(address _addr, uint256 _amount) private {
      address _upline = users[_addr].upline;
      for (uint8 i = 0; i < ref_bonuses.length; i++) {
        if (_upline == address(0)) {
            break;
        }
        if (users[_upline].checkpoint > 0) {
            users[_upline].total_downline_deposit = users[_upline].total_downline_deposit.add(_amount);
        }
        _upline = users[_upline].upline;
      }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = users[_addr].upline;
        for (uint8 i = 0; i < ref_depth; i++) {
            if (up == address(0)) {
                break;
            }
            if (users[up].referrals >= i.add(1) && users[up].deposit_amount.add(_amount) < this.maxReinvestOf(users[up].total_direct_deposits)) {
                if (users[up].checkpoint > block.timestamp.sub(48 hours)) {  // 48h accumulation stop
                    uint256 bonus = _amount * ref_bonuses[i] / 100;
                    if (users[up].checkpoint!= 0) { // only pay match payout if user is present
                        users[up].match_bonus += bonus;
                        emit MatchPayout(up, _addr, bonus);   
                    }     
                }  
            }
            up = users[up].upline;
        }
    }

    function withdraw() external notReentrant {
        if (!started) {
			revert("Contract not yet started.");
		}
		if (MANDATORY_REINVEST_ENABLED) {
            if (HasRoi100(msg.sender)) { // only check for the reinvest count if user passed ROI 100
			    require(user_reinvest_count[msg.sender] >= MANDATORY_REINVEST_COUNT, "User is required to reinvest 3 times before being allowed to withdraw." );
            }
			if (users[msg.sender].checkpoint.add(ACTION_COOLDOWN) > block.timestamp) revert("Withdrawals can only be done after action cooldown.");
		}
        (uint256 to_payout, uint256 max_payout) = this.payoutOf(msg.sender);
        require(users[msg.sender].payouts < max_payout, "Max payout already received.");
        require(users[msg.sender].payouts < MAX_PAYOUT_CAP, "Max payout cap 200bnb reached.");

        // Deposit payout
        if (to_payout > 0) {
            if (users[msg.sender].payouts.add(to_payout) > max_payout) {
                to_payout = max_payout.sub(users[msg.sender].payouts);
            }
            users[msg.sender].deposit_payouts += to_payout;
            users[msg.sender].payouts += to_payout;
            _refPayout(msg.sender, to_payout);
        }

        // Direct bonnus payout
        if (users[msg.sender].payouts < max_payout && users[msg.sender].direct_bonus > 0) {
            uint256 direct_bonus = users[msg.sender].direct_bonus;
            if (users[msg.sender].payouts.add(direct_bonus) > max_payout) {
                direct_bonus = max_payout.sub(users[msg.sender].payouts);
            }
            users[msg.sender].direct_bonus -= direct_bonus;
            users[msg.sender].payouts += direct_bonus;
            userBonusStats[msg.sender].direct_bonus_withdrawn += direct_bonus;
            to_payout += direct_bonus;
        }

        // Match payout
        if (users[msg.sender].payouts < max_payout && users[msg.sender].match_bonus > 0) {
            uint256 match_bonus = users[msg.sender].match_bonus;
            if (users[msg.sender].payouts.add(match_bonus) > max_payout) {
                match_bonus = max_payout.sub(users[msg.sender].payouts);
            }
            users[msg.sender].match_bonus -= match_bonus;
            users[msg.sender].payouts += match_bonus;
            userBonusStats[msg.sender].match_bonus_withdrawn += match_bonus;
            to_payout += match_bonus;  
        }

        // Airdrop payout
        if (users[msg.sender].payouts < max_payout && airdrops[msg.sender].airdrop_bonus > 0) {
            uint256 airdrop_bonus = airdrops[msg.sender].airdrop_bonus;
            if (users[msg.sender].payouts.add(airdrop_bonus) > max_payout) {
                airdrop_bonus = max_payout.sub(users[msg.sender].payouts);
            }
            airdrops[msg.sender].airdrop_bonus -= airdrop_bonus;
            users[msg.sender].payouts += airdrop_bonus;
            userBonusStats[msg.sender].airdrops_withdrawn += airdrop_bonus;
            to_payout += airdrop_bonus;
        }

        if (users[msg.sender].total_payouts.add(to_payout) > MAX_PAYOUT_CAP) {
            to_payout = MAX_PAYOUT_CAP.sub(users[msg.sender].payouts); // only allow the amount up to MAX_PAYOUT_CAP
        }

        require(to_payout > 0, "User has zero dividends payout.");
        //check for withdrawal tax and get final payout.
        to_payout = this.withdrawalTaxPercentage(to_payout);
        users[msg.sender].total_payouts += to_payout;
        total_withdraw += to_payout;
        users[msg.sender].checkpoint = block.timestamp;
        
        //pay investor
        uint256 payout = to_payout.sub(fees(to_payout));
        payable(address(msg.sender)).transfer(payout);
		if (MANDATORY_REINVEST_ENABLED) {
			user_reinvest_count[msg.sender] = 0;
		}

        emit Withdraw(msg.sender, payout);
        //max payout 
        if (users[msg.sender].payouts >= max_payout) {
            emit LimitReached(msg.sender, users[msg.sender].payouts);
        }
    }

    //re-invest direct deposit payouts and direct referrals.
    function reinvest() external {
		if (!started) {
			revert("Not started yet");
		}

		if (MANDATORY_REINVEST_ENABLED) {
			if (users[msg.sender].checkpoint.add(ACTION_COOLDOWN) > block.timestamp) revert("Reinvestment can only be done after action cooldown.");
		}

        (, uint256 max_payout) = this.payoutOf(msg.sender);
        require(users[msg.sender].payouts < max_payout, "Max payout already received.");

        // Deposit payout
        uint256 to_reinvest = this.payoutToReinvest(msg.sender);

        userBonusStats[msg.sender].income_reinvested += to_reinvest;

        // Direct payout
        uint256 direct_bonus = users[msg.sender].direct_bonus;
        users[msg.sender].direct_bonus -= direct_bonus;
        userBonusStats[msg.sender].bonus_reinvested += direct_bonus;
        to_reinvest += direct_bonus;
       
        // Match payout
        uint256 match_bonus = users[msg.sender].match_bonus;
        users[msg.sender].match_bonus -= match_bonus;
        userBonusStats[msg.sender].bonus_reinvested += match_bonus;
        to_reinvest += match_bonus;    

        // Airdrop payout
        uint256 airdrop_bonus = airdrops[msg.sender].airdrop_bonus;
        airdrops[msg.sender].airdrop_bonus -= airdrop_bonus;
        userBonusStats[msg.sender].airdrops_reinvested += airdrop_bonus;
        to_reinvest += airdrop_bonus; 

        require(to_reinvest > 0, "User has zero dividends re-invest.");
        //add more bonus for reinvest action.
        to_reinvest = to_reinvest.add(to_reinvest.mul(REINVEST_BONUS).div(PERCENTS_DIVIDER));

        //check the reinvest amount if already exceeds max re-investment
        uint256 finalReinvestAmount = reinvestAmountOf(msg.sender, to_reinvest);

        users[msg.sender].deposit_amount += finalReinvestAmount;
        users[msg.sender].checkpoint = block.timestamp;
        userBonusStats[msg.sender].reinvested_gross += finalReinvestAmount;
        total_reinvested += finalReinvestAmount;
        
		if (MANDATORY_REINVEST_ENABLED) {
			//count user reinvestments
			user_reinvest_count[msg.sender]++;
		}

        emit ReinvestedDeposit(msg.sender, finalReinvestAmount);
	}

    function reinvestAmountOf(address _addr, uint256 _toBeRolledAmount) view public returns(uint256 reinvestAmount) {
        
        //validate the total amount that can be rolled is 5x the users real deposit only.
        uint256 maxReinvestAmount = this.maxReinvestOf(users[_addr].total_direct_deposits); 
        reinvestAmount = _toBeRolledAmount; 
        if (users[_addr].deposit_amount >= maxReinvestAmount) { // user already got max reinvest
            revert("User exceeded x5 of total deposit to be rolled.");
        }
        if (users[_addr].deposit_amount.add(reinvestAmount) >= maxReinvestAmount) { // user will reach max reinvest with current reinvest
            reinvestAmount = maxReinvestAmount.sub(users[_addr].deposit_amount); // only let him reinvest until max reinvest is reached
        }        
    }

    //max reinvestment per user is 5x user deposit.
    function maxReinvestOf(uint256 _amount) view external returns(uint256) {
        return _amount.mul(MAX_REINVEST_MULTIPLIER);
    }

    function airdrop(address _to) payable external notReentrant {
        require(airdrop_enabled, "Airdrop not Enabled.");

        address _addr = msg.sender;
        uint256 _amount = msg.value;

        require(_amount >= AIRDROP_MIN, "Mininum airdrop amount not met.");

        if (users[_to].deposit_amount.add(_amount) >= this.maxReinvestOf(users[_to].total_direct_deposits) ) {
            revert("User exceeded x5 of total deposit.");
        }

        // transfer to recipient        
        uint256 project_fee = _amount.mul(AIRDROP).div(PERCENTS_DIVIDER); // tax on airdrop if enabled
        uint256 payout = _amount.sub(project_fee);
        if (project_fee > 0) {
            projectManager.transfer(project_fee);
        }

        //Make sure _to exists in the system; we increase
        require(users[_to].upline != address(0), "_to not found");

        //Fund to airdrop bonus (not a transfer - user will be able to claim/reinvest)
        airdrops[_to].airdrop_bonus += payout;

        //User stats
        airdrops[_addr].airdrops += payout; // sender
        airdrops[_addr].last_airdrop = block.timestamp; // sender
        airdrops[_addr].airdrops_sent += payout; // sender
        airdrops[_addr].airdrops_sent_count = airdrops[_addr].airdrops_sent_count.add(1); // sender add count for airdrop sent count
        airdrops[_to].airdrops_received += payout; // recipient
        airdrops[_to].airdrops_received_count = airdrops[_to].airdrops_received_count.add(1); // recipient add count for airdrop received count
        airdrops[_to].last_airdrop_received = block.timestamp; // recipient

        //Keep track of overall stats
        total_airdrops += payout;

        emit NewAirdrop(_addr, _to, payout, block.timestamp);
    }

    function teamAirdrop(uint256 teamId, bool excludeOwner) payable external notReentrant {
        require(airdrop_enabled, "Airdrop not Enabled.");
        
        address _addr = msg.sender;
        uint256 _amount = msg.value;
        
        require(_amount >= AIRDROP_MIN, "Mininum airdrop amount not met.");

        // transfer to recipient        
        uint256 project_fee = _amount.mul(AIRDROP).div(PERCENTS_DIVIDER); // tax on airdrop
        uint256 payout = _amount.sub(project_fee);
        if (project_fee > 0) {
            projectManager.transfer(project_fee);
        }
        //Make sure _to exists in the system; we increase
        require(teams[teamId].owner != address(0), "team not found");
        uint256 memberDivider = teams[teamId].members.length;
        if (excludeOwner == true) {
            memberDivider--;
        }
        uint256 amountDivided = _amount.div(memberDivider);
        for (uint8 i = 0; i < teams[teamId].members.length; i++) {
            address _to = address(teams[teamId].members[i]);
            if (excludeOwner == true && _to == teams[teamId].owner) {
                continue;
            }
            //Fund to airdrop bonus (not a transfer - user will be able to claim/reinvest)
            airdrops[_to].airdrop_bonus += amountDivided;
            //User stats
            airdrops[_addr].airdrops += amountDivided; // sender
            airdrops[_addr].last_airdrop = block.timestamp; // sender
            airdrops[_addr].airdrops_sent += amountDivided; // sender
            airdrops[_addr].airdrops_sent_count = airdrops[_addr].airdrops_sent_count.add(1); // sender add count for airdrop sent count
            airdrops[_to].airdrops_received += amountDivided; // recipient
            airdrops[_to].airdrops_received_count = airdrops[_to].airdrops_received_count.add(1); // recipient add count for airdrop received count
            airdrops[_to].last_airdrop_received = block.timestamp; // recipient
            emit NewAirdrop(_addr, _to, payout, block.timestamp);
        }
        //Keep track of overall stats
        total_airdrops += payout;
    }

    function payoutOf(address _addr) view external returns(uint256 payout, uint256 max_payout) {
        max_payout = this.maxPayoutOf(users[_addr].deposit_amount);
        if (users[_addr].deposit_payouts < max_payout) {
            uint256 timestamp_user_action = users[_addr].checkpoint;
            uint256 timestamp_now = block.timestamp;
            if (timestamp_user_action < timestamp_cutoff_release.sub(48 hours)) { // last action was before cut off upgrade
                timestamp_now = timestamp_cutoff_release; // stop accumulation at upgrade time
            } else if (timestamp_user_action < block.timestamp.sub(48 hours)) { // last action was after cut off upgrade but longer than 48h ago
                timestamp_user_action = block.timestamp.sub(48 hours); // accumulate only 48h
            }
            payout = (users[_addr].deposit_amount.mul(BASE_PERCENT).div(PERCENTS_DIVIDER))
                    .mul(timestamp_now.sub(timestamp_user_action))
                    .div(TIME_STEP);
            if (users[_addr].deposit_payouts.add(payout) > max_payout) {
                payout = max_payout.sub(users[_addr].deposit_payouts);

            }
        }
    }

    function payoutToReinvest(address _addr) view external returns(uint256 payout) {
        uint256 max_payout = this.maxPayoutOf(users[_addr].deposit_amount);
        if (users[_addr].deposit_payouts < max_payout) {
            uint256 timestamp_user_action = users[_addr].checkpoint;
            uint256 timestamp_now = block.timestamp;
            if (timestamp_user_action < timestamp_cutoff_release.sub(48 hours)) { // last action was before cut off upgrade
                timestamp_now = timestamp_cutoff_release; // stop accumulation at upgrade time
            } else if (timestamp_user_action < block.timestamp.sub(48 hours)) { // last action was after cut off upgrade but longer than 48h ago
                timestamp_user_action = block.timestamp.sub(48 hours); // accumulate only 48h
            }
            payout = (users[_addr].deposit_amount.mul(BASE_PERCENT).div(PERCENTS_DIVIDER))
                    .mul(timestamp_now.sub(timestamp_user_action))
                    .div(TIME_STEP);
        }
    }

    function maxPayoutOf(uint256 _amount) view external returns(uint256) {
        return _amount.mul(MAX_PAYOUT).div(PERCENTS_DIVIDER);
    }

    function fees(uint256 amount) internal returns(uint256) {
        uint256 project = amount.mul(PROJECT).div(PERCENTS_DIVIDER);
        uint256 marketing = amount.mul(MARKETING).div(PERCENTS_DIVIDER);
        projectManager.transfer(project);
        for (uint256 i = 0; i < marketingWallets.length; i++) {
            uint256 feeShare = amount.mul(marketingBasis[i]).div(FEE_DIVIDER);
            payable(marketingWallets[i]).transfer(feeShare);
        }
        return project.add(marketing);
    }

    function withdrawalTaxPercentage(uint256 to_payout) view external returns(uint256 finalPayout) {
      uint256 contractBalance = address(this).balance;
	  
      if (to_payout < contractBalance.mul(10).div(PERCENTS_DIVIDER)) {           // 0% tax if amount is  <  1% of contract balance
          finalPayout = to_payout; 
      } else if (to_payout >= contractBalance.mul(10).div(PERCENTS_DIVIDER)) {
          finalPayout = to_payout.sub(to_payout.mul(50).div(PERCENTS_DIVIDER));  // 5% tax if amount is >=  1% of contract balance
      } else if (to_payout >= contractBalance.mul(20).div(PERCENTS_DIVIDER)) {
          finalPayout = to_payout.sub(to_payout.mul(100).div(PERCENTS_DIVIDER)); //10% tax if amount is >=  2% of contract balance
      } else if (to_payout >= contractBalance.mul(30).div(PERCENTS_DIVIDER)) {
          finalPayout = to_payout.sub(to_payout.mul(150).div(PERCENTS_DIVIDER)); //15% tax if amount is >=  3% of contract balance
      } else if (to_payout >= contractBalance.mul(40).div(PERCENTS_DIVIDER)) {
          finalPayout = to_payout.sub(to_payout.mul(200).div(PERCENTS_DIVIDER)); //20% tax if amount is >=  4% of contract balance
      } else if (to_payout >= contractBalance.mul(50).div(PERCENTS_DIVIDER)) {
          finalPayout = to_payout.sub(to_payout.mul(250).div(PERCENTS_DIVIDER)); //25% tax if amount is >=  5% of contract balance
      } else if (to_payout >= contractBalance.mul(60).div(PERCENTS_DIVIDER)) {
          finalPayout = to_payout.sub(to_payout.mul(300).div(PERCENTS_DIVIDER)); //30% tax if amount is >=  6% of contract balance
      } else if (to_payout >= contractBalance.mul(70).div(PERCENTS_DIVIDER)) {
          finalPayout = to_payout.sub(to_payout.mul(350).div(PERCENTS_DIVIDER)); //35% tax if amount is >=  7% of contract balance
      } else if (to_payout >= contractBalance.mul(80).div(PERCENTS_DIVIDER)) {
          finalPayout = to_payout.sub(to_payout.mul(400).div(PERCENTS_DIVIDER)); //40% tax if amount is >=  8% of contract balance
      } else if (to_payout >= contractBalance.mul(90).div(PERCENTS_DIVIDER)) {
          finalPayout = to_payout.sub(to_payout.mul(450).div(PERCENTS_DIVIDER)); //45% tax if amount is >=  9% of contract balance
      } else if (to_payout >= contractBalance.mul(100).div(PERCENTS_DIVIDER)) {
          finalPayout = to_payout.sub(to_payout.mul(500).div(PERCENTS_DIVIDER)); //50% tax if amount is >= 10% of contract balance
      }
    }

    function _createTeam(address userAddress, bool is_referral_team) private returns(uint256 teamId) {
        uint8 numberOfExistingTeams = user_teams_counter[userAddress];
        require(numberOfExistingTeams <= MAX_TEAMS_PER_ADDRESS, "Max number of teams reached.");
        teamId = total_teams_created++;
        teams[teamId].id = teamId;
        teams[teamId].created_at = block.timestamp;
        teams[teamId].owner = userAddress;
        teams[teamId].members.push(userAddress);
        teams[teamId].is_referral_team = is_referral_team;
        user_teams[userAddress].push(TeamInfo(teamId, true));
        user_teams_counter[userAddress]++;
    }

    function _addTeamMember(uint256 teamId, address member) private {
        Team storage team = teams[teamId];

        team.members.push(member);
        user_teams[member].push(TeamInfo(teamId, true));
        user_teams_counter[member]++;
    }

    function removeUserNickname() external {
        nicknames[msg.sender] = "";
    }

    function getAddressToNickname(string memory name) public view returns (address) {
        for (uint256 i = 0; i < total_users; i++) {
            string memory nick = nicknames[id2Address[i]];
            if (strcmp(nick, name)) {
                return id2Address[i];
            }
        }

        return address(0);
    }

    function getNicknameToAddress(address _addr) public view returns (string memory nick) {
        return nicknames[_addr];
    }

    /* string helper functions */
    function memcmp(bytes memory a, bytes memory b) internal pure returns(bool) {
        return (a.length == b.length) && (keccak256(a) == keccak256(b));
    }
    function strcmp(string memory a, string memory b) internal pure returns(bool) {
        return memcmp(bytes(a), bytes(b));
    }

    /* Views */
    function userInfo(address _addr) view external returns(address upline, uint256 checkpoint, uint256 deposit_amount, uint256 payouts, uint256 direct_bonus, uint256 match_bonus) {
        return (users[_addr].upline, users[_addr].checkpoint, users[_addr].deposit_amount, users[_addr].payouts, users[_addr].direct_bonus, users[_addr].match_bonus);
    }

    function userInfo2(address _addr) view external returns(uint256 last_airdrop, uint8 teams_counter, TeamInfo[] memory member_of_teams, string memory nickname, uint256 airdrop_bonus, uint8 reinvest_count) {
        return (airdrops[_addr].last_airdrop, user_teams_counter[_addr], user_teams[_addr], nicknames[_addr], airdrops[_addr].airdrop_bonus, user_reinvest_count[_addr]);
    }

    function userDirectTeamsInfo(address _addr) view external returns(uint256 referral_team, bool referral_team_exists, uint256 upline_team, bool upline_team_exists) {
        User memory user = users[_addr];
        return (user_referral_team[_addr].id, user_referral_team[_addr].exists, user_referral_team[user.upline].id, user_referral_team[user.upline].exists);
    }

    function teamInfo(uint256 teamId) view external returns(Team memory _team, string[] memory nicks) {
        Team memory team = teams[teamId];
        nicks = new string[](team.members.length);

        for (uint256 i = 0; i < team.members.length; i++) {
            nicks[i] = nicknames[team.members[i]];
        }
        return (team, nicks);
    }

    function userInfoTotals(address _addr) view external returns(uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure,uint256 total_downline_deposit, uint256 airdrops_total, uint256 airdrops_received) {
        return (users[_addr].referrals, users[_addr].total_direct_deposits, users[_addr].total_payouts, users[_addr].total_structure, users[_addr].total_downline_deposit, airdrops[_addr].airdrops, airdrops[_addr].airdrops_received);
    }

    function HasRoi100(address _addr) view public returns (bool result) {
        result = users[_addr].total_payouts >= users[_addr].total_direct_deposits;
    }

    function contractInfo() view external returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw, uint256 _total_airdrops) {
        return (total_users, total_deposited, total_withdraw, total_airdrops);
    }
		
    /*  Admin only */
    function CHANGE_OWNERSHIP(address value) external {
        require(msg.sender == owner, "Admin use only");
        owner = payable(value);
    }

    function CHANGE_PROJECT_WALLET(address value) external {
        require(msg.sender == owner, "Admin use only");
        projectManager = payable(value);
    }

    function ENABLE_AIRDROP(bool value) external {
        require(msg.sender == owner, "Admin use only");
        airdrop_enabled = value;
    }

	function UPRGADE_130622() external {
        require(msg.sender == owner, "Admin use only");
        ref_bonuses[0] = 10;
        ref_bonuses[1] = 5;
        ref_bonuses[2] = 5;
    }

	function ENABLE_MANDATORY_REINVEST(bool value) external {
        require(msg.sender == owner, "Admin use only");
		MANDATORY_REINVEST_ENABLED = value;																					  
    }

    function SET_STARTED() external {
        require(msg.sender == owner, "Admin use only");
		started = true;
        timestamp_cutoff_release = block.timestamp;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
