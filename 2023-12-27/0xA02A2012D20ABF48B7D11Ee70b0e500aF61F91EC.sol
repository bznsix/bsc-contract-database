// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


/*  ________                   ________                                         _         
|        \                 |        \                                       |  \         
| ▓▓▓▓▓▓▓▓ ______   ______  \▓▓▓▓▓▓▓▓ ______  ______ ____   ______  _______  \▓▓ ______  
| ▓▓__    /      \ /      \    /  ▓▓ /      \|      \    \ |      \|       \|  \|      \ 
| ▓▓  \  |  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\  /  ▓▓ |  ▓▓▓▓▓▓\ ▓▓▓▓▓▓\▓▓▓▓\ \▓▓▓▓▓▓\ ▓▓▓▓▓▓▓\ ▓▓ \▓▓▓▓▓▓\
| ▓▓▓▓▓  | ▓▓  | ▓▓ ▓▓  | ▓▓ /  ▓▓  | ▓▓  | ▓▓ ▓▓ | ▓▓ | ▓▓/      ▓▓ ▓▓  | ▓▓ ▓▓/      ▓▓
| ▓▓_____| ▓▓__| ▓▓ ▓▓__| ▓▓/  ▓▓___| ▓▓__/ ▓▓ ▓▓ | ▓▓ | ▓▓  ▓▓▓▓▓▓▓ ▓▓  | ▓▓ ▓▓  ▓▓▓▓▓▓▓
| ▓▓     \\▓▓    ▓▓\▓▓    ▓▓  ▓▓    \\▓▓    ▓▓ ▓▓ | ▓▓ | ▓▓\▓▓    ▓▓ ▓▓  | ▓▓ ▓▓\▓▓    ▓▓
 \▓▓▓▓▓▓▓▓_\▓▓▓▓▓▓▓_\▓▓▓▓▓▓▓\▓▓▓▓▓▓▓▓ \▓▓▓▓▓▓ \▓▓  \▓▓  \▓▓ \▓▓▓▓▓▓▓\▓▓   \▓▓\▓▓ \▓▓▓▓▓▓▓
         |  \__| ▓▓  \__| ▓▓                                                             
          \▓▓    ▓▓\▓▓    ▓▓                                                             
           \▓▓▓▓▓▓  \▓▓▓▓▓▓                                                              

https://eggzomania.biz
https://t.me/eggzomania
https://twitter.com/eggzomania
https://www.youtube.com/@Egg_Zomania

*/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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

