//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing necessary OpenZeppelin contracts for security and utility
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DigiStake is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    address public stakingToken; // Address of the staked token
    uint256 public constant periodicTime = 365 days; // Constant representing a year in seconds
    uint256 public planLimit = 3; // Maximum number of staking plans allowed
    uint256 public totalStaked; // Total amount staked across all plans
    uint256[] public refPercent; // percent for referral

    struct Plan {
        uint256 overallStaked; // Total staked amount in this plan
        uint256 stakesCount; // Number of stakes within this plan
        uint256 apr; // Annual Percentage Rate for the plan
        uint256 stakeDuration; // Duration for which the stake is held
        uint256 earlyPenalty; // Penalty for early withdrawal
        bool conclude; // Flag to mark if the staking in this plan is concluded
    }
    
    struct Staking {
        uint256 amount; // Amount staked
        uint256 stakeAt; // Time when staking started
        uint256 endstakeAt; // Time when the stake ends
        uint256 lastClaim; // Time of the last claimed reward
        uint256 totalClaim; // Total claimed rewards
        uint256 unclaimed; // Unclaimed earned rewards
    }

    struct Users {
        bool status;
        address invitedBy;
        uint256 totalDownline;
        uint256 totalEarning;
        uint256 claimableEarning;
    }

    mapping(address => Users) public user;
    mapping(uint256 => mapping(address => Staking[])) public stakes;
    mapping(uint256 => Plan) public plans; // Mapping for different staking plans

    // Constructor initializing the staking token and minimum stake amount
    constructor(address _stakingToken) {
        stakingToken = _stakingToken;

        // Initializing three predefined staking plans with different parameters
        plans[0].apr = 8;
        plans[0].stakeDuration = 15 days;
        plans[0].earlyPenalty = 15;

        plans[1].apr = 18;
        plans[1].stakeDuration = 30 days;
        plans[1].earlyPenalty = 15;

        plans[2].apr = 30;
        plans[2].stakeDuration = 45 days;
        plans[2].earlyPenalty = 15; 
   
        refPercent = [3, 2, 1];    
    }

    // Staking function allowing users to stake their tokens with referrer
    function rStake(uint256 _stakingId, uint256 _amount, address _referrer) external {  
        if(_referrer != msg.sender && _referrer != address(0)) {
            if(!user[msg.sender].status){
                user[msg.sender].invitedBy = _referrer;
                user[msg.sender].status = true;

                address currentUpline0 = _referrer; 
                for (uint i = 0; i < refPercent.length; ++i) {
                    if (currentUpline0 == address(0)) {
                        break; // Stop processing if the upline is a non-existent referrer
                    }                    
                    user[currentUpline0].totalDownline += 1;
                    currentUpline0 = user[currentUpline0].invitedBy; // Move to next referrer
                }               
            }                      
        }
        stake(_stakingId, _amount); 
    }

    // Staking function allowing users to stake their tokens
    function stake(uint256 _stakingId, uint256 _amount) public nonReentrant {
        require(_amount > 0, "Staking Amount cannot be zero");
        require(IERC20(stakingToken).balanceOf(msg.sender) >= _amount,"Balance is not enough");
        require(_stakingId < planLimit, "Staking is unavailable");

        Plan storage plan = plans[_stakingId];
        require(!plan.conclude, "Staking in this pool is concluded");

        _updateUnclaimedEarnings(msg.sender, _stakingId);

        uint256 beforeBalance = IERC20(stakingToken).balanceOf(address(this));
        IERC20(stakingToken).safeTransferFrom(msg.sender, address(this), _amount);
        uint256 afterBalance = IERC20(stakingToken).balanceOf(address(this));
        uint256 amount = afterBalance - beforeBalance;
        
        uint256 stakelength = stakes[_stakingId][msg.sender].length;
        if(stakelength == 0) {
            ++plan.stakesCount; 
        }

        stakes[_stakingId][msg.sender].push();
        Staking storage _staking = stakes[_stakingId][msg.sender][stakelength];
        _staking.amount = amount;
        _staking.stakeAt = block.timestamp;
        _staking.endstakeAt = block.timestamp + plan.stakeDuration;
        _staking.lastClaim = block.timestamp;

        plan.overallStaked += amount;
        totalStaked += amount;

        emit Stake(msg.sender, amount, _stakingId);
    }

    // Function allowing users to withdraw their stakes
    function unstake(uint256 _stakingId, uint256 _amount) external nonReentrant {
        uint256 _stakedAmount;
        uint256 _canWithdraw;
        Plan storage plan = plans[_stakingId];
        (_stakedAmount, _canWithdraw) = canWithdrawAmount(_stakingId, msg.sender);
        require(_stakedAmount >= _amount, "Insufficient staked amount");

        _updateUnclaimedEarnings(msg.sender, _stakingId);

        uint256 amountToWithdraw = _amount;
        uint256 totalPenalty = 0;

        uint256 stakesCount = stakes[_stakingId][msg.sender].length;

        // First pass: Process stakings without penalty
        for (uint256 i = 0; i < stakesCount && amountToWithdraw > 0; ++i) {
            Staking storage _staking = stakes[_stakingId][msg.sender][i];
            if (block.timestamp >= _staking.endstakeAt) {
                uint256 withdrawableAmount = (_staking.amount <= amountToWithdraw) ? _staking.amount : amountToWithdraw;
                amountToWithdraw -= withdrawableAmount;
                _staking.amount -= withdrawableAmount;
                _staking.lastClaim = block.timestamp;
            }
        }

        // Second pass: Process stakings with penalty
        for (uint256 i = 0; i < stakesCount && amountToWithdraw > 0; ++i) {
            Staking storage _staking = stakes[_stakingId][msg.sender][i];
            if (block.timestamp < _staking.endstakeAt && _staking.amount > 0) {
                uint256 withdrawableAmount = (_staking.amount <= amountToWithdraw) ? _staking.amount : amountToWithdraw;
                uint256 penaltyAmount = calculatePenalty(withdrawableAmount, plan.earlyPenalty);
                totalPenalty += penaltyAmount;
                amountToWithdraw -= withdrawableAmount;
                _staking.amount -= withdrawableAmount;
                _staking.lastClaim = block.timestamp;
            }
        }

        require(amountToWithdraw == 0, "Requested amount too high");

        uint256 netAmount = _amount - totalPenalty;
        if (netAmount > 0) {
            IERC20(stakingToken).safeTransfer(msg.sender, netAmount);
        }

        plans[_stakingId].overallStaked -= _amount;
        totalStaked -= _amount;

        removeEmptyStakes(_stakingId, msg.sender);

        emit unStake(msg.sender, _amount, _stakingId);
    }

    // Function to claim earned rewards from staking
    function claimEarned(uint256 _stakingId, uint256 _eAmount) external nonReentrant checkPools(_eAmount) {
        require(_eAmount > 0, "Requested claim amount must be greater than zero");

        // Update unclaimed earnings before distributing the claim
        _updateUnclaimedEarnings(msg.sender, _stakingId);

        uint256 originalTotalUnclaimed = _getTotalUnclaimed(msg.sender, _stakingId);
        require(originalTotalUnclaimed >= _eAmount, "Not enough earned rewards to claim");

        uint256 stakesCount = stakes[_stakingId][msg.sender].length;
        uint256 remainingClaim = _eAmount; // Remaining amount to be claimed

        for (uint256 i = 0; i < stakesCount && remainingClaim > 0; ++i) {
            Staking storage staking = stakes[_stakingId][msg.sender][i];

            // Calculate the proportion of the claim from this staking
            uint256 claimFromThisStake = (staking.unclaimed * remainingClaim) / originalTotalUnclaimed;

            // Ensure we do not claim more than remaining
            if (claimFromThisStake > remainingClaim) {
                claimFromThisStake = remainingClaim;
            }

            // Adjust the remaining claim amount and the unclaimed rewards
            remainingClaim -= claimFromThisStake;

            // Deduct the staking's unclaimed amount from originalTotalUnclaimed
            originalTotalUnclaimed -= staking.unclaimed;    

            staking.unclaimed -= claimFromThisStake;
            staking.totalClaim += claimFromThisStake; // Update totalClaim
        }

        // Transfer the claimed amount
        IERC20(stakingToken).safeTransfer(msg.sender, _eAmount - remainingClaim);

        // Update referral earnings and emit event
        updateReferralEarnings(_eAmount - remainingClaim);

        emit Claim(msg.sender, _eAmount - remainingClaim, _stakingId);
    }

    // Function to claim earning rewards from invite
    function claimReward(uint256 _ramount) external nonReentrant checkPools(_ramount) {
        uint256 _claimable = user[msg.sender].claimableEarning;

        require(_ramount > 0, "Cannot claim zero");
        require(_claimable > 0, "no amount to claim");
        require(_claimable >= _ramount, "input amount higher than claimable balance");

        if(_claimable > 0 && _claimable >= _ramount){
            user[msg.sender].claimableEarning -= _ramount;
            IERC20(stakingToken).safeTransfer(msg.sender, _ramount);
        }
    }

    //--------------- Public View ---------------//

    // public view function for get staked and withdraw data
    function canWithdrawAmount(uint256 _stakingId, address _account) public view returns (uint256, uint256) {
        uint256 _stakedAmount = 0;
        uint256 _canWithdraw = 0;

        for (uint256 i = 0; i < stakes[_stakingId][_account].length; ++i) {
            Staking storage _staking = stakes[_stakingId][_account][i];
            _stakedAmount = _stakedAmount + _staking.amount;
            if(block.timestamp >= _staking.endstakeAt){
                _canWithdraw = _canWithdraw + _staking.amount;
            } 
        }
        return (_stakedAmount, _canWithdraw);
    }

    // public view function for get stake data
    function stakeData(uint256 _stakingId, address _account) external view returns (Staking[] memory) {
        Staking[] memory _stakeDatas = new Staking[](stakes[_stakingId][_account].length);

        for (uint256 i = 0; i < stakes[_stakingId][_account].length; ++i) {
            Staking storage _staking = stakes[_stakingId][_account][i];
            _stakeDatas[i] = _staking;
        }

        return (_stakeDatas);
    }

    // public view function for get earned token
    function earnedToken(uint256 _stakingId, address account) external view returns (uint256) {
        uint256 totalEarned = 0;
        Staking[] storage userStakes = stakes[_stakingId][account];

        for (uint256 i = 0; i < userStakes.length; ++i) {
            Staking storage staking = userStakes[i];

            // Calculate earnings since last claim
            uint256 earnedSinceLastClaim = calculateEarned(staking.amount, staking.lastClaim, plans[_stakingId].apr);

            // Add to unclaimed rewards
            totalEarned += (staking.unclaimed + earnedSinceLastClaim);
        }

        return totalEarned;
    }

    // Function to return the total rewards available in the pool
    function getTotalPoolRewards() external view returns (uint256) {
        uint256 totalsPools = IERC20(stakingToken).balanceOf(address(this));
        return totalsPools - totalStaked;
    }
    
    //--------------- Only Owner Function ---------------//

    // function for set enable or disable for specific stake plan
    function setStakeConclude(uint256 _stakingId, bool _conclude) external onlyOwner {
        plans[_stakingId].conclude = _conclude;
    }

    // function for recover other token than staked token
    function recoverOtherERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        require(stakingToken != tokenAddress, "Cannot recover stakingToken");
        IERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);
    }

    //--------------- Private Function ---------------//

    // Private function to remove empty stakes
    function removeEmptyStakes(uint256 _stakingId, address _user) private {
        Staking[] storage userStakes = stakes[_stakingId][_user];
        uint256 i = 0;
        while (i < userStakes.length) {
            // Check if both amount and unclaimed are zero
            if (userStakes[i].amount == 0 && userStakes[i].unclaimed == 0) {
                if (i != userStakes.length - 1) {
                    userStakes[i] = userStakes[userStakes.length - 1];
                }
                userStakes.pop(); // Remove the last element
            } else {
                ++i; // Increment the index only if an element is not removed
            }
        }
    }

    //update unclaimed earnings
    function _updateUnclaimedEarnings(address _users, uint256 _stakingId) private {
        Staking[] storage userStakes = stakes[_stakingId][_users];
        for (uint256 i = 0; i < userStakes.length; ++i) {
            Staking storage staking = userStakes[i];
            uint256 earned = calculateEarned(staking.amount, staking.lastClaim, plans[_stakingId].apr);
            staking.unclaimed += earned;
            staking.lastClaim = block.timestamp; // Update last claim time
        }
    }

    //get total unclaimed
    function _getTotalUnclaimed(address _users, uint256 _stakingId) private view returns (uint256) {
        uint256 totalUnclaimed = 0;
        Staking[] storage userStakes = stakes[_stakingId][_users];
        for (uint256 i = 0; i < userStakes.length; ++i) {
            totalUnclaimed += userStakes[i].unclaimed;
        }
        return totalUnclaimed;
    }

    //--------------- Internal Function ---------------//

    // Internal function to update earnings based on referrals
    function updateReferralEarnings(uint256 amount) internal {
        address currentUpline = user[msg.sender].invitedBy;
        for (uint256 i = 0; i < refPercent.length; ++i) {
            if (currentUpline == address(0)) {
                break; // Stop processing if the upline is a non-existent referrer
            }
            uint256 bonusInvite = (amount * refPercent[i]) / 100;
            user[currentUpline].totalEarning += bonusInvite;
            user[currentUpline].claimableEarning += bonusInvite;
            currentUpline = user[currentUpline].invitedBy; // Move to next referrer
        }
    }

    // Internal function to calculate earned rewards based on stake amount, time, and APR
    function calculateEarned(uint256 amount, uint256 lastClaim, uint256 apr) internal view returns (uint256) {
        return (amount * (block.timestamp - lastClaim) * apr) / 100 / periodicTime;
    }

    // Internal function to calculate penalty for early withdrawal
    function calculatePenalty(uint256 amount, uint256 earlyPenalty) internal pure returns (uint256) {
        return (amount * earlyPenalty) / 100;
    }

    //--------------- Modifier Function ---------------//

    //Security for claim earning, Cannot claim staked balance
    modifier checkPools(uint256 maxPossibleDeduction) {
        uint256 totalsPools = IERC20(stakingToken).balanceOf(address(this));
        require(totalsPools > totalStaked, "Insufficient balance pools: need to refill token into contract");

        // Check if the balance remains sufficient after the potential action
        require(totalsPools - maxPossibleDeduction >= totalStaked, "Action may lead to insufficient balance");
        _;
    }

    //--------------- Events Logs ---------------//

    // Events to log important contract actions
    event Stake(address indexed user, uint256 amount, uint256 stakeId);
    event unStake(address indexed user, uint256 amount, uint256 stakeId);    
    event Claim(address indexed user, uint256 amount, uint256 stakeId);  
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
