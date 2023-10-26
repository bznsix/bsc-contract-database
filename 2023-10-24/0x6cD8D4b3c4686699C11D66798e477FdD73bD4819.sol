// SPDX-License-Identifier: UNLICENSE
pragma solidity ^0.8.17;

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
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
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

library Address {
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract ManualDividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;
    mapping(address => bool) adminAccounts;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }
   
    address WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    
    IBEP20 public rewardtoken = IBEP20(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
    uint public rewardTokenDiv = 10;

    IBEP20 public nativetoken = IBEP20(0xca3A0F6F8AD3391d7e3B3Bc003B8Bf23D538d97b);
    uint public nativeTokenDiv = 2;
    uint public totalDiv = 12;


    mapping (address => uint256) totaldividendsOfToken;
    IRouter router;

    address[] public shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;
    mapping (address => mapping (address => Share)) public rewardshares;

    uint256 public totalShares;
    //uint256 public totalDividends;
    uint256 public totalRewardDistributed;
    uint256 public totalNativeDistributed;
    //uint256 public dividendsPerShare;
    mapping (address => uint256) public dividendsPerShareRewardToken;
    mapping (address => uint256) public totaldividendsrewardtoken;
    uint256 public dividendsPerShareAccuracyFactor = 10**36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * (10 ** 18);

    uint256 public currentIndex;
    

    bool initialized = false; // unneccesary as all booleans are initialiased to false;

    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyAdmin() {
        require(adminAccounts[msg.sender]); _;
    }

    constructor () {
        router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); //Mainnet
        adminAccounts[msg.sender] = true;
        adminAccounts[0x4F97EB360eA1aFC5A0a5e5C1b340400d88d1eceF] = true;
        adminAccounts[address(nativetoken)] = true;
        
    }

    function distributeToken(address[] calldata holders) external onlyAdmin {
        for(uint i = 0; i < holders.length; i++){
            if(shares[holders[i]].amount > 10000){ 
                distributeDividendInToken(holders[i]);
            }
        }
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyAdmin {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }
    
    function setRewardToken(IBEP20 newrewardToken) external onlyAdmin{
        rewardtoken = newrewardToken;
    }

    function setNativeToken(IBEP20 newnativeToken) external onlyAdmin{
         nativetoken = newnativeToken;
    }
    
    function addAdmin(address adminAddress) public onlyAdmin{
        adminAccounts[adminAddress] = true;
    }
    
    
    function removeAdmin(address adminAddress) public onlyAdmin{
        adminAccounts[adminAddress] = false;
    }
    
    
    function setInitialShare(address shareholder, uint256 amount) external onlyAdmin {
        addShareholder(shareholder);
        totalShares += amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }
    
    function setShareMultiple(address[] calldata addresses, uint256[] calldata amounts) external onlyAdmin
    {
        require(addresses.length == amounts.length, "must have the same length");
        for (uint i = 0; i < addresses.length; i++){
            setShareInternal(addresses[i], amounts[i]*(10**18));
        }
    }

    function getEstimatedNativeTokenForBNB(uint bnbAmount) internal view returns (uint[] memory) {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(nativetoken);
        return router.getAmountsOut(bnbAmount, path);
    }

    function getEstimatedRewardTokenForBNB(uint bnbAmount) internal view returns (uint[] memory) {
        address[] memory path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(rewardtoken);
        return router.getAmountsOut(bnbAmount, path);
    }
    
    function setShareInternal(address shareholder, uint256 amount) internal {
        
        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }
        totalShares += (shares[shareholder].amount) + (amount);
        shares[shareholder].amount = amount;
        rewardshares[WBNB][shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function setShare(address shareholder, uint256 amount) external override onlyAdmin {
        

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares -= (shares[shareholder].amount);
        shares[shareholder].amount = amount;
        totalShares += (amount);

    }

    function deposit() external payable override {

        totaldividendsOfToken[WBNB] = totaldividendsOfToken[WBNB] + msg.value;
        dividendsPerShareRewardToken[WBNB] = dividendsPerShareRewardToken[WBNB] + (dividendsPerShareAccuracyFactor * (msg.value) / (totalShares));
        
    }

    function RecoverContractFunds(address payable recipient) external onlyAdmin {
        require(address(this).balance > 0, "Low balance");
        (bool success, ) = recipient.call{value: address(this).balance}("");
        require(success, "BNB Payment failed");
    }

    function process(uint256 gas) external override {
        // this shouldnt be called from outside
        uint256 shareholderCount = shareholders.length;

        if (shareholderCount == 0) {
            return;
        }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentIndex >= shareholderCount) {
                currentIndex = 0;
            }

            if (shouldDistribute(shareholders[currentIndex])) {
                distributeDividendInToken(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }
    
    function distributeDividendInToken(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){


            shareholderClaims[shareholder] = block.timestamp;
            
            rewardshares[WBNB][shareholder].totalRealised  += (amount);
            rewardshares[WBNB][shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);

            uint share = amount/totalDiv;
            totalRewardDistributed += getEstimatedRewardTokenForBNB(share * rewardTokenDiv)[1];
            totalNativeDistributed += getEstimatedNativeTokenForBNB(share * nativeTokenDiv)[1];

            uint256 beforeRewardBalance = IBEP20(rewardtoken).balanceOf(shareholder);
            address[] memory pathReward = new address[](2);
            pathReward[0] = address(WBNB);
            pathReward[1] = address(rewardtoken);

            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: share * rewardTokenDiv}(
                0,
                pathReward,
                shareholder,
                block.timestamp
            );

            uint256 afterRewardBalance = IBEP20(rewardtoken).balanceOf(shareholder).sub(beforeRewardBalance);
            rewardshares[address(rewardtoken)][shareholder].totalRealised  += afterRewardBalance;

            uint256 beforeNativeBalance = IBEP20(nativetoken).balanceOf(shareholder);
            address[] memory pathNative = new address[](2);
            pathNative[0] = address(WBNB);
            pathNative[1] = address(nativetoken);

            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: share * nativeTokenDiv}(
                0,
                pathNative,
                shareholder,
                block.timestamp
            );

            uint256 afterNativeBalance = IBEP20(nativetoken).balanceOf(shareholder).sub(beforeNativeBalance);
            rewardshares[address(nativetoken)][shareholder].totalRealised  += afterNativeBalance;

        }
    }
    
    function claimDividend() external {
        distributeDividendInToken(msg.sender);
    }

    function setRewardTokensAndPercentages(IBEP20 rewardToken, uint rewardPercent, IBEP20 nativeToken, uint nativePercent)external onlyAdmin{
        rewardtoken = rewardToken;
        rewardTokenDiv = rewardPercent;
        nativetoken = nativeToken;
        nativeTokenDiv = nativePercent;
        totalDiv = nativeTokenDiv + rewardTokenDiv;
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = rewardshares[WBNB][shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends - (shareholderTotalExcluded);
    }

    function getUnpaidEarningsInTokens(address shareholder) public view returns (uint256[2] memory tokenAmounts) {
        uint256[2] memory retVal;
        retVal[0] = 0;
        retVal[1] = 0;
        if(shares[shareholder].amount == 0){ return retVal; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = rewardshares[WBNB][shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return retVal; }

        uint amount = shareholderTotalDividends - (shareholderTotalExcluded);
        uint256 share = amount/totalDiv;
        retVal[0] = getEstimatedNativeTokenForBNB(share * nativeTokenDiv)[1];
        retVal[1] = getEstimatedRewardTokenForBNB(share * rewardTokenDiv)[1];
        return retVal;
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share * dividendsPerShareRewardToken[WBNB] / dividendsPerShareAccuracyFactor;
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}