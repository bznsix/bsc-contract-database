/**
 *Submitted for verification at BscScan.com on 2024-01-08
 */

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

interface IPanackeRouter {
    function getAmountsOut(
        uint amount,
        address[] memory path
    ) external view returns (uint[] memory);
}

contract GrokStaking is Ownable {
    address public immutable grok;
    address public immutable router;
    address public immutable WETH;
    address public immutable USDT;

    //staker
    mapping(address => uint) public stakeAmounts;
    mapping(address => uint) public stakeAPR;
    mapping(address => uint) public stakeDuration;
    mapping(address => uint) public stakeStart;

    uint public totalStaked;
    uint public minStakeUSD; //minimum amount of usd that staker must have before staking

    mapping(uint => uint) public APRs;
    mapping(uint => uint) public MinAPRs;
    mapping(uint => uint) public MaxAPRs;
    uint public constant DENOMINATOR = 100_000;
    uint public constant DELTA = 10_000; //10% increase/decrease when someone joins/lefts in a duration
    uint public constant SIX_MONTH = 6 * 30 days;
    uint public constant TWELVE_MONTH = 12 * 30 days;
    uint public constant EIGHIN_MONTH = 18 * 30 days;

    string public constant name = "Grok Staking";
    string public constant symbol = "";

    event Stake(
        address indexed staker,
        uint indexed amount,
        uint time,
        uint indexed duration
    );
    event Unstake(
        address indexed staker,
        uint indexed amount,
        uint indexed time
    );

    constructor(
        address grok_,
        address router_,
        uint _minStake,
        address _weth,
        address _usdt
    ) Ownable(msg.sender) {
        grok = grok_;
        router = router_;
        minStakeUSD = _minStake;
        APRs[SIX_MONTH] = 60_000; //60%
        APRs[TWELVE_MONTH] = 120_000; //120%
        APRs[EIGHIN_MONTH] = 180_000; //180%
        MinAPRs[SIX_MONTH] = 6_000; //60%
        MinAPRs[TWELVE_MONTH] = 12_000; //120%
        MinAPRs[EIGHIN_MONTH] = 18_000; //180%
        MaxAPRs[SIX_MONTH] = 60_000; //60%
        MaxAPRs[TWELVE_MONTH] = 120_000; //120%
        MaxAPRs[EIGHIN_MONTH] = 180_000; //180%
        WETH = _weth;
        USDT = _usdt;
    }

    function balanceOf(address _staker) public view returns (uint) {
        return stakeAmounts[_staker];
    }

    function totalSupply() public view returns (uint) {
        return totalStaked;
    }

    //minimum amount of GROK in usd to have to be able to stake GROK
    function updateMinimumGrokToHave(uint _minStake) public onlyOwner {
        minStakeUSD = _minStake;
    }

    function stake_6Month(uint _amount) public returns (bool) {
        _stake(_amount, SIX_MONTH);
        return true;
    }

    function stake_12Month(uint _amount) public returns (bool) {
        _stake(_amount, TWELVE_MONTH);
        return true;
    }

    function stake_18Month(uint _amount) public returns (bool) {
        _stake(_amount, EIGHIN_MONTH);
        return true;
    }

    function _stake(uint _amount, uint _duration) internal returns (bool) {
        //grok in staker balance minum the amount that he/she is going to stake
        //example: if alice has 2000 grok and is going to stake 100 grok, then stakerBalance would be 100
        //the usd value of stakerBalance must be more than or equal to minStakeUSD which is 100$ initialy
        {
            uint stakerBalance = IERC20(grok).balanceOf(msg.sender) - _amount;
            uint usdValue = grokToUSD(stakerBalance);
            require(
                usdValue >= minStakeUSD,
                "your remaining grok tokens must worth than minStakeUSD"
            );
        }
        uint APR = APRs[_duration];
        //take fees into account
        uint b0 = IERC20(grok).balanceOf(address(this));
        IERC20(grok).transferFrom(msg.sender, address(this), _amount);
        _amount = IERC20(grok).balanceOf(address(this)) - b0;

        //if first time staking, this check is very important
        if (stakeAmounts[msg.sender] == 0) {
            stakeAPR[msg.sender] = APR;
            if (APR >= DELTA) {
                if (APR - DELTA <= MinAPRs[_duration]) {
                    APR = MinAPRs[_duration];
                } else {
                    APR -= DELTA;
                }
            }
            APRs[_duration] = APR;
            stakeDuration[msg.sender] = _duration;
            stakeStart[msg.sender] = block.timestamp;
        }

        stakeAmounts[msg.sender] += _amount;

        totalStaked += _amount;

        emit Stake(msg.sender, _amount, block.timestamp, _duration);
        return true;
    }

    //staker is able to unstake anytime, but will not receive rewards untill end of stake period
    function unstake(uint _amount) public returns (bool) {
        uint beforeStake = stakeAmounts[msg.sender];
        //0- decrease staker balance
        stakeAmounts[msg.sender] -= _amount;

        //1- if staker is going to unstake whole amount
        if (
            stakeAmounts[msg.sender] == 0 &&
            beforeStake > 0 &&
            stakeStart[msg.sender] > 0
        ) {
            //2- and the stake duration is ended
            if (
                stakeStart[msg.sender] + stakeDuration[msg.sender] <=
                block.timestamp
            ) {
                uint rewards = (beforeStake * stakeAPR[msg.sender]) /
                    DENOMINATOR;
                IERC20(grok).transfer(msg.sender, rewards);
            }
            //3- reset the staker start time and duration
            stakeStart[msg.sender] = 0;
            stakeAPR[msg.sender] = 0;
            uint duration = stakeDuration[msg.sender];
            stakeDuration[msg.sender] = 0;
            //4- increase the APR of duration
            if (APRs[duration] >= MaxAPRs[duration]) {
                APRs[duration] = MaxAPRs[duration];
            } else if (APRs[duration] == MinAPRs[duration]) {
                APRs[duration] += DELTA - (MinAPRs[duration] % DELTA);
            } else {
                APRs[duration] += DELTA;
            }
        }
        //5- transfer tokens to staker
        IERC20(grok).transfer(msg.sender, _amount);
        totalStaked -= _amount;
        emit Unstake(msg.sender, _amount, block.timestamp);
        return true;
    }

    //calculate rewards of a staker
    function calculateReward(
        address staker
    ) public view returns (uint rewardAmount) {
        if (stakeAmounts[staker] == 0) return 0;
        uint stakeAmount = stakeAmounts[staker];
        uint timeElapsed = block.timestamp - stakeStart[staker];
        rewardAmount =
            ((stakeAmount * stakeAPR[staker]) * timeElapsed) /
            (stakeDuration[staker] * DENOMINATOR);
    }

    function grokToUSD(uint amount) public view returns (uint usdtAmount) {
        if (amount == 0) return 0;
        address[] memory path = new address[](3);
        path[0] = address(grok);
        path[1] = WETH;
        path[2] = USDT;
        usdtAmount = IPanackeRouter(router).getAmountsOut(amount, path)[2];
    }

    //emergency withdraw all tokensk
    function emergencyWithdraw(address receiver) public onlyOwner {
        IERC20(grok).transfer(receiver, IERC20(grok).balanceOf(address(this)));
    }
}