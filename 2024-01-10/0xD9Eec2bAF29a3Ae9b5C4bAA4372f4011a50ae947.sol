// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol
interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// File: test.sol
interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

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
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(
        address _owner,
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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

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

contract SwtStaking is Ownable {
    IBEP20 public starToken = IBEP20(0x52CD40697ee19e0a3B99F67B5f8c111Ad54728Bb);

    uint256 dailyROI = 80; // 0.8%  0.8 * 10**2
    uint256 maxROIrewards = 20000; // Max ROI 200%  200 * 10**2
    uint256 minimumUsdStake = 100 ether; // USD amount $100 worth of SWT
    uint256 oneDayTimestamp = 86400; // 86400 One day
    uint256 feesPercentage = 500; // 5%  5 * 10**2

    address public feesWallet;
    address public minter;

    address public USDT = 0x55d398326f99059fF775485246999027B3197955; // Mainnet USDT
    IUniswapV2Router02 public router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    struct StakeDetails {
        uint256 swtAmount;
        uint256 usdtAmount;
        uint256 dailyROI;
        uint256 totalRewardDays;
        uint256 stakeTime;
        uint256 withdrawAmount;
        bool isExpired;
    }

    mapping(address => StakeDetails[]) public stakeData;

    event Staked(
        address indexed user,
        uint256 indexed stakeId,
        uint256 usdtAmount,
        uint256 swtAmount
    );

    event Claim(address indexed user, uint256 usdtAmount, uint256 swtAmount);
    event Withdraw(address indexed walletAddress, uint256 amount);
    event ExpiredStaking(
        address indexed walletAddress,
        uint256 indexed stakeId,
        bool isExpired
    );

    constructor(address _minter, address _feesWallet) {
        minter = _minter;
        feesWallet = _feesWallet;
    }

    modifier onlyMinter() {
        require(
            minter == msg.sender || owner() == msg.sender,
            "Only minter can call"
        );
        _;
    }

    function getSwtPriceInUSDT() public view returns (uint256) {
        address WBNB = router.WETH();
        address[] memory path = new address[](3);
        path[0] = address(starToken);
        path[1] = WBNB;
        path[2] = USDT;
        uint256[] memory Price = router.getAmountsOut(1 ether, path);
        return Price[2];
    }

    function getFeesPercentage() public view returns (uint256) {
        return feesPercentage;
    }

    function getCountStaking(address wallet) public view returns (uint256) {
        return stakeData[wallet].length;
    }

    function getUsdtAmountInSwt(
        uint256 _usdtToken
    ) public view returns (uint256) {
        return (_usdtToken * 10 ** 18) / getSwtPriceInUSDT();
    }

    function getDailyROI() public view returns (uint256) {
        return dailyROI;
    }

    function getTotalSwtInContract() public view returns (uint256) {
        return starToken.balanceOf(address(this));
    }

    function setMinimumUsdStake(uint256 _minimumUsdStake) external onlyOwner {
        minimumUsdStake = _minimumUsdStake; // _minimumUsdStake * 10 ** 18
    }

    function setDailyROI(uint256 _ROI) external onlyOwner {
        dailyROI = _ROI; // _ROI * 10 ** 2
    }

    function setMaxROIrewards(uint256 _maxROIrewards) external onlyOwner {
        maxROIrewards = _maxROIrewards; // _maxROIrewards * 10 ** 2
    }

    function setFeesWallet(address _feesWallet) external onlyOwner {
        require(address(0) != _feesWallet, "Zero address not allowed");
        feesWallet = _feesWallet; // Receive claim amount fees
    }

    function setFeesPercentage(uint256 _percent) external onlyOwner {
        feesPercentage = _percent; // _percent * 10 ** 2
    }

    function setMinter(address _minter) external onlyOwner {
        minter = _minter;
    }

    function expireStaking(
        address _user,
        uint256 index,
        bool _isExpired
    ) external onlyMinter {
        require(stakeData[_user].length > 0, "You do not have any staking.");

        if (_isExpired) {
            uint256 amountToClaim = calculateRewardAmount(_user, index); // In USDT
            if (amountToClaim > 0) {
                claimTransfer(index, _user);
            }
        }

        stakeData[_user][index].isExpired = _isExpired;

        emit ExpiredStaking(_user, index, _isExpired);
    }

    function stake(uint256 _usdtAmount) external {
        require(_usdtAmount > 0, "Amount must be greater than 0");
        require(
            _usdtAmount >= minimumUsdStake,
            "Staking amount should be greater than minimum amount"
        );
        uint _swtAmount = getUsdtAmountInSwt(_usdtAmount);
        require(
            starToken.balanceOf(msg.sender) >= _swtAmount,
            "Insufficient funds for stake"
        );
        require(
            starToken.allowance(msg.sender, address(this)) >= _swtAmount,
            "Insufficient approval for stake"
        );

        starToken.transferFrom(msg.sender, address(this), _swtAmount);

        uint256 totalDays = maxROIrewards / dailyROI;
        uint256 index = stakeData[msg.sender].length;

        require(totalDays > 0, "Invalid totalDays value");

        stakeData[msg.sender].push(
            StakeDetails({
                swtAmount: _swtAmount,
                usdtAmount: _usdtAmount,
                dailyROI: dailyROI,
                totalRewardDays: totalDays,
                stakeTime: block.timestamp,
                withdrawAmount: 0,
                isExpired: false
            })
        );

        emit Staked(msg.sender, index, _usdtAmount, _swtAmount);
    }

    function getAmountToCliam(
        uint256 index,
        address sender
    ) public view returns (uint256) {
        require(stakeData[sender].length > 0, "You do not have any staking.");
        require(
            !stakeData[sender][index].isExpired,
            "Your staking is expired."
        );
        uint256 amountToClaim = calculateRewardAmount(sender, index);
        return amountToClaim;
    }

    function claim(uint256 index) external {
        require(
            stakeData[msg.sender].length > 0,
            "You do not have any staking."
        );

        require(
            block.timestamp - stakeData[msg.sender][index].stakeTime >
                oneDayTimestamp,
            "No reward generated yet."
        );

        claimTransfer(index, msg.sender);
    }

    function claimTransfer(uint256 index, address _user) internal {
        require(!stakeData[_user][index].isExpired, "Your staking is expired.");

        uint256 amountToClaim = calculateRewardAmount(_user, index); // In USDT
        uint rewardInSWT = getUsdtAmountInSwt(amountToClaim); // IN SWT

        require(
            amountToClaim > 0,
            "Rewards generated already claimed. Please try later."
        );

        require(
            rewardInSWT <= getTotalSwtInContract(),
            "Insufficient amount in staking pool."
        );
        uint256 fees = (rewardInSWT * feesPercentage) / 10000;

        stakeData[_user][index].withdrawAmount += amountToClaim; // USDT Amount

        starToken.transfer(_user, rewardInSWT - fees);
        starToken.transfer(feesWallet, fees);

        emit Claim(_user, amountToClaim, rewardInSWT);
    }

    function calculateRewardAmount(
        address sender,
        uint256 index
    ) internal view returns (uint256) {
        uint256 rewardGeneratedAmount = (stakeData[sender][index].usdtAmount *
            stakeData[sender][index].dailyROI) / 10000;

        uint256 daysPassed = (block.timestamp -
            stakeData[sender][index].stakeTime) / oneDayTimestamp;

        if (daysPassed <= stakeData[sender][index].totalRewardDays) {
            return
                (rewardGeneratedAmount * daysPassed) -
                stakeData[sender][index].withdrawAmount;
        } else {
            return
                (rewardGeneratedAmount *
                    stakeData[sender][index].totalRewardDays) -
                stakeData[sender][index].withdrawAmount;
        }
    }

    function withdraw(
        uint256 amount,
        address walletAddress
    ) external onlyOwner {
        require(amount <= getTotalSwtInContract(), "Insufficient amount.");
        require(walletAddress != address(0), "Wallet address is required.");
        starToken.transfer(walletAddress, amount);
        emit Withdraw(walletAddress, amount);
    }
}