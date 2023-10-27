// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

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
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
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
    function transfer(
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
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
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
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
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
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
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
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
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
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

abstract contract Ownable is Context {
    address private _owner;
    mapping(address => bool) public addressAdmin;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function addAdmin(address _address) external onlyOwner {
        addressAdmin[_address] = true;
    }

    function removeAdmin(address _address) external onlyOwner {
        addressAdmin[_address] = false;
    }

    modifier admin() {
        require(
            addressAdmin[msg.sender] == true || owner() == _msgSender(),
            "You do not have auth to do this"
        );
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    // modifier onlyOwner() {
    //     require(owner() == _msgSender() || addressAdmin[msg.sender] == true, "Ownable: caller is not the owner");
    //     _;
    // }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

contract ONEXToken is ERC20, Ownable {
    uint256 public MAX_SUPPLY = 100000000 * 10 ** 18;
    uint256 public MINT_PRICE = 0.00413 ether; // BNB has the same decimals as Ether
    uint256 public USDT_MINT_PRICE = 1 ether; // BSC USDT has the same decimals as Ether
    uint256 public REFERRAL_REWARD_PERCENT = 1;
    uint256 public MINIMUM_MINT_FOR_REFERRAL = 0 * 10 ** 18;
    uint256 public MIN_MINT = 100 * 10 ** 18;
    uint256 public MAX_MINT = 1000000 * 10 ** 18;
    uint256 public MAX_TOTAL_REWARDS = MAX_SUPPLY / 10; // 10% of MAX_SUPPLY
    uint256 public totalRewards = 0;
    mapping(address => address) public referrers;
    address public paymentTokenAddress =
        0x55d398326f99059fF775485246999027B3197955; // BSC USDT
    bool public isUSDTMintingEnabled = false;
    bool public isMintingEnabled = true;
    uint256 public mintTime;
    uint256 public RESTRICTED_TRANSFER_PERIOD = 30 days;
    struct StakeInfo {
        uint256 amount;
        uint256 stakedAt;
        uint256 claimableAt;
        uint256 unstakeBalance;
    }

    uint256 public STAKING_DIRECTLY_REWARD_PERCENT = 0;
    uint256 public MAX_STAKING_REWARD_PERCENT = 300000;
    uint256 public INCREMENTAL_DAILY_REWARD_PERCENT = 550;
    uint256 public MIN_STAKING = 100 * 10 ** 18;
    uint256 public STAKING_LOCKED_TIME = 7 days;

    mapping(address => StakeInfo) public stakes;
    event UnstakeEvent(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed claimdate
    );
    event StakeEvent(
        address indexed user,
        uint256 indexed amount,
        uint256 indexed stakedate
    );
    event ClaimUnstakeEvent(address indexed user, uint256 indexed amount);
    event RestakeEvent(
        address indexed user,
        uint256 indexed restakedate,
        uint256 indexed amount
    );

    constructor(address _initialOwner , address _firstAdmin) ERC20("OneX Token", "ONEX") {
        mintTime = block.timestamp; // The mintTime is set when the contract is deployed
        transferOwnership(_initialOwner); // Set the owner of the contract to _initialOwner
        addressAdmin[_firstAdmin] = true;
    }

    // The mint function allows a user to mint tokens by paying BNB
    function mint(address _to, uint256 _amount) public payable {
        require(isMintingEnabled, "Minting is disabled");
        require(_amount >= MIN_MINT, "Amount is less than minimum mint");
        require(_amount <= MAX_MINT, "Amount is more than maximum mint");
        require(totalSupply() + _amount <= MAX_SUPPLY, "Exceeds max supply");
        require(
            msg.value == (_amount * MINT_PRICE) / 10 ** 18,
            "BNB value sent is not correct"
        );

        _mint(_to, _amount);
    }

    // The mint function allows a user to mint tokens by paying BNB
    function usdtMint(address _to, uint256 _amount) public payable {
        require(totalSupply() + _amount <= MAX_SUPPLY, "Exceeds max supply");
        require(_amount >= MIN_MINT, "Amount is less than minimum mint");
        require(_amount <= MAX_MINT, "Amount is more than maximum mint");
        uint256 paymentAmount = (_amount * USDT_MINT_PRICE) / 10 ** 18;
        require(
            IERC20(paymentTokenAddress).balanceOf(msg.sender) >= paymentAmount,
            "Insufficient token balance"
        );

        // Transfer the payment amount from the caller to this contract
        IERC20(paymentTokenAddress).transferFrom(
            msg.sender,
            address(this),
            paymentAmount
        );

        _mint(_to, _amount);
    }

    // Referral mint
    function referralMint(
        address _to,
        uint256 _amount,
        address _referrer
    ) external payable {
        require(isMintingEnabled, "Minting is disabled");
        require(_amount >= MIN_MINT, "Amount is less than minimum mint");
        require(_amount <= MAX_MINT, "Amount is more than maximum mint");
        // Create a mapping if there is no referrer yet.
        if (referrers[_to] == address(0) && _to != _referrer) {
            referrers[_to] = _referrer;
        }

        // Mint to the _to address regardless of the referrer status.
        mint(_to, _amount);

        // Get the mapped referrer.
        address mappedReferrer = referrers[_to];

        // If there is a valid referrer, and it meets the minimum mint requirement, reward them.
        if (
            mappedReferrer != address(0) &&
            mappedReferrer != _to &&
            balanceOf(mappedReferrer) >= MINIMUM_MINT_FOR_REFERRAL
        ) {
            StakeInfo storage stakeInfo = stakes[mappedReferrer];
            uint256 reward = (_amount * REFERRAL_REWARD_PERCENT) / 100;
            uint256 referralBalance = balanceOf(mappedReferrer) + stakeInfo.amount + stakeInfo.unstakeBalance;
            if (referralBalance < reward) {
                reward = referralBalance;
            }
            _mint(mappedReferrer, reward);
        }
    }

    // The mint function allows a user to mint tokens by paying USDT
    function usdtReferralMint(
        address _to,
        uint256 _amount,
        address _referrer
    ) public {
        require(totalSupply() + _amount <= MAX_SUPPLY, "Exceeds max supply");
        require(_amount >= MIN_MINT, "Amount is less than minimum mint");
        require(_amount <= MAX_MINT, "Amount is more than maximum mint");
        // Transfer USDT from sender to this contract
        require(
            IERC20(paymentTokenAddress).transferFrom(
                msg.sender,
                address(this),
                (_amount * USDT_MINT_PRICE) / 10 ** 18
            ),
            "USDT transfer failed"
        );

        // Create a mapping if there is no referrer yet.
        if (referrers[_to] == address(0) && _to != _referrer) {
            referrers[_to] = _referrer;
        }

        // Mint to the _to address regardless of the referrer status.
        _mint(_to, _amount);

        // Get the mapped referrer.
        address mappedReferrer = referrers[_to];

        // If there is a valid referrer, and it meets the minimum mint requirement, reward them.
        if (
            mappedReferrer != address(0) &&
            mappedReferrer != _to &&
            balanceOf(mappedReferrer) >= MINIMUM_MINT_FOR_REFERRAL
        ) {
            uint256 reward = (_amount * REFERRAL_REWARD_PERCENT) / 100;
            uint256 referralBalance = balanceOf(mappedReferrer);
            if (referralBalance < reward) {
                reward = referralBalance;
            }
            _mint(mappedReferrer, reward);
        }
    }

    // Allow the contract owner to update the mint price
    function setMintPrice(uint256 _newPrice) external admin {
        MINT_PRICE = _newPrice;
    }

    // Function to increase max supply, can only be called by contract owner
    function addMaxSupply(uint256 _amount) public admin {
        MAX_SUPPLY = MAX_SUPPLY + _amount;
    }

    function editMinMint(uint256 _amount) public admin {
        MIN_MINT = _amount;
    }

    function editMaxMint(uint256 _amount) public admin {
        MAX_MINT = _amount;
    }

    // Function to burn tokens, can be called by any user with a balance
    function burn(uint256 _amount) public {
        require(balanceOf(msg.sender) >= _amount, "Not enough tokens to burn");
        _burn(msg.sender, _amount);
    }

    // Allow the contract owner to update the usdt mint price
    function setUsdtMintPrice(uint256 _newPrice) external admin {
        USDT_MINT_PRICE = _newPrice;
    }

    // Allow the contract owner to update the referral reward percentage
    function setReferralRewardPercent(uint256 _newPercent) external admin {
        REFERRAL_REWARD_PERCENT = _newPercent;
    }

    function setPaymentTokenAddress(
        address _paymentTokenAddress
    ) external admin {
        paymentTokenAddress = _paymentTokenAddress;
    }

    function toggleMinting() external admin {
        isMintingEnabled = !isMintingEnabled;
    }

    function toggleUSDTMinting() external admin {
        isUSDTMintingEnabled = !isUSDTMintingEnabled;
    }

    // Allow the contract owner to update the minimum mint for referral
    function setMinimumMintForReferral(uint256 _newMinimum) external admin {
        MINIMUM_MINT_FOR_REFERRAL = _newMinimum;
    }

    // Allows a user to stake tokens
    function stake(uint256 _amount) external {
        require(balanceOf(msg.sender) >= _amount, "Insufficient balance");
        require(_amount >= MIN_STAKING, "Amount is less than minimum staking");

        StakeInfo storage stakeInfo = stakes[msg.sender];

        // Unstaking the previous staked tokens and staking rewards
        if (stakeInfo.amount > 0) {
            restake();
        }

        _transfer(msg.sender, address(this), _amount);

        stakeInfo.amount += _amount;
        stakeInfo.stakedAt = block.timestamp;
        emit StakeEvent(msg.sender, _amount, block.timestamp);
    }

    //Check the balance of staked tokens and rewards
    function checkStakeBalance(address _user) public view returns (uint256) {
        StakeInfo storage stakeInfo = stakes[_user];
        uint256 stakingDays = (block.timestamp - stakeInfo.stakedAt) / 1 days;
        uint256 stakingRewardPercent = STAKING_DIRECTLY_REWARD_PERCENT +
            INCREMENTAL_DAILY_REWARD_PERCENT *
            stakingDays;
        if (stakingRewardPercent > MAX_STAKING_REWARD_PERCENT) {
            stakingRewardPercent = MAX_STAKING_REWARD_PERCENT;
        }

        uint256 stakingReward = (stakeInfo.amount * stakingRewardPercent) /
            1000000;
        return stakeInfo.amount + stakingReward;
    }

    // Allows a user to unstake tokens and claim rewards
    function unstake() public {
        StakeInfo storage stakeInfo = stakes[msg.sender];
        require(stakeInfo.amount > 0, "No staked tokens");

        // Calculate staking reward
        uint256 stakingDays = (block.timestamp - stakeInfo.stakedAt) / 1 days;
        uint256 stakingRewardPercent = STAKING_DIRECTLY_REWARD_PERCENT +
            INCREMENTAL_DAILY_REWARD_PERCENT *
            stakingDays;
        if (stakingRewardPercent > MAX_STAKING_REWARD_PERCENT) {
            stakingRewardPercent = MAX_STAKING_REWARD_PERCENT;
        }

        uint256 stakingReward = (stakeInfo.amount * stakingRewardPercent) /
            1000000;

        // Check if the total rewards exceed the max limit
        require(
            totalRewards + stakingReward <= MAX_TOTAL_REWARDS,
            "Total rewards limit reached"
        );

        // Update total rewards
        totalRewards += stakingReward;

        // Transfer staked tokens and reward back to the staker
        // _transfer(address(this), msg.sender, stakeInfo.amount + stakingReward);

        // Reset staking info
        stakeInfo.unstakeBalance += stakeInfo.amount + stakingReward;
        stakeInfo.amount = 0;
        stakeInfo.stakedAt = 0;
        stakeInfo.claimableAt = block.timestamp + STAKING_LOCKED_TIME;
        emit UnstakeEvent(
            msg.sender,
            stakeInfo.unstakeBalance,
            stakeInfo.claimableAt
        );
    }

    //Claim unstock tokens
    function claimUnstake() public {
        StakeInfo storage stakeInfo = stakes[msg.sender];
        require(stakeInfo.unstakeBalance > 0, "No unstaked tokens");
        require(
            stakeInfo.claimableAt <= block.timestamp,
            "Unstake tokens are locked and only claimable after 7 days"
        );

        // Transfer unstaked tokens back to the staker
        _transfer(address(this), msg.sender, stakeInfo.unstakeBalance);
        emit ClaimUnstakeEvent(msg.sender, stakeInfo.unstakeBalance);
        // Reset unstake balance
        stakeInfo.claimableAt = 0;
        stakeInfo.unstakeBalance = 0;
    }

    //Restake unstaked tokens
    function restake() public {
        StakeInfo storage stakeInfo = stakes[msg.sender];
        require(stakeInfo.amount > 0, "No staked tokens");

        uint256 totalUserBalance = checkStakeBalance(msg.sender);

        stakeInfo.amount = totalUserBalance;
        stakeInfo.stakedAt = block.timestamp;
        emit RestakeEvent(msg.sender, block.timestamp, totalUserBalance);
    }

    // Setters for owner to adjust staking parameters
    function setStakingDirectlyRewardPercent(
        uint256 _newPercent
    ) external admin {
        STAKING_DIRECTLY_REWARD_PERCENT = _newPercent;
    }

    function setMaxStakingRewardPercent(uint256 _newPercent) external admin {
        MAX_STAKING_REWARD_PERCENT = _newPercent;
    }

    function setMinStaking(uint256 _amount) external admin {
        MIN_STAKING = _amount;
    }

    function setIncrementalDailyRewardPercent(
        uint256 _newPercent
    ) external admin {
        INCREMENTAL_DAILY_REWARD_PERCENT = _newPercent;
    }

    function setMaxTotalRewards(uint256 _newAmount) external admin {
        MAX_TOTAL_REWARDS = _newAmount;
    }

    // Allows the owner to withdraw BNB from the contract
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // Allows the owner to withdraw any ERC20 token from the contract
    function withdrawERC20(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        token.transfer(owner(), token.balanceOf(address(this)));
    }

    function setMintTime(uint256 _timestamp) external admin {
        mintTime = _timestamp;
    }

    function setMintTimeRestrict(uint256 _seconds) external admin {
        RESTRICTED_TRANSFER_PERIOD = _seconds;
    }

    // Function to restrict token transfers during the restricted period
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        // Transfer restriction doesn't apply for minting (when from address is zero)
        // Transfer restriction also doesn't apply for the contract owner
        if (from != address(0) && from != owner() && to != address(this)) {
            require(
                block.timestamp >= mintTime + RESTRICTED_TRANSFER_PERIOD,
                "Token transfer restricted until the end of the period"
            );
        }
    }
}