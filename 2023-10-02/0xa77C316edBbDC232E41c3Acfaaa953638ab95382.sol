// SPDX-License-Identifier: MIT


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// File: contracts/Fiverr/parifinance/parifinanceV3.sol


pragma solidity ^0.8.0;




library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}



interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}

contract ParFinance is Ownable {
    using SafeMath for uint256;

    uint256 public constant BASE = 10**18;
    uint256 public constant DIVIDEND_PERCENTAGE = 10;
    uint256 public constant CASHBACK_PERCENTAGE = 15;
    uint256 public constant APR = 12;
    uint256 public constant MAX_LTV = 80;
    // uint256 public constant LIQUIDATION_THRESHOLD = 49;
    uint256 public constant WITHDRAWAL_FEE = 39;
    uint256 public constant BORROWING_FEE = 39;
    // uint256 public constant BORROWING_UTILIZATION_THRESHOLD = 80;
    // uint256 public constant BORROWING_INTEREST_RATE = 12;
    // uint256 public constant BORROWING_INTEREST_RATE_THRESHOLD = 30;
    uint256 public constant maxLendAmount = 9000 * BASE;
    uint256 public constant maxBNBDeposit = 30 * BASE;
    uint256 public constant maxBETHDeposit = 5 * BASE;
    uint256 public constant maxADADeposit = 39000 * BASE;
    uint256 public constant depositFee = 0.001 ether;



    uint256 public depositFeeCollected;
    uint256 public lendingApr = 1020;

    uint256 public totalBorrowings;


    //tokens
    address public dai;
    address public usdc;
    address public usdt;

    //deposit tokens
    address public eth;
    address public ada;

    //price feeds
    address private daiPriceFeed;
    address private usdcPriceFeed;
    address private usdtPriceFeed;
    address private ethPriceFeed;
    address private adaPriceFeed;


    struct Token {
        address tokenAddress;
        uint256 balance;
    }

    struct Collateral {
        address tokenAddress;
        uint256 amount;
        uint256 depositTime;
    }

    struct Lend {
        address tokenAddress;
        uint256 amount;
        uint256 lastDepositTime;
    }

    struct Loan {
        uint256 id;
        address borrower;
        address token;
        uint256 amount;
        address collatToken;
        uint256 bnbCollateral;
        uint256 tokenCollateral;
        uint256 apr;
        uint256 startTimestamp;
        bool active;
    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 APY;
        uint256 totalInterest;
        uint256 totalDeposited;
        uint256 totalBorrowed;
        uint256 dividendReward;
        uint256 lastCalculatedInterest;
        uint256 lastCalculatedBorrow;
    }

    struct depositToken {
        address tokenAddress;
        uint256 balance;
    }

    struct diviDend {
        uint256 amount;
        uint256 lastCalculatedDividend;
        uint256 lastRewardTimeStamp;
    }

    address [] public lendingTokens;

    mapping(address => uint256) public totalDividend;
    mapping(address => depositToken) public deposittokens;
    mapping (address => PoolInfo) public pools;
    mapping(address => Token) public tokens;
    mapping (address => uint256) public bnbCollat;
    mapping(address =>mapping(address => Collateral)) public collatDet;
    mapping(address =>mapping(address => Lend)) public lendDet;
    mapping(address =>mapping(address => uint256)) public earnedInterest;
    mapping(address => uint256) public borrowingDebt;
    mapping(address => Loan[]) public loansByBorrower;
    mapping (address => mapping(address => diviDend)) public totalBorrowedAmountByUser;
    mapping (address => bool) private lenders;
    mapping (address => bool) private borrowers;
    mapping (address => uint256) public adminFee;
    mapping (address => uint256) public totalDeposits;


    event NewDeposit(address indexed from, address indexed tokenAddress, uint256 amount);
    event NewWithdrawal(address indexed from, address indexed tokenAddress, uint256 amount, uint256 fee);
    event NewLoan(address indexed borrower, uint256 amount, uint256 collateral);
    event LoanRepayed(uint256 indexed loanId, address indexed borrower, uint256 amount, uint256 interest);
    event DividendPaid(address indexed to, uint256 amount);
    event CashbackPaid(address indexed to, uint256 amount);

    constructor(address _daiPriceFeed,address _usdcPriceFeed,address _usdtPriceFeed, address _ethPriceFeed, address _adaPriceFeed, address _dai, address _usdc, address _usdt, address _eth, address _ada) {
        daiPriceFeed = _daiPriceFeed;
        usdcPriceFeed = _usdcPriceFeed;
        usdtPriceFeed = _usdtPriceFeed;
        ethPriceFeed = _ethPriceFeed;
        adaPriceFeed = _adaPriceFeed;


        tokens[_dai] = Token(_dai, 0);
        tokens[_usdc] = Token(_usdc, 0);
        tokens[_usdt] = Token(_usdt, 0);
        deposittokens[_eth] = depositToken(_eth, 0);
        deposittokens[_ada] = depositToken(_ada, 0);

        dai = _dai;
        usdc = _usdc;
        usdt = _usdt;
        eth = _eth;
        ada = _ada;

        lendingTokens.push(dai);
        lendingTokens.push(usdc);
        lendingTokens.push(usdt);

    }

function addPool(IERC20 _lpToken, uint256 _APY, uint256 _totalInterest, uint256 _totalDeposited,uint256 _totalBorrowed)public onlyOwner {
    require(tokens[address(_lpToken)].tokenAddress != address(0), "Invalid token address");

    pools[address(_lpToken)] = PoolInfo({
        lpToken: _lpToken,
        APY: _APY,
        totalInterest: _totalInterest,
        totalDeposited:_totalDeposited,
        totalBorrowed:_totalBorrowed,
        dividendReward: 0,
        lastCalculatedInterest:0,
        lastCalculatedBorrow:0
    });
}

function addLiquidity( address _lpTokenAddress, uint256 amount) public onlyOwner{
    require(amount > 0, "Amount must be greater than 0");
    pools[_lpTokenAddress].lpToken.transferFrom(msg.sender, address(this), amount);

    pools[_lpTokenAddress].totalDeposited += amount;
    tokens[_lpTokenAddress].balance += amount;
    totalDeposits[_lpTokenAddress] += amount;
}

function depositTokenCollat(address tokenAddress, uint256 amount) public payable {
    uint256 maxDeposit = tokenAddress == eth ? maxBETHDeposit : maxADADeposit;
    require(amount > 0 && amount <= maxDeposit, "Invalid Amount");
    require(tokenAddress != address(0), "Invalid token address");
    require(msg.value == depositFee, "Wrong Fee");
    depositToken storage deposittoken = deposittokens[tokenAddress];
    require(deposittoken.tokenAddress == tokenAddress, "Invalid token address");

    IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
    deposittoken.balance += amount;
    totalDeposits[tokenAddress] += amount;

    depositFeeCollected += msg.value;

    collatDet[msg.sender][deposittoken.tokenAddress].tokenAddress = deposittoken.tokenAddress;
    collatDet[msg.sender][deposittoken.tokenAddress].amount += amount;
    collatDet[msg.sender][deposittoken.tokenAddress].depositTime = block.timestamp;

    emit NewDeposit(msg.sender, tokenAddress, amount);
}

function depositBNB() public payable {
    require(msg.value > 0 && msg.value <= maxBNBDeposit , "Invalid amount");

    bnbCollat[msg.sender] += msg.value - depositFee;
    depositFeeCollected += depositFee;
    payable(address(this)).transfer(msg.value);
    emit NewDeposit(msg.sender, address(this), msg.value);
}

receive() external payable{}

function withdrawToken(address tokenAddress, uint256 amount) public {
    require(amount > 0, "Amount must be greater than 0");
    Token storage token = tokens[tokenAddress];
    require(token.tokenAddress != address(0), "Invalid token address");
    require(amount <= token.balance, "Insufficient balance");

    PoolInfo storage pool = pools[tokenAddress];
    require(address(pool.lpToken) != address(0), "Invalid token address");

    uint256 fee = (amount * WITHDRAWAL_FEE) / 10000;

    uint256 dividendAmt = (fee * DIVIDEND_PERCENTAGE).div(100);

    totalDividend[tokenAddress] += dividendAmt;

    adminFee[tokenAddress] += fee.sub(dividendAmt);
        
    uint256 netAmount = amount - fee;

    require(netAmount + fee <= lendDet[msg.sender][tokenAddress].amount, "Don't have enough tokens");


    token.balance -= amount;

    lendDet[msg.sender][token.tokenAddress].amount -= amount;
    pool.totalDeposited -= amount;

    totalDeposits[tokenAddress] -= amount;

    IERC20(tokenAddress).transfer(msg.sender, netAmount);

    if(lendDet[msg.sender][token.tokenAddress].amount == 0){
        lenders[msg.sender] = false;
    }

    emit NewWithdrawal(msg.sender, tokenAddress, netAmount, fee);
}

function withdrawBNBCollat(uint256 amount)public {
    require(amount <=bnbCollat[msg.sender], "You don't have enough balance.");
    uint256 repaid = 0;
    uint256 notRepaid = 0;
    uint256 loans = loansByBorrower[msg.sender].length;
    if(loans > 0){
    for (uint256 i= 0; i <loans; i++){
        if(loansByBorrower[msg.sender][i].active == false){
           repaid++;
        }else if(loansByBorrower[msg.sender][i].active == true){
            notRepaid++;
        }
    }
        require(notRepaid == 0, "You have active loan to repay");
        bnbCollat[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }else{
        bnbCollat[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

}

//withdraw token collat
function withdrawTokenCollat(address _token, uint256 amount)public {
    require(amount <=collatDet[msg.sender][_token].amount, "You don't have enough balance.");
    require(_token == collatDet[msg.sender][_token].tokenAddress, "No collateral" );
    require(amount <= IERC20(_token).balanceOf(address(this)), "Not enough balance.");
    uint256 repaid = 0;
    uint256 notRepaid = 0;
    uint256 loans = loansByBorrower[msg.sender].length;
    if(loans > 0){
    for (uint256 i= 0; i <loans; i++){
        if(loansByBorrower[msg.sender][i].active == false){
           repaid++;
        }else if(loansByBorrower[msg.sender][i].active == true){
            notRepaid++;
        }
    }
        require(notRepaid == 0, "You have active loan to repay");
        collatDet[msg.sender][_token].amount -= amount;
        totalDeposits[_token] -= amount;
        IERC20(_token).transfer(msg.sender, amount);
    }else{
        collatDet[msg.sender][_token].amount -= amount;
        totalDeposits[_token] -= amount;
        IERC20(_token).transfer(msg.sender, amount);
    }

}

// admin withdraw
function withdraw(address tokenAddress) external onlyOwner{
        require(tokenAddress!= address(0), "Invalid token address");
        uint256 amount = adminFee[tokenAddress];
        require(amount > 0, "No amount");
        require(amount <= IERC20(tokenAddress).balanceOf(address(this)), "Not enough balance");

        adminFee[tokenAddress] = 0;

        IERC20(tokenAddress).transfer(owner(), amount);
}

function withdrawBNBFee() external onlyOwner{
    require(depositFeeCollected > 0 , "No fee to withdraw");

    uint256 amount = depositFeeCollected;

    depositFeeCollected = 0;

    payable(owner()).transfer(amount);
}


//borrow with token
function borrowWithToken(address tokenAddress, uint256 amount, address collateralToken) public {
    require(amount > 0, "Amount must be greater than 0");
    require(lenders[msg.sender] == false, "Lenders can't borrow");
    require(tokens[tokenAddress].tokenAddress != address(0), "Invalid token address");

    PoolInfo storage pool = pools[tokenAddress];
    require(address(pool.lpToken) != address(0) && address(pool.lpToken) == tokenAddress, "Invalid token address");
    require(IERC20(pool.lpToken).balanceOf(address(this)) >= amount, "Not enough token");

    uint256 collateralAmount = calculateTokenCollateralValue(collateralToken, tokenAddress, amount, msg.sender);

    uint256 maxCollateral = ((collatDet[msg.sender][collateralToken].amount) * MAX_LTV) / 100;
    require(collateralAmount > 0 && collateralAmount.add(calculateCollateralAmount(msg.sender, collateralToken)) <= maxCollateral, "Invalid collateral amount");


    uint256 borrowingInterest = APR;

    uint256 borrowingFee = (amount * BORROWING_FEE) / 10000;
    // uint256 interest = (amount * borrowingInterest) / 100;

    uint256 dividendAmt = (borrowingFee * DIVIDEND_PERCENTAGE).div(100);

    totalDividend[tokenAddress] += dividendAmt;

    adminFee[tokenAddress] += (borrowingFee).sub(dividendAmt);

    uint256 remainingAmount = (amount - borrowingFee);

    tokens[tokenAddress].balance -= amount;
    totalBorrowings += amount;

    pool.totalBorrowed += amount;

    Loan memory loan = Loan({
        id: loansByBorrower[msg.sender].length + 1,
        borrower: msg.sender,
        token: tokenAddress,
        collatToken: collateralToken,
        amount: amount,
        bnbCollateral: 0,
        tokenCollateral: collateralAmount,
        apr: borrowingInterest,
        startTimestamp: block.timestamp,
        active: true
    });

    loansByBorrower[msg.sender].push(loan);

    // borrowingCollateral[collateralToken] += collateralAmount;
    borrowingDebt[tokenAddress] += amount;
    totalBorrowedAmountByUser[msg.sender][tokenAddress].amount += amount;
    totalBorrowedAmountByUser[msg.sender][tokenAddress].lastCalculatedDividend = totalDividend[tokenAddress];
    if(totalBorrowedAmountByUser[msg.sender][tokenAddress].lastRewardTimeStamp == 0){
        totalBorrowedAmountByUser[msg.sender][tokenAddress].lastRewardTimeStamp = block.timestamp;
    }

    totalDeposits[tokenAddress] -= amount;

    IERC20(tokenAddress).transfer(msg.sender, remainingAmount);

    borrowers[msg.sender] = true;

    emit NewLoan(msg.sender, amount, collateralAmount);
}

function borrowWithBNB(address tokenAddress, uint256 amount) public {
    require(amount > 0, "Amount must be greater than 0");
    require(lenders[msg.sender] == false, "Lenders can't borrow");
    Token storage token = tokens[tokenAddress];
    require(token.tokenAddress != address(0), "Invalid token address");

    PoolInfo storage pool = pools[tokenAddress];
    require(address(pool.lpToken) != address(0), "Invalid token address");
    require(IERC20(pool.lpToken).balanceOf(address(this)) >= amount, "Not enough token");

    uint256 collateralAmount = calculateBNBCollateralValue(tokenAddress, amount, msg.sender);

    uint256 maxCollateral = (bnbCollat[msg.sender] * MAX_LTV) / 100;
    require(collateralAmount > 0 && collateralAmount.add(calculateCollateralAmount(msg.sender, address(0))) <= maxCollateral, "Invalid collateral amount");


    uint256 borrowingInterest = APR;

    uint256 borrowingFee = (amount * BORROWING_FEE) / 10000;

    uint256 dividendAmt = (borrowingFee * DIVIDEND_PERCENTAGE).div(100);

    totalDividend[tokenAddress] += dividendAmt;

    adminFee[tokenAddress] += (borrowingFee).sub(dividendAmt);

    uint256 remainingAmount = (amount - borrowingFee);

    
    token.balance -= amount;
    totalBorrowings += amount;

    pool.totalBorrowed += amount;

    Loan memory loan = Loan({
        id: loansByBorrower[msg.sender].length + 1,
        borrower: msg.sender,
        token: tokenAddress,
        collatToken: address(0),
        amount: amount,
        bnbCollateral: collateralAmount,
        tokenCollateral: 0,
        apr: borrowingInterest,
        startTimestamp: block.timestamp,
        active: true
    });

    loansByBorrower[msg.sender].push(loan);
    borrowingDebt[tokenAddress] += amount;

    totalBorrowedAmountByUser[msg.sender][tokenAddress].amount += amount;
    totalBorrowedAmountByUser[msg.sender][tokenAddress].lastCalculatedDividend = totalDividend[tokenAddress];
    if(totalBorrowedAmountByUser[msg.sender][tokenAddress].lastRewardTimeStamp == 0){
        totalBorrowedAmountByUser[msg.sender][tokenAddress].lastRewardTimeStamp = block.timestamp;
    }

    totalDeposits[tokenAddress] -= amount;

    IERC20(tokenAddress).transfer(msg.sender, remainingAmount);

    borrowers[msg.sender] = true;

    emit NewLoan(msg.sender, amount, amount);
}

function lend(address tokenAddress, uint256 _amount) public {
    require(borrowers[msg.sender] == false, "Borrowers can't be lender");
    require(_amount > 0 && _amount <= maxLendAmount, "Invalid amount");
    require(tokenAddress != address(0), "Invalid token address");
    require(tokens[tokenAddress].tokenAddress != address(0), "Invalid token address");
    require(address(pools[tokenAddress].lpToken) != address(0), "Invalid token address");

    tokens[tokenAddress].balance += _amount;
    totalDeposits[tokenAddress] += _amount;

    pools[tokenAddress].totalDeposited += _amount;

    uint256 intAmount = calculateInterest(tokenAddress);

    lendDet[msg.sender][tokens[tokenAddress].tokenAddress].tokenAddress = tokens[tokenAddress].tokenAddress;
    lendDet[msg.sender][tokens[tokenAddress].tokenAddress].amount += _amount;
    lendDet[msg.sender][tokens[tokenAddress].tokenAddress].lastDepositTime = block.timestamp;

    lenders[msg.sender] = true;
    earnedInterest[msg.sender][tokens[tokenAddress].tokenAddress] += intAmount;

    IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);

    emit NewDeposit(msg.sender, tokenAddress, _amount);

}


function repayLoan(uint256 loanId, address _token) public {
    Loan storage loan = loansByBorrower[msg.sender][loanId];
    require(loan.active, "Loan is not active");
    require(loan.token == _token, "Invalid Token");

    Token storage token = tokens[_token];
    PoolInfo storage pool = pools[_token];

    uint256 time = (block.timestamp).sub(loan.startTimestamp);

    uint256 loanInterest = (((loan.amount).mul(loan.apr)).mul(time)).div(365 days * 100);

    uint256 cashback = (loanInterest * CASHBACK_PERCENTAGE) / 100;

    uint256 netInterest = loanInterest.sub(cashback);

    uint256 netRepayment = ((loan.amount).add(loanInterest));

    totalBorrowedAmountByUser[msg.sender][token.tokenAddress].amount -= loan.amount;

    token.balance += netRepayment;

    pool.totalBorrowed -= loan.amount;

    pool.totalInterest += netInterest;

    borrowingDebt[_token] -= loan.amount;
    loan.bnbCollateral = 0;
    loan.tokenCollateral = 0;

    totalDeposits[_token] += loan.amount;

    IERC20(token.tokenAddress).transferFrom(msg.sender, address(this), netRepayment);

    IERC20(token.tokenAddress).transfer(loan.borrower, cashback);

    loan.active = false;
    
    uint256 repaid = 0;
    uint256 notRepaid = 0;

    uint256 loans = loansByBorrower[msg.sender].length;
    for (uint256 i= 0; i <loans; i++){
        if(loansByBorrower[msg.sender][i].active == false){
           repaid++;
        }else if(loansByBorrower[msg.sender][i].active == true){
            notRepaid++;
        }
    }
    
    if(notRepaid == 0){
        borrowers[msg.sender] = false;
    }
    emit LoanRepayed(loanId, loan.borrower, loan.amount, loanInterest);

}


function loanToInterest(uint256 loanId, address _owner) public view returns(uint256){
    Loan storage loan = loansByBorrower[_owner][loanId];
    require(loan.active, "Loan is not active");
    
    uint256 time = ((block.timestamp).sub(loan.startTimestamp)).add(90);

    uint256 loanInterest = (((loan.amount).mul(loan.apr)).mul(time)).div(365 days * 100);

    uint256 netRepayment = ((loan.amount).add(loanInterest));

    return netRepayment;
}

function claimReward(address _token) public {
    require(totalBorrowedAmountByUser[msg.sender][_token].amount > 0, "Nothing to claim");
    // require(block.timestamp.sub(totalBorrowedAmountByUser[msg.sender][_token].lastRewardTimeStamp) > 1 days, "Claim after 1 day");

    uint256 lastDivAmt = (totalDividend[_token]).sub(totalBorrowedAmountByUser[msg.sender][_token].lastCalculatedDividend);

    uint256 rewardPerToken = calculateDividends(_token, lastDivAmt);

    uint256 rewardAmount = ((totalBorrowedAmountByUser[msg.sender][_token].amount).mul(rewardPerToken)).div(BASE);
    require(rewardAmount > 0, "No Reward");
    require(rewardAmount <= IERC20(_token).balanceOf(address(this)), "Not enough balance");
    IERC20(_token).transfer(msg.sender, rewardAmount);
    totalBorrowedAmountByUser[msg.sender][_token].lastRewardTimeStamp = block.timestamp;
}

function calculateInterest(address _token) internal view returns(uint256){
    uint256 timeDiff = (block.timestamp).sub(lendDet[msg.sender][_token].lastDepositTime);

    uint256 interestAmt = (((lendDet[msg.sender][_token].amount).mul(lendingApr)).mul(timeDiff)).div(10000 * 365 days);

    return interestAmt;
}

function claimInterest(address _token) public {
    require(lendDet[msg.sender][_token].amount > 0, "Nothing to claim");
    PoolInfo storage pool = pools[_token];

    uint256 interestAmt = calculateInterest( _token);

    require(interestAmt > 0 && interestAmt <= pool.totalInterest, "No interest");

    uint256 totalInterest = earnedInterest[msg.sender][_token] + interestAmt;
    require(totalInterest <= IERC20(_token).balanceOf(address(this)), "Not enough balance");

    earnedInterest[msg.sender][_token] = 0;

    IERC20(_token).transfer(msg.sender, interestAmt);

    lendDet[msg.sender][_token].lastDepositTime = block.timestamp;
}

function calculateDividends(address _token, uint256 lastDivAmt) internal view returns(uint256){

    PoolInfo storage pool = pools[_token];

    uint256 reward = (lastDivAmt.mul(BASE)).div(pool.totalBorrowed);

    return reward;
}


function calculateBNBCollateralValue(address _token, uint256 _amount, address _owner) public view returns (uint256) {
    uint256 bnbBalance = bnbCollat[_owner];
    require(bnbBalance > 0, "No collateral");
    uint256 price;
    uint256 decimals;
    (price, decimals) = getPrice(_token);
    return (_amount * price).div(10 ** (decimals));
}

function calculateTokenCollateralValue(address collatToken, address _token, uint256 _amount, address _owner) public view returns (uint256) {
    uint256 tokenCollatBalance = collatDet[_owner][collatToken].amount;
    require(tokenCollatBalance > 0, "No collateral");
    uint256 collatprice;
    uint256 collatdecimals;
    (collatprice, collatdecimals) = getPrice(collatToken);

    uint256 tokenprice;
    uint256 tokendecimals;
    (tokenprice, tokendecimals) = getPrice(_token);
    return (_amount * tokenprice).div(collatprice);
}

function getPrice(address _token) public view returns (uint256, uint256) {
    AggregatorV3Interface priceFeed;
    if(_token == dai){
        priceFeed = AggregatorV3Interface(daiPriceFeed);
    }else if(_token == usdc){
        priceFeed = AggregatorV3Interface(usdcPriceFeed);
    }else if(_token == usdt){
        priceFeed = AggregatorV3Interface(usdtPriceFeed);
    }else if(_token == eth){
        priceFeed = AggregatorV3Interface(ethPriceFeed);
    }else if(_token == ada){
        priceFeed = AggregatorV3Interface(adaPriceFeed);
    }
    (,int256 price,,,) = priceFeed.latestRoundData();
    uint256 decimals = priceFeed.decimals();
    return (uint256(price), uint256(decimals));
}



function calculateCollateralAmount(address _owner, address _collatToken) internal view returns(uint256){
    uint256 collatAmount = 0;
    uint256 loans = loansByBorrower[_owner].length;
    if(loans > 0){
    for (uint256 i= 0; i <loans; i++) {
        Loan storage loan = loansByBorrower[msg.sender][i];

        if(_collatToken == address(0)){
            collatAmount += loan.bnbCollateral;
        }else if(_collatToken == loan.collatToken){
            collatAmount += loan.tokenCollateral;
        }

        }
    }

    return collatAmount;
}

function calculateLTVToToken(address _token, address _collatAddr, address _account) public view returns(uint256){
    uint256 maxCollateral;
    uint256 collatAmt = calculateCollateralAmount(msg.sender, _collatAddr);
    if(_collatAddr == address(0)){
        maxCollateral = (bnbCollat[_account] * MAX_LTV) / 100;
    }else{
        maxCollateral = (collatDet[_account][_collatAddr].amount * MAX_LTV) / 100;
    }
    require(maxCollateral > 0 && maxCollateral > collatAmt, "Invalid Collateral");

    uint256 remainCollat = maxCollateral - collatAmt;

    uint256 collatprice;
    uint256 collatdecimals;
    uint256 tokenprice;
    uint256 tokendecimals;

    if(_collatAddr == address(0)){
        (tokenprice, tokendecimals) = getPrice(_token);
        return remainCollat.div(tokenprice);
    }else{
        (collatprice, collatdecimals) = getPrice(_collatAddr);
        (tokenprice, tokendecimals) = getPrice(_token);
        return (remainCollat * collatprice).div(tokenprice);
    }
}


function getBorrowList(address _borrower) public view returns(Loan[] memory) {
    return loansByBorrower[_borrower];
}


}