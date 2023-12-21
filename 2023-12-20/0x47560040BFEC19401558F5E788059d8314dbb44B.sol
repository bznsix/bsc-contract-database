// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

contract SanSanHuaLuo13 is Ownable, ReentrancyGuard {
    struct Member {
        address sponsor;
        address[] referrals;
        uint8 level;
        uint256 totalReferredAmount;
        uint256[8] pendingRewards; // 每个等级的待领取奖励
        uint joinTimestamp; // 加入时间戳
        uint256[8] totallevelRewardAmount;
    }
    IERC20 public usdt;
    IERC20 public nftt;

    receive() external payable {}

    mapping(address => Member) public members;
    mapping(uint8 => uint256) public levelPrice;
    mapping(uint8 => uint256) public commissionRate;
    mapping(address => address) public inviter;
    mapping(address => bool) private _isExcludedFromFees;

    uint256 public NFTTpriceRate = 1_000_000_000_000_000;
    address public FundToken = address(0xc5D7Ef68a76f534Ede7c3f4A227e46580A86D3f2);

    // 用户的奖励结构
    struct RewardInfo {
        uint256 totalReward;      // 总奖励
        uint256 rewardClaimed;    // 已领取的奖励
    }

    event CommissionPending(address indexed sponsor, uint8 level, uint256 amount);
    event CommissionClaimed(address indexed sponsor, uint8 level, uint256 amount);

    // 用户的奖励映射
    mapping(address => mapping(uint8 => RewardInfo)) public userRewards;
    mapping(address => uint256) public _dayBuyAmountMap;
    mapping(address => uint256) public total_pledage;
    address[] private _dayBuyAddressList;
    uint256 public NetworkInfo;

    event CommissionPaid(address indexed sponsor, uint256 amount);
    event CommissionPending(address indexed sponsor, uint256 amount);
    // 事件声明
    // event MemberJoined(address member, address referrer);
    // event MemberLevelUpdated(address member, uint level);
    event MemberReplaced(address member, address newMember);
    event MemberRemoved(address member);

    // 设置每个等级的奖励金额
    mapping(uint8 => uint256) public levelRewardAmount;
    address public USDT_ADDRESS;
    address public nftToken;

    mapping(uint => uint) public levelRewardPercentage;

    uint256 public DAY = 120;

    constructor() {
        nftToken = address(0x933e44D39a4E0CABa42D3114E3A7401144F5145B);   //主网
        // uniswapV2Router = IUniswapV2Router02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));         //主网
        USDT_ADDRESS = address(0x55d398326f99059fF775485246999027B3197955);     //主网

        // nftToken = address(0xe36e6DE8962d2ECa7CC8b98Db46f5F7224D927c5);    //测试网
        // USDT_ADDRESS = address(0x90BE2D7031D723033e7f3CBc0e18Dcf511bb6033);    //测试网
        // uniswapV2Router = IUniswapV2Router02(address(0xD99D1c33F9fC3444f8101754aBC46c52416550D1));    //测试网

        usdt = IERC20(USDT_ADDRESS);
        nftt = IERC20(nftToken);

        // 设置等级价格
        levelPrice[1] = 100;
        levelPrice[2] = 200;
        levelPrice[3] = 400;
        levelPrice[4] = 1000;
        levelPrice[5] = 4000;
        levelPrice[6] = 13000;
        levelPrice[7] = 28000;
        // 设置分佣比例
        commissionRate[1] = 50;
        commissionRate[2] = 50;
        commissionRate[3] = 40;
        commissionRate[4] = 40;
        commissionRate[5] = 30;
        commissionRate[6] = 30;
        commissionRate[7] = 20;

        levelRewardAmount[1] = 150;
        levelRewardAmount[2] = 900;
        levelRewardAmount[3] = 4320;
        levelRewardAmount[4] = 32400;
        levelRewardAmount[5] = 291600;
        levelRewardAmount[6] = 2843100;
        levelRewardAmount[7] = 12247200;

        members[msg.sender].sponsor = address(this);
        members[msg.sender].level = 1;
    }

    function join(address sponsor) public nonReentrant {
        require(sponsor != msg.sender,"Cannot bind oneself");
        require(members[sponsor].sponsor != address(0),"Cannot bind oneself");
        require(members[msg.sender].level == 0, "Already a member");
        checkForSliding(sponsor);

        if(members[sponsor].referrals.length < 3) {
            members[sponsor].referrals.push(msg.sender);
        } else {
            inviter[msg.sender] = sponsor;         //直推地址
            // 如果直接推荐人已经有3个下线，则寻找下一个可用的推荐人
            
            address newSponsor = findNextAvailableSponsor(sponsor);      //
            members[newSponsor].referrals.push(msg.sender);
            sponsor = newSponsor;
        }
        members[msg.sender].sponsor = sponsor;
        members[msg.sender].joinTimestamp = block.timestamp;
    }

    function checkForSliding(address _referrer) private {
        for (uint i = 0; i < members[_referrer].referrals.length; i++) {
            address referral = members[_referrer].referrals[i];
            if (block.timestamp > members[referral].joinTimestamp + DAY && members[referral].level == 0 || members[_referrer].referrals[i] == members[_referrer].referrals[(i + 1)]) {
                // This referral didn't buy a level within a day and will be replaced
                removeReferral(_referrer, referral);
                break; // Assuming only one referral can be removed at a time
            }
        }
    }

    function checkSliding(address _referrer) public onlyOwner {
        for (uint i = 0; i < members[_referrer].referrals.length; i++) {
            address referral = members[_referrer].referrals[i];
            if ( members[_referrer].referrals[i] == members[_referrer].referrals[(i + 1)]) {
                // This referral didn't buy a level within a day and will be replaced
                removeReferral(_referrer, referral);
                break; // Assuming only one referral can be removed at a time
            }
        }
    } 

    function removeReferral(address _referrer, address _referral) private {
        address[] storage referrals = members[_referrer].referrals;
        for (uint i = 0; i < referrals.length; i++) {
            if (referrals[i] == _referral) {
                referrals[i] = referrals[referrals.length - 1];
                referrals.pop();
                members[_referral].sponsor = address(0); // Clear the upline relationship
                members[_referral].joinTimestamp = 0; // Reset join time as if they never joined
                break;
            }
        }
    }

    function findNextAvailableSponsor(address sponsor) private  returns(address) {
        // require(members[sponsor].referrals.length >= 3, "Sponsor has less than 3 referrals");
        for(uint i = 0; i < members[sponsor].referrals.length; i++) {
            address referral = members[sponsor].referrals[i];
            if(members[referral].referrals.length < 3 && members[referral].level >=1 ) {
                return referral;
            }
        }

        // 递归查找下一个可用的推荐人
        for(uint i = 0; i < members[sponsor].referrals.length; i++) {
            address nextSponsor = findNextAvailableSponsor(members[sponsor].referrals[i]);
            if(nextSponsor != address(0) && members[nextSponsor].level >=1 ) {
                return nextSponsor;
            }
        }

        return address(this);
    }

    function buyLevel(uint8 _level) public nonReentrant {
        require(members[msg.sender].level == _level - 1, "You already have this level");
        require(_level > 0 && _level <= 7, "Invalid level");
        Member storage member = members[msg.sender];
        uint256 LevelPrices = levelPrice[_level];
        uint256 commission = NFTTpriceRate * LevelPrices ;
        nftt.transferFrom(msg.sender, address(this), commission);
        if(_dayBuyAmountMap[msg.sender] == 0) { 
            _dayBuyAddressList.push(msg.sender);
        } 
        _dayBuyAmountMap[msg.sender] += commission;
        total_pledage[msg.sender] += commission;
        NetworkInfo += commission;
        
        member.level = _level;
        member.totallevelRewardAmount[_level] = levelRewardAmount[_level];
        userRewards[msg.sender][_level].totalReward = levelRewardAmount[_level];

        // 支付或待领取的佣金
        payOrAccrueCommission(msg.sender, NFTTpriceRate, _level, LevelPrices ,commission);
    }

    function payOrAccrueCommission(address buyer, uint256 tokenAmount, uint8 _level, uint256 LevelPrices, uint256 commission) private {
        address sponsor = members[buyer].sponsor;
        uint256 commissionAmount = (levelPrice[_level] * commissionRate[_level]) / 100;
        uint i = 1;
        while (sponsor != address(0)) { 
            if (i == _level) {             //      1
                if (members[sponsor].level >= _level) {
                    if (inviter[msg.sender] != address(0x0) && _level == 1) {
                        address  invit = inviter[msg.sender];
                        uint256 invitcommission = tokenAmount * 60;
                        require(nftt.transfer(invit , invitcommission), "Transfer failed");
                    } else {
                        nftt.transfer(sponsor, (commission * commissionRate[_level]) /100 );
                        userRewards[sponsor][_level].rewardClaimed += commissionAmount;
                        emit CommissionPaid(sponsor, commission);
                        return ;
                    }
                } else {
                    // uint256 LevelPrices = levelLevelPrices[_level];
                    uint256 PRcommission = ( LevelPrices * commissionRate[_level]) / 100;
                    // members[sponsor].pendingRewards += commissionAmount;
                    members[sponsor].pendingRewards[_level] += PRcommission;
                    emit CommissionPending(sponsor, PRcommission);
                }
                members[sponsor].totalReferredAmount += levelPrice[_level] * 1e18;
                return ;
            }
            
            sponsor = members[sponsor].sponsor;
            i++;
        } 
    }

    function getNetworkInfo() external view returns (uint256) {
        return NetworkInfo;
    }
    
    function excludeFromFees(address account, bool excluded) public onlyOwner {
        _isExcludedFromFees[account] = excluded;
    }
    
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }

    function setSponsor(address user ,address Sponsor, uint8 level ) public onlyOwner {
        members[user].sponsor = Sponsor;
        members[user].level = level;
    }

    function setLevelPrice(uint8 level, uint256 price) public onlyOwner {
        levelPrice[level] = price;
    }

    function setCommissionRate(uint8 level, uint256 rate) public onlyOwner {
        commissionRate[level] = rate;
    }

    function setlevelRewardAmount(uint8 level, uint256 rate) public onlyOwner {
        levelRewardAmount[level] = rate;
    }

    function claimPendingRewards(uint8 level) public nonReentrant {
        Member storage member = members[msg.sender];
        uint256 reward = member.pendingRewards[level];
        require(reward > 0, "No pending rewards");
        require(member.level >= level, "Not eligible to claim rewards for this level");
        member.pendingRewards[level] = 0;
        member.totallevelRewardAmount[level] -= reward  ;
        userRewards[msg.sender][level].rewardClaimed += reward;
        require(nftt.transfer(msg.sender, reward * NFTTpriceRate ), "Transfer failed");
        emit CommissionClaimed(msg.sender, level, reward * NFTTpriceRate);
    }

    function setNFTT(address _nftTokenAddress) public onlyOwner {
        nftToken = _nftTokenAddress;
        nftt = IERC20(nftToken);
    }

    function setday(uint256 _nftTokenAddress) public onlyOwner {
        DAY = _nftTokenAddress;
    }

    function setNFTTprice(uint _swapNFTTs ) public {
        require (_isExcludedFromFees[msg.sender] , "swap failed");  
        NFTTpriceRate = _swapNFTTs;
    }

    function withdrawToken(address _tokenAddress,address _to,uint256 amount) public onlyOwner{
        IERC20(_tokenAddress).transfer(_to,amount);
    }

    function getReferrals(address _member) public view returns(address[] memory) {
        return members[_member].referrals;
    }

    function getReferrals(address _member, address newSponsor) public onlyOwner {
        members[_member].referrals.push(newSponsor);
    } 

    //待领取奖励
    function getPendingRewards(address user, uint8 level) public view returns (uint256) {
        require(level >= 1 && level <= 8, "Invalid level");
        return members[user].pendingRewards[level];
    }

    function gettotalPendingRewards(address user, uint8 level) public view returns (uint256) {
        require(level >= 1 && level <= 8, "Invalid level");
        return members[user].totallevelRewardAmount[level];
    }

        // 获取待领取的奖励
    function getPendingReward(address _user, uint8 _level) public view returns (uint256) {
        uint256 total = userRewards[_user][_level].totalReward;
        uint256 claimed = userRewards[_user][_level].rewardClaimed;
        return total - claimed;
    }

    // 获取某个用户的直接下级充值总额
    function getDirectReferredInvestment(address user) public view returns (uint256 total) {
        address[] memory referrals = members[user].referrals;
        for (uint i = 0; i < referrals.length; i++) {
            total += members[referrals[i]].totalReferredAmount;
        }
    }

    function getTodayBuyAmount() external view returns(uint256){
        uint256 TodayBuyAmount = 0;
        address[] memory addressList = _dayBuyAddressList;
        for(uint i ;i<addressList.length;i++){
            TodayBuyAmount += _dayBuyAmountMap[addressList[i]];
        }
        return TodayBuyAmount;
    }

    function resetDayBuyLimit() public {    
        // uint32 today = uint32(block.timestamp/86400); 

        address[] memory addressList = _dayBuyAddressList;
        for(uint i ;i<addressList.length;i++){
            delete _dayBuyAmountMap[addressList[i]];
        }
        delete _dayBuyAddressList;
    }

    // 出金
    function AwardTokenSwapUSDT(uint amount) public nonReentrant {
        IERC20(nftToken).transferFrom(msg.sender,address(this),amount);
        uint256 Sell = token2Usdt(amount);
       
        IERC20(USDT_ADDRESS).transfer(msg.sender,Sell);
    }
    // 入金
    function USDT2awardTokenSwap(uint256 amount) public nonReentrant {
        IERC20(USDT_ADDRESS).transferFrom(msg.sender,address(FundToken),amount);
        uint256 usdtSwapToken = usdt2Token(amount);
        IERC20(nftToken).transfer(msg.sender,usdtSwapToken);
    }
    
    function setSwapTokensaddress(address _swapTokens) public onlyOwner {
        nftToken = _swapTokens;
    }

    function token2Usdt(uint256 tokenAmount) public view returns(uint256){
        return tokenAmount / NFTTpriceRate * 1e18;
    }

    function usdt2Token(uint256 usdtAmount) public view returns(uint256){
        return usdtAmount * NFTTpriceRate / 1e18;
    }

    function setSwap(address _swapTokens) public onlyOwner {
        FundToken = _swapTokens;
    }
}