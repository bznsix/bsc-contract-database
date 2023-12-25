// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}
contract ERC20 is Context, IERC20 {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overloaded;
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
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
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

/**
 * @title StakingContract
 * @dev This contract represents a staking system with different plans.
 */
contract CUnetwork is ERC20 {
    IERC20 public USDT;

    // Constants defining referral limits and tier values
     address public admin1_address;
    address public admin2_address;
    address public admin3_address; // New admin3 address
    uint public UsdtPool;
    uint public ReferralPool;
    uint256[] public BuyPercent = [500, 300, 200, 100, 100, 100, 50, 50, 50, 50];
    uint256[] public Salepercent = [50, 50, 50, 50, 50, 50, 50, 50, 50, 50];
    uint8 public BuyandSellDivisor = 100;
    uint8 public amountForReffererForBuying = 15;
    uint8 public amountForReffererForSeller = 5;
    uint public TokenPrice = 10000000000000 wei;
    uint256 public maxPurchaseAmount = 1000 * 10**18; // $1,000 in USDT's smallest unit
    uint256 public minPurchaseAmount = 10 * 10**18;   // $10 in USDT's smallest unit
    uint8 public constant MAX_LEVELS = 10;
    uint public constant ACTIVATION_AMOUNT = 10 * 10**18; // 10 USDT in smallest unit
    address public Owner;


    // Structs
    struct BuyDetail {
        address parent;
        uint amount;
        uint currentRate;
        uint256 dateTime;
        address[] Refferrers;
        uint[] amounts;
    }

    struct SellDetail {
        uint amount;
        uint currentRate;
        uint256 dateTime;
        address[] Refferrers;
        uint[] amounts;
    }

    struct WithdrawalDetail {
        uint amount;
        uint currentRate;
        uint256 dateTime;
        address[] Refferrers;
        uint[] amounts;
    }

    struct User_children {
        address[] child;
    }
    struct UserCount{
        uint buyCount;
        uint withdrawCount;
        uint SellCount;
    }

    // Mappings
    mapping(address => uint8) public userLevels;
    mapping(address => bool) public accountActivated;
    mapping(address => User_children) internal referrerToDirectChildren;
    mapping(address => User_children) internal referrerToIndirectChildren;
    mapping(address => address) public parent;
    mapping(address => uint) public RewardAmount;
    mapping(address => uint) public totalInvested;
    mapping(address => uint) public totalWithdrawn;
    mapping(address => uint) public totalAmountSold;
    mapping(address => BuyDetail[]) public userBuys;
    mapping(address => SellDetail[]) public userSells;
    mapping(address => WithdrawalDetail[]) public userWithdrawals;
    mapping(address => UserCount) public UserCounts;


    modifier onlyOwner(){
        require(msg.sender == Owner,"The sender needs to be the owner");
        _;
    }


    // Events
    event TokenSold(address indexed user, uint256 tokenAmount, uint256 usdtAmount);

    // Constructor
    constructor(address _usdt) ERC20("CUN", "CUN")  {
        USDT = IERC20(_usdt);
        Owner = msg.sender;
        userLevels[msg.sender] = MAX_LEVELS;
        accountActivated[msg.sender] = true;
    }



  function BuyTokens(uint amountInUSDT, address _referrer) external {
    // Validate input parameters
    require(amountInUSDT > 0, "The amount cannot be less than 0");
    require(_referrer != address(0), "The address cannot be equal to the zero address");
    require(USDT.balanceOf(msg.sender) >= amountInUSDT, "Insufficient USDT balance");
    require(USDT.allowance(msg.sender, address(this)) >= amountInUSDT, "Insufficient allowance");
    if (_referrer != Owner) {
        require(totalInvested[_referrer] > 0, "The referrer should have some investment");
    }

    // Check purchase limits
    require(amountInUSDT <= maxPurchaseAmount, "Purchase exceeds maximum limit");
    require(amountInUSDT % minPurchaseAmount == 0, "Amount must be a multiple of $10");
    // Check and set referrer
    if (parent[msg.sender] != address(0)) {
        require(parent[msg.sender] == _referrer, "Incorrect referrer");
    } else {
        parent[msg.sender] = _referrer;
    }
    // Transfer USDT from user to contract
    require(USDT.transferFrom(msg.sender, address(this), amountInUSDT), "Transfer failed");



    userBuys[msg.sender].push(BuyDetail({
        parent: _referrer,
        amount: amountInUSDT,
        currentRate: TokenPrice,
        dateTime: block.timestamp,
        Refferrers: new address[](0), // Initialize with empty array
        amounts: new uint[](0)       // Initialize with empty array
    }));
     BuyDetail storage buy = userBuys[msg.sender][userBuys[msg.sender].length-1];
    if(UserCounts[msg.sender].buyCount == 0 )
    {
        setDirectAndIndirectUsers(msg.sender,_referrer);
    }
    
    // Unlock user levels
    if (msg.sender != Owner && msg.sender != admin1_address && msg.sender != admin2_address && msg.sender != admin3_address) {
        uint amount=amountInUSDT;
        if (!accountActivated[msg.sender]) {
                // Account activation
                if (amount >= ACTIVATION_AMOUNT) {
                    accountActivated[msg.sender] = true;
                    amount -= ACTIVATION_AMOUNT;
                } 
            }

        uint8 levelsToUnlock = uint8(amount / (10 * (10**18)));
        userLevels[msg.sender] = (userLevels[msg.sender] + levelsToUnlock > MAX_LEVELS) ? MAX_LEVELS : (userLevels[msg.sender] + levelsToUnlock);

        // Update referrer's levels
        if (_referrer != address(0) && _referrer != msg.sender &&msg.sender != Owner && msg.sender != admin1_address && msg.sender != admin2_address ) {
            uint8 additionalLevelsForReferrer = levelsToUnlock;
            if (userLevels[_referrer] + additionalLevelsForReferrer > MAX_LEVELS) {
                additionalLevelsForReferrer = MAX_LEVELS - userLevels[_referrer];
            }
            userLevels[_referrer] += additionalLevelsForReferrer;
        }
    }

    // Calculate and update pool amounts
    uint LpPoolAmount = (amountInUSDT * 85) / 100;
    UsdtPool += LpPoolAmount;
    // Distribute rewards and admin fees
    distributeRewardsAndFees(amountInUSDT,buy  );
   

    // Mint tokens
    mintTokens(amountInUSDT);

    // Update invested amount
    totalInvested[msg.sender] += amountInUSDT;
    updateTokenPrice();
    UserCounts[msg.sender].buyCount++;

}
function distributeRewardsAndFees(uint amountInUSDT,BuyDetail storage _buy) internal {
    address new_referrel = msg.sender;
    

    for (uint256 i = 0; i < 10; i++) {
        if (new_referrel == Owner) {
            uint RemainingamountDistributed = (BuyPercent[i] * amountInUSDT) / 10000;
           ReferralPool+= RemainingamountDistributed;
        } else {
            address parent_addr = parent[new_referrel];
            uint amountDistributed = (BuyPercent[i] * amountInUSDT) / 10000;
            if(userLevels[parent_addr] >= i+1)
            { 
                RewardAmount[parent_addr] += amountDistributed;
                _buy.Refferrers.push(parent_addr);
                _buy.amounts.push(amountDistributed);
            }
            ReferralPool +=amountDistributed;
            new_referrel = parent_addr;
        }
    }
}
function mintTokens(uint amountInUSDT) internal {
   uint tokenPerUSDT = 1e18 / TokenPrice;
    uint256 amountForTokenUserConversion = (amountInUSDT * 50) / 100;
    uint256 tokensToMintForUser = amountForTokenUserConversion * tokenPerUSDT;
    uint amountForTokenAdmin1Conversion = (amountInUSDT * 4) / 100;
uint amountForTokenAdmin2Conversion = (amountInUSDT * 4) / 100;
uint amountForTokenAdmin3Conversion = (amountInUSDT * 2) / 100;
    uint256 tokensToMintForAdmin1 = amountForTokenAdmin1Conversion * tokenPerUSDT;
    uint256 tokensToMintForAdmin2 = amountForTokenAdmin2Conversion * tokenPerUSDT;
    uint256 tokensToMintForAdmin3 = amountForTokenAdmin3Conversion * tokenPerUSDT;

    _mint(msg.sender, tokensToMintForUser);
   _mint(admin1_address, tokensToMintForAdmin1); // 4%
     _mint(admin2_address, tokensToMintForAdmin2); // 4%
     _mint(admin3_address, tokensToMintForAdmin3); // 2%

   
}


function withdraw(uint256 rewardAmount) external {
    require(rewardAmount > 0, "The reward amount should be greater than 0");
    require(RewardAmount[msg.sender] >= rewardAmount, "Insufficient reward amount");
    require(ReferralPool >= rewardAmount,"Not enough tokens in refferel pool");
    if (msg.sender != admin1_address && msg.sender != admin2_address && msg.sender != admin3_address) {
        uint256 withdrawLimit = 5 * totalInvested[msg.sender] - totalWithdrawn[msg.sender];
        require(rewardAmount <= withdrawLimit, "Withdrawal exceeds limit");
    }
     userWithdrawals[msg.sender].push(WithdrawalDetail({
        amount: rewardAmount,
        currentRate: TokenPrice,
        dateTime: block.timestamp,
        Refferrers: new address[](0), // Initialize with empty array
        amounts: new uint[](0)       // Initialize with empty array
    }));

     WithdrawalDetail storage withdrawal = userWithdrawals[msg.sender][userWithdrawals[msg.sender].length-1];
    // userWithdrawals[msg.sender].push(withdrawal);
     uint256 amountForLP = (rewardAmount * 10) / 100;
    uint256 amountForAdmin1 = (rewardAmount * 2) / 100;
    uint256 amountForAdmin2 = (rewardAmount * 2) / 100;
    uint256 amountForAdmin3 = (rewardAmount * 1) / 100;
    uint256 amountForReferer = (rewardAmount * 5) / 100;
     UsdtPool += amountForLP;
      
    USDT.transfer(admin1_address, amountForAdmin1);
    USDT.transfer(admin2_address, amountForAdmin2);
     USDT.transfer(admin3_address, amountForAdmin3);
    distributeToReferrer(rewardAmount,withdrawal);
    //calculate the user share 
    uint256 amountForUser = rewardAmount - (amountForLP + (amountForAdmin1+amountForAdmin2+amountForAdmin3) + amountForReferer);
    ReferralPool -= amountForUser;
    transferToUser(amountForUser);

     RewardAmount[msg.sender] -= rewardAmount;
    totalWithdrawn[msg.sender] += rewardAmount;
    updateTokenPrice();
    UserCounts[msg.sender].withdrawCount++;
}


function transferToUser(uint256 amountForUser) internal {
    USDT.transfer(msg.sender, amountForUser);
}

function distributeToReferrer(uint256 rewardAmount,WithdrawalDetail storage _withdraw) internal {
    address new_referrel = msg.sender;
    

    for (uint256 i = 0; i < 10; i++) {
        if (new_referrel == Owner) {
            uint RemainingdistributionAmount= (Salepercent[i] * rewardAmount) / 10000;
             ReferralPool +=RemainingdistributionAmount;

        } else {
            address parent_addr = parent[new_referrel];
            uint distributionAmount = (Salepercent[i] * rewardAmount) / 10000;
            if(userLevels[parent_addr] >= i+1)
            {
                RewardAmount[parent_addr] += distributionAmount;
                _withdraw.Refferrers.push(parent_addr);
                _withdraw.amounts.push(distributionAmount);
            }
             ReferralPool +=distributionAmount;
            new_referrel = parent_addr; 
        }
    }
}






function sellTokens(uint256 tokenAmount) external {
    require(tokenAmount > 0, "Amount must be greater than 0");
    require(balanceOf(msg.sender) >= tokenAmount, "Insufficient token balance");

    uint usdtAmount = (tokenAmount * TokenPrice) / (1e18);
    require(usdtAmount <= maxPurchaseAmount, "Purchase exceeds maximum limit");
    if (msg.sender != admin1_address && msg.sender != admin2_address && msg.sender != Owner && msg.sender != admin3_address) {
        uint256 sellingLimit = 2 * totalInvested[msg.sender];
        require(usdtAmount <= sellingLimit, "Selling amount exceeds limit");
    }

userSells[msg.sender].push(SellDetail({
        amount: usdtAmount,
        currentRate: TokenPrice,
        dateTime: block.timestamp,
        Refferrers: new address[](0), // Initialize with empty array
        amounts: new uint[](0)       // Initialize with empty array
    }));

    // WithdrawalDetail storage withdrawal = userWithdrawals[msg.sender][userWithdrawals[msg.sender].length-1];
    // Record sell details
     SellDetail storage seller = userSells[msg.sender][userSells[msg.sender].length-1];

    // Perform the sell operation
    performSell(usdtAmount, tokenAmount);

    // Distribute rewards and update total amount sold
    distributeSellRewards(usdtAmount,seller);
     uint256 amountForLP = (usdtAmount * 10) / 100;
    uint256 amountForAdmin1 = (usdtAmount * 2) / 100;
    uint256 amountForAdmin2 = (usdtAmount * 2) / 100;
    uint256 amountForAdmin3 = (usdtAmount * 1) / 100;
    uint256 amountForReferer = (usdtAmount * 5) / 100;
    UsdtPool += amountForLP;
    //Distribute 50% to the Admin
   
    USDT.transfer(admin1_address, amountForAdmin1);
    USDT.transfer(admin2_address, amountForAdmin2);
    USDT.transfer(admin3_address, amountForAdmin3);
    // Transfer USDT from contract to user
     uint256 amountForCharges = amountForLP + (amountForAdmin1+amountForAdmin2+amountForAdmin3) + amountForReferer;
    uint256 amountAfterCharge = usdtAmount - amountForCharges;
    USDT.transfer(msg.sender, amountAfterCharge);
    totalAmountSold[msg.sender] += usdtAmount;
    
    // Update token price
    updateTokenPrice();
    UserCounts[msg.sender].SellCount++;
}



function performSell(uint usdtAmount, uint256 tokenAmount) internal {
    UsdtPool -= usdtAmount;
    _burn(msg.sender, tokenAmount);
}



function distributeSellRewards(uint usdtAmount,SellDetail storage sell) internal {
 address new_referrel = msg.sender;

    for (uint256 i = 0; i < 10; i++) {
        if (new_referrel == Owner) {
            uint RemainingdistributeAmount= (Salepercent[i] * usdtAmount) / 10000;
             ReferralPool +=RemainingdistributeAmount;
        } else {
            address parent_addr = parent[new_referrel];
            uint distributeAmount = (Salepercent[i] * usdtAmount) / 10000;
            if(userLevels[parent_addr] >= i+1)
            {
                RewardAmount[parent_addr] += distributeAmount;
                sell.Refferrers.push(parent_addr);
                sell.amounts.push(distributeAmount);
            }
            ReferralPool +=distributeAmount;
            new_referrel = parent_addr; 
        }
    }
}


function updateTokenPrice() internal {
    TokenPrice = (UsdtPool * (1e18)) / totalSupply();
}

function setAdminaddresses(address _admin1,address _admin2,address _admin3)external onlyOwner()
{
     require(_admin1 != address(0), "Admin1 address cannot be zero");
        require(_admin2 != address(0), "Admin2 address cannot be zero");
        require(_admin3 != address(0), "Admin3 address cannot be zero");

        admin1_address = _admin1;
        admin2_address = _admin2;
        admin3_address = _admin3;

        // Unlock all levels for the new admins
        userLevels[_admin1] = MAX_LEVELS;
        userLevels[_admin2] = MAX_LEVELS;
        userLevels[_admin3] = MAX_LEVELS; // For admin3
        accountActivated[_admin1] = true;
        accountActivated[_admin2] = true;
        accountActivated[_admin3] = true; // For admin3

}

function setDirectAndIndirectUsers(address _user, address _referee) internal {
        address DirectReferee = _referee;
      
        referrerToDirectChildren[DirectReferee].child.push(_user);
        setIndirectUsersRecursive(_user, _referee);
    }
    function setIndirectUsersRecursive(address _user, address _referee) internal {
    if (_referee != Owner) {
        address presentReferee = parent[_referee];
        referrerToIndirectChildren[presentReferee].child.push(_user);
        setIndirectUsersRecursive(_user, presentReferee);
    }
}

function getAvailableRewards(address user) external view returns (uint256) {
    return RewardAmount[user];
}


function getRewardsWithdrawn(address user) external view returns (uint256) {
    return totalWithdrawn[user];
}
function getRewardLimit(address user) external view returns (uint256) {
    // Assuming the reward limit is 5 times the total invested amount
    return 5 * totalInvested[user] - totalWithdrawn[user];
}
function getSellingLimit(address user) external view returns (uint256) {

    return 2 * totalInvested[user] - totalAmountSold[user];
}
function getUsdtBalanceInPool() external view returns (uint256) {
    return USDT.balanceOf(address(this));
}
function getTokensBalanceInPool() external view returns (uint256) {
    return balanceOf(address(this));
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
    
      function getUserLevels(address user) external view returns (uint8) {
        return userLevels[user];
    }
    function transferOwnership(address newOwner) public  onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
         Owner= newOwner;

        // Set max levels and activate account for the new owner
        userLevels[newOwner] = MAX_LEVELS;
        accountActivated[newOwner] = true;
        
    }

}
