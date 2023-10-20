// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "IERC20.sol";
import "SafeERC20.sol";
import "IShareToken.sol";

import "ContractGuard.sol";
import "ReentrancyGuard.sol";

import "Ownable.sol";
import "Blacklistable.sol";
import "Pausable.sol";

import "IAlgoVaultRouter.sol";
import "IWrappedToken.sol";
import "IAlgoVaultOracle.sol";

contract AlgoVault is ContractGuard, ReentrancyGuard, Ownable, Blacklistable, Pausable {

    using SafeERC20 for IERC20;
    using Address for address;

    struct TokenInfo {
        address token;
        uint256 amount;
    }

    uint256 public constant DIVISION_PRECISION = 1e6;
    uint256 public constant PRICE_PRECISION = 1e18;

    mapping(address => mapping(address => uint256)) public stakeInfo;
    mapping(address => mapping(address => uint256)) public withdrawInfo;

    mapping(address => uint256) public totalStakeRequest;
    mapping(address => uint256) public totalWithdrawRequest;

    mapping(address => uint256) public minimumRequest;

    address public share;
    address public wrappedToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address[] public baseTokenList;
    address[] public portfolioTokenList;


    uint256 public feeIn;
    uint256 public feeOut;
    uint256 public dailyFee;
    uint256 public instantWithdrawFee;
    uint256 public instantWithdrawFeeRatio;
    address public feeTo;
    uint256 public lastWithdrawTime;

    address public sharePriceOracle;

    uint256 public lockupStartTime;
    uint256 public lockupEndTime;

    bool public initialized;
    mapping (address => bool) public isOperator;

    event StakeRequest(address indexed user, address indexed token, uint256 amount);
    event WithdrawRequest(address indexed user, address indexed token, uint256 amount);
    event InstantWithdrawn(address indexed user, uint256 amount);
    event CancelStakeRequest(address indexed user, address indexed token, uint256 amount);
    event CancelWithdrawRequest(address indexed user, address indexed token, uint256 amount);
    event StakeRequestIgnored(address indexed ignored, uint256 at);
    event WithdrawRequestIgnored(address indexed ignored, uint256 at);
    event HandledStakeRequest(uint256 indexed at, address _address, address stakeTokens, uint256 baseTokenAmount, uint256 stakeShareAmount);
    event HandledWithdrawRequest(uint256 indexed at, address _address, address withdrawTokens, uint256 withdrawTokenAmount, uint256 shareTokenAmount);
    event WithdrawRequestRemoved(uint256 indexed at, address _address, address withdrawTokens, uint256 withdrawShareAmount);
    event FeeUpdated(uint256 indexed _feeIn, uint256 indexed _feeOut);
    event InstantWithdrawFeeUpdated(uint256 indexed _instantWithdrawFee);
    event InstantWithdrawFeeRatioUpdated(uint256 indexed _instantWithdrawFeeRatio);
    event DailyFeeUpdated(uint256 indexed _dailyFee);
    event FeeToUpdated(address indexed _feeTo);
    event OperatorUpdated(address indexed _operator, bool indexed _isActive);
    event MinimumRequestUpdated(address indexed token, uint256 _minimumRequest);
    event LockupTimeUpdated(uint256 indexed _lockupStartTime, uint256 indexed _lockupEndTime);
    event PortfolioTokenListUpdated(uint256 indexed at, address[] newPortfolioTokenList);
    event BaseTokenListUpdated(uint256 indexed at, address[] newBaseTokenList);
    event ShareTokenUpdated(address indexed newToken);
    event SharePriceOracleUpdated(address indexed newOracle);
    event GovernanceWithdrawFunds(address indexed executor, address indexed token, uint256 amount, address to);
    event GovernanceWithdrawFundsETH(address indexed executor, uint256 amount, address to);
    event DailyWithdrawn(address indexed executor, uint256 indexed time);

    modifier onlyOperator() {
        require(isOperator[msg.sender] == true, "caller is not the operator");
        _;
    }

    modifier notInitialized() {
        require(!initialized, "already initialized");
        _;
    }

    modifier whenNotLockup() {
        require(getCurrentMinute() < lockupStartTime || getCurrentMinute() > lockupEndTime, "contract lock up");
        _;
    }

    receive() payable external {}
    
    function initialize (
        address _share,
        uint256 _feeIn,
        uint256 _feeOut,
        uint256 _instantWithdrawFee,
        uint256 _instantWithdrawFeeRatio,
        uint256 _dailyFee,
        address _feeTo,
        uint256 _lockupStartTime,
        uint256 _lockupEndTime,
        uint256 _startTime
    ) public notInitialized {
        require(_share != address(0), "share address can not be zero address");
        require(_feeTo != address(0), "feeTo address can not be zero address");
        
        share = _share;
        feeIn = _feeIn;
        feeOut = _feeOut;
        instantWithdrawFee = _instantWithdrawFee;
        instantWithdrawFeeRatio = _instantWithdrawFeeRatio;
        dailyFee = _dailyFee;
        feeTo = _feeTo;
        lockupStartTime = _lockupStartTime;
        lockupEndTime = _lockupEndTime;
        isOperator[msg.sender] = true;
        lastWithdrawTime = _startTime;

        initialized = true;
    }

    function setFee(uint256 _feeIn, uint256 _feeOut) external onlyOperator {
        require(_feeIn <= 50000 && _feeOut <= 50000, "fee: out of range");
        feeIn = _feeIn;
        feeOut = _feeOut;
        emit FeeUpdated(_feeIn, _feeOut);
    }

    function setInstantWithdrawFee(uint256 _instantWithdrawFee) external onlyOperator {
        require(_instantWithdrawFee <= 50000, "instantWithdrawFee: out of range");
        instantWithdrawFee = _instantWithdrawFee;
        emit InstantWithdrawFeeUpdated(_instantWithdrawFee);
    }

    function setDailyFee(uint256 _dailyFee) external onlyOperator {
        require(_dailyFee <= 500, "dailyFee: out of range");
        dailyFee = _dailyFee;
        emit DailyFeeUpdated(_dailyFee);
    }

    function setInstantWithdrawFeeRatio(uint256 _instantWithdrawFeeRatio) external onlyOperator {
        require(_instantWithdrawFeeRatio <= 1e6, "dailyFee: out of range");
        instantWithdrawFeeRatio = _instantWithdrawFeeRatio;
        emit InstantWithdrawFeeRatioUpdated(_instantWithdrawFeeRatio);
    }

    function setFeeTo(address _feeTo) external onlyOperator {
        require(_feeTo != address(0), "feeTo can not be zero address");
        feeTo = _feeTo;
        emit FeeToUpdated(_feeTo);
    }

    function setOperator(address _operator, bool _isActive) external onlyOwner {
        require(_operator != address(0), "operator address can not be zero address");
        isOperator[_operator] = _isActive;
        emit OperatorUpdated(_operator, _isActive);
    }

    function setShareToken(address _share) external onlyOperator {
        require(_share != address(0), "share token address can not be zero address");
        share = _share;
        emit ShareTokenUpdated(_share);
    }

    function setOracle(address _sharePriceOracle) external onlyOperator {
        require(_sharePriceOracle != address(0), "sharePriceOracle address can not be zero address");
        sharePriceOracle = _sharePriceOracle;
        emit SharePriceOracleUpdated(_sharePriceOracle);
    }

    function pause() external onlyOperator {
        super._pause();
    }

    function unpause() external onlyOperator {
        super._unpause();
    }

    function setMinimumRequest(address token, uint256 _minimumRequest) external onlyOperator {
        minimumRequest[token] = _minimumRequest;
        emit MinimumRequestUpdated(token, _minimumRequest);
    }  

    function setLockupTime(uint256 _lockupStartTime, uint256 _lockupEndTime) external onlyOperator {
        require(_lockupStartTime < 1440, "lockup start time exceeds the limit.");
        require(_lockupEndTime < 1440, "lockup end time exceeds the limit.");
        lockupStartTime = _lockupStartTime;
        lockupEndTime = _lockupEndTime;
        emit LockupTimeUpdated(_lockupStartTime, _lockupEndTime);
    }

    function updatePortfolioTokenList(address[] memory newPortfolioTokenList) external onlyOperator {
        delete portfolioTokenList;
        uint256 length = newPortfolioTokenList.length;
        for (uint256 pid = 0; pid < length; pid++) {
            portfolioTokenList.push(newPortfolioTokenList[pid]);
        }
        emit PortfolioTokenListUpdated(block.number, newPortfolioTokenList);
    } 

    function updateBaseTokenList(address[] memory newBaseTokenList) external onlyOperator {
        delete baseTokenList;
        uint256 length = newBaseTokenList.length;
        for (uint256 pid = 0; pid < length; pid++) {
            baseTokenList.push(newBaseTokenList[pid]);
        }
        emit BaseTokenListUpdated(block.number, newBaseTokenList);
    } 

    function convertToWrappedToken() external payable {
        address user = msg.sender;
        uint256 amount = msg.value;
        IWrappedToken(wrappedToken).deposit{value:amount}();
        IERC20(wrappedToken).safeTransfer(user, amount);
    }

    function convertToNativeToken(uint256 amount) external {
        require(amount != 0, "amount can not be zero");
        address user = msg.sender;
        IERC20(wrappedToken).transferFrom(user, address(this), amount);
        IWrappedToken(wrappedToken).withdraw(amount);
        Address.sendValue(payable(user), amount);
    }

    /* ========== VIEW FUNCTIONS ========== */

    function shareTokenPrice(address baseToken) public view returns (uint256) {
        return IAlgoVaultOracle(sharePriceOracle).shareTokenPrice(baseToken);
    }

    function checkPortfolioTokenList(address token) public view returns (bool) {
        uint length = portfolioTokenList.length;
        for (uint i = 0; i < length; i++) {
            if (token == portfolioTokenList[i])
                return true;
        }
        return false;
    }

    function checkBaseTokenList(address token) public view returns (bool) {
        uint length = baseTokenList.length;
        for (uint i = 0; i < length; i++) {
            if (token == baseTokenList[i])
                return true;
        }
        return false;
    }

    function getTokenBalance(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function getAllPortfolioTokenBalance() public view returns (TokenInfo[] memory _balance) {
        uint256 length = portfolioTokenList.length;
        _balance = new TokenInfo[](length); // Allocate memory for the dynamic array
        for (uint256 pid = 0; pid < length; pid++) {
            address _token = portfolioTokenList[pid];
            _balance[pid].token = _token;
            _balance[pid].amount = getTokenBalance(_token);
        }
    }

    function getTotalStakeRequest() public view returns (TokenInfo[] memory _totalStakeRequest) {
        uint256 length = baseTokenList.length;
        _totalStakeRequest = new TokenInfo[](length); // Allocate memory for the dynamic array
        for (uint256 pid = 0; pid < length; pid++) {
            address _token = baseTokenList[pid];
            _totalStakeRequest[pid].token = _token;
            _totalStakeRequest[pid].amount = totalStakeRequest[_token];
        }
    }

    function getTotalWithdrawRequest() public view returns (TokenInfo[] memory _totalWithdrawRequest) {
        uint256 length = baseTokenList.length;
        _totalWithdrawRequest = new TokenInfo[](length); // Allocate memory for the dynamic array
        for (uint256 pid = 0; pid < length; pid++) {
            address _token = baseTokenList[pid];
            _totalWithdrawRequest[pid].token = _token;
            _totalWithdrawRequest[pid].amount = totalWithdrawRequest[_token];
        }
    }

    // get portfolioTokenList
    function getAllPortfolioTokenList() public view returns (address[] memory) {
        return portfolioTokenList;
    }
    
    // get baseTokenList
    function getAllBaseTokenList() public view returns (address[] memory) {
        return baseTokenList;
    }

    // get portfolio
    function getPortfolio() public view returns (TokenInfo[] memory _portfolio) {
        uint256 length = portfolioTokenList.length;
        _portfolio = new TokenInfo[](length); // Allocate memory for the dynamic array
        for (uint256 pid = 0; pid < length; pid++) {
            address _token = portfolioTokenList[pid];
            if (checkBaseTokenList(_token) == true) {
                _portfolio[pid].token = _token;
                _portfolio[pid].amount = getTokenBalance(_token) - totalStakeRequest[_token];
            } else {
                _portfolio[pid].token = _token;
                _portfolio[pid].amount = getTokenBalance(_token);
            }
        }
    }

    // Get the timestamp of the current block and convert it to minutes
    function getCurrentMinute() public view returns (uint) {
        return (block.timestamp / 60) % 1440;
    }

    function calculateShareTokenAmount(address baseToken, uint256 baseTokenAmount) public view returns (uint256) {
        require(baseTokenAmount != 0, "base token amount can not be zero");
        return baseTokenAmount * PRICE_PRECISION / shareTokenPrice(baseToken);
    }

    function calculateBaseTokenAmount(address baseToken, uint256 shareTokenAmount) public view returns (uint256) {
        require(shareTokenAmount != 0, "share token amount can not be zero");
        return shareTokenAmount * shareTokenPrice(baseToken) / PRICE_PRECISION;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function stakeRequest(address token, uint256 amount) external onlyOneBlock notBlacklisted(msg.sender) whenNotPaused whenNotLockup {
        require(amount >= minimumRequest[token], "stake amount too low");
        require(checkBaseTokenList(token) == true, "token address is not in the baseTokenList");
        if (feeIn > 0) {
            uint fee = amount * feeIn / DIVISION_PRECISION;
            amount = amount - fee;
            IERC20(token).safeTransferFrom(msg.sender, feeTo, fee);
        }
        stakeInfo[msg.sender][token] += amount;
        totalStakeRequest[token] += amount;
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        emit StakeRequest(msg.sender, token, amount);
    }

    function withdrawRequest(address token, uint256 amount) external notBlacklisted(msg.sender) whenNotPaused whenNotLockup {
        require(amount != 0, "withdraw request cannot be equal to 0");
        require(checkBaseTokenList(token) == true, "token address is not in the baseTokenList");
        uint256 _balance = IERC20(share).balanceOf(msg.sender);
        require(amount <= _balance, "withdraw amount exceeds the balance");
        withdrawInfo[msg.sender][token] += amount;
        totalWithdrawRequest[token] += amount;
        IERC20(share).safeTransferFrom(msg.sender, address(this), amount);
        emit WithdrawRequest(msg.sender, token, amount);
    }


    function instantWithdraw(uint256 amount) external notBlacklisted(msg.sender) whenNotPaused whenNotLockup {
        require(amount != 0, "withdraw request cannot be equal to 0");
        uint256 _balance = IERC20(share).balanceOf(msg.sender);
        require(amount <= _balance, "withdraw amount exceeds the balance");
        uint256 shareTotalSupply = IERC20(share).totalSupply();
        uint256 shareRatio = amount * PRICE_PRECISION / shareTotalSupply;
        IShareToken(share).burn(msg.sender, amount);
        for (uint i = 0; i < portfolioTokenList.length; i++) {
            address token = portfolioTokenList[i];
            uint256 token_balance = getTokenBalance(token) - totalStakeRequest[token];
            uint256 withdrawAmount = token_balance * shareRatio / PRICE_PRECISION;
            if (withdrawAmount != 0) {
                if (instantWithdrawFee > 0) {
                    uint fee = withdrawAmount * instantWithdrawFee / DIVISION_PRECISION;
                    withdrawAmount = withdrawAmount - fee;
                    uint _fee = fee * instantWithdrawFeeRatio / DIVISION_PRECISION;
                    IERC20(token).safeTransfer(feeTo, _fee);
                }
                IERC20(token).safeTransfer(msg.sender, withdrawAmount);
            }
        }
        emit InstantWithdrawn(msg.sender, amount);
    }


    function cancelStakeRequest(address token) external onlyOneBlock notBlacklisted(msg.sender) whenNotPaused whenNotLockup {
        uint amount = stakeInfo[msg.sender][token];
        require(amount != 0, "staked token amount can not be zero");
        totalStakeRequest[token] -= amount;
        delete stakeInfo[msg.sender][token];
        IERC20(token).safeTransfer(msg.sender, amount);  
        emit CancelStakeRequest(msg.sender, token, amount);   
    }

    function cancelWithdrawRequest(address token) external onlyOneBlock notBlacklisted(msg.sender) whenNotPaused whenNotLockup {
        uint amount = withdrawInfo[msg.sender][token];
        require(amount != 0, "withdraw token amount can not be zero");
        totalWithdrawRequest[token] -= amount;
        delete withdrawInfo[msg.sender][token];
        IERC20(share).safeTransfer(msg.sender, amount);
        emit CancelWithdrawRequest(msg.sender, token, amount);   
    }

    function handleStakeRequest(address[] memory _address, address[] memory stakeTokens) external onlyOperator {
        require(_address.length == stakeTokens.length, "array length mismatch");
        for (uint i = 0; i < _address.length; i++) {
            address user = _address[i];
            address token = stakeTokens[i];
            uint256 baseTokenAmount = stakeInfo[user][token];
            if (baseTokenAmount == 0) { 
                continue;
            }
            uint256 stakeShareAmount = calculateShareTokenAmount(token, baseTokenAmount);
            IShareToken(share).mint(user, stakeShareAmount);
            totalStakeRequest[token] -= baseTokenAmount;
            delete stakeInfo[user][token];
            emit HandledStakeRequest(block.number, user, token, baseTokenAmount, stakeShareAmount);
        }
    }

    function handleWithdrawRequest(address[] memory _address, address[] memory withdrawTokens) external onlyOperator {
        require(_address.length == withdrawTokens.length, "array length mismatch");
        for (uint i = 0; i < _address.length; i++) {
            address user = _address[i];
            address token = withdrawTokens[i];
            uint256 shareTokenAmount = withdrawInfo[user][token];
            if (shareTokenAmount == 0) {
                continue;
            }
            uint256 withdrawTokenAmount = calculateBaseTokenAmount(token, shareTokenAmount);
            if (feeOut > 0) {
                uint fee = withdrawTokenAmount * feeOut / DIVISION_PRECISION;
                withdrawTokenAmount = withdrawTokenAmount - fee;
                IERC20(token).safeTransfer(feeTo, fee);
            }
            IShareToken(share).burn(address(this), shareTokenAmount);
            IERC20(token).safeTransfer(user, withdrawTokenAmount);
            totalWithdrawRequest[token] -= shareTokenAmount;
            delete withdrawInfo[user][token];
            emit HandledWithdrawRequest(block.number, user, token, withdrawTokenAmount, shareTokenAmount);
        }
    }

    function removeWithdrawRequest(address[] memory _address, address[] memory tokens) external onlyOperator {
        require(_address.length == tokens.length, "array length mismatch");
        for (uint i = 0; i < _address.length; i++) {
            address user = _address[i];
            address token = tokens[i];
            uint withdrawShareAmount = withdrawInfo[user][token];
            IERC20(share).safeTransfer(user, withdrawShareAmount);
            totalWithdrawRequest[token] -= withdrawShareAmount;
            delete withdrawInfo[user][token];
            emit WithdrawRequestRemoved(block.number, user, token, withdrawShareAmount);
        }      
    }

    function withdrawFunds(address _token, uint256 amount, address to) public onlyOperator {
        require(to != address(0), "to address can not be zero address");
        IERC20(_token).safeTransfer(to, amount);
        emit GovernanceWithdrawFunds(msg.sender, _token, amount, to);
    }

    function withdrawFundsETH(uint256 amount, address to) public nonReentrant onlyOperator {
        require(to != address(0), "to address can not be zero address");
        Address.sendValue(payable(to), amount);
        emit GovernanceWithdrawFundsETH(msg.sender, amount, to);
    }

    function dailyWithdraw() external nonReentrant onlyOperator {
        require(block.timestamp - lastWithdrawTime > 86400, "can not withdraw");
        uint epochs = (block.timestamp - lastWithdrawTime) / 86400;
        for (uint i = 0; i < portfolioTokenList.length; i++) {
            address token = portfolioTokenList[i];
            uint256 token_balance = getTokenBalance(token) - totalStakeRequest[token];
            if (token_balance != 0) {
                uint256 withdrawAmount = token_balance * dailyFee * epochs / DIVISION_PRECISION;  
                withdrawFunds(token, withdrawAmount, feeTo);
            }
        }
        lastWithdrawTime = block.timestamp;
        emit DailyWithdrawn(msg.sender, block.timestamp);
    }

    function executeAction(
        address internalRouter,
        address externalRouter,
        address fromTokenAddress,
        address toTokenAddress,
        uint256 amount,
        bytes memory data
    ) public onlyOperator {
        IERC20(fromTokenAddress).safeApprove(internalRouter, 0);
        IERC20(fromTokenAddress).safeApprove(internalRouter, amount);
        IAlgoVaultRouter(internalRouter).executeWithData(externalRouter, fromTokenAddress, toTokenAddress, amount, address(this), data, true);
    }

    function batchExecuteActions(
        address[] memory internalRouter,
        address[] memory externalRouter,
        address[] memory fromTokenAddresses,
        address[] memory toTokenAddresses,
        uint256[] memory amounts,
        bytes[] memory data
    ) external onlyOperator {
        require(fromTokenAddresses.length == internalRouter.length, "address array length mismatch");
        require(fromTokenAddresses.length == externalRouter.length, "address array length mismatch");
        require(fromTokenAddresses.length == toTokenAddresses.length, "address array length mismatch");
        require(fromTokenAddresses.length == amounts.length, "amount array length mismatch");
        require(fromTokenAddresses.length == data.length, "data array length mismatch");
        for (uint i = 0; i < fromTokenAddresses.length; i++) {
            address _internalRouter = internalRouter[i];
            address _externalRouter = externalRouter[i];
            address fromTokenAddress = fromTokenAddresses[i];
            address toTokenAddress = toTokenAddresses[i];
            uint256 amount = amounts[i];
            bytes memory _data = data[i];
            executeAction(_internalRouter, _externalRouter, fromTokenAddress, toTokenAddress, amount, _data);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.13;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "IERC20.sol";
import "Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.13;

import "IERC20.sol";

interface IShareToken is IERC20 {
    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

contract ContractGuard {
    mapping(uint256 => mapping(address => bool)) private _status;

    function checkSameOriginReentranted() internal view returns (bool) {
        return _status[block.number][tx.origin];
    }

    function checkSameSenderReentranted() internal view returns (bool) {
        return _status[block.number][msg.sender];
    }

    modifier onlyOneBlock() {
        require(!checkSameOriginReentranted(), "ContractGuard: one block, one function");
        require(!checkSameSenderReentranted(), "ContractGuard: one block, one function");

        _status[block.number][tx.origin] = true;
        _status[block.number][msg.sender] = true;

        _;
    }
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity 0.8.13;

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
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "Context.sol";
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
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

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
}/**
 * SPDX-License-Identifier: MIT
 *
 * Copyright (c) 2018-2020 CENTRE SECZ
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

pragma solidity 0.8.13;

import "Ownable.sol";

abstract contract Blacklistable is Ownable {
    address internal _blacklister;
    mapping(address => bool) internal _blacklisted;

    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);
    event BlacklisterChanged(address indexed newBlacklister);

    /**
     * @notice Throw if called by any account other than the blacklister
     */
    modifier onlyBlacklister() {
        require(msg.sender == _blacklister, "caller is not the blacklister");
        _;
    }

    /**
     * @notice Throw if argument account is blacklisted
     * @param account The address to check
     */
    modifier notBlacklisted(address account) {
        require(!_blacklisted[account], "account is blacklisted");
        _;
    }

    /**
     * @notice Blacklister address
     * @return Address
     */
    function blacklister() external view returns (address) {
        return _blacklister;
    }

    /**
     * @notice Check whether a given account is blacklisted
     * @param account The address to check
     */
    function isBlacklisted(address account) external view returns (bool) {
        return _blacklisted[account];
    }

    /**
     * @notice Add an account to blacklist
     * @param account The address to blacklist
     */
    function blacklist(address account) external onlyBlacklister {
        _blacklisted[account] = true;
        emit Blacklisted(account);
    }

    /**
     * @notice Remove an account from blacklist
     * @param account The address to remove from the blacklist
     */
    function unBlacklist(address account) external onlyBlacklister {
        _blacklisted[account] = false;
        emit UnBlacklisted(account);
    }

    /**
     * @notice Change the blacklister
     * @param newBlacklister new blacklister's address
     */
    function updateBlacklister(address newBlacklister) external onlyOwner {
        require(
            newBlacklister != address(0),
            "new blacklister is the zero address"
        );
        _blacklister = newBlacklister;
        emit BlacklisterChanged(_blacklister);
    }
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity 0.8.13;

import "Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool internal _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IAlgoVaultRouter {
    function executeWithData(
        address externalRouter,
        address fromTokenAddress, 
        address toTokenAddress, 
        uint256 amount, 
        address receiver,
        bytes memory data, 
        bool restriction
    ) external;
}// SPDX-License-Identifier: MIT

import "IERC20.sol";

pragma solidity 0.8.13;

interface IWrappedToken is IERC20 {
    
    function deposit() external payable;

    function withdraw(uint256 amount) external;
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IAlgoVaultOracle {

    function shareTokenPrice(address token) external view returns (uint256);

}