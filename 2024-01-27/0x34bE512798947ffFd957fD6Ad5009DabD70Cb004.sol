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
}

// 
/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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
        require(c >= a, 'SafeMath: addition overflow');

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
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
        return div(a, b, 'SafeMath: division by zero');
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
        return mod(a, b, 'SafeMath: modulo by zero');
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

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

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
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

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

contract GokuStaking is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    
    IBEP20 public GOKU = IBEP20(0x87429B114315E8DBfA8b9611BEf07EcAD9a13742);
    
    uint256 public INTEREST_RATE_PACKAGE_1 = 118;
    uint256 public INTEREST_RATE_PACKAGE_2 = 219;
    uint256 public INTEREST_RATE_PACKAGE_3 = 308;

    uint256 public WITHDRAW_PERIOD_1 = 30 days;
    uint256 public WITHDRAW_PERIOD_2 = 90 days;
    uint256 public WITHDRAW_PERIOD_3 = 180 days;

    struct UserInfo {
        uint256 package;
        uint256 stakingAmount;
        uint256 bonusDebt;
        uint256 depositAt;
    }

    mapping(address => UserInfo) public userInfo;

    event RescueFundsGoku(address indexed owner, address _to, uint256 _amount);
    event SetGokuToken(address indexed owner, address _to);
    event SetInterestRatePackage(address indexed owner, uint256 _interestRatePackage1, uint256 _interestRatePackage2, uint256 _interestRatePackage3);
    event SetWithdrawPeriod(address indexed owner, uint256 _withdrawPeriod1, uint256 _withdrawPeriod2, uint256 _withdrawPeriod3);
    event Stake(address indexed owner, uint256 _package, uint256 _amount);
    event Withdraw(address indexed owner, uint256 _amount);
    event Claim(address indexed owner);
    event AddUserInfo(address indexed owner, address _account, uint256 _package, uint256 _stakingAmount, uint256 _bonusDebt, uint256 _depositAt);
    event RemoveUserInfo(address indexed owner, address _account);

    /* --VIEWS-- */

    function balanceGoku() public view returns(uint256) {
        return GOKU.balanceOf(address(this));
    }

    function balanceGokuOfUser(address account) public view returns(uint256) {
        return GOKU.balanceOf(account);
    }

    function calculateBonus(address account) public view returns(uint256) {
        UserInfo storage user = userInfo[account];
        if(user.stakingAmount > 0) {
            uint256 dayBonus = 0;
            uint256 timestampBonus = block.timestamp.sub(user.depositAt);
            
            if(timestampBonus > 86400) {
                uint256 modBonus = timestampBonus.mod(86400);
                uint256 modBonusTimeStamp = timestampBonus.sub(modBonus);
                dayBonus = modBonusTimeStamp.div(86400);
            } else {
                return 0;
            }

            if(user.package == 1) {
                return user.stakingAmount.mul(INTEREST_RATE_PACKAGE_1).div(100).div(365).mul(dayBonus).sub(user.bonusDebt);
            } else if (user.package == 2) {
                return user.stakingAmount.mul(INTEREST_RATE_PACKAGE_2).div(100).div(365).mul(dayBonus).sub(user.bonusDebt);
            } else if (user.package == 3) {
                return user.stakingAmount.mul(INTEREST_RATE_PACKAGE_3).div(100).div(365).mul(dayBonus).sub(user.bonusDebt);
            }
            
        } else {
            return 0;
        }
    }

    function checkWithdraw(address account) public view returns(bool) {
        UserInfo storage user = userInfo[account];
        if(user.package == 1) {
            if(user.depositAt.add(WITHDRAW_PERIOD_1) > block.timestamp) {
                return false;
            }
        } else if (user.package == 2) {
            if(user.depositAt.add(WITHDRAW_PERIOD_2) > block.timestamp) {
                return false;
            }
        } else if (user.package == 3) {
            if(user.depositAt.add(WITHDRAW_PERIOD_3) > block.timestamp) {
                return false;
            }
        }
        return true;
    }

    /* --OWNER-- */

    function addUserInfo(address account, uint256 _package, uint256 _stakingAmount, uint256 _bonusDebt, uint256 _depositAt) external onlyOwner {
        userInfo[account].package = _package;
        userInfo[account].stakingAmount = _stakingAmount;
        userInfo[account].bonusDebt = _bonusDebt;
        userInfo[account].depositAt = _depositAt;

        emit AddUserInfo(msg.sender, account, _package, _stakingAmount, _bonusDebt, _depositAt);
    }

    function removeUserInfo(address account) external onlyOwner {
        delete userInfo[account];

        emit RemoveUserInfo(msg.sender, account);
    }

    function rescueFundsGoku(address to, uint256 _amount) external onlyOwner {
        uint256 bal = balanceGoku();
        require(_amount > 0, 'dont have a GOKU');
        require(bal >= _amount, 'dont have a GOKU');
        GOKU.transfer(to, _amount);

        emit RescueFundsGoku(msg.sender, to, _amount);
    }

    function setGokuToken(address _goku) external onlyOwner {
        GOKU = IBEP20(_goku);

        emit SetGokuToken(msg.sender, _goku);
    }

    function setInterestRatePackage(uint256 _interestRatePackage1, uint256 _interestRatePackage2, uint256 _interestRatePackage3) external onlyOwner {
        INTEREST_RATE_PACKAGE_1 = _interestRatePackage1;
        INTEREST_RATE_PACKAGE_2 = _interestRatePackage2;
        INTEREST_RATE_PACKAGE_3 = _interestRatePackage3;

        emit SetInterestRatePackage(msg.sender, _interestRatePackage1, _interestRatePackage2, _interestRatePackage3);
    }

    function setWithdrawPeriod(uint256 _withdrawPeriod1, uint256 _withdrawPeriod2, uint256 _withdrawPeriod3) external onlyOwner {
        WITHDRAW_PERIOD_1 = _withdrawPeriod1;
        WITHDRAW_PERIOD_2 = _withdrawPeriod2;
        WITHDRAW_PERIOD_3 = _withdrawPeriod3;

        emit SetWithdrawPeriod(msg.sender, _withdrawPeriod1, _withdrawPeriod2, _withdrawPeriod3);
    }

    /* --EXTERNAL-- */

    function stake(uint256 package, uint256 amount) public {
        if(!_isContract(msg.sender)) {
            _stake(package, msg.sender, amount);
        }
    }

    function withdraw(uint256 amount) public {
        if(!_isContract(msg.sender)) {
            _withdraw(msg.sender, amount);
        }
    }

    function claim() public {
        if(!_isContract(msg.sender)) {
            _claim(msg.sender);
        }
    }

    /* --INTERNAL-- */

    /**
     * @notice Checks if address is a contract
     */
    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function _stake(uint256 package, address account, uint256 amount) private {
        require(amount > 0, "amount must greater than zero");
        require(account != address(0), "account must not zero address");
        require(balanceGokuOfUser(account) >= amount, "balance BTCETF is not enough");
        UserInfo storage user = userInfo[account];
        if(user.stakingAmount > 0) {
            require(package == user.package, "user already staked on other package");
        }

        user.package = package;
        user.stakingAmount = user.stakingAmount.add(amount);
        user.depositAt = block.timestamp;
        user.bonusDebt = 0;
        GOKU.transferFrom(account, address(this), amount);

        emit Stake(account, package, amount);
    }

    function _withdraw(address account, uint256 amount) private nonReentrant {
        UserInfo storage user = userInfo[account];
        require(user.stakingAmount >= amount, "sender dont have a enough fund");
        require(amount > 0, "amount must greater than zero");
        require(account != address(0), "account must not zero address");
        require(checkWithdraw(account) == true, "your account was locked"); 
        
        uint256 balGoku = balanceGoku();
        require(balGoku >= amount, "smartcontract is not enough GOKU");
        user.stakingAmount = user.stakingAmount.sub(amount);
        user.depositAt = block.timestamp;
        user.bonusDebt = 0;
        GOKU.transfer(account, amount);
        emit Withdraw(account, amount);
    }

    function _claim(address account) private nonReentrant {
        UserInfo storage user = userInfo[account];
        require(user.stakingAmount > 0, "user is not staking");    
        uint256 bonus = calculateBonus(account);
        require(bonus > 0, "bonus must be greater than zero");

        GOKU.transfer(account, bonus);

        userInfo[account].bonusDebt = userInfo[account].bonusDebt.add(bonus);
        emit Claim(account);
    }
}