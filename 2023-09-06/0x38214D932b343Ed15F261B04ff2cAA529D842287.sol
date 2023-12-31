// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

contract SafoFarm is ReentrancyGuard {
    address payable public OWNER;
    address payable public teamWallet;
    IERC20 public stakedToken;
    IERC20 public rewardToken;

    address public APE_ROUTER;
    address public TOKEN_WBNB_LP;
    address public TOKEN;
    address public WETH;

    uint public acceptableSlippage = 500;
    uint public tokenPerBnb;
    bool public tokenBondBonusActive = false;
    uint public tokenBondBonus = 1000;
    uint public tokensForBondsSupply;
    uint public beansFromSoldToken;

    struct UserInfo {
        uint tokenBalance;
        uint bnbBalance;
        uint tokenBonds;
    }
    mapping(address => UserInfo) public addressToUserInfo;
    mapping(address => uint) public userStakedBalance;
    mapping(address => uint) public userPaidRewards;
    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) public userRewards;
    mapping(address => bool) public userStakeAgain;
    mapping(address => bool) public userStakeIsReferred;
    mapping(address => address) public userReferred;
    mapping(address => uint) public referralRewardCount;
    mapping(address => uint) public referralIncome;

    uint public earlyUnstakeFee = 2000;
    uint public poolDuration = 180 days;
    uint public poolStartTime;
    uint public poolEndTime;
    uint public updatedAt;
    uint public rewardRate;
    uint public rewardPerTokenStored;
    uint private _totalStaked;
    uint public totalBeansOwed;
    uint public totalTokenOwed;
    uint public totalLPTokensOwed;
    uint public liquidityPercentage = 3000;

    uint public referralLimit = 5;
    uint public referralPercentage = 2000; // referral percentage is 20%

    /* ========== MODIFIERS ========== */

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();
        if (_account != address(0)) {
            userRewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == OWNER, "Ownable: caller is not the owner");
        _;
    }

    /* ========== EVENTS ========== */

    event Reward(address indexed user, uint256 amount);
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 amount);
    event TokenBondsPurchased(
        address indexed user,
        uint tokenAmount,
        uint wbnbAmount,
        uint lpAmount
    );
    event TokenBondSold(
        address indexed user,
        uint tokenAmount,
        uint wbnbAmount
    );

    receive() external payable {}

    /* ========== CONSTRUCTOR ========== */

    constructor(
        address _teamWallet,
        address _stakedToken,
        address _rewardToken,
        address _apeRouter,
        address _token,
        address _weth,
        address _tokenWbnbLp
    ) {
        OWNER = payable(0x58490A6eD97F8820D8c120dC102F50c638B3C81E);
        teamWallet = payable(_teamWallet);
        stakedToken = IERC20(_stakedToken);
        rewardToken = IERC20(_rewardToken);
        APE_ROUTER = _apeRouter;
        TOKEN = _token;
        WETH = _weth;
        TOKEN_WBNB_LP = _tokenWbnbLp;
    }

    /* ========== Token BOND FUNCTIONS ========== */

    function purchaseTokenBond(
        address _referralUserAddress
    ) external payable nonReentrant {
        require(block.timestamp <= poolEndTime, "Pool Ended");
        if (userStakeAgain[msg.sender] == false) {
            userStakeAgain[msg.sender] = true;
            if (
                _referralUserAddress != address(0) &&
                _referralUserAddress != msg.sender
            ) {
                userReferred[msg.sender] = _referralUserAddress;
                userStakeIsReferred[msg.sender] = true;
            }
        }

        uint256 totalBeans = msg.value;
        require(totalBeans > 0, "Purchase amount must be greater than 0");

        uint256 beanForLiqudity = (totalBeans * liquidityPercentage) / 10000;
        uint256 beanForToken = totalBeans - beanForLiqudity;

        uint256 tokensForLiquidity = _beanToToken(beanForLiqudity);
        uint256 tokensForUser = _beanToToken(beanForToken);

        (bool success, ) = payable(OWNER).call{value: beanForToken}("");
        require(success, "Failed to send BNB");

        uint256 tokenMin = _calSlippage(tokensForLiquidity);
        uint256 beanMin = _calSlippage(beanForLiqudity);

        IERC20(TOKEN).approve(APE_ROUTER, tokensForLiquidity);
        (
            uint256 _amountA,
            uint256 _amountB,
            uint256 _liquidity
        ) = IUniswapV2Router01(APE_ROUTER).addLiquidityETH{
                value: beanForLiqudity
            }(
                TOKEN,
                tokensForLiquidity,
                tokenMin,
                beanMin,
                address(this),
                block.timestamp + 500
            );

        tokensForBondsSupply -= _amountA;

        UserInfo memory userInfo = addressToUserInfo[msg.sender];
        userInfo.tokenBalance += tokensForUser;
        userInfo.bnbBalance += beanForToken;
        userInfo.tokenBonds += _liquidity;

        totalTokenOwed += tokensForUser;
        totalBeansOwed += beanForToken;
        totalLPTokensOwed += _liquidity;

        addressToUserInfo[msg.sender] = userInfo;
        emit TokenBondsPurchased(msg.sender, _amountA, _amountB, _liquidity);
        _stake(_liquidity);
    }

    function redeemTokenBond(uint percentage) external nonReentrant {
        require(percentage <= 10000, "Invalid percentage");
        require(block.timestamp >= poolEndTime, "Pool is not ended yet");

        UserInfo storage userInfo = addressToUserInfo[msg.sender];
        uint bnbOwed = (userInfo.bnbBalance * percentage) / 10000;
        uint tokenOwed = (userInfo.tokenBalance * percentage) / 10000;
        uint tokenBonds = (userInfo.tokenBonds * percentage) / 10000;
        require(tokenBonds > 0, "No Tokens to unstake");

        userInfo.bnbBalance -= bnbOwed;
        userInfo.tokenBalance -= tokenOwed;
        userInfo.tokenBonds -= tokenBonds;
        addressToUserInfo[msg.sender] = userInfo;

        _unstake(tokenBonds);

        IERC20(TOKEN_WBNB_LP).approve(APE_ROUTER, tokenBonds);

        (uint _amountA, uint _amountB) = IUniswapV2Router01(APE_ROUTER)
            .removeLiquidity(
                TOKEN,
                WETH,
                tokenBonds,
                0,
                0,
                address(this),
                block.timestamp + 500
            );

        totalBeansOwed -= bnbOwed;
        totalTokenOwed -= tokenOwed;
        totalLPTokensOwed -= tokenBonds;

        // sending wbnb to the user which recieved from pancakeswap router
        IERC20(WETH).transfer(msg.sender, _amountB);
        IERC20(TOKEN).transfer(msg.sender, tokenOwed);
        tokensForBondsSupply += _amountA;
        emit TokenBondSold(msg.sender, _amountA, _amountB);
    }

    function _calSlippage(uint _amount) private view returns (uint) {
        return (_amount * acceptableSlippage) / 10000;
    }

    function _beanToToken(uint _amount) private returns (uint) {
        uint tokenJuice;
        uint tokenJuiceBonus;

        //confirm token0 & token1 in LP contract
        IPancakePair lpContract = IPancakePair(TOKEN_WBNB_LP);

        (uint tokenReserves, uint bnbReserves, ) = IPancakePair(lpContract)
            .getReserves();

        tokenPerBnb = (tokenReserves * 10 ** 18) / bnbReserves;

        if (tokenBondBonusActive) {
            tokenJuiceBonus = (tokenPerBnb * tokenBondBonus) / 10000;
            uint tokenPerBnbDiscounted = tokenPerBnb + tokenJuiceBonus;
            tokenJuice = (_amount * tokenPerBnbDiscounted) / 10 ** 18;
        } else tokenJuice = (_amount * tokenPerBnb) / 10 ** 18;

        require(tokenJuice <= tokensForBondsSupply, "Not Enough Tokens Supply");

        tokensForBondsSupply -= tokenJuice;

        return tokenJuice;
    }

    function fundTokenBonds(uint _amount) external onlyOwner {
        require(_amount > 0, "Invalid Amount");

        tokensForBondsSupply += _amount;
        IERC20(TOKEN).transferFrom(msg.sender, address(this), _amount);
    }

    function defundTokenBonds(uint _amount) external onlyOwner {
        require(_amount > 0, "Invalid Amount");
        require(_amount <= tokensForBondsSupply, "Not Enough Tokens Supply");
        tokensForBondsSupply -= _amount;
        IERC20(TOKEN).transfer(msg.sender, _amount);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function _stake(uint _amount) private updateReward(msg.sender) {
        require(block.timestamp <= poolEndTime, "Pool Ended");
        require(_amount > 0, "Invalid Amount");
        userStakedBalance[msg.sender] += _amount;
        _totalStaked += _amount;
        emit Staked(msg.sender, _amount);
    }

    function _unstake(uint _amount) private updateReward(msg.sender) {
        require(block.timestamp >= poolEndTime, "Tokens Locked");
        require(_amount > 0, "Invalid Amount");
        require(
            _amount <= userStakedBalance[msg.sender],
            "Not Enough Lp Tokens To Unstake"
        );

        userStakedBalance[msg.sender] -= _amount;
        _totalStaked -= _amount;
        emit Unstaked(msg.sender, _amount);
    }

    function emergencyUnstake(
        uint percentage
    ) external nonReentrant updateReward(msg.sender) {
        require(block.timestamp <= poolEndTime, "Pool Ended");
        require(percentage <= 10000, "Invalid percentage");

        UserInfo storage userInfo = addressToUserInfo[msg.sender];

        uint bnbOwed = (userInfo.bnbBalance * percentage) / 10000;
        uint tokenOwed = (userInfo.tokenBalance * percentage) / 10000;
        uint tokenBonds = (userInfo.tokenBonds * percentage) / 10000;
        require(tokenBonds > 0, "No Tokens to unstake");

        userInfo.bnbBalance -= bnbOwed;
        userInfo.tokenBalance -= tokenOwed;
        userInfo.tokenBonds -= tokenBonds;
        addressToUserInfo[msg.sender] = userInfo;

        uint amount = (userStakedBalance[msg.sender] * percentage) / 10000;
        require(amount > 0, "No LP Tokens to unstake");

        userStakedBalance[msg.sender] -= amount;
        _totalStaked -= amount;

        IERC20(TOKEN_WBNB_LP).approve(APE_ROUTER, amount);
        (uint _amountA, uint _amountB) = IUniswapV2Router01(APE_ROUTER)
            .removeLiquidity(
                TOKEN,
                WETH,
                amount,
                0,
                0,
                address(this),
                block.timestamp + 500
            );

        totalBeansOwed -= bnbOwed;
        totalTokenOwed -= tokenOwed;
        totalLPTokensOwed -= tokenBonds;

        uint wbnbFee = (_amountB * earlyUnstakeFee) / 10000;
        uint bnbOwedAfterFee = _amountB - wbnbFee;
        uint tokenFee = (tokenOwed * earlyUnstakeFee) / 10000;
        uint tokenOwedAfterFee = tokenOwed - tokenFee;
        tokensForBondsSupply += _amountA;

        IERC20(WETH).transfer(msg.sender, bnbOwedAfterFee);
        IERC20(TOKEN).transfer(msg.sender, tokenOwedAfterFee);
        IERC20(WETH).transfer(teamWallet, wbnbFee);
        IERC20(TOKEN).transfer(teamWallet, tokenFee);

        emit Unstaked(msg.sender, amount);
        emit TokenBondSold(msg.sender, _amountA, _amountB);
    }

    function claimRewards() public nonReentrant updateReward(msg.sender) {
        uint rewards = userRewards[msg.sender];
        require(rewards > 0, "No Claim Rewards Yet!");
        require(
            rewards <= tokensForBondsSupply,
            "Not Enough Tokens To Distribute Rewards"
        );

        userRewards[msg.sender] = 0;
        userPaidRewards[msg.sender] += rewards;
        tokensForBondsSupply -= rewards;
        if (userStakeIsReferred[msg.sender] == true) {
            if (referralRewardCount[msg.sender] < referralLimit) {
                uint referalReward = (rewards * referralPercentage) / 10000;
                referralRewardCount[msg.sender] =
                    referralRewardCount[msg.sender] +
                    1;
                referralIncome[userReferred[msg.sender]] += referalReward;
                rewardToken.transfer(userReferred[msg.sender], referalReward);
                rewardToken.transfer(msg.sender, rewards - referalReward);
                emit RewardPaid(userReferred[msg.sender], referalReward);
                emit RewardPaid(msg.sender, rewards - referalReward);
            } else {
                rewardToken.transfer(msg.sender, rewards);
                emit RewardPaid(msg.sender, rewards);
            }
        } else {
            rewardToken.transfer(msg.sender, rewards);
            emit RewardPaid(msg.sender, rewards);
        }
    }

    /* ========== OWNER RESTRICTED FUNCTIONS ========== */

    function setAcceptableSlippage(uint _amount) external onlyOwner {
        require(_amount <= 30, "Can't set above 30%");

        acceptableSlippage = _amount * 100;
    }

    function setTokenBondBonus(uint _amount) external onlyOwner {
        require(_amount <= 30, "Can't set above 30%");

        tokenBondBonus = _amount * 100;
    }

    function setTokenBondBonusActive(bool _status) external onlyOwner {
        tokenBondBonusActive = _status;
    }

    function setPoolDuration(uint _duration) external onlyOwner {
        require(poolEndTime < block.timestamp, "Pool still live");
        poolDuration = _duration;
    }

    function setPoolRewards(
        uint _amount
    ) external onlyOwner updateReward(address(0)) {
        require(_amount > 0, "Invalid Reward Amount");

        if (block.timestamp >= poolEndTime) {
            rewardRate = (_amount) / poolDuration;
        } else {
            uint remainingRewards = (poolEndTime - block.timestamp) *
                rewardRate;
            rewardRate = (_amount + remainingRewards) / poolDuration;
        }
        require(rewardRate > 0, "Invalid Reward Rate");

        poolStartTime = block.timestamp;
        poolEndTime = block.timestamp + poolDuration;
        updatedAt = block.timestamp;
    }

    function topUpPoolRewards(
        uint _amount
    ) external onlyOwner updateReward(address(0)) {
        uint remainingRewards = (poolEndTime - block.timestamp) * rewardRate;
        rewardRate = (_amount + remainingRewards) / poolDuration;
        require(rewardRate > 0, "reward rate = 0");
        updatedAt = block.timestamp;
    }

    function updateTeamWallet(address payable _teamWallet) external onlyOwner {
        require(_teamWallet != address(0), "Invalid Address");
        teamWallet = _teamWallet;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Invalid Address");
        OWNER = payable(_newOwner);
    }

    function setEarlyUnstakeFee(uint _earlyUnstakeFee) external onlyOwner {
        require(_earlyUnstakeFee <= 25, "the amount of fee is too damn high");
        earlyUnstakeFee = _earlyUnstakeFee * 100;
    }

    function setLiquidityPercentage(
        uint256 _newLiquidityPercentage
    ) external onlyOwner {
        require(_newLiquidityPercentage >= 0, "Invalid Liquidity Percentage");
        liquidityPercentage = _newLiquidityPercentage * 100;
    }

    function setReferralPercentage(
        uint _newReferralPercentage
    ) external onlyOwner {
        require(_newReferralPercentage >= 0, "Invalid Referral Percentage");
        referralPercentage = _newReferralPercentage * 100;
    }

    function setReferralLimit(uint _newReferralLimit) external onlyOwner {
        require(_newReferralLimit >= 0, "Invalid Referral Limit");
        referralLimit = _newReferralLimit;
    }

    function emergencyRecoverBeans() public onlyOwner {
        uint balance = address(this).balance;
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed.");
    }

    function emergencyRecoverTokens(
        address tokenAddress,
        uint _amount
    ) external onlyOwner {
        require(_amount > 0, "Invalid Amount");
        IERC20(tokenAddress).transfer(msg.sender, _amount);
    }

    /* ========== VIEW & GETTER FUNCTIONS ========== */

    function viewUserInfo(address _user) public view returns (UserInfo memory) {
        return addressToUserInfo[_user];
    }

    function earned(address _account) public view returns (uint) {
        return
            (userStakedBalance[_account] *
                (rewardPerToken() - userRewardPerTokenPaid[_account])) /
            1e18 +
            userRewards[_account];
    }

    function lastTimeRewardApplicable() private view returns (uint) {
        return _min(block.timestamp, poolEndTime);
    }

    function rewardPerToken() private view returns (uint) {
        if (_totalStaked == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) /
            _totalStaked;
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }

    function tokenForStakingRewards() public view returns (uint) {
        return tokensForBondsSupply;
    }

    function balanceOf(address _account) external view returns (uint) {
        return userStakedBalance[_account];
    }

    function totalStaked() external view returns (uint) {
        return _totalStaked;
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}
