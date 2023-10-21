pragma solidity ^0.5.16;

/**
 * @title ERC 20 Token Standard Interface
 *  https://eips.ethereum.org/EIPS/eip-20
 */
interface EIP20Interface {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    /**
      * @notice Get the total number of tokens in circulation
      * @return The supply of tokens
      */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Gets the balance of the specified address
     * @param owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
      * @notice Transfer `amount` tokens from `msg.sender` to `dst`
      * @param dst The address of the destination account
      * @param amount The number of tokens to transfer
      * @return Whether or not the transfer succeeded
      */
    function transfer(address dst, uint256 amount) external returns (bool success);

    /**
      * @notice Transfer `amount` tokens from `src` to `dst`
      * @param src The address of the source account
      * @param dst The address of the destination account
      * @param amount The number of tokens to transfer
      * @return Whether or not the transfer succeeded
      */
    function transferFrom(address src, address dst, uint256 amount) external returns (bool success);

    /**
      * @notice Approve `spender` to transfer up to `amount` from `src`
      * @dev This will overwrite the approval amount for `spender`
      *  and is subject to issues noted [here](https://eips.ethereum.org/EIPS/eip-20#approve)
      * @param spender The address of the account which may transfer tokens
      * @param amount The number of tokens that are approved (-1 means infinite)
      * @return Whether or not the approval succeeded
      */
    function approve(address spender, uint256 amount) external returns (bool success);

    /**
      * @notice Get the current allowance from `owner` for `spender`
      * @param owner The address of the account which owns the tokens to be spent
      * @param spender The address of the account which may transfer tokens
      * @return The number of tokens allowed to be spent (-1 means infinite)
      */
    function allowance(address owner, address spender) external view returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}

// From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/Math.sol
// Subject to the MIT license.

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
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting with custom message on overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction underflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on underflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot underflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
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
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers.
     * Reverts on division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers.
     * Reverts with custom message on division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/**
 * @title OVA's Staking Contract
 * @author OVA
 */
contract OvaStaking {

    using SafeMath for uint256;

    /// @notice Emitted when OVA is staked  
    event OvaStaked(address account, uint amount);

    /// @notice Emitted when OVA is withdrawn 
    event OvaWithdrawn(address account, uint amount);

    /// @notice Emitted when OVA is claimed 
    event OvaClaimed(address account, uint amount);

    // @notice The rate every day. 
    uint256 public dayOvaRate; 

    // @notice Owner address
    address payable public owner;

    // @notice OVA token
    EIP20Interface ova;

    // @notice A checkpoint for staking
    struct Checkpoint {
        uint256 deposit_time; //last check time
        uint256 total_staked;
        uint256 bonus_unclaimed;
    }

    // @notice staking struct of every account
    mapping (address => Checkpoint) internal stakings;

    // @notice total stake amount
    uint256 public total_deposited;

    constructor(address ovaAddress) public {
        owner = msg.sender;
	dayOvaRate = 1e16;
	ova = EIP20Interface(ovaAddress);
    }


    /**
     * @notice Stake OVA token to contract 
     * @param amount The amount of address to be staked 
     * @return Success indicator for whether staked 
     */
    function stake(uint256 amount) public returns (bool) {
	require(amount > 0, "No zero.");
	require(amount <= ova.balanceOf(msg.sender), "Insufficient OVA token.");

	Checkpoint storage cp = stakings[msg.sender];

	ova.transferFrom(msg.sender, address(this), amount);

	if(cp.deposit_time > 0)
	{
		uint256 bonus = block.timestamp.sub(cp.deposit_time).mul(cp.total_staked).mul(dayOvaRate).div(1e18).div(86400);
		cp.bonus_unclaimed = cp.bonus_unclaimed.add(bonus);
		cp.total_staked = cp.total_staked.add(amount);
		cp.deposit_time = block.timestamp;
	}else
	{
		cp.total_staked = amount;
		cp.deposit_time = block.timestamp;
	}
    total_deposited = total_deposited.add(amount);
	emit OvaStaked(msg.sender, amount);

	return true;
    }

    /**
     * @notice withdraw all OVA token staked in contract 
     * @return Success indicator for success 
     */
    function withdraw() public returns (bool) {

	Checkpoint storage cp = stakings[msg.sender];

	uint256 amount = cp.total_staked;

	uint256 bonus = block.timestamp.sub(cp.deposit_time).mul(cp.total_staked).mul(dayOvaRate).div(1e18).div(86400);
	cp.bonus_unclaimed = cp.bonus_unclaimed.add(bonus);
	cp.total_staked = 0;
	cp.deposit_time = 0;
    total_deposited = total_deposited.sub(amount);
	ova.transfer(msg.sender, amount);

	emit OvaWithdrawn(msg.sender, amount); 

	return true;
    }

    /**
     * @notice claim all OVA token bonus in contract 
     * @return Success indicator for success 
     */
    function claim() public returns (bool) {

	Checkpoint storage cp = stakings[msg.sender];

	uint256 amount = cp.bonus_unclaimed;
	if(cp.deposit_time > 0)
	{
		uint256 bonus = block.timestamp.sub(cp.deposit_time).mul(cp.total_staked).mul(dayOvaRate).div(1e18).div(86400);
		amount = amount.add(bonus);
		cp.bonus_unclaimed = 0; 
		cp.deposit_time = block.timestamp;
	}else
	{
		//has beed withdrawn
		cp.bonus_unclaimed = 0;
	}

	ova.transfer(msg.sender, amount);

	emit OvaClaimed (msg.sender, amount); 

	return true;
    }

    // set the dayrate
    function setDayOvaRate(uint256 dayRateMantissa) public
    {
	    require(msg.sender == owner, "only owner can set this value.");
	    dayOvaRate = dayRateMantissa;
    }

    /**
     * @notice Returns the balance of OVA an account has staked
     * @param account The address of the account 
     * @return balance of OVA 
     */
    function getStakingBalance(address account) external view returns (uint256) {
	Checkpoint memory cp = stakings[account];
        return cp.total_staked;
    }

    /**
     * @notice Return the unclaimed bonus OVA of staking 
     * @param account The address of the account 
     * @return The amount of unclaimed OVA 
     */
    function getUnclaimedOva(address account) public view returns (uint256) {
	Checkpoint memory cp = stakings[account];

	uint256 amount = cp.bonus_unclaimed;
	if(cp.deposit_time > 0)
	{
		uint256 bonus = block.timestamp.sub(cp.deposit_time).mul(cp.total_staked).mul(dayOvaRate).div(1e18).div(86400);
		amount = amount.add(bonus);
	}
	return amount;
    }

    /**
     * @notice Return the APY of staking 
     * @return The APY multiplied 1e18
     */
    function getStakingAPYMantissa() public view returns (uint256) {
        return dayOvaRate.mul(25);
    }

    /**
     * @notice Return the address of the OVA token
     * @return The address of OVA 
     */
    function getOvaAddress() public view returns (address) {
        return address(ova);
    }
}