contract EggZomaniaSmart is Ownable, ReentrancyGuard 
{
    modifier CallVerification {
        require(_msgSender() == tx.origin, "Function can only be called by a user account");
        _;
    }

    address internal E_Owner = 0xFA48A62A54F9b88e4805F6567f00a0550F9DA795;
    address internal E_Market = 0xFb80eC9F2FC5fF747df73db3669215FC1542aa61;

    uint256 internal MIN_DEPOSIT = 50000000000000000; // 0.05 BNB
    uint256 public MAX_DEPOSIT = 5000000000000000000000; // 5000 BNB
    uint256 internal MIN_WITHDRAWAL = 10000000000000000; // 0.01 BNB 

    uint256[5] internal PERCENT = [27000, 30000, 33000, 36000, 40000];
    uint256[5] internal AFFILIATE_PERCENTS_1 = [70, 10, 7, 5, 3];
    uint256[5] internal AFFILIATE_PERCENTS_2 = [100, 20, 10, 10, 5];
    uint256[5] internal AFFILIATE_PERCENTS_3 = [130, 30, 20, 20, 10];

    uint256 OwnerPerc = 5;
    uint256 MarketPerc = 2;

    uint256 public totalInvested;
    uint256 public totalInvestors;

    uint8 internal _decimals = 18;
    address public PairAddress = 0xA3E83Bb38d437542152520c2E40Ed7EAB5f3c5e1;
    IERC20 internal Token;

    struct User 
    {
        uint256 money;
        uint256 token;
        uint256 deposit;
        uint256 earned;
        uint256 farmed;
        uint256 withdrawn;
        uint256 timestamp;
        uint256 timestamp_token;
        uint256 timestamp_game;
        uint256 percentage;
        address partner;
    }

    struct UserStats
    {
        uint256 refsTotal;
        uint256 refs1level;
        uint256 turnover;
        uint256 total_turnover;
        uint256 refearned;
        uint256 refearned_total;
        uint8 affiliate;
        uint256 refback;
    }

    struct Assets 
    {
        address addr;
        uint8 decimals;
    }

    mapping(address => User) public user;
    mapping(address => UserStats) public user_stats;
    mapping(uint => Assets) public assets;

    constructor() {
        assets[0].addr = 0x9E5eC7eFb40Ab114e7daA072D5201Fc40762a89F;
        assets[0].decimals = 18;
        Token = IERC20(assets[0].addr);
    }

    receive() external payable onlyOwner {}

    function eggGame() external nonReentrant CallVerification
    {
        require(block.timestamp >= user[_msgSender()].timestamp_game, "Time limit");

        if(user[_msgSender()].deposit > 0)
        {
            uint256 tokenPrice = _getTokenPrice();
            uint256 bonus = user[_msgSender()].deposit / 10000 * 20; // 0.2% from deposit
            bonus = (bonus*10**18) / tokenPrice;
            user[_msgSender()].token += bonus;
            user[_msgSender()].timestamp_game = block.timestamp + 86400;
        }
    }

    function makeDeposit(address partner) external payable nonReentrant CallVerification {
        uint256 amount = msg.value;
        require(amount >= MIN_DEPOSIT, "Min deposit limit");

        if(user[_msgSender()].percentage == 0) {
            require(partner != _msgSender(), "Cannot set your own address as partner");
            address ref = user[partner].deposit == 0 ? address(0) : partner;
            user[_msgSender()].percentage = PERCENT[0];
            user[_msgSender()].partner = ref;
            user_stats[ref].refs1level++;
            user_stats[ref].refsTotal++;
            totalInvestors += 1;

            address setPartner = user[ref].partner;

            if(setPartner != address(0))
            {
                for (uint8 i; i < 4; i++) 
                {
                    user_stats[setPartner].refsTotal++;
                    setPartner = user[setPartner].partner;
                    if(setPartner == address(0)) break;
                }
            }
        }
        
        user[_msgSender()].deposit += amount;
        user[_msgSender()].timestamp = block.timestamp;
        _referralAccrual(user[_msgSender()].partner, amount, _msgSender());
        _updatePercent(_msgSender());

        // Comission
        uint256 fee1 = (amount * OwnerPerc) / 100;
        uint256 fee2 = (amount * MarketPerc) / 100;
        user[E_Owner].money += fee1;
        user[E_Market].money += fee2;
    }

    function makeWithdrawal(uint256 amount) external nonReentrant CallVerification {
        require(amount >= MIN_WITHDRAWAL, "Min withdrawal limit");
        require(amount <= user[_msgSender()].money, "Insufficient funds");
        user[_msgSender()].money -= amount;
        user[_msgSender()].withdrawn += amount;
        payable(_msgSender()).transfer(amount);
    }

    function makeReinvest(uint256 amount) external nonReentrant CallVerification {
        require(amount > 0, "Min reinvest limit");
        require(amount <= user[_msgSender()].money, "Insufficient funds");
        user[_msgSender()].money -= amount;
        user[_msgSender()].deposit += amount;
        user[_msgSender()].timestamp = block.timestamp;
    }

    function setRefback(uint256 percent) external nonReentrant CallVerification {
        require(percent >= 0, "Error");
        require(percent <= 100, "Error");
        user_stats[_msgSender()].refback = percent;
    }

    function freezeToken(uint256 amount) external nonReentrant CallVerification {
        require(amount > 0, "Min freeze limit");
        user[_msgSender()].token += amount;
        user[_msgSender()].timestamp_token = block.timestamp;
        Token = IERC20(assets[0].addr);
        Token.transferFrom(_msgSender(), address(this), amount);
        _updatePercent(_msgSender());
    }

    function unfreezeToken(uint256 amount) external nonReentrant CallVerification {
        require(amount > 0, "Min unfreeze limit");
        require(amount <= user[_msgSender()].token, "Insufficient funds");
        user[_msgSender()].token -= amount;
        Token = IERC20(assets[0].addr);

        // Comission
        uint256 fee = (amount * MarketPerc) / 100;
        Token.transfer(_msgSender(), amount - fee);
        user[E_Market].money += fee;
        _updatePercent(_msgSender());
    }

    function claim() external nonReentrant CallVerification {
        require(user[_msgSender()].deposit > 0, "Insufficient deposit");
        _makeAccrue(_msgSender());
    }

    function pendingFarm(address account) public view returns(uint256) {
        uint256 DiffUnix = (block.timestamp - user[account].timestamp_token) / (4 * 3600);
        DiffUnix = (DiffUnix > 6) ? 6 : DiffUnix;
        uint256 IncomePeriod = 15; // 0.09 per day / 0.015 per 4h
        uint256 tokenPrice = _getTokenPrice();
        uint256 Reward = 0;

        if(DiffUnix > 0 && user[account].token > 0) {
            Reward = user[account].deposit * (IncomePeriod * DiffUnix) / 100000;
            Reward = (Reward*10**18) / tokenPrice;
        }

        return Reward;
    }

    function pendingReward(address account) public view returns(uint256) {
        uint256 DiffUnix = (block.timestamp - user[account].timestamp) / (4 * 3600);
        DiffUnix = (DiffUnix > 6) ? 6 : DiffUnix;
        uint256 IncomePeriod = user[account].percentage / 6;
        uint256 Reward = 0;

        if(DiffUnix > 0) {
            Reward = user[account].deposit * (IncomePeriod * DiffUnix) / 1000000;
        }

        return Reward;
    }

    function _makeAccrue(address account) internal {
        uint256 pending = pendingReward(account);
        uint256 pendingFarma = pendingFarm(account);

        if(pending > 0)
        {
            user[account].timestamp = block.timestamp;
            user[account].money += pending;
            user[account].earned += pending;
        }

        if(pendingFarma > 0) {
            user[_msgSender()].timestamp_token = block.timestamp;
            user[_msgSender()].token += pendingFarma;
            user[_msgSender()].farmed += pendingFarma;
        }
    }

    function _referralAccrual(address account, uint256 value, address depositer) internal {
        if (value > 0 && account != address(0)) 
        {
            for (uint8 i; i < 5; i++) 
            {
                uint256 topay = AFFILIATE_PERCENTS_1[i];

                if(user_stats[account].affiliate == 1)
                    topay = AFFILIATE_PERCENTS_2[i];
                else if(user_stats[account].affiliate == 2)
                    topay = AFFILIATE_PERCENTS_3[i];

                uint256 refacc = ((value * topay) / 1000);
                uint256 refback = 0;

                if(i == 0 && user_stats[account].refback > 0)
                {
                    refback = refacc / 100 * user_stats[account].refback;
                    refacc = refacc - refback;
                }

                if(refacc > 0)
                    payable(account).transfer(refacc);

                if(refback > 0)
                    payable(depositer).transfer(refback);

                user_stats[account].refearned_total += refacc;
                user_stats[account].total_turnover += value;

                if(i == 0) {
                    user_stats[account].refearned += refacc;
                    user_stats[account].turnover += value;
                    _updateAffiliate(account, user_stats[account].turnover);
                }
                
                account = user[account].partner;
                if(account == address(0)) break;
            }
        }
    }

    function _updatePercent(address account) internal {
        uint256 newPerc = PERCENT[0];
        uint256 amount = user[account].deposit;

        if(amount >= 50000000000000000 && amount < 4000000000000000000) {
            newPerc = PERCENT[0];
        } else if(amount >= 4000000000000000000 && amount < 10000000000000000000) {
            newPerc = PERCENT[1];
        } else if(amount >= 10000000000000000000 && amount < 20000000000000000000) {
            newPerc = PERCENT[2];
        } else if(amount >= 20000000000000000000 && amount < 40000000000000000000) {
            newPerc = PERCENT[3];
        } else if(amount >= 40000000000000000000) {
            newPerc = PERCENT[4];
        }

        if(user[account].token >= 250*10**_decimals)
        {
            uint256 farmToken = user[account].token / (250*10**_decimals);
            if(farmToken > 0) {
                uint256 addPerc = (375 * farmToken); // 0,0375% for each 250 tokens
                addPerc = (addPerc > 3000) ? 3000 : addPerc; // max 0.3%, div 10,000
                newPerc += addPerc; 
            }
        }
        
        if(user[account].percentage != newPerc)
            user[account].percentage = newPerc;
    }

    function _updateAffiliate(address account, uint256 turnover) internal {
        uint8 affiliate = 0;

        if(turnover >= 0 && turnover < 20000000000000000000) affiliate = 0;
        else if(turnover >= 20000000000000000000 && turnover < 60000000000000000000) affiliate = 1;
        else if(turnover >= 60000000000000000000) affiliate = 2;

        if(user_stats[account].affiliate != affiliate) {
            user_stats[account].affiliate = affiliate;
        }
    }

    function _getPriceDiv1() internal view returns(uint) {
        address WBNBtoken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // WBNB
        uint256 WBNB = IERC20(WBNBtoken).balanceOf(PairAddress);
        return(WBNB);
    }

    function _getPriceDiv2() internal view returns(uint) {
        uint256 EGG = IERC20(assets[0].addr).balanceOf(PairAddress); // TOKEN
        return(EGG);
    }

    function _getTokenPrice() public view returns(uint) {
        uint256 WBNB = _getPriceDiv1();
        uint256 EGG = _getPriceDiv2();
        return(WBNB*(10**18) / EGG);
    }
}// SPDX-License-Identifier: MIT
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
