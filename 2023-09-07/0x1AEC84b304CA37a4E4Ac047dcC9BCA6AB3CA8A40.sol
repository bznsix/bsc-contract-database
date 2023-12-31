
// SPDX-License-Identifier: UNLICENSED

/// @title SimpleDefiStaking - staking contract for easy
/// @author Derrick Bradbury - derrickb@halex.com
pragma solidity ^0.8.13;
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract SimpleDefiStaking {
    address public owner;
    uint256 public startDate;

    struct returnStakes {
        uint period;
        uint amount;
        uint entryDate;
        uint exitDate;
    }

    struct stakingPool {
        uint256 initialRewards;
        uint256 remainingRewards;
        uint256 vestingPeriod;
        uint256 totalStaked;
        uint256 initDate; 
        mapping(uint=>uint) tvl;
        mapping(uint=>uint) pendingWithdrawals;              
    }
    
    uint256[] public stakingPeriods;
    mapping(uint256=>stakingPool) public stakingPools;

    struct userStake {
        uint256 entryDate;
        uint256 amount;
    }

    struct mStake {
        address user;
        uint256 amount;
        uint256 period;
    }

    struct userPools {
        uint totalStaked;
        userStake[] stakes;
    }
    
    struct usersInfo {
        uint256 pos;
        mapping(uint256=>userPools) pools;
    }

    mapping(address=>usersInfo) public users;
    address[] public stakedUsers;

    mapping (uint=>uint) private runningStaked;
    mapping(uint=>mapping(uint=>uint)) deposits;
    mapping(uint=>mapping(uint=>uint)) depositTotals;
    mapping(uint=>mapping(uint=>uint)) withdrawalTotals;
    
    address public token;
    address public rewardToken;
    address holdbackAddr;
    uint256 public totalStaked;

    bool public paused = false;
    bool private locked;

    event sdOwnerTransferred(address _newOwner);
    event sdAddStake(address indexed user, uint256 amount, uint256 entryDate, uint256 releaseAt);
    event sdAddRewards(uint256 _period, uint256 _initalRewards, uint256 _vestingPeriod);
    event sdWithdrawCalc(address _user, uint _period, uint _stake, uint _calcAmount);
    event sdWithdrawStake(address indexed user, uint256 amount);
    event sdHoldback(address _user, uint _holdback);
    event sdTokensRemoved(address _token, uint _amount, address _addr);
    event sdTokensAdded(address _user, uint _amount);
    event debug(uint);

    error sdNotOwner();
    error sdRequiredParameter();
    error sdInvalidPeriod();
    error sdTransferError();
    error sdDepositsPaused();
    error sdInsufficentFunds();
    error sdWithdrawFailed();
    error sdNotActive();

    modifier onlyOwner {
        if (msg.sender != owner) revert sdNotOwner();
        _;
    }

    modifier depositsPaused {
        if (paused) revert sdDepositsPaused();
        _;
    }

    modifier lock {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

    constructor(address _token, address _rewardToken, address _holdbackAddr) {
        if (_token == address(0) || _rewardToken == address(0) || _holdbackAddr == address(0)) revert sdRequiredParameter();

        owner = msg.sender;
        token = _token;
        rewardToken = _rewardToken;
        holdbackAddr = _holdbackAddr;
    }

    /// @notice Transfer of ownership to new owner
    /// @param _newOwner - address of new owner
    function transferOwner(address _newOwner) public onlyOwner {
        if (_newOwner == address(0)) revert sdRequiredParameter();

        owner = _newOwner;
        emit sdOwnerTransferred(_newOwner);
    }

    function activate(uint _start) public onlyOwner {
      require(startDate == 0);
      if (_start == 0) _start = block.timestamp;
      startDate = _start;
    }


    /// @notice Allows calling user to add a stake for a specified period.
    /// @param _amount: amount of tokens to stake
    /// @param _period: period in seconds (DAYS * 86400)
    /// @dev user must call approve function on token contract to allow staking contract to transfer tokens
    /// @dev if _period < 1000 it assumes that the period is in days and will automatically convert to seconds
    /// @dev calls the overloaded "addStake" passing in the calling user as the user.
    /// @return success returns true if successful
    function addStake(uint256 _amount, uint256 _period) public depositsPaused returns (bool){
        return addStake(msg.sender,_amount,_period);
    }

    /// @notice Allows defined user to add a stake for a specirfied period
    /// @param _user  : user to transfer tokens from and to stake
    /// @param _amount: amount of tokens to stake
    /// @param _period: period in seconds (DAYS * 86400)
    /// @dev user must call approve function on token contract to allow staking contract to transfer tokens
    /// @dev if _period < 1000 it assumes that the period is in days and will automatically convert to seconds
    /// @dev calls the overloaded "addStake" passing in the calling user as the user.
    /// @return success returns true if successful
    function addStake(address _user, uint256 _amount, uint256 _period) public depositsPaused lock returns (bool){
        if (_user == address(0) || _amount == 0 || _period ==0 ) revert sdRequiredParameter();
        if (_period < 1000) _period = _period * 86400; // assume anything < 1000 is a day convert days to seconds        
        emit debug(_period);    
        if (stakingPools[_period].initialRewards == 0) revert sdInvalidPeriod();
        uint _d = block.timestamp - block.timestamp%86400; //calculate the day deposit was made
        //Add user to list if does not exist
        if (users[_user].pos == 0) {
            stakedUsers.push(_user);
            users[_user].pos = stakedUsers.length;
        }

        //transfer tokens to be staked from user. Allways from the msg.sender
        bool success = IERC20(token).transferFrom(msg.sender, address(this),_amount);
        if (success) {
            totalStaked += _amount;
            stakingPools[_period].totalStaked += _amount;
            users[_user].pools[_period].totalStaked += _amount;
            users[_user].pools[_period].stakes.push(userStake(_d,_amount));
            stakingPools[_period].pendingWithdrawals[_d + _period] += _amount;

            updateTVL(_period,_amount);
            emit sdAddStake(_user, _amount, _d, _d + _period);
        }
        else
            revert sdTransferError();

        return success;
    }

    /// @notice Allows multiple users to be staked, and draw funds from the senders account
    /// @param _users - array of users, amounts, and periods
    function multiStake(mStake[] calldata _users) public {
        for(uint i = 0;i<_users.length;i++) {
            addStake(_users[i].user,_users[i].amount,_users[i].period);
        }
    }

    /// @notice Updates the TVL of the contract based on a period and the current date
    /// @param _period - staking period of 30/90/356 days in unixtime
    /// @param _amount - amount being added to the staked pool
    /// @dev Assumes period is current datetime
    function updateTVL(uint _period, uint _amount) private {
        uint _sd = block.timestamp-block.timestamp%86400;

        deposits[_period][_sd] += _amount;
        
        runningStaked[_period] += _amount;
        depositTotals[_period][_sd] = runningStaked[_period];

        withdrawalTotals[_period][_sd + _period] += _amount; // update totals on calculated withdrawal date
    }

    
    /// @notice Returns calculated TVL for specified staking period and date
    /// @param _period - staking period of 30/90/356 days in unixtime
    /// @param _date    - unixtime of date to calculate TVL for
    /// @return _rv - TVL based on deposits and expired stakes

    function getTVL(uint _period, uint _date) public view returns (uint _rv) {
        uint _sd = _date-_date%86400;
        uint _tmpDate1 = _sd;

        // Find Last deposit based on passed in date
        while(depositTotals[_period][_tmpDate1] == 0 && _tmpDate1 >= stakingPools[_period].initDate) {
            _tmpDate1 -= 86400;               

        }

        //Add total to return value
        _rv = depositTotals[_period][_tmpDate1];

        // Walk backwards and add all stake expiries
        uint _tmpDate2 = _sd;
        uint _wdt;
        while( _tmpDate2 >= stakingPools[_period].initDate) {
            _wdt += withdrawalTotals[_period][_tmpDate2];
            _tmpDate2 -= 86400;
        }
        _rv -= _wdt;
    }

    /// @notice Overloaded function to use the msg.sender to withdraw a stake.
    /// @return _sendAmount - value sent back to the user
    function withdrawStake() public returns (uint _sendAmount) {
        return internalWithdraw(msg.sender, 0);
    }

    /// @notice Withdraw stake from staking pools    
    /// @param _user     - user to withdraw stake from 
    /// @param _holdback - amount to holdback in fees. Administrative function.
    /// @return _sendAmount - value sent back to the user
    function internalWithdraw(address _user, uint _holdback) private lock returns (uint _sendAmount){        
        uint _totalReward;
        // Iterate through periods looking for stakes to return to suer.
        for (uint t; t< stakingPeriods.length;t++) {   
            // Calculate amount to withdraw from staking period.
            (uint _tmpAmount, uint _totalCalcAmount) = calcWithdraw(_user, stakingPeriods[t], _holdback);
            _sendAmount += _tmpAmount;
            _totalReward += _totalCalcAmount;

            stakingPools[stakingPeriods[t]].remainingRewards -= _totalCalcAmount;
        }
        if (_sendAmount > 0) {
            // Admin functionality to charge fee if administrateivly withdrawn
            if (_holdback >= 1) {
                if (_holdback > 1) {
                    uint _sendback = (_totalReward * _holdback) / 1e20;
                    _totalReward -= _sendback;
                    bool success = IERC20(token).transfer(holdbackAddr, _sendback);
                    if (!success) revert sdWithdrawFailed();
                    emit sdHoldback(_user,_sendback);
                }
            }
            // deduct amount from total staked in contract
            totalStaked -= _sendAmount;

            // add the rewards to the total amount to send to user
            _sendAmount += _totalReward;
            //transfer funds to user, and fail i
            bool _success = IERC20(token).transfer(_user, _sendAmount);            
            if (!_success || _sendAmount == 0) revert sdWithdrawFailed();
            
            emit sdWithdrawStake(_user, _sendAmount);
        }
    }

    /// @notice Calculates the amount to withdraw for a user across all periods and stakes
    /// @param _user     - user to withdraw stake from 
    /// @param _period - staking period of 30/90/356 days in unixtime
    /// @param _holdback - amount to holdback in fees. Administrative function.
    /// @return _sendAmount      - total amount staked to be sent back
    /// @return _totalCalcAmount - total rewards earned to send back
    function calcWithdraw(address _user, uint _period, uint _holdback) private returns (uint _sendAmount, uint _totalCalcAmount){
        //based on initial rewards and vesting period calculate daily reward amount        
        uint _dailyAmount = stakingPools[_period].initialRewards/stakingPools[_period].vestingPeriod; 

        // While stakes exist calculate amounts to send back
        while(true)  {
            (uint _amount, uint _ed) = getNextStake(_user, _period, _holdback);
            if (_amount == 0) break; // If there are no more stakes, break out and return.
            _sendAmount += _amount;

            //Calculate the daily reward based on the TVL for that period on individual stakes from entry date to the exit date.
            uint _tempDate = _ed;
            while (_tempDate < _ed + _period){
                uint _tvl = getTVL(_period, _tempDate);
                uint _calcAmount = (_dailyAmount * ((_amount)*1e18 / _tvl)/1e18);
                _totalCalcAmount += _calcAmount;
                _tempDate += 86400;
            }            
            emit sdWithdrawCalc(_user, _period, _amount, _totalCalcAmount); //emit withdrawal for each indivudial stake
        }
        if (_sendAmount>0) emit sdWithdrawCalc(_user, 0, _sendAmount, _totalCalcAmount); // emit total result
    }


    /// @notice Function iterates through and pulls out the stakes and clears it out of the stack. 
    /// @dev If there is a failure, a revert will return all state variables back to their original values.
    /// @param _user     - user to withdraw stake from 
    /// @param _period - staking period of 30/90/356 days in unixtime
    /// @param _holdback - amount to holdback in fees. Administrative function.
    /// @return _amount - total amount staked to be sent back
    /// @return _entryDate  - date stake was entered    
    function getNextStake(address _user, uint _period, uint _holdback) private returns (uint _amount, uint _entryDate) {
        uint _sl = users[_user].pools[_period].stakes.length;
        for (uint i; i < _sl;i++)  {
            uint _ed = users[_user].pools[_period].stakes[i].entryDate;
            if ( _ed + _period <= block.timestamp-block.timestamp%86400 || _holdback > 0) {
                _amount = users[_user].pools[_period].stakes[i].amount;
                _entryDate = users[_user].pools[_period].stakes[i].entryDate;

                if (_sl > 1) users[_user].pools[_period].stakes[i] = users[_user].pools[_period].stakes[_sl-1];
                users[_user].pools[_period].stakes.pop();
                break;
            }
        }
    }
 
    /// @notice - returns available rewards to be withdrawn, and total amount of tokens staked
    /// @param _user - address of the user
    /// @return _totalStaked - total amount of tokens staked in the contract for the user
    /// @return _available   - total amount of tokens no longer held by staking rules    
    function stakedBalance(address _user) public view returns (uint256 _totalStaked, uint256 _available) {
        for (uint i; i < stakingPeriods.length;i++) {         
            uint _p =   stakingPeriods[i];
            (uint _s, uint _a) = stakedBalancePeriod(_user,_p);
            _totalStaked += _s;
            _available += _a;
        }        
    }

    /// @notice - returns available rewards to be withdrawn, and total amount of tokens staked for a specific period
    /// @param _user  - address of the user
    /// @param _period - staking period of 30/90/356 days in unixtime
    /// @return _totalStaked - total amount of tokens staked in the contract for the user
    /// @return _available   - total amount of tokens no longer held by staking rules    
    function stakedBalancePeriod(address _user, uint256 _period) public view returns (uint256 _totalStaked, uint256 _available) {
        _totalStaked += users[_user].pools[_period].totalStaked;
        uint _sl = users[_user].pools[_period].stakes.length;
        for(uint t = 0; t < _sl;t++){
            uint _d = block.timestamp-block.timestamp%86400;
            if (users[_user].pools[_period].stakes[t].entryDate + _period <= _d) {
                _available += users[_user].pools[_period].stakes[t].amount;
            }
        }
    }


    /// @notice - returns array of stakes for the user across all periods
    /// @param _user  - address of the user
    /// @return _stakes - array of staked assets across all periods
    function stakes(address _user) public view returns (returnStakes[] memory){
        uint _sl; // calculate the length of the dynamic array
        for (uint i; i < stakingPeriods.length;i++) 
            _sl +=  users[_user].pools[stakingPeriods[i]].stakes.length;

        returnStakes[] memory _stakes = new returnStakes[](_sl);
        uint cnt = 0;
        for (uint i; i < stakingPeriods.length;i++) {
            uint _stl = users[_user].pools[stakingPeriods[i]].stakes.length;
            for(uint s = 0; s < _stl; s++) {
                if (users[_user].pools[stakingPeriods[i]].stakes[s].amount>0)
                    _stakes[cnt] = returnStakes(
                        stakingPeriods[i],
                        users[_user].pools[stakingPeriods[i]].stakes[s].amount, 
                        users[_user].pools[stakingPeriods[i]].stakes[s].entryDate,
                        users[_user].pools[stakingPeriods[i]].stakes[s].entryDate + stakingPeriods[i]
                    );
                    cnt += 1;
            }
        }
        return _stakes;
    }
    /// @notice Admin function to add new period with details.
    /// @param _period - staking period of 30/90/356 days in unixtime
    /// @param _initialRewards - total number of rewards available for the period pool
    /// @param _vestingPeriod total number of days to spread out the _initialRewards
    function addRewards(uint256 _period, uint256 _initialRewards, uint256 _vestingPeriod) public onlyOwner {
        uint _totalRewards;
        for (uint i; i < stakingPeriods.length;i++){
            _totalRewards += stakingPools[stakingPeriods[i]].initialRewards;
        }

        uint tBalance = IERC20(token).balanceOf(address(this));
        if (tBalance < _totalRewards + _initialRewards) revert sdInsufficentFunds();
             
        if (_period == 0 || _initialRewards == 0 || _vestingPeriod == 0) revert sdRequiredParameter();
        if (stakingPools[_period].initialRewards != 0) revert sdInvalidPeriod();

        uint _d = block.timestamp-block.timestamp%86400;
        stakingPools[_period].initialRewards = _initialRewards;
        stakingPools[_period].remainingRewards = _initialRewards;
        stakingPools[_period].vestingPeriod = _vestingPeriod;
        stakingPools[_period].initDate = _d;
        stakingPools[_period].tvl[_d]=0;
        stakingPeriods.push(_period);
        
        emit sdAddRewards (_period, _initialRewards, _vestingPeriod);
    }

    /// @notice Override release of funds
    /// @dev does not update the TVL or pending withdrawals
    /// @param _user            - address of the user
    /// @param _penaltyPercent  - amount of STAKING REWARDS ONLY to penalize
    function adminRelease(address _user, uint256 _penaltyPercent) public onlyOwner {
        if (_penaltyPercent == 0) _penaltyPercent = 1;
        internalWithdraw(_user, _penaltyPercent);
    }

    /// @notice - returns array of stakes for the user across all periods
    /// @param _p  - staking period of 30/90/356 days in unixtime

    /// @param _ed  - date to get the pending reward for 
    /// @return _pw - value of pending rewards
   function pending(uint _p, uint _ed) public view returns (uint _pw) {
        _pw = stakingPools[_p].pendingWithdrawals[_ed +_p];
    }


    /// @notice Allows admin to transfer tokens that were mistakenly sent to this contract
    /// @dev If all the reward tokens are removed, it will pause the contract
    /// @param _token  - token to return
    /// @param _amount - amount to return to user
    /// @param _addr   - address to send tokens to 
    function recover_tokens(address _token, uint _amount, address _addr) public onlyOwner {
        bool success = IERC20(_token).transfer(_addr,_amount);
        require(success);
        if (_token == rewardToken && IERC20(_token).balanceOf(address(this)) == 0) {
            paused = true;
        }
        emit sdTokensRemoved(_token, _amount, _addr);
    }

    /// @notice Allows admin to add reward tokens back into the contract
    /// @dev If contract is paused, it will unpause contract when tokens are added
    /// @param _user   - user to add tokens from 
    /// @param _amount - amount to return to user
    function add_tokens(address _user, uint _amount) public onlyOwner {
        if (_amount == 0) revert sdRequiredParameter();

        bool success = IERC20(rewardToken).transferFrom(_user,address(this),_amount);
        require(success);
        if(paused == true) paused == false;
        emit sdTokensAdded(_user,_amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
