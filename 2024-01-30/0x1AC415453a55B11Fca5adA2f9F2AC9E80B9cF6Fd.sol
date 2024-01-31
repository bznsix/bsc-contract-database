//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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


contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

interface IStableSwapRouter {
    enum FLAG {
        STABLE_SWAP,
        V2_EXACT_IN
    }
    
    function swap(
        IERC20 srcToken,
        IERC20 dstToken,
        uint256 amount,
        uint256 minReturn,
        FLAG flag
    ) external payable returns (uint256 returnAmount);
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

interface INexusToken {
    function mintWithBacking(
        uint256 numTokens,
        address recipient
    ) external returns (uint256);
}

/**
    Prop Pool Submission Contract

    - User spends predetermined amount of money ($5,000) for Prop Pool
    - If User has not been confirmed before, he waits in Escrow for owner to approve him
    - Once Approved, user can be automatically confirmed and no Escrow is needed
    - Once confirmed, user gets points added to his total (staking points)
    - USDT comes into the contract, we need to automatically convert it to NEXUS and add to the rewards
        - rewards are split evenly based on the number of points in the pool
    - Send $5,000 immediately to wallet specified by owner
 */
contract PropPool is Ownable, ReentrancyGuard, IERC20 {

    // name and symbol for tokenized contract
    string private constant _name = "Prop Pools";
    string private constant _symbol = "PropPools";
    uint8 private constant _decimals = 0;

    // User Info
    struct UserInfo {
        uint256 amount;
        uint256 totalExcluded;
        bool isConfirmed;
    }

    // Address => UserInfo
    mapping ( address => UserInfo ) public userInfo;

    // List of users waiting to be confirmed
    address[] public escrowUsers;
    mapping ( address => uint256 ) public pointsInEscrow;

    // Tracks Dividends
    uint256 public totalRewards;
    uint256 private totalShares;
    uint256 private dividendsPerPoint;
    uint256 private constant precision = 10**18;

    // minimum entry fee in USDT
    uint256 public entryFee = 5_000 * 10**18;

    // Token used to enter the pool
    address public entryToken = 0xE02b3F47B0528440a948cE53C8Cc2882A8d34164;

    // Nexus Token, the payout token
    address public nexusToken;

    // mint token for nexus
    address public constant mintToken = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;

    // reward token that is converted into NEXUS
    address public conversionToken = 0x55d398326f99059fF775485246999027B3197955;

    // fund recipient
    address public fundRecipient;

    // pause function
    bool public paused;

    // router
    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor(
        address nexusToken_,
        address fundRecipient_
    ) {
        nexusToken = nexusToken_;
        fundRecipient = fundRecipient_;
    }

    function setEntryFee(uint256 newMin) external onlyOwner {
        entryFee = newMin;
    }

    function setEntryToken(address newToken) external onlyOwner {
        entryToken = newToken;
    }

    // reward token to be converted into usdc then nexus
    function setConversionToken(address newToken) external onlyOwner {
        conversionToken = newToken;
    }

    function setNexusToken(address newToken) external onlyOwner {
        nexusToken = newToken;
    }

    function setRouter(address newRouter) external onlyOwner {
        router = newRouter;
    }

    function setFundRecipient(address newRecipient) external onlyOwner {
        fundRecipient = newRecipient;
    }

    function pauseBuying(bool isPaused) external onlyOwner {
        paused = isPaused;
    }

    function getEscrowUsers() external view returns (address[] memory) {
        return escrowUsers;
    }

    /** Returns the total number of tokens in existence */
    function totalSupply() external view override returns (uint256) { 
        return totalShares; 
    }

    /** Returns the number of tokens owned by `account` */
    function balanceOf(address account) public view override returns (uint256) { 
        return userInfo[account].amount;
    }

    /** Returns the number of tokens `spender` can transfer from `holder` */
    function allowance(address, address) external pure override returns (uint256) { 
        return 0; 
    }
    
    /** Token Name */
    function name() public pure override returns (string memory) {
        return _name;
    }

    /** Token Ticker Symbol */
    function symbol() public pure override returns (string memory) {
        return _symbol;
    }

    /** Tokens decimals */
    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    /** Approves `spender` to transfer `amount` tokens from caller */
    function approve(address, uint256) public override returns (bool) {
        emit Approval(msg.sender, address(0), 0);
        return true;
    }
  
    /** Transfer Function */
    function transfer(address, uint256) external override returns (bool) {
        emit Transfer(address(0), address(0), 0);
        return true;
    }

    /** Transfer Function */
    function transferFrom(address, address, uint256) external override returns (bool) {
        emit Transfer(address(0), address(0), 0);
        return true;
    }

    function withdrawForeignToken(address token_) external onlyOwner {
        require(
            IERC20(token_).transfer(
                msg.sender,
                IERC20(token_).balanceOf(address(this))
            ),
            'Failure On Token Withdraw'
        );
    }

    function withdrawETH() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function claimRewardsFor(address[] calldata users) external onlyOwner nonReentrant {
        uint len = users.length;
        for (uint i = 0; i < len;) {
            _claimReward(users[i]);
            unchecked {
                ++i;
            }
        }
    }

    function confirmUser(address user, uint256 index) external onlyOwner {
        require(
            escrowUsers[index] == user,
            'Invalid Index'
        );
        require(
            pointsInEscrow[user] > 0,
            'Zero Points'
        );

        // get the users escrow points
        uint256 nPoints = pointsInEscrow[user];

        // delete the points for reentry
        delete pointsInEscrow[user];

        // remove user from array
        escrowUsers[index] = escrowUsers[escrowUsers.length - 1];
        escrowUsers.pop();

        // set user to be confirmed
        userInfo[user].isConfirmed = true;

        // award user points
        _stakePoints(user, nPoints);
    }


    function convert(uint256 minReturn) external nonReentrant {
        // convert USDT into USDC, then swap into nexus, deposit as rewards

        // get USDT balance
        uint256 balance = IERC20(conversionToken).balanceOf(address(this));

        // approve of router
        IERC20(conversionToken).approve(router, balance);

        // swap USDT to USDC
        IStableSwapRouter(router).swap(
            IERC20(conversionToken), 
            IERC20(mintToken), 
            balance, 
            minReturn, 
            IStableSwapRouter.FLAG.STABLE_SWAP
        );

        // note USDC amount received
        uint256 received = IERC20(mintToken).balanceOf(address(this));

        // approve of nexus
        IERC20(mintToken).approve(nexusToken, received);

        // mint NEXUS, noting amount minted
        uint256 balanceBefore = IERC20(nexusToken).balanceOf(address(this));
        INexusToken(nexusToken).mintWithBacking(
            received,
            address(this)
        );
        uint256 balanceAfter = IERC20(nexusToken).balanceOf(address(this));
        require(
            balanceAfter > balanceBefore,
            'Zero Received'
        );

        // calculate amount received
        uint256 amountMinted;
        unchecked {
            amountMinted = balanceAfter - balanceBefore;
        }
        
        // add to rewards
        _depositRewards(amountMinted);
    }

    function buyPools(uint nPools) external nonReentrant {
        require(
            paused == false,
            'Buying Is Paused'
        );

        // calculate cost
        uint256 cost = entryFee * nPools;

        // transfer in cost
        uint256 received = _transferIn(entryToken, cost);
        require(
            received >= cost,
            'Invalid Transfer In'
        );

        // transfer cost to fund recipient
        IERC20(entryToken).transfer(fundRecipient, cost);

        // stake points if user has been approved
        if (userInfo[msg.sender].isConfirmed) {
            _stakePoints(msg.sender, nPools);
        } else {
            _holdPointsInEscrow(msg.sender, nPools);
        }
    }

    function claimRewards() external nonReentrant {
        _claimReward(msg.sender);
    }

    function giveRewards(uint256 amount) external payable nonReentrant {
        uint256 received = _transferIn(nexusToken, amount);
        _depositRewards(received);
    }


    function _holdPointsInEscrow(address user, uint256 nPoints) internal {

        // add to list if they are not already in list
        if (pointsInEscrow[user] == 0) {
            escrowUsers.push(user);
        }

        // add to points
        unchecked {
            pointsInEscrow[user] += nPoints;
        }
    }

    function _stakePoints(address user, uint nPoints) internal {

        // claim reward if applicable
        if (userInfo[user].amount > 0) {
            _claimReward(user);
        }

        // increment points
        unchecked {
            userInfo[user].amount += nPoints;
            totalShares += nPoints;
        }
        
        // reset reward debt
        userInfo[user].totalExcluded = getCumulativeDividends(userInfo[user].amount);

        // emit Transfer Event
        emit Transfer(address(0), user, nPoints);
    }


    function _depositRewards(uint256 amount) internal {
        if (totalShares > 0) {
            unchecked {
                dividendsPerPoint += ( amount * precision ) / totalShares;
                totalRewards += amount;
            }
        }
    }

    function _claimReward(address user) internal {

        // exit if zero value locked
        if (userInfo[user].amount == 0) {
            return;
        }

        // fetch pending rewards
        uint256 amount = pendingRewards(user);
        uint256 balance = IERC20(nexusToken).balanceOf(address(this));

        // prevent overflow
        if (amount > balance) {
            amount = balance;
        }
        
        // exit if zero rewards
        if (amount == 0) {
            return;
        }

        // update total excluded
        userInfo[user].totalExcluded = getCumulativeDividends(userInfo[user].amount);

        // transfer reward to user
        IERC20(nexusToken).transfer(user, amount);
    }

    function _transferIn(address token, uint256 amount) internal returns (uint256) {
        require(
            IERC20(token).balanceOf(msg.sender) >= amount,
            'Insufficient Balance'
        );
        require(
            IERC20(token).allowance(msg.sender, address(this)) >= amount,
            'Insufficient Allowance'
        );

        uint256 before = IERC20(token).balanceOf(address(this));

        IERC20(token).transferFrom(msg.sender, address(this), amount);

        uint256 After = IERC20(token).balanceOf(address(this));
        require(
            After > before,
            'Zero Received'
        );
        return After - before;
    }


    function pendingRewards(address user) public view returns (uint256) {
        if(userInfo[user].amount == 0){ return 0; }

        uint256 cumulativeRewards = getCumulativeDividends(userInfo[user].amount);
        uint256 excludedRewards = userInfo[user].totalExcluded;

        if(cumulativeRewards <= excludedRewards){ return 0; }

        return cumulativeRewards - excludedRewards;
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return ( share * dividendsPerPoint ) / precision;
    }

}