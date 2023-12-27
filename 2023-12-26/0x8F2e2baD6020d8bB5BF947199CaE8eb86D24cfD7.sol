// Sources flattened with hardhat v2.18.1 https://hardhat.org

// SPDX-License-Identifier: MIT

// File contracts/interfaces/IERC20.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


// File contracts/interfaces/IERC20Metadata.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.19;

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


// File contracts/utils/Context.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File contracts/libraries/ERC20.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.19;



contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() external view virtual override returns (string memory) {
        return _name;
    }

    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() external view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) external view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) external virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20Stake: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) external virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) external virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20Stake: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20Stake: transfer from the zero address");
        require(recipient != address(0), "ERC20Stake: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20Stake: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20Stake: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20Stake: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20Stake: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function burn(uint256 amount) external virtual {
        require(_msgSender() != address(0), "ERC20Stake: burn from the zero address");
        require(amount > 0, "ERC20Stake: burn amount exceeds balance");
        require(_balances[_msgSender()] >= amount, "ERC20Stake: burn amount exceeds balance");
        _burn(_msgSender(), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20Stake: approve from the zero address");
        require(spender != address(0), "ERC20Stake: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


// File contracts/projects/SakaiDAO/interfaces/IEpoch.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.19;

interface IEpoch {
    function getCurrentEpoch() external view returns(uint256);
}


// File contracts/projects/SakaiDAO/interfaces/ITokenVote.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.19;

interface ITokenVote is IEpoch {
    function isCanVote(address account, uint256 _currentEpoch) external view returns(bool);
    function isCanCreateProposal(address account) external view returns(bool);
}


// File contracts/utils/Ownable.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.19;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "OwnableStake: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "OwnableStake: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// File contracts/utils/ReentrancyGuard.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.19;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuardStake: reentrant call");

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


// File contracts/projects/SakaiDAO/SakaiDAO.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.19;





/**
* This contract is part of SakaiDAO system.
* purpose of this contract is for staking and get reward
* user can stake and get reward from this contract
* with this token, user can vote, create proposal, and get reward with specific condition
*/
contract SakaiDAO is ITokenVote, ERC20, Ownable, ReentrancyGuard {
    address public tokenAddress;
    uint256 public currentEpoch;
    uint256 public lastResetEpochAt;
    uint256 public resetEpochEvery;
    uint256 public pendingCalculateReward;
    address public voteAddress;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalClaimed;
        bool isReceiveReward;
        uint256 lastDepositTimestamp;
        uint256 lastWithdrawnTimestamp;
        uint256 lastDepositEpoch;
        uint256 lastEpochNumberWhenDeposit;
    }

    address[] public shareholders;
    mapping (address => uint256) public shareholderIndexes;
    mapping (address => uint256) public shareholderClaims;
    mapping (address => bool) public isCanSetShares;
    mapping (address => Share) public shares;

    // mapping account -> referrer
    mapping(address => address) public referrers;

    // mapping referrer accumulation
    mapping(address => uint256) public rewardsFromReferrer;

    // mapping referrer pending amount
    mapping(address => uint256) public referrerPendingAmount;

    // total claimed referrer amount
    mapping(address => uint256) public referrerTotalClaimedAmount;

    mapping(address => mapping(address => uint256)) public referrerTotalAmountByAccount;

    // total accumulate referrer amount
    uint256 public totalAccumulateReferrerAmount;

    // total pending referrer amount
    uint256 public totalPendingReferrerAmount;

    uint256 public minimumStakeForVote;
    uint256 public minimumStakeForCreateProposal;
    uint256 public minimumStakeForGetReward;
    uint256 public minimumStake;

    uint256 public percentTaxForStakingPool;
    uint256 public percentTaxForVaultCapital;

    uint256 public percentDistributionForReferrerLayer1;
    uint256 public percentDistributionForReferrerLayer2;
    uint256 public percentDistributionForReferrerLayer3;

    uint256 public constant percentDenominator = 1000;

    uint256 public percentTaxClaimReferrer;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public constant dividendsPerShareAccuracyFactor = 10**36;
    uint256 public accumulateAmount;

    address public addressStakingPool;
    address public addressVaultCapital;
    address public treasuryAddress;

    event Stake(address account, uint256 amount);
    event UnStake(address account, uint256 amount);
    event ReceiveReward(uint256 amount, uint256 epoch);
  event ReceiveRewardReferrer(address account, uint256 amount, uint256 claimedAmount, uint256 epoch);
    event ClaimReward(address account, uint256 amount);
    event UpdateMinimumStakeForVote(uint256 minimumStakeForVote);
    event UpdateMinimumStakeForCreateProposal(uint256 minimumStakeForCreateProposal);
    event UpdateMinimumStakeForGetReward(uint256 minimumStakeForGetReward);
    event UpdatePercentDistributionReferrer(uint256 percentDistributionForReferrerLayer1, uint256 percentDistributionForReferrerLayer2, uint256 percentDistributionForReferrerLayer3);
    event UpdatePercentTax(uint256 percentTaxForStakingPool, uint256 percentTaxForVaultCapital);
    event UpdateVaultCapital(address addressVaultCapital);
    event UpdateStakingPool(address addressStakingPool);
    event UpdateResetEpochEvery(uint256 resetEpochEvery);
    event UpdateVoteAddress(address voteAddress);
    event UpdateTreasuryAddress(address treasuryAddress);
    event UpdatePercentTaxReferer(uint256 percentTaxClaimReferrer);
    event UpdateMinimumStake(uint256 minimumStake);

    constructor(address _tokenAddress) ERC20("SakaiDAO", "Sakai-DAO") {
        require(_tokenAddress != address(0), "SakaiDAO: token address is the zero address");
        tokenAddress = _tokenAddress;

        minimumStakeForVote = 5_000 * 10 ** 18;
        minimumStakeForCreateProposal = 25_000 * 10 ** 18;
        minimumStakeForGetReward = 1_000 * 10 ** 18;
        minimumStake = 1_000 * 10 ** 18;


        percentTaxForStakingPool = 20;
        percentTaxForVaultCapital = 30;
        percentTaxClaimReferrer = 50;

        percentDistributionForReferrerLayer1 = 30;
        percentDistributionForReferrerLayer2 = 20;
        percentDistributionForReferrerLayer3 = 10;

        addressStakingPool = _msgSender();
        addressVaultCapital = _msgSender();
        treasuryAddress = _msgSender();

       resetEpochEvery = 1 days;
    
    }

    receive() external payable {}

    // Region Internal Function

    function _addShareholder(address shareholder) internal {
        /** this function for add shareholders*/
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function _calculateReward(uint256 rewardAmount) internal {
        /** this function for calculate reward and count dividendsPerShare */
        pendingCalculateReward += rewardAmount;

        if(totalShares > 0 && (lastResetEpochAt + resetEpochEvery <= block.timestamp)){
            uint256 amount = pendingCalculateReward;
            totalDividends += amount;
            dividendsPerShare += (dividendsPerShareAccuracyFactor * amount / totalShares);

            currentEpoch++;
            lastResetEpochAt = block.timestamp;
            pendingCalculateReward = 0;
        } else {
            pendingCalculateReward += rewardAmount;
        }
    }

    function _claimReward(address account) internal {
        /** this function for claim reward */
        require(account != address(0), "SakaiDAO: account is the zero address");
        require(shares[account].amount > 0, "SakaiDAO: account is not stake");
        uint256 originalAmount = dividendOf(account);
        uint256 amount = _deductTaxClaimReward(originalAmount);
        if(IERC20(tokenAddress).balanceOf(address(this)) >= amount){
            IERC20(tokenAddress).transfer(account, amount);
            _setClaimed(account, originalAmount);
        }
    }

    function _claimRewardReferrer(address account) internal {
        /** this function for claim reward referrer */
        require(account != address(0), "SakaiDAO: account is the zero address");
        uint256 amount = referrerPendingAmount[account];
        referrerPendingAmount[account] = 0;
        totalPendingReferrerAmount -= amount;
        referrerTotalClaimedAmount[account] += amount;
        uint256 amountAfterTax = amount * percentTaxClaimReferrer / percentDenominator;
        uint256 amountForReferrer = amount - amountAfterTax;
        IERC20(tokenAddress).transfer(account, amountForReferrer);
        _distributeTaxClaimReward(amountAfterTax);
        emit ReceiveRewardReferrer(account, amountAfterTax, amountForReferrer, currentEpoch);
    }

    function _deductTaxUnstake(address account, uint256 amount ) internal returns(uint256){
        /** this function for deduct tax if user unstake early */
        uint256 amountAfterTax = amount;
        uint256 tax = _estimateTaxPercentEarlyUnstake(account);
        if(tax > 0){
            uint256 taxAmount = amount * tax / percentDenominator;
            amountAfterTax = amount - taxAmount;

            //distribute to dao user
            _calculateReward(taxAmount);
        }
        return amountAfterTax;
    }

    function _deductTaxClaimReward(uint256 amount ) internal returns(uint256){
        /** this function for deduct tax if user claim reward and distribute tax */
        uint256 amountAfterTax = amount;
        uint256 totalTax = percentTaxForStakingPool + percentTaxForVaultCapital;
        if(totalTax > 0){
            uint256 taxAmount = amount * totalTax / percentDenominator;
            amountAfterTax = amount - taxAmount;
            _distributeTaxClaimReward(taxAmount);
        }
        return amountAfterTax;
    }

    function _distributeTaxClaimReward(uint256 taxAmount) internal {
        /**
         * 1. Distribute tax to staking pool
         * 2. Distribute tax to vault capital
        */
        uint256 totalTax = percentTaxForStakingPool + percentTaxForVaultCapital;

        uint256 amountForStakingPool = taxAmount * percentTaxForStakingPool / totalTax;
        IERC20(tokenAddress).transfer(addressStakingPool, amountForStakingPool);

        uint256 amountForVaultCapital = taxAmount * percentTaxForVaultCapital / totalTax;
        IERC20(tokenAddress).transfer(addressVaultCapital, amountForVaultCapital);
    }

    function _estimateTaxPercentEarlyUnstake(address account) internal view returns(uint256) {
        /** this function for estimate tax if user unstake early */

        uint256 lastDepositTimestamp = shares[account].lastDepositTimestamp;
        uint256 totalDaysStake = (block.timestamp - lastDepositTimestamp) / 86400;
        uint256 tax = 0;

        if(totalDaysStake >=0 && totalDaysStake <= 90) tax = 250;
        else if(totalDaysStake > 90 && totalDaysStake <= 120) tax = 223;
        else if(totalDaysStake > 120 && totalDaysStake <= 150) tax = 196;
        else if(totalDaysStake > 150 && totalDaysStake <= 180) tax = 169;
        else if(totalDaysStake > 180 && totalDaysStake <= 210) tax = 142;
        else if(totalDaysStake > 210 && totalDaysStake <= 240) tax = 115;
        else if(totalDaysStake > 240 && totalDaysStake <= 270) tax = 88;
        else if(totalDaysStake > 270 && totalDaysStake <= 300) tax = 61;
        else if(totalDaysStake > 300 && totalDaysStake <= 330) tax = 34;
        else if(totalDaysStake > 330 && totalDaysStake <= 365) tax = 7;

        return tax;
    }

    function _getCumulativeDividend(uint256 share) internal view returns (uint256) {
        /** this function for calculate cumulative dividend */
        return share * dividendsPerShare / dividendsPerShareAccuracyFactor;
    }

    function _getReferrerOfAccount(address account) internal view returns(address, address, address) {
        /** this function for get referrer of account */
        address referrerLayer1 = referrers[account];
        address referrerLayer2 = referrers[referrerLayer1];
        address referrerLayer3 = referrers[referrerLayer2];
        return (referrerLayer1, referrerLayer2, referrerLayer3);
    }

    function _isContract(address account) internal view returns (bool) {
        /** this function for check is contract or not */
        return account.code.length > 0;
    }

    function _removeShareholder(address shareholder) internal {
        /** this function for remove shareholder */
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function _setClaimed(address account, uint256 amount) internal {
        /** this function for set claimed reward */
        shareholderClaims[account] = block.timestamp;
        shares[account].totalClaimed = shares[account].totalClaimed + (amount);
        shares[account].totalExcluded = _getCumulativeDividend(shares[account].amount);
        shares[account].lastWithdrawnTimestamp = block.timestamp;
        totalDistributed = totalDistributed + (amount);
        emit ClaimReward(account, amount);
    }

    function _setShare(address account, uint256 amount) internal {
        /** this function for set shares balance */

        if(amount > 0 && shares[account].amount == 0){
            // if amount > 0 then add shareholder
            _addShareholder(account);
        } else if(amount == 0 && shares[account].amount > 0){
            // if amount = 0 then remove shareholder
            _removeShareholder(account);
        }

        /** Update shares balance */
        totalShares = totalShares - shares[account].amount + amount;
        shares[account].amount = amount;
        shares[account].totalExcluded = _getCumulativeDividend(shares[account].amount);
        shares[account].lastDepositTimestamp = block.timestamp;
        shares[account].lastDepositEpoch = currentEpoch;

        // get current epoch from vote contract for prevent user voting on running epoch
        shares[account].lastEpochNumberWhenDeposit = voteAddress != address(0) ? ITokenVote(voteAddress).getCurrentEpoch() : 0;

        if(shares[account].amount >= minimumStakeForGetReward){
            shares[account].isReceiveReward = true;
        } else {
            shares[account].isReceiveReward = false;
            totalShares = totalShares - shares[account].amount;
        }
    }

    function _stake(uint256 amount, address referrerAddress) internal {
        /** this function for stake */
        address account = _msgSender();
        address referrerLayer1 = referrerAddress;
        /** Transfer tokens to contract */
        IERC20(tokenAddress).transferFrom(_msgSender(), address(this), amount);

        /** Mint shares to user*/
        _mint(account,amount);

        /** Set shares balance*/
        _setShare(account, balanceOf(account));

        // get user upline of account if exists
        address userUpline = referrers[account];

        // if user upline is zero address, combine with user input from API
        if(userUpline == address(0) && referrerLayer1 != address(0)){
            referrers[account] = referrerLayer1;
            userUpline = referrerLayer1;
        }
        /** Set referrer */
        if(userUpline != address(0)){
            referrerLayer1 = userUpline;

            /** count first layer of referrer**/
            uint256 amountLayer1 = amount * percentDistributionForReferrerLayer1 / percentDenominator;
            rewardsFromReferrer[referrerLayer1] += amountLayer1;
            referrerPendingAmount[referrerLayer1] += amountLayer1;
            referrerTotalAmountByAccount[account][referrerLayer1] += amountLayer1;
            totalAccumulateReferrerAmount += amountLayer1;
            totalPendingReferrerAmount += amountLayer1;

            /** layer 2 referrer */
            address referrerLayer2 = referrers[referrerLayer1];
            if(referrerLayer2 != address(0)){
                uint256 amountLayer2 = amount * percentDistributionForReferrerLayer2 / percentDenominator;
                rewardsFromReferrer[referrerLayer2] += amountLayer1;
                referrerPendingAmount[referrerLayer2] += amountLayer2;
                referrerTotalAmountByAccount[account][referrerLayer2] += amountLayer2;
                totalAccumulateReferrerAmount += amountLayer2;
                totalPendingReferrerAmount += amountLayer2;
            }

            /** layer 3 referrer */
            address referrerLayer3 = referrers[referrerLayer2];
            if(referrerLayer3 != address(0)){
                uint256 amountLayer3 = amount * percentDistributionForReferrerLayer3 / percentDenominator;
                rewardsFromReferrer[referrerLayer3] += amountLayer3;
                referrerPendingAmount[referrerLayer3] += amountLayer3;
                referrerTotalAmountByAccount[referrerLayer3][account] += amountLayer3;
                totalAccumulateReferrerAmount += amountLayer3;
                totalPendingReferrerAmount += amountLayer3;
            }

        }


        emit Stake(account,amount);
    }

    function _unstake(uint256 amount) internal {
        /** this function for unstake */
        _burn(_msgSender(),amount);
        uint256 amountAfterTax = _deductTaxUnstake(_msgSender(), amount);
        IERC20(tokenAddress).transfer(_msgSender(), amountAfterTax);
        _setShare(_msgSender(), balanceOf(_msgSender()));
        emit UnStake(_msgSender(),amount);
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        // Prevent user for transfering token
    }

    // End Region Internal Function

    // Region Public / External Function

    function estimateTaxPercentEarlyUnstake(address account) external view returns(uint256, uint256){
        return (_estimateTaxPercentEarlyUnstake(account), percentDenominator);
    }

    function claimReward() external nonReentrant {
        _claimReward(_msgSender());
    }

    function claimRewardReferrer() external nonReentrant {
        _claimRewardReferrer(_msgSender());
    }

    function claimRewardForAccount(address account) external nonReentrant onlyOwner {
        _claimReward(account);
    }

    function claimStuckBNB() external nonReentrant onlyOwner {
        require(address(this).balance > 0, "SakaiDAO: No stuck BNB");
        payable(msg.sender).transfer(address(this).balance);
    }

    function claimStuckTokens(address token) external nonReentrant onlyOwner {
        require(token != tokenAddress, "Owner cannot claim native tokens");
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function dividendOf(address account) public view returns (uint256) {

        if(shares[account].amount == 0){ return 0; }
        if(shares[account].isReceiveReward == false){ return 0; }

        uint256 shareholderTotalDividends = _getCumulativeDividend(shares[account].amount);
        uint256 shareholderTotalExcluded = shares[account].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function diffAmount() public view returns (uint256) {
        if(!isValidBalance()){
            return totalSupply() - IERC20(tokenAddress).balanceOf(address(this));
        } else {
            return 0;
        }
    }

    /** Get referrer rewards */
    function dividendOfReferrer(address account) public view returns (uint256) {
        return referrerPendingAmount[account];
    }

    function getReferrerOfAccount(address account) external view returns(address, address, address) {
        return _getReferrerOfAccount(account);
    }

    function getTotalDaysStake(address account) external view returns(uint256){
        uint256 lastDepositTimestamp = shares[account].lastDepositTimestamp;
        uint256 totalDaysStake = (block.timestamp - lastDepositTimestamp) / 86400;
        return totalDaysStake;
    }

    function getNextResetEpochAt() external view returns(uint256){
        return lastResetEpochAt + resetEpochEvery;
    }

    function getCurrentEpoch() external view returns(uint256) {
        return currentEpoch;
    }

    function isCanVote(address account, uint256 _currentEpoch) external view returns(bool){
        return shares[account].amount >= minimumStakeForVote &&
            shares[account].lastEpochNumberWhenDeposit < _currentEpoch;
    }

    function isCanCreateProposal(address account) external view returns(bool) {
        return shares[account].amount >= minimumStakeForCreateProposal;
    }

    function isValidBalance() public view returns(bool) {
        return IERC20(tokenAddress).balanceOf(address(this)) >= totalSupply();
    }

    function sendReward(uint256 rewardAmount) external returns(bool) {
        // Sending and calculate reward
        require(IERC20(tokenAddress).allowance(_msgSender(),address(this)) >= rewardAmount,"SakaiDAO: Insufficient Allowance");
        require(IERC20(tokenAddress).balanceOf(_msgSender()) >= rewardAmount,"SakaiDAO: Insufficient Balance");
        if(rewardAmount > 0){
            IERC20(tokenAddress).transferFrom(_msgSender(), address(this), rewardAmount);
            _calculateReward(rewardAmount);
            return true;
        }
        return false;
    }

    function stake(uint256 amount, address referrer) external nonReentrant {
        require(amount > 0,"SakaiDAO: Invalid Amount");
        require(IERC20(tokenAddress).allowance(_msgSender(),address(this)) >= amount,"SakaiDAO: Insufficient Allowance");
        require(IERC20(tokenAddress).balanceOf(_msgSender()) >= amount,"SakaiDAO: Insufficient Balance");
        require(amount >= minimumStake, "SakaiDAO: Invalid amount, should more than minimum stake");
        require(referrer != _msgSender(), "SakaiDAO: Invalid referrer");
        _stake(amount, referrer);
    }

    function unstake(uint256 amount) external nonReentrant {
        require(amount > 0,"SakaiDAO: Invalid Amount");
        require(balanceOf(_msgSender()) >= amount, "SakaiDAO: Insufficient Amount");
        _unstake(amount);
    }

    function updateMinimumStakeForVote(uint256 _amountInWei) external onlyOwner {
        minimumStakeForVote = _amountInWei;
        emit UpdateMinimumStakeForVote(_amountInWei);
    }

    function updateMinimumStakeForCreateProposal(uint256 _amountInWei) external onlyOwner {
        minimumStakeForCreateProposal = _amountInWei;
        emit UpdateMinimumStakeForCreateProposal(_amountInWei);
    }

    function updateMinimumStakeForGetReward(uint256 _amountInWei) external onlyOwner {
        minimumStakeForGetReward = _amountInWei;
        emit UpdateMinimumStakeForGetReward(_amountInWei);
    }

    function updateMinimumStake(uint256 _amountInWei) external onlyOwner {
        minimumStake = _amountInWei;
        emit UpdateMinimumStake(_amountInWei);
    }

    function updatePercentTaxClaimReferrer(uint256 _percentTaxClaimReferrer) external onlyOwner {
        percentTaxClaimReferrer = _percentTaxClaimReferrer;
        emit UpdatePercentTaxReferer(_percentTaxClaimReferrer);
    }

    function updatePercentDistributionForReferrer(uint256 _layer1, uint256 _layer2, uint256 _layer3) external onlyOwner {
        require(_layer1 + _layer2 + _layer3 == percentDenominator, "SakaiDAO: Maximum Referrer should 100%");
        percentDistributionForReferrerLayer1 = _layer1;
        percentDistributionForReferrerLayer2 = _layer2;
        percentDistributionForReferrerLayer3 = _layer3;
        emit UpdatePercentDistributionReferrer(_layer1, _layer2, _layer3);
    }

    function updatePercentTax(uint256 _percentTaxForStakingPool, uint256 _percentTaxForVaultCapital) external onlyOwner {
        require(_percentTaxForStakingPool + _percentTaxForVaultCapital <= 100, "SakaiDAO: Maximum tax is 10%");
        percentTaxForStakingPool = _percentTaxForStakingPool;
        percentTaxForVaultCapital = _percentTaxForVaultCapital;
        emit UpdatePercentTax(_percentTaxForStakingPool, _percentTaxForVaultCapital);
    }

    function updateVaultCapital(address _addressVaultCapital) external onlyOwner {
        require(_addressVaultCapital != address(0), "SakaiDAO: Invalid address");
        require(addressVaultCapital != _addressVaultCapital, "SakaiDAO: Vault Capital address is already that address");
        addressVaultCapital = _addressVaultCapital;
        emit UpdateVaultCapital(_addressVaultCapital);
    }

    function updateStakingPool(address _addressStakingPool) external onlyOwner {
        require(_addressStakingPool != address(0), "SakaiDAO: Invalid address");
        require(addressStakingPool != _addressStakingPool, "SakaiDAO: Staking Pool address is already that address");
        addressStakingPool = _addressStakingPool;
        emit UpdateStakingPool(_addressStakingPool);
    }

    function updateTreasuryAddress(address _treasuryAddress) external onlyOwner {
        require(_treasuryAddress != address(0), "SakaiDAO: Invalid address");
        require(treasuryAddress != _treasuryAddress, "SakaiDAO: Treasury address is already that address");
        treasuryAddress = _treasuryAddress;
        emit UpdateTreasuryAddress(_treasuryAddress);
    }

    function updateResetEpochEvery(uint256 _valueInDays) external onlyOwner {
        require(_valueInDays >= 1 && _valueInDays <= 7, "SakaiDAO: Invalid reset epoch 1-7 days");
        resetEpochEvery = _valueInDays * 1 days;
        emit UpdateResetEpochEvery(_valueInDays);
    }

    function updateVoteAddress(address _voteAddress) external onlyOwner {
        require(_voteAddress != address(0), "SakaiDAO: Invalid address");
        require(voteAddress != _voteAddress, "SakaiDAO: Vote address is already that address");
        voteAddress = _voteAddress;
        emit UpdateVoteAddress(_voteAddress);
    }
    // Region Public Function
}