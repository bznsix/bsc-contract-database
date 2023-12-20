// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
/**
 * @title StakingContract
 * @dev This contract represents a staking system with different plans.
 */
contract Staking {
    address immutable owner; // The address of the contract owner

    ERC20 immutable token; // Address of the ERC20 token being staked

    // Constants defining referral limits and tier values
    uint256 public constant maxRefferalLimit = 10;
    uint256 public constant ZeroUSD = 0;
    uint256 public constant FiftyUSD = 50;
    uint256 public constant HundreadUSD = 100;
    uint256 public constant TwoHundreadUSD = 200;
    uint256 public constant FiveHundreadUSD = 500;
    uint256 public constant ThousandUSD = 1000;
    address public fees_address;
    uint public  fee_percent;
    uint public DirectStakingPercent=15;
    uint256 public totalStaked;
    uint256[] RewardPercentage = [50, 20, 10, 5, 5, 4, 3, 2, 1];
      uint public amountForoRefferer=85;

    uint public amountForRewardUser=15;

    uint public PercentForYearDist=50;

    // Struct to store user staking information
    struct UserStaking {
        uint256 stakedAmount; // Amount of tokens staked
        uint256 stakingEndTime; // Time when staking ends
        uint256 StartDate;
        uint256 teamSize; // Size of the staking team
    }
    
    struct UserBuy {
        address referrer;
        uint amount;
        uint _tier;
        uint timestamp;
    }
    // Struct to store subscription details
    struct Subscription {
        uint256 tokenAmount;//How much token amount you have invested
        address parent;//who is the referer
        uint256 tier;//which tier who have choosen
    }

    // Struct to store Stake_subscription details
    struct StakeSubscription {
        uint256 tokenAmount;
        address parent;
    }

    //Struct to Store Rewards
    struct Rewards {
        uint256 totalrewards;
    }
    struct User_children {
        address[] child;
    }//children of certain users 

    // Mapping to store user data using their address
    mapping(address => UserStaking[]) public userStaking;
    //mapping for the UserBuys
    mapping(address=>UserBuy[]) public userBuys;
    //total staked amount
    mapping (address => uint)public  totalInvestedAmount;

    mapping(address => uint256) public userCount; // Count of stakes per user

    // Mapping to store user subscription data using their address
    mapping(address => Subscription) public userSubscription;

    // Mapping to store user subscription data using their address
    mapping(address => StakeSubscription) public stakeSubscription;

    mapping(address => Rewards) public userRewards;

    // Mapping to track whether an address has been referred by the owner
    mapping(address => bool) public ownerReferred;

    // Mapping to store children for each referrer
    mapping(address => User_children) private referrerToDirectChildren;

    //mapping to store  indirect children for each referrer
    mapping (address=> User_children) private  referrerToIndirectChildren;


    //mapping For level1 Users to referrer
   mapping(uint => mapping(address => address[])) public LevelUsers;

   //mapping For Level Users Count
   mapping(uint =>mapping(address=>uint))public  LevelCountUsers;

    // Mapping to track the number of referrals per tier for each referrer
    mapping(address => uint256) public maxTierReferralCounts;

    mapping(address => uint256) public rewardAmount;

    mapping(address => mapping (uint=>uint))PlanCount;


    mapping(address =>mapping (uint=>bool))planUnlocked;

    mapping(address=>mapping(uint=>uint))YearlyRewardForUser;

    mapping(address=>mapping(uint=>bool))claimedYearlyReward;

    // Event to log staking action
    event TokensStaked(
        address indexed user,
        uint256 amount,
        uint256 stakingEndTime
    );//event for tokens staked

    // Event to log unstaking action
    event TokensUnstaked(address indexed user, uint256 amount);

    // Event to log referred from referrer
    event UserReferred(address indexed user, address indexed referrer);

    // Event to log buy token with tier
    event TokenBought(address indexed buyer, uint256 amount, uint256 tier);

    event DirectEntry(address indexed buyer, uint256 amount);

    /**
     * @dev Modifier to restrict function access to the contract owner only.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }
    constructor(address _tokenAddress) {
        token = ERC20(_tokenAddress);
        owner = msg.sender;
        fees_address = 0x7597C6c5e04E159f669B85aFDf67979Da5047ef1;
    }

    /**
     *@dev Parent Address for a given User
     */
    function getParent(address user) public view returns (address) {
        Subscription memory parent = userSubscription[user];

        return parent.parent;
    }

    /**
     * @dev Stake tokens for a given plan, staking duration, and team size.
     * @param tokenAmount_ amount of tokens to stake.
     * @param stakingDuration_ The duration of staking in days.
     * @param teamSize_ The size of the staking team.
     */
    function stakeTokens(
        uint256 tokenAmount_,
        uint256 stakingDuration_,
        uint256 teamSize_
    ) public {
        uint256 requiredAmount = tokenAmount_ * (10**(token.decimals()));
        require(
            stakingDuration_ == 90 ||
                stakingDuration_ == 180 ||
                stakingDuration_ == 365,
            "Invalid staking duration"
        );
        uint256 stakingEndTime = block.timestamp + stakingDuration_ * 1 days;
        uint256 StartDate = block.timestamp;
        UserStaking memory _newStake = UserStaking({
            stakedAmount: requiredAmount,
            stakingEndTime: stakingEndTime,
            StartDate: StartDate,
            teamSize: teamSize_ 
        });
        userStaking[msg.sender].push(_newStake);
        userCount[msg.sender]++;
        totalInvestedAmount[msg.sender] +=requiredAmount;
       
        totalStaked += requiredAmount;
        token.transferFrom(msg.sender, address(this), requiredAmount);
      
        emit TokensStaked(msg.sender, requiredAmount, stakingEndTime);
    }


    function TotalTokenStaked(
        address userAddress
    ) public view returns (uint256) {
        uint256 totalStakedByUser = 0;

        for (uint256 id = 0; id <= userCount[userAddress]; id++) {
            UserStaking memory user = userStaking[userAddress][id];
            totalStakedByUser += user.stakedAmount ;
        }

        return totalStakedByUser;
    }

    /**
     * @dev Check if a user is referred by a given referrer.
     * @param _referrer The address of the referrer.
     * @return Whether the user is referred and the tier of the referrer.
     */
    function isReferred(address _referrer) public view returns (uint256) {
        if (_referrer == owner) {
            return (ThousandUSD);
        }

        Subscription memory referrerSubscription = userSubscription[_referrer];//if he not the owner then check the subscrition he was 

        if (referrerSubscription.tokenAmount == 0) {
            return (ZeroUSD);
        }

        return (referrerSubscription.tier);
    }

    /**
     * @dev Direct stake tokens and associate them with a referrer.
     * @param _referreladdress The address of the referrel.
     * @param _tokenAmount The amount of token.

     */
    function DirectStakeJoining(
        address _referreladdress,
        uint256 _tokenAmount
    ) external {
        StakeSubscription memory subscription = stakeSubscription[msg.sender];
        require(
            subscription.tokenAmount == 0,
            "User already has a subscription"
        );
        uint256 amount = _tokenAmount * (10**(token.decimals()));
        subscription.tokenAmount = amount;
        subscription.parent = _referreladdress;
        totalInvestedAmount[msg.sender] +=amount;

        require(
            token.balanceOf(msg.sender) >= (amount),
            "Not enough tokens in the contract"
        );
        require(
            token.allowance(msg.sender, address(this)) >= (amount),
            "Not enough allowance"
        );
        token.transferFrom(msg.sender, address(this), amount);
       
        uint  percenttorefferer=((amount*DirectStakingPercent)/100);
        token.transfer(_referreladdress, percenttorefferer);

        emit DirectEntry(msg.sender, _tokenAmount);
    }

    /**
     * @dev Buy tokens and associate them with a referrer.
     * @param _referrer The address of the referrer.
     * @param _tokenAmount The amount of token.
     * @param _tier The chosen referral tier.
     */
    function buyTokens(
        address _referrer,//given the refferer address
        uint256 _tokenAmount,//given the tokenAmount which will include fee also
        uint256 _tier//given the tier amount
    ) external {
        require(
            _tier == ZeroUSD ||
                _tier == FiftyUSD ||
                _tier == HundreadUSD ||
                _tier == TwoHundreadUSD ||
                _tier == FiveHundreadUSD ||
                _tier == ThousandUSD,
            "Invalid tier value"
        );
        require(planUnlocked[msg.sender][_tier]== false,"the planUnlocked Should be false");
        uint256 amount = _tokenAmount * (10**(token.decimals()));
        uint256 fee = ((_tokenAmount*(fee_percent))/100);
        require(_referrer != address(0), "Invalid referrer address");
        if (_referrer == owner) {
            Subscription memory subscription = Subscription(
                amount,
                _referrer,
                _tier
            );
            
            userSubscription[msg.sender] = subscription;
        }


        uint256 userTier = isReferred(_referrer);
        bool isReffererRewardEnabled;
        if (_tier == userTier) {

            if( maxTierReferralCounts[_referrer] > maxRefferalLimit){
                isReffererRewardEnabled =false;
            }  
            else {
                isReffererRewardEnabled=true;
                maxTierReferralCounts[_referrer]++;
            } 
            
            Subscription memory subscription = Subscription(
                amount,
                _referrer,
                _tier
            );//
            userSubscription[msg.sender] = subscription;
            
           
        }
        else {
            isReffererRewardEnabled=true;
            Subscription memory subscription = Subscription(
                amount,
                _referrer,
                _tier
            );
            userSubscription[msg.sender] = subscription;
            
        }


        //Set the Direct and Indirect Users
        setDirectAndIndirectUsers(msg.sender, _referrer);
        //Set the levels for the users
        setLevelUsers(msg.sender, _referrer);
        //Shown the total Invested Amount
        totalInvestedAmount[msg.sender] += _tokenAmount * (10**(token.decimals()));
        //what is the planCount
        PlanCount[_referrer][_tier] += 1;
        //add to the user Buys
        UserBuy memory _newBuy=UserBuy( {
         referrer:_referrer,
         amount :amount,
         _tier:_tier,
         timestamp:block.timestamp
       });
       userBuys[msg.sender].push(_newBuy);
        //Unlock the Plan
        planUnlocked[msg.sender][_tier]= true;
        
        // Check if the contract has enough tokens to transfer
        require(
            token.balanceOf(msg.sender) >= (amount+fee),
            "Not enough tokens in the contract"
        );


        // Check allowance
        require(
            token.allowance(msg.sender, address(this)) >= (amount+fee),
            "Not enough allowance"
        );

        // Perform the transfer
        require(
            token.transferFrom(msg.sender, address(this), (amount+fee)),
            "Token transfer failed"
        );

        // Transfer fees to fees_address
        require(token.transfer(fees_address, fee), "Fee transfer failed");
        if(isReffererRewardEnabled)
        {
        address new_referrel;
        new_referrel = msg.sender;
       
        uint EightyFivePercentOfAmount=(amount*(amountForoRefferer))/100;
        uint fifteenPercentOfAmount=(amount*(amountForRewardUser))/100;
        require((EightyFivePercentOfAmount+fifteenPercentOfAmount)==amount,"the amount needs to be equally distrinbuted");
        token.transfer(msg.sender, fifteenPercentOfAmount);
        YearlyRewardForUser[msg.sender][_tier]=fifteenPercentOfAmount;

        for (uint256 i = 0; i < 9; i++) {
            if(isReffererRewardEnabled)
            {
                if (new_referrel == owner) {
                
                 break;
                }
            address parent_addr = getParent(new_referrel);
            if(planUnlocked[parent_addr][_tier]==true)
            {
            uint256 reward_amount = (RewardPercentage[i] * EightyFivePercentOfAmount) / 100;
            userRewards[parent_addr] = Rewards({totalrewards :(userRewards[parent_addr].totalrewards+reward_amount)});
           
            require(
                token.balanceOf(address(this)) >= reward_amount,
                "Not enough tokens in the contract"
            );

            require(
                token.transfer(parent_addr, reward_amount),
                "Reward transfer failed"
            );
            }

            new_referrel = parent_addr;
            }
            
        }
       }
        emit TokenBought(msg.sender, amount, _tier);

    }
    // function ClaimYearlyReward(uint _tier)external {
    //         require(_tier !=0,"the tier should not be zero tier");
    //         require(claimedYearlyReward[msg.sender][_tier]==false,"you have already claimed the reward for this plan");
    //         uint FiftyPercentOfReward=((YearlyRewardForUser[msg.sender][_tier])*PercentForYearDist)/100;
    //         require(token.balanceOf(address(this))>=FiftyPercentOfReward);
    //         claimedYearlyReward[msg.sender][_tier] =true;
    //         token.transfer(msg.sender, FiftyPercentOfReward);

    // }
    function showAllParent(
        address user
    ) external view returns (address[] memory) {
        address[] memory parent = new address[](9); 
        address new_referrel = user;
        for (uint256 i = 0; i < 9; i++) {
            address parent_addr = getParent(new_referrel);
            parent[i] = parent_addr;

            if (new_referrel == owner) {
                break;
            } else {
                new_referrel = parent_addr;
            }
        }

        return parent;
    }

    function showAllDirectChild(
        address user
    ) external view returns (address[] memory) {
        address[] memory children = referrerToDirectChildren[user].child;

        return children;
    }

   function showAllInDirectChild(
        address user
    ) external view returns (address[] memory) {
        address[] memory children = referrerToIndirectChildren[user].child;

        return children;
    }


    /*
    */
    function SetFeePercent(uint _feePercent)external onlyOwner{
        require(_feePercent != 0,"the fee percent should not be equal to zero");
        fee_percent= _feePercent;
    }

    function setDirectAndIndirectUsers(address _user, address _referee) internal {
        address DirectReferee = _referee;
      
        referrerToDirectChildren[DirectReferee].child.push(_user);
        setIndirectUsersRecursive(_user, _referee);
    }
    function setIndirectUsersRecursive(address _user, address _referee) internal {
    if (_referee != owner) {
        address presentReferee = getParent(_referee);
        referrerToIndirectChildren[presentReferee].child.push(_user);
        setIndirectUsersRecursive(_user, presentReferee);
    }
}
    function setLevelUsers(address _user, address _referee) internal {
        address presentReferee = _referee;
        
        for (uint i = 1; i <= 9; i++) {
            LevelUsers[i][presentReferee].push(_user);
            LevelCountUsers[i][presentReferee]++;


            if (presentReferee == owner) {
                break;
            } else {
                presentReferee = getParent(presentReferee);
            }
        }
    }

    function getTotalInvestedAmount(address _user)external view returns(uint) {
        require(_user!=address(0),"the user address cannot be equal to zero");
        return totalInvestedAmount[_user];
    }
    //return the plancount
    function getThePlanCount(address _referee,uint _plan)external view returns(uint)
    {
        require(_referee != address(0),"the referee address is not equal to zero");
        return PlanCount[_referee][_plan];
    }
    //get the Unlock Plan details
    function getUnlockPlanDetails(address _user,uint _plan)external view returns(bool)
    {
        require(_user != address(0),"the user address is not equal to zero address");
        return planUnlocked[_user][_plan];
    }
    //get function to get the userBuys
    function getUserBuys(address _user)external view returns(UserBuy[] memory) 
    {
        require(_user != address(0),"the user address is not equal to zero address");
        return userBuys[_user];
    }
    /**
     * @dev Calculate the total rewards received by a user.
     * @param userAddress The address of the user.
     * @return The total rewards received by the user.
     */
    function totalRewardsReceived(
        address userAddress
    ) public view returns (uint256) {
        uint256 totalRewards = 0;
        StakeSubscription memory directStake = stakeSubscription[userAddress];
        totalRewards += userRewards[directStake.parent].totalrewards;
        totalRewards += userRewards[userAddress].totalrewards;
         return totalRewards;
    }
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./extensions/IERC20Metadata.sol";
import {Context} from "../../utils/Context.sol";
import {IERC20Errors} from "../../interfaces/draft-IERC6093.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.0;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import {IERC20} from "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

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
}
