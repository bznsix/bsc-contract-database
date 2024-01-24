// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
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
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
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
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
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
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
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
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
/**

 * @title StakingContract

 * @dev This contract represents a staking system with different plans.

 */

contract Staking {

    address public owner; // The address of the contract owner

    ERC20 public usdtToken; // USDT token address

    ERC20 public MJCTToken; // MGCT token address

    address public adminWallet; // Admin wallet address

    address public proxyAddress2;




    // Constants defining referral limits and tier values

    uint256  immutable maxRefferalLimit = 10;

    uint256  constant FiftyUSD = 50*(10**18);

    uint256  constant HundreadUSD = 100*(10**18);

    uint256  constant TwoHundreadUSD = 200*(10**18);

    uint256  constant FiveHundreadUSD = 500*(10**18);

    uint256  constant ThousandUSD = 1000*(10**18);

    address public fees_address;

    uint256[] RewardPercentage = [50, 20, 10, 5, 5, 4, 3, 2, 1];

    uint  amountForoRefferer=85;

    uint public purchaseFee = 0 ether;  

    uint  amountForRewardUser=15;

    uint  gasfee=3000000000000000 wei;




   




    // Struct to store user staking information

    struct UserBuy {

        uint256 tier;

        uint256 stakedAmount; // Amount of tokens staked

        uint256 stakingEndTime; // Time when staking ends

        uint256 StartDate;

        address referrer; // Size of the staking team

    }




    //Struct to Store Rewards

    struct Rewards {

        uint256 totalrewards;

    }

    struct User_children {

        address[] child;

    }//children of certain users 




    // Mapping to store user data using their address

    mapping(address => UserBuy[]) public userBuys;




    //total invested amount

    mapping (address => uint)public  totalInvestedAmount;

    //total Staked Amount

    mapping(address=>uint)public  totalStakedAmount;




    mapping(address => uint256) public userCount; // Count of stakes per user




    mapping(address=>address)public Parent;




    mapping(address => uint256) public userRewards;




    mapping (address => uint256) public  adminRewards;




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







    mapping(address => mapping (uint=>uint))PlanCount;







    mapping(address =>mapping (uint=>bool))planUnlocked;




    mapping(address=>mapping(uint=>uint))YearlyRewardForUser;




    mapping(address=>mapping(uint=>bool))claimedYearlyReward;

    mapping(uint256 => bool) public tierState;




     







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

    event TokenBought(address indexed buyer, uint256 tier ,address _refferer);




    event DirectEntry(address indexed buyer, uint256 amount);

        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev Modifier to restrict function access to the contract owner only.

     */

    modifier onlyOwner() {

        require(msg.sender == owner, "Only the owner can perform this action");

        _;

    }




     modifier onlyAdmin() {

    require(msg.sender == adminWallet, "Only admin can perform this action");

    _;

}

    constructor(address _usdtTokenAddress, address _MJCTTokenAddress, address _adminWallet,address _feeAddress,address _proxyAddress2) {

        usdtToken = ERC20(_usdtTokenAddress);

        owner = msg.sender;

        MJCTToken = ERC20(_MJCTTokenAddress);

        adminWallet = _adminWallet;

        fees_address = _feeAddress;

        proxyAddress2=_proxyAddress2;

        planUnlocked[msg.sender][FiftyUSD]=true;

        planUnlocked[msg.sender][HundreadUSD] =true;

        planUnlocked[msg.sender][TwoHundreadUSD]=true;

        planUnlocked[msg.sender][FiveHundreadUSD]=true;

        planUnlocked[msg.sender][ThousandUSD]=true;

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

        UserBuy storage _userbuy = userBuys[_referrer][userCount[msg.sender]-1];//if he not the owner then check the subscrition he was 

        return (_userbuy.tier);

    }




    

    function buyTokens(

    address _referrer, // Referrer address

    uint256 _tier, // Tier amount

    uint256 _conversionRate

) external payable {

    // Check for valid tier

    require(

        _tier == FiftyUSD ||

        _tier == HundreadUSD ||

        _tier == TwoHundreadUSD ||

        _tier == FiveHundreadUSD ||

        _tier == ThousandUSD,

        "Invalid tier value"

    );

     // Ensure a valid referrer is provided

    require(_referrer != address(0), "Invalid referrer address");




    // Ensure the plan hasn't been previously unlocked

    require(planUnlocked[msg.sender][_tier] == false, "Plan already purchased");




    // Check if the buyer has purchased all lower-tier plans

    require(hasPurchasedLowerTiers(msg.sender, _tier), "Lower-tier plans not purchased");







    // Increment user's count of purchases

    userCount[msg.sender]++;




    // Set direct and indirect users

    setDirectAndIndirectUsers(msg.sender, _referrer);

    // Set the levels for users

    setLevelUsers(msg.sender, _referrer);

     // Increment plan count for the referrer

    PlanCount[_referrer][_tier] += 1;




    // Unlock the plan for the user

    planUnlocked[msg.sender][_tier] = true;




    // Set the parent referrer

    Parent[msg.sender] = _referrer;




    // Adjust price and rewards based on tier state

    uint256 actualPayment = _tier;




    bool isFullPrice = true;

     if (tierState[_tier]) {

        actualPayment = 1 ether; // Adjusted price if tier state is true

        isFullPrice = false; // Flag to indicate reduced pricing

    }




    if(!isFullPrice)

    {
        require(msg.value >= gasfee,"The gasfee you need to pay");
        // Check if the contract has enough tokens and user has enough allowance

        require(usdtToken.balanceOf(msg.sender) >= (actualPayment+ purchaseFee), "Insufficient USDT tokens");

        require(usdtToken.allowance(msg.sender, address(this)) >= (actualPayment+purchaseFee), "Insufficient allowance");


        // Transfer USDT tokens to the contract

        require(usdtToken.transferFrom(msg.sender, address(this), (actualPayment+ purchaseFee)), "Token transfer failed");

        require(usdtToken.transfer(proxyAddress2, (actualPayment+purchaseFee)), "Transfer to admin wallet failed");

        // Transfer BNB fee to the fee address

        payable (proxyAddress2).transfer(gasfee);

    }

    else{

                    // Update total invested amount

            totalInvestedAmount[msg.sender] += _tier;


            require(msg.value >= gasfee,"The gasfee you need to pay");

            // Check if the contract has enough tokens

            require(usdtToken.balanceOf(msg.sender) >= (_tier + purchaseFee), "Insufficient USDT tokens");

            require(usdtToken.allowance(msg.sender, address(this)) >= (_tier + purchaseFee), "Insufficient allowance");




            // Transfer USDT tokens to the contract

            require(usdtToken.transferFrom(msg.sender, address(this), (_tier + purchaseFee)), "Token transfer failed");

            // Transfer purchase fee to the fee address

            require(usdtToken.transfer(fees_address, purchaseFee), "Fee transfer failed");

            // Transfer BNB fee to the fee address

            payable (proxyAddress2).transfer(gasfee);

            // Calculate reward distribution

            uint EightyFivePercentOfAmount = (_tier * amountForoRefferer) / 100;




            uint fifteenPercentOfAmount = (_tier * amountForRewardUser) / 100;




            require((EightyFivePercentOfAmount + fifteenPercentOfAmount) == _tier, "Incorrect distribution");




            // Calculate reward token amount

            uint256 rewardTokenAmount = (fifteenPercentOfAmount * _conversionRate)/(1e18);




            require(MJCTToken.balanceOf(address(this)) >= rewardTokenAmount, "Insufficient MGCT tokens");

            YearlyRewardForUser[msg.sender][_tier] = rewardTokenAmount;

            totalStakedAmount[msg.sender] += rewardTokenAmount;




            // Transfer 15% to admin wallet

            usdtToken.transfer(adminWallet, fifteenPercentOfAmount);




            // Record user's purchase

            UserBuy memory _newBuy = UserBuy({

                tier: _tier,

                stakedAmount: rewardTokenAmount,

                stakingEndTime: block.timestamp + 365 days,

                StartDate: block.timestamp,

                referrer: _referrer

            });

            userBuys[msg.sender].push(_newBuy);




            // Distribute referral rewards

            distributeReferralRewards(msg.sender, _tier, EightyFivePercentOfAmount);

    }

    







    // Emit event

    emit TokenBought(msg.sender, _tier, _referrer);

}

function distributeReferralRewards(address buyer, uint256 _tier, uint256 EightyFivePercentOfAmount) internal {

    address currentReferrer = buyer;

    uint256 adminWalletRewards = 0;

    for (uint256 level = 0; level < 9; level++) {

        




        // If reached the owner or invalid referrer, allocate remaining rewards to admin wallet

        if (currentReferrer == owner || currentReferrer == address(0)) {

            adminWalletRewards += calculateRewardAmount(EightyFivePercentOfAmount, level);

        }

        else

        {

            // Move to the next referrer in the chain

            address PresentRef = Parent[currentReferrer];

            // Check if the referrer or any of its parents up to the owner are eligible for the reward

            address eligibleReferrer = findEligibleReferrer(PresentRef, _tier,1);

            uint256 rewardAmount = calculateRewardAmount(EightyFivePercentOfAmount, level);

            if (eligibleReferrer != address(0)) {

                // Distribute the reward to the eligible referrer

                userRewards[eligibleReferrer] += rewardAmount;

                require(usdtToken.transfer(eligibleReferrer, rewardAmount), "Referral reward transfer failed");

                maxTierReferralCounts[eligibleReferrer]++;

            } else {

                // If no eligible referrer is found up the chain, allocate to admin wallet

                

                adminWalletRewards += rewardAmount;

            }

            currentReferrer=PresentRef;

        }

        

    }




    // Transfer accumulated rewards to the admin wallet

    if (adminWalletRewards > 0) {

        usdtToken.transfer(adminWallet, adminWalletRewards);




        adminRewards[adminWallet] += adminWalletRewards;

    }

}




function calculateRewardAmount(uint256 EightyFivePercentOfAmount, uint256 level) internal view returns (uint256) {

   

    return (RewardPercentage[level] * EightyFivePercentOfAmount) / 100; 

}




    function findEligibleReferrer(address referrer, uint256 _tier, uint256 depth) internal view returns (address _refferer) {

    if (depth >= 9) {

        // Limit recursion to 10 levels

        return address(0);

    }




    if (referrer == owner) {

        // The owner is always eligible

        return referrer;

    } else if (maxTierReferralCounts[referrer] > maxRefferalLimit || !planUnlocked[referrer][_tier]) {

        // If the referrer has exceeded the limit, move up the chain

        address cur_parent = Parent[referrer];

        return findEligibleReferrer(cur_parent, _tier, depth + 1);

    } 

    else {

        return referrer;




    }

}







    function showAllParent(

        address user

    ) external view returns (address[] memory) {

        address[] memory parent = new address[](9); 

        address new_referrel = user;

        for (uint256 i = 0; i < 9; i++) {

            address parent_addr = Parent[new_referrel];

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










    function setDirectAndIndirectUsers(address _user, address _referee) internal {

        address DirectReferee = _referee;

      

        referrerToDirectChildren[DirectReferee].child.push(_user);

        setIndirectUsersRecursive(_user, _referee);

    }

    function setIndirectUsersRecursive(address _user, address _referee) internal {

    if (_referee != owner) {

        address presentReferee = Parent[_referee];

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

                presentReferee = Parent[presentReferee];

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




    //this is to set the purchase the fee

     function setPurchaseFee(uint newFee) external onlyOwner {

        purchaseFee = newFee;

    }







    function withdrawReward(uint256 _tier) external {

        // Check if one year has passed since the reward was assigned

        require(block.timestamp >= userBuys[msg.sender][_tier].stakingEndTime, "Reward can only be withdrawn after 1 year");




        require(!claimedYearlyReward[msg.sender][_tier],"Not claim any yearly Reward");

        // Double the reward amount

        uint256 rewardToWithdraw = YearlyRewardForUser[msg.sender][_tier] * 2;




        // Check if the contract has enough tokens

        require(MJCTToken.balanceOf(address(this)) >= rewardToWithdraw, "Not enough tokens in the contract for withdrawal");




        // Transfer the reward to the user

        require(MJCTToken.transfer(msg.sender, rewardToWithdraw), "Reward transfer failed");




        // Optionally, you can reset the reward for the user after withdrawal

        YearlyRewardForUser[msg.sender][_tier] = 0;




        claimedYearlyReward[msg.sender][_tier]=true;

   }







   function hasPurchasedLowerTiers(address _user, uint256 _tier) internal view returns (bool) {

    if (_tier > FiftyUSD && !planUnlocked[_user][FiftyUSD]) return false;

    if (_tier > HundreadUSD && !planUnlocked[_user][HundreadUSD]) return false;

    if (_tier > TwoHundreadUSD && !planUnlocked[_user][TwoHundreadUSD]) return false;

    if (_tier > FiveHundreadUSD && !planUnlocked[_user][FiveHundreadUSD]) return false;

    return true;

    }




   







    function changeFiftyState() external onlyOwner {

        tierState[FiftyUSD] = !tierState[FiftyUSD];

    }




    function changeHundredState() external onlyOwner {

        tierState[HundreadUSD] = !tierState[HundreadUSD];

    }




    function changeTwoHundredState() external onlyOwner {

        tierState[TwoHundreadUSD] = !tierState[TwoHundreadUSD];

    }




    function changeFiveHundredState() external onlyOwner {

        tierState[FiveHundreadUSD] = !tierState[FiveHundreadUSD];

    }




    function changeThousandState() external onlyOwner

    {

        tierState[ThousandUSD] = !tierState[ThousandUSD];

    }


    function transferOwnership(address newOwner) external  onlyOwner {
        require(newOwner!=address(0),"new Owner cannot be equal to address zero");
        address oldOwner = owner;
        owner = newOwner;
        planUnlocked[newOwner][FiftyUSD]=true;

        planUnlocked[newOwner][HundreadUSD] =true;

        planUnlocked[newOwner][TwoHundreadUSD]=true;

        planUnlocked[newOwner][FiveHundreadUSD]=true;

        planUnlocked[newOwner][ThousandUSD]=true;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

}