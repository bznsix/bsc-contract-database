// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
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
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract PapaJolie is Ownable, ReentrancyGuard {

    address public Puma = address(0); 
    address public Pair = address(0);
    address private priceAddress = 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE;

    AggregatorV3Interface internal priceFeed;
    IERC20 public tokenUSDT;

    uint8 constant _decimals = 18; 
    uint256 public MIN_DEPOSIT = 1 * 10**_decimals;
    uint256 public MAX_DEPOSIT = 100 * 10**_decimals;
    uint256 public MIN_WITHDRAWAL = 1 * 10**_decimals;
    uint256 public MIN_REINVEST = 1 * 10**_decimals;

    uint256 private PERCENT = 300;
    uint256[2] private AFFILIATE_PERCENTS = [50, 20];
    uint256[2] private AFFILIATE_PERCENTS_TOP5 = [70, 30];

    address public defaultRef = address(0);
    uint256 public totalInvested;
    uint256 public totalInvestors;
    uint256 public daysWork;
    uint256 public startTime = 0;

    struct User 
    {
        uint256 money;
        uint256 puma;
        uint256 deposit;
        uint256 earned;
        uint256 withdrawn;
        uint256 timestamp;
        address partner;
        uint256 refsTotal;
        uint256 refs1level;
        uint256 turnover;
        uint256 refearnUSDT;
        uint256 percentage;
        uint256 top5Earned;
        bool affiliateBonus;
    }

    struct Top5 
    {
        address user;
        uint256 turnover;
    }

    struct supportedTokens 
    {
        address addr;
        uint256 decimals;
    }

    mapping(address => User) public user;
    mapping(uint => Top5) public top5;
    mapping(uint => supportedTokens) public SupportedTokens;

    constructor() 
    {
        priceFeed = AggregatorV3Interface(priceAddress); 
        SupportedTokens[0].addr = 0x55d398326f99059fF775485246999027B3197955; // USDT
        SupportedTokens[0].decimals = 18;
        tokenUSDT = IERC20(SupportedTokens[0].addr);
    }

    receive() external payable onlyOwner {}

    function Create(uint amount, address partner, uint tokenIndex) external nonReentrant 
    {
        require(_msgSender() == tx.origin, "Function can only be called by a user account");
        require(startTime > 0, "Contract not running");
        require(amount >= MIN_DEPOSIT, "Min deposit limit");
        require(tokenIndex == 0, "Parse token error");
        require((user[_msgSender()].deposit + amount) <= MAX_DEPOSIT, "Max deposit limit has been exceeded");

        if (user[_msgSender()].percentage == 0) 
        {
            require(partner != _msgSender(), "Cannot set your own address as partner");
            address ref = user[partner].deposit == 0 ? defaultRef : partner;
            user[_msgSender()].partner = ref;
            user[_msgSender()].percentage = PERCENT;
            user[_msgSender()].timestamp = block.timestamp;
            user[ref].refs1level++;
            user[ref].refsTotal++;
            user[user[ref].partner].refsTotal++;
            totalInvestors += 1;
        }

        totalInvested += amount;
        user[_msgSender()].deposit += amount;

        tokenUSDT = IERC20(SupportedTokens[tokenIndex].addr);
        tokenUSDT.transferFrom(_msgSender(), address(this), amount);

        // Token bonus
        uint256 tokenPrice = _getTokenPrice();
        uint256 needSend = ((amount*10**18) / tokenPrice) * 10 / 100;
        if(IERC20(Puma).balanceOf(address(this)) > needSend)
            IERC20(Puma).transfer(_msgSender(), needSend);

        _updatePercentage(_msgSender(), needSend);
        _updateprePayment(_msgSender());
        _referralAccrual(user[_msgSender()].partner, amount);
        
        // Owner-Fee
        uint256 feeUSDT = (amount * 4) / 100;
        tokenUSDT.transfer(owner(), feeUSDT);
    }

    function Reinvest(uint256 amount) external nonReentrant 
    {
        require(_msgSender() == tx.origin, "Function can only be called by a user account");
        require(amount >= MIN_REINVEST, "Min reinvest limit");
        _updatePercentage(_msgSender(), 0);
        _updateprePayment(_msgSender());
        require(amount <= user[_msgSender()].money, "Insufficient funds");
        user[_msgSender()].money -= amount;
        user[_msgSender()].deposit += amount;
    }

    function Withdraw(uint256 amount, uint tokenIndex) external nonReentrant 
    {
        require(_msgSender() == tx.origin, "Function can only be called by a user account");
        require(amount >= MIN_WITHDRAWAL, "Min withdrawal limit");
        require(tokenIndex == 0, "Parse token error");
        _updatePercentage(_msgSender(), 0);
        _updateprePayment(_msgSender());
        require(amount <= user[_msgSender()].money, "Insufficient funds");
        user[_msgSender()].money -= amount;
        user[_msgSender()].withdrawn += amount;
        tokenUSDT = IERC20(SupportedTokens[tokenIndex].addr);
        tokenUSDT.transfer(_msgSender(), amount);
    }

    function ClaimRewards() external nonReentrant
    {
        require(_msgSender() == tx.origin, "Function can only be called by a user account");
        require(user[_msgSender()].deposit > 0, "Insufficient deposit");
        _updatePercentage(_msgSender(), 0);
        _updateprePayment(_msgSender());
    }

    function ReplenishTuna(uint amount, uint tokenIndex) external nonReentrant 
    {
        require(_msgSender() == tx.origin, "Function can only be called by a user account");
        require(SupportedTokens[tokenIndex].addr == Puma, "Parse token error");
        require(amount >= 1*10**18, "Min replenishment limit");
        _updatePercentage(_msgSender(), 0);
        _updateprePayment(_msgSender());
        user[_msgSender()].puma += amount;
        tokenUSDT = IERC20(SupportedTokens[tokenIndex].addr);
        tokenUSDT.transferFrom(_msgSender(), address(this), amount);
    }

    function ReinvestTuna(uint amount) external nonReentrant
    {
        require(_msgSender() == tx.origin, "Function can only be called by a user account");
        require(amount <= user[_msgSender()].puma, "Insufficient funds");
        uint256 decimalsToken = 10**_decimals;
        uint256 tokenPrice = _getTokenPrice();
        uint256 swapExactly = ((amount * (tokenPrice * decimalsToken)) * 90 / 100);
        user[_msgSender()].puma -= amount;
        user[_msgSender()].deposit += swapExactly;
        _updatePercentage(_msgSender(), 0);
        _updateprePayment(_msgSender());
    }

    function pendingReward(address account) public view returns(uint256) 
    {
        uint256 RewardTime = (block.timestamp - user[account].timestamp) / 600;
        RewardTime = (RewardTime > 1) ? 1 : 0; 
        return (((user[account].deposit / 100 * user[account].percentage) / 100) * RewardTime);
    }

    function _updateprePayment(address account) internal 
    {
        uint256 pending = pendingReward(account);
        user[account].timestamp = block.timestamp;

        if(pending > 0)
        {
            user[account].money += pending;
            user[account].earned += pending;
        }

        if(user[account].earned >= (user[account].deposit * 3))
        {
            user[account].deposit = 0;
            user[account].timestamp = 0;
        }

        // WorkDays counter
        uint256 newCounter = (block.timestamp - startTime) / 86400;
        if(newCounter > daysWork)
        {
            daysWork++;
            MAX_DEPOSIT += 200 * 10**18;
        }
    }

    function _referralAccrual(address account, uint256 value) internal 
    {
        if (value > 0 && account != address(0)) 
        {
            for (uint8 i; i < 2; i++) 
            {
                
                uint256 affPercent = (user[account].affiliateBonus == true) ? AFFILIATE_PERCENTS_TOP5[i] : AFFILIATE_PERCENTS[i];
                uint256 feeUSDT = ((value * affPercent) / 1000);
                user[account].money += feeUSDT;
                user[account].refearnUSDT += feeUSDT;

                if(i == 0) 
                { 
                    user[account].turnover += value;
                    _updateTop5(account, user[account].turnover); 
                }
                
                account = user[account].partner;
                if(account == address(0)) break;
            }

            for (uint8 i; i < 5; i++) 
            {
                if(top5[i].user != address(0))
                {
                    uint256 bonus = value * 40 / 10000;
                    user[top5[i].user].money += bonus;
                    user[top5[i].user].top5Earned += bonus;
                }
            }
        }
    }

    function _updateTop5(address account, uint256 turnover) internal
    {
        bool search = false;

        for (uint8 i; i < 5; i++) 
        {
            if(top5[i].user == account)
            {
                search = true;
                top5[i].turnover = turnover;

                if(i > 0)
                {
                    for(uint8 y = (i-1); top5[y].turnover < turnover && y >= 0; y--)
                    {
                        top5[y+1].user = top5[y].user;
                        top5[y+1].turnover = top5[y].turnover;

                        top5[y].user = account;
                        top5[y].turnover = turnover;

                        if(y == 0) break;
                    }
                }
                
                break;
            }
        }

        if(search == false)
        {

            user[account].affiliateBonus = false;

            for (uint8 i; i < 5; i++) 
            {
                if(top5[i].turnover < turnover)
                {
                    

                    address next1 = top5[i].user;
                    uint256 next2 = top5[i].turnover;

                    for (uint8 j = i; j < (4 - i); j++) 
                    {
                        user[top5[j+1].user].affiliateBonus = false;
                        address prev1 = top5[j+1].user;
                        uint256 prev2 = top5[j+1].turnover;

                        top5[j+1].user = next1;
                        top5[j+1].turnover = next2;
                        user[top5[j+1].user].affiliateBonus = true;

                        if(prev1 == address(0)) break;

                        next1 = prev1;
                        next2 = prev2;

                    }

                    top5[i].user = account;
                    top5[i].turnover = turnover;
                    user[account].affiliateBonus = true;

                    break;
                }
            }
        }
        
    }

    function _updatePercentage(address account, uint256 amount) internal 
    {
        uint tokenBalance = IERC20(Puma).balanceOf(account) + amount;
        uint updPercentage;

        if(tokenBalance >= 500*(10**18) && tokenBalance < 1000*(10**18))
            updPercentage = 330;
        else if(tokenBalance >= 1000*(10**18) && tokenBalance < 1500*(10**18))
            updPercentage = 360;
        else if(tokenBalance >= 1500*(10**18))
            updPercentage = 400;
        else 
            updPercentage = 300;
            
        if(user[account].percentage != updPercentage)
            user[account].percentage = updPercentage;
    }

    function _getLatestPrice() public view returns (uint) 
    { 
        (,int price,,uint timeStamp,)= priceFeed.latestRoundData();
        require(timeStamp > 0, "Round not complete");
        return (uint)(price * 10000000000); 
    }

    function _getTokenPrice() public view returns(uint)
    {
        IPancakePair pair = IPancakePair(Pair);
        (uint Res0, uint Res1,) = pair.getReserves();
        uint BNBPrice = _getLatestPrice();
        uint divider1 = (Res0 > Res1) ? Res1 : Res0;
        uint divider2 = (Res0 > Res1) ? Res0 : Res1;
        return((divider1*(10**18) / divider2) * BNBPrice / 10**18);
    }

    function runContract(uint256 time) external onlyOwner { if(startTime == 0) startTime = time; }

    function addSupportedToken(uint tokenIndex, address addr, uint decimals) external onlyOwner 
    {
        require(tokenIndex > 0, "Dont change USDT token");
        SupportedTokens[tokenIndex].addr = addr;
        SupportedTokens[tokenIndex].decimals = decimals;
    }

    function addParams(address smartPuma, address smartPair) external onlyOwner { Puma = smartPuma; Pair = smartPair; }
}// SPDX-License-Identifier: MIT

interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  function getRoundData(
    uint80 _roundId
  )
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
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
