// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPoolManager {
    function COIN() external view returns (address);
    function ROUTER() external view returns (address);
    function addLiquidity(address token, address lpHolder, uint256 value) external payable;
    function createPool(address token) external returns(address);
    function swap(address[] memory path, address to, uint256 value) external payable;
    function clearETH() external;
    function clearToken(address token) external;
    function setInitiator(address initiator) external;
    
    receive() external payable;
    fallback() external payable;
}/**
 *  _____ _____ _____  _______     __
 * |  __ \_   _/ ____|/ ____\ \   / /
 * | |__) || || |  __| |  __ \ \_/ / 
 * |  ___/ | || | |_ | | |_ | \   /  
 * | |    _| || |__| | |__| |  | |   
 * |_|   |_____\_____|\_____|  |_|Coink   
 *                                   
 *    https://piggycoin.finance
 */

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PiggyDistributor.sol";
import "./interfaces/IPoolManager.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IPiggyDistributor {
    function deposit() external payable;
    function process(uint256 gas) external;
    function claimDividend(address shareholder) external;
    function shareholderCount() external returns (uint);
    function shareholders(uint256) external returns (address);
    function setShare(address shareholder, uint256 amount) external;
    function getUnpaidEarnings(address shareholder) external view returns (uint256);
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
}


contract PiggyDistributor is IPiggyDistributor {
    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    address initiator;
    IERC20 rewardToken;
    IPoolManager manager;

    address[] public shareholders;
    mapping (address => uint256) shareholderClaims;
    mapping (address => uint256) shareholderIndexes;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 1 hours;
    uint256 public minDistribution = 1 * 1e18;

    uint256 currentIndex;

    modifier onlyInitiator() {
        require(msg.sender == initiator); _;
    }

    constructor (address managerAddress, address tokenAddress) {
        initiator = msg.sender;
        
        rewardToken = IERC20(tokenAddress);
        manager = IPoolManager(payable(managerAddress));
    }
    
    /**
     * Public functions 
     */
    
    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = _getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends - shareholderTotalExcluded;
    }

    function claimDividend(address shareholder) external {
        _distributeDividend(shareholder);
    }

    function shareholderCount() public view returns (uint) {
        return shareholders.length;
    }

    /**
     * Initiator functions 
     */

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyInitiator {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyInitiator {
        if(shares[shareholder].amount > 0){
            _distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            _addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            _removeShareholder(shareholder);
        }

        totalShares = (totalShares - shares[shareholder].amount) + amount;
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = _getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyInitiator {
        uint256 balanceBefore = rewardToken.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = manager.COIN();
        path[1] = address(rewardToken);

        manager.swap{value: msg.value}(path, address(this), msg.value);

        uint256 amount = rewardToken.balanceOf(address(this)) - balanceBefore;

        totalDividends += amount;
        dividendsPerShare = (dividendsPerShare + (dividendsPerShareAccuracyFactor * amount / totalShares));
    }

    function process(uint256 gas) external override onlyInitiator {
        uint256 shareholderCount_ = shareholderCount();

        if(shareholderCount_ == 0) { return; }

        uint256 gasUsed = 0;
        uint256 totalSpend = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(totalSpend < gas && gasLeft > gasUsed && iterations < shareholderCount_) {
            if(currentIndex >= shareholderCount_){
                currentIndex = 0;
            }

            if(_shouldDistribute(shareholders[currentIndex])){
                _distributeDividend(shareholders[currentIndex]);
            }

            totalSpend += (gasLeft - gasleft());
            gasLeft = gasleft();
            currentIndex++;
            iterations++;

            if(gasUsed == 0) gasUsed = totalSpend;
        }
    }
    
    /**
     * Internal functions 
     */

    function _addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function _distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed += amount;
            rewardToken.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised += amount;
            shares[shareholder].totalExcluded = _getCumulativeDividends(shares[shareholder].amount);
        }
    }

    function _getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share * dividendsPerShare / dividendsPerShareAccuracyFactor;
    }

    function _removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function _shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
            && getUnpaidEarnings(shareholder) > minDistribution;
    }
}
