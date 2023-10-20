// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interfaces/IDecubateMasterChef.sol";
import "../interfaces/IDCBVault.sol";
import "../interfaces/ILinearPool.sol";

contract VoteContract is Ownable {
    IDecubateMasterChef public compoundStakingContract;
    IDCBVault public compounderContract;
    ILinearPool public linearStakingContract;
    address CGPTAddress;
    uint256 voteRate;

    //steps 
    uint256 bronze;
    uint256 silver;
    uint256 gold;
    uint256 diamond;

    using SafeMath for uint256;

    constructor(
        address _compoundStakingContract,
        address _compounderContract,
        address _linearStakingContract,
        uint256 _voteRate
    ) 
    {
        compoundStakingContract = IDecubateMasterChef(_compoundStakingContract);
        compounderContract = IDCBVault(_compounderContract);
        linearStakingContract = ILinearPool(_linearStakingContract);
        voteRate = _voteRate;
        CGPTAddress = 0x9840652DC04fb9db2C43853633f0F62BE6f00f98;

        bronze=20000;
        silver=50000;
        gold=100000;
        diamond=200000;
    }
    function setVoteRate(uint256 newRate) external onlyOwner {
        voteRate = newRate;
    }

    function getVotingPower(address addr) public view returns (uint256 amount) {
        uint256 tempAmt;

        //V1 Staking
        uint256 len_1 = compoundStakingContract.poolLength();

        for (uint256 i = 0; i < len_1; i++) {
            (, uint256 localPeriodDays, , , , , address token) = compoundStakingContract.poolInfo(i);

            if (token == CGPTAddress) {
                (, , tempAmt, ) = compounderContract.users(i, addr);
                uint256 pw; //Power according to the localPeriodDayss
                if(localPeriodDays==15) pw=10;
                else if(localPeriodDays==45) pw=10;
                else if(localPeriodDays==180) pw=15;
                else if(localPeriodDays==365) pw=20;
                amount = amount.add(tempAmt.mul(pw));
            }
        }

        //V2 Staking
        uint256 len_2 = linearStakingContract.linearPoolLength();
        
        for (uint256 i = 0; i< len_2; i++) {
            tempAmt = linearStakingContract.linearBalanceOf(i, addr);
            uint256 lockDuration = linearStakingContract.linearPoolInfo(i).lockDuration;
            lockDuration = lockDuration.div(86400);
            uint256 pw;
            if(lockDuration==45) pw=10;
            else if(lockDuration==90) pw=13;
            else if(lockDuration==180) pw=15;
            else if(lockDuration==365) pw=20;
            amount = amount.add(tempAmt.mul(pw));
        }

        return
            amount.mul(voteRate).div(
                10 ** 5
            );
    }

    function getUserTier(address addr) public view returns (string memory tier) {
        uint256 points=getVotingPower(addr).div(1e18);
        if(points>=diamond) tier="Diamond";
        else if(points>=gold) tier="Gold";
        else if(points>=silver) tier="Silver";
        else if(points>=bronze) tier="Bronze";
        else tier="None";
    }

    function changeTierPoints(uint256 bronze_, uint256 silver_, uint256 gold_, uint256 diamond_) public onlyOwner {
        bronze=bronze_;
        silver=silver_;
        gold=gold_;
        diamond=diamond_;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

interface IDecubateMasterChef {
  struct NFTMultiplier {
    bool active;
    string name;
    address contractAdd;
    uint16 multiplier;
    uint16 startIdx;
    uint16 endIdx;
  }

  /**
   *
   * @dev User reflects the info of each user
   *
   *
   * @param {totalInvested} how many tokens the user staked
   * @param {totalWithdrawn} how many tokens withdrawn so far
   * @param {lastPayout} time at which last claim was done
   * @param {depositTime} Time of last deposit
   * @param {totalClaimed} Total claimed by the user
   *
   */
  struct User {
    uint256 totalInvested;
    uint256 totalWithdrawn;
    uint256 lastPayout;
    uint256 depositTime;
    uint256 totalClaimed;
  }

  function add(
    uint256 _apy,
    uint256 _lockPeriodInDays,
    uint256 _endDate,
    uint256 _hardCap,
    address token
  ) external;

  function set(
    uint256 _pid,
    uint256 _apy,
    uint256 _lockPeriodInDays,
    uint256 _endDate,
    uint256 _hardCap,
    uint256 _maxTransfer,
    address token
  ) external;

  function setNFT(
    uint256 _pid,
    string calldata _name,
    address _contractAdd,
    bool _isUsed,
    uint16 _multiplier,
    uint16 _startIdx,
    uint16 _endIdx
  ) external;

  function stake(uint256 _pid, uint256 _amount) external returns (bool);

  function claim(uint256 _pid) external returns (bool);

  function reinvest(uint256 _pid) external returns (bool);

  function reinvestAll() external returns (bool);

  function claimAll() external returns (bool);

  function handleNFTMultiplier(
    uint256 _pid,
    address _user,
    uint256 _rewardAmount
  ) external returns (uint256);

  function unStake(uint256 _pid, uint256 _amount) external returns (bool);

  function updateCompounder(address _compounder) external;

  function canClaim(uint256 _pid, address _addr) external view returns (bool);

  function calcMultiplier(uint256 _pid, address _addr) external view returns (uint16);

  function payout(uint256 _pid, address _addr) external view returns (uint256 value);

  function poolInfo(uint256)
    external
    view
    returns (
      uint256 apy,
      uint256 lockPeriodInDays,
      uint256 totalDeposit,
      uint256 startDate,
      uint256 endDate,
      uint256 hardCap,
      address token
    );

  function users(uint256, address)
    external
    view
    returns (
      uint256 totalInvested,
      uint256 totalWithdrawn,
      uint256 lastPayout,
      uint256 depositTime,
      uint256 totalClaimed
    );

  function poolLength() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IDCBVault {
  function deposit(uint256 _pid, uint256 _amount) external;

  function withdrawAll(uint256 _pid) external;

  function harvestAll() external;

  function setCallFee(uint256 _callFee) external;

  function pause() external;

  function unpause() external;

  function transferToken(address _addr, uint256 _amount) external returns (bool);

  function withdraw(uint256 _pid, uint256 _shares) external;

  function harvest(uint256 _pid) external;

  function callFee() external view returns (uint256);

  function masterchef() external view returns (address);

  function owner() external view returns (address);

  function paused() external view returns (bool);

  function pools(uint256) external view returns (uint256 totalShares, uint256 lastHarvestedTime);

  function users(uint256, address)
    external
    view
    returns (
      uint256 shares,
      uint256 lastDepositedTime,
      uint256 totalInvested,
      uint256 totalClaimed
    );

  function calculateTotalPendingRewards(uint256 _pid) external view returns (uint256);

  function calculateHarvestDcbRewards(uint256 _pid) external view returns (uint256);

  function getRewardOfUser(address _user, uint256 _pid) external view returns (uint256);

  function getPricePerFullShare(uint256 _pid) external view returns (uint256);

  function canUnstake(address _user, uint256 _pid) external view returns (bool);

  function available(uint256 _pid) external view returns (uint256);

  function balanceOf(uint256 _pid) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface ILinearPool {
  
  function linearPoolLength() external view returns (uint256);

  function linearBalanceOf(uint256 _poolId, address _account) external view returns (uint128);
  
  struct LinearPoolInfo {
        uint128 cap;
        uint128 totalStaked;
        uint128 minInvestment;
        uint128 maxInvestment;
        uint64 APR;
        uint128 lockDuration;
        uint128 delayDuration;
        uint128 startJoinTime;
        uint128 endJoinTime;
  }
  
  function linearPoolInfo(uint256 index) external view returns (LinearPoolInfo memory);
}// SPDX-License-Identifier: MIT
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
