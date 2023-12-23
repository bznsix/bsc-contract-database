/***
 *      ______  _____         ______  _______ __   _  
 *     |  ____ |     | |      |     \ |______ | \  |  
 *     |_____| |_____| |_____ |_____/ |______ |  \_|  
 *                                                    
 *     ______  _______ _______ ______   _____   _____ 
 *     |_____] |_____| |  |  | |_____] |     | |     |
 *     |_____] |     | |  |  | |_____] |_____| |_____|
 *                                                    
 *     _______  _____  _     _ _______ __   _         
 *        |    |     | |____/  |______ | \  |         
 *        |    |_____| |    \_ |______ |  \_|         
 *                                                    
 *     Website: https://gbt.gold
 *     Twitter(X): https://twitter.com/gbt_gold
 *     Telegram: https://t.me/gbt_gold
 *     Email: gbt@gbt.im
 */

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}
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

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
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

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

interface IUniswapV2Router02 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract GbtBroker {
    using SafeERC20 for IERC20;
    struct User {
        uint id;
        address referrer;
        // Number of referrals
        uint partnersCount;

        // X3 level status
        mapping(uint8 => bool) activeX3Levels;
        // X6 level status
        mapping(uint8 => bool) activeX6Levels;

        mapping(uint8 => X3) x3Matrix;
        mapping(uint8 => X6) x6Matrix;
    }

    struct X3 {
        // Current referrer of the level
        address currentReferrer;
        // Referrals of the level
        address[] referrals;
        // Number of matrix completions in history
        uint reinvestCount;
    }

    struct X6 {
        // Current referrer of the level
        address currentReferrer;
        // First level users collection
        address[] firstLevelReferrals;
        // Second level users collection
        address[] secondLevelReferrals;
        // Number of matrix completions in history
        uint reinvestCount;

        // Closed part of the matrix
        address closedPart;
    }

    uint8 public LAST_LEVEL;

    mapping(address => User) public users;
    mapping(uint => address) public idToAddress;
    mapping(uint => address) public userIds;
    mapping(address => uint) public balances;
    mapping(address => uint) public userRewards;

    uint public lastUserId;
    address public _usdt;
    address public _token;
    IUniswapV2Router02 public _uniswapV2Router; // Router

    mapping(uint8 => uint) public levelPrice;
    // Upgrade condition (number of matrix completions required)
    mapping(uint => uint) public upgradeCondition;

    // Registration event
    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    // Investment event
    event Invest(address indexed user, uint indexed amount);
    // Reinvestment event
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    // Upgrade event
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level);
    // New user placement event
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint8 place, uint reward);
    // Reward event
    event Reward(uint reward);

    constructor() {
        LAST_LEVEL = 7;
        lastUserId = 2;
        _usdt = 0x55d398326f99059fF775485246999027B3197955;
        _token = 0xb0d22255889850F41D3ffA5BA4152f8865AAAAAA;
        _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // Pricing starts at 100u
        uint8 decimals = IERC20(_usdt).decimals();
        levelPrice[1] = 100 * 10 ** decimals;
        levelPrice[2] = 500 * 10 ** decimals;
        upgradeCondition[2] = 2;
        for (uint8 i = 3; i <= LAST_LEVEL; i++) {
            levelPrice[i] = levelPrice[i - 1] * 2;
            upgradeCondition[i] = (i - 1) ** 2;
        }
        address firstAddress = address(0x7159D6Cd0CA651296BB6586623D5861111111111);

        User storage user = users[firstAddress];
        user.id = 1;
        user.referrer = address(0);
        user.partnersCount = 0;
        user.activeX3Levels[0] = false;
        user.activeX6Levels[0] = false;
        user.x3Matrix[0] = X3({
        currentReferrer : address(0),
        // Referrals of the level
        referrals : new address[](0),
        // Number of matrix completions in history
        reinvestCount : 0
        });
        user.x6Matrix[0] = X6({
        // Current referrer of the level
        currentReferrer : address(0),
        // First level users collection
        firstLevelReferrals : new address[](0),
        // Second level users collection
        secondLevelReferrals : new address[](0),
        // Number of matrix completions in history
        reinvestCount : 0,
        // Closed part of the matrix
        closedPart : address(0)
        });

        idToAddress[1] = firstAddress;

        users[firstAddress].activeX3Levels[1] = true;
        for (uint8 i = 1; i <= LAST_LEVEL; i++) {
            users[firstAddress].activeX6Levels[i] = true;
        }

        userIds[1] = firstAddress;
    }

    // Bind the superior
    function registrationExt(address referrerAddress) external {
        registration(msg.sender, referrerAddress);
    }

    bool private locked;
    modifier nonReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
    // Buy a new level (Change to only buy X6)
    function buyNewLevel(uint8 level) external nonReentrant(){
        require(isUserExists(msg.sender), "User does not exist. Register first.");
        require(level > 1 && level <= LAST_LEVEL, "Invalid level");
        require(users[msg.sender].activeX6Levels[level - 1], "Last level not activated");
        require(upgradeCondition[level] <= users[msg.sender].x3Matrix[1].reinvestCount, "Level 1 reinvest count not enough");
        // Pay in 'u' to buy the level
        uint uAmount = levelPrice[level];
        // Buy X6 level
        require(!users[msg.sender].activeX6Levels[level], "Level already activated");

        address freeX6Referrer = findFreeX6Referrer(msg.sender, level);

        users[msg.sender].activeX6Levels[level] = true;
        _pay(uAmount);
        updateX6Referrer(msg.sender, freeX6Referrer, level);

        emit Upgrade(msg.sender, freeX6Referrer, 2, level);
        emit Invest(msg.sender, levelPrice[level]);
    }

    function registration(address userAddress, address referrerAddress) private nonReentrant(){
        require(userAddress != address(0) && referrerAddress != address(0), "User or Referrer cannot be a zero address");
        require(!isUserExists(userAddress), "User already exists");
        require(isUserExists(referrerAddress), "Referrer does not exist");
        uint uAmount = levelPrice[1];

        uint32 size;
        // Check if the address is a contract
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "Cannot be a contract");

        User storage user = users[userAddress];
        user.id = lastUserId;
        user.referrer = referrerAddress;
        user.partnersCount = 0;
        user.activeX3Levels[0] = false;
        user.activeX6Levels[0] = false;
        user.x3Matrix[1] = X3({
        currentReferrer : address(0),
        // Referrals of the level
        referrals : new address[](0),
        // Number of matrix completions in history
        reinvestCount : 0
        });
        user.x6Matrix[1] = X6({
        // Current referrer of the level
        currentReferrer : address(0),
        // First level users collection
        firstLevelReferrals : new address[](0),
        // Second level users collection
        secondLevelReferrals : new address[](0),
        // Number of matrix completions in history
        reinvestCount : 0,
        // Closed part of the matrix
        closedPart : address(0)
        });

        // Mapping ID to address
        idToAddress[lastUserId] = userAddress;

        // Set user's referrer
        users[userAddress].referrer = referrerAddress;

        // Activate X3 level 1 and X6 level 1 by default
        users[userAddress].activeX3Levels[1] = true;
        users[userAddress].activeX6Levels[1] = true;

        // Mapping ID to address
        userIds[lastUserId] = userAddress;
        lastUserId++;

        // Increase the partner count of the referrer
        users[referrerAddress].partnersCount++;

        // Find a free X3 referrer for the new user
        address freeX3Referrer = findFreeX3Referrer(userAddress, 1);
        // Set up the X3 matrix for level 1
        // Set the current referrer of the level
        users[userAddress].x3Matrix[1].currentReferrer = freeX3Referrer;

        // Pay in 'u'
        _pay(uAmount);
        updateX3Referrer(userAddress, freeX3Referrer, 1);

        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
        emit Invest(userAddress, levelPrice[1]);
    }

    function updateX3Referrer(address userAddress, address referrerAddress, uint8 level) private{
        // Add the new member to the referrals of the current referrer of the level
        users[referrerAddress].x3Matrix[level].referrals.push(userAddress);

        // If the current referrer doesn't have enough referrals, distribute rewards and complete the matrix
        if (users[referrerAddress].x3Matrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress, 1, level, uint8(users[referrerAddress].x3Matrix[level].referrals.length), IERC20(_token).balanceOf(address(this)));
            return sendTokenDividends(referrerAddress);
        }

        emit NewUserPlace(userAddress, referrerAddress, 1, level, 3, IERC20(_token).balanceOf(address(this)));
        // Close the matrix and clear the referrals collection
        users[referrerAddress].x3Matrix[level].referrals = new address[](0);

        // Create a new matrix by recursion
        if (referrerAddress != idToAddress[1]) {
            // Check the referrer's active level
            address freeReferrerAddress = findFreeX3Referrer(referrerAddress, level);
            if (users[referrerAddress].x3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].x3Matrix[level].currentReferrer = freeReferrerAddress;
            }

            users[referrerAddress].x3Matrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, level);
            emit Invest(referrerAddress, levelPrice[level]);
            updateX3Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            // If the current referrer is the owner, stop searching for higher referrers
            sendTokenDividends(idToAddress[1]);
            users[idToAddress[1]].x3Matrix[level].reinvestCount++;
            emit Reinvest(idToAddress[1], address(0), userAddress, 1, level);
            emit Invest(idToAddress[1], levelPrice[level]);
        }
    }

    function updateX6Referrer(address userAddress, address referrerAddress, uint8 level) private {
        require(users[referrerAddress].activeX6Levels[level], "500. Referrer level is inactive");

        if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length < 2) {
            // Place in the first level
            users[referrerAddress].x6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, referrerAddress, 2, level, uint8(users[referrerAddress].x6Matrix[level].firstLevelReferrals.length), IERC20(_token).balanceOf(address(this)));

            // Set the current level
            users[userAddress].x6Matrix[level].currentReferrer = referrerAddress;

            if (referrerAddress == idToAddress[1]) {
                return sendTokenDividends(referrerAddress);
            }

            address ref = users[referrerAddress].x6Matrix[level].currentReferrer;
            users[ref].x6Matrix[level].secondLevelReferrals.push(userAddress);

            uint len = users[ref].x6Matrix[level].firstLevelReferrals.length;

            if ((len == 2) &&
            (users[ref].x6Matrix[level].firstLevelReferrals[0] == referrerAddress) &&
                (users[ref].x6Matrix[level].firstLevelReferrals[1] == referrerAddress)) {
                if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5, IERC20(_token).balanceOf(address(this)));
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6, IERC20(_token).balanceOf(address(this)));
                }
            } else if ((len == 1 || len == 2) &&
                users[ref].x6Matrix[level].firstLevelReferrals[0] == referrerAddress) {
                if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 3, IERC20(_token).balanceOf(address(this)));
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 4, IERC20(_token).balanceOf(address(this)));
                }
            } else if (len == 2 && users[ref].x6Matrix[level].firstLevelReferrals[1] == referrerAddress) {
                if (users[referrerAddress].x6Matrix[level].firstLevelReferrals.length == 1) {
                    emit NewUserPlace(userAddress, ref, 2, level, 5, IERC20(_token).balanceOf(address(this)));
                } else {
                    emit NewUserPlace(userAddress, ref, 2, level, 6, IERC20(_token).balanceOf(address(this)));
                }
            }

            return updateX6ReferrerSecondLevel(userAddress, ref, level);
        }

        // Place in the second level
        users[referrerAddress].x6Matrix[level].secondLevelReferrals.push(userAddress);

        if (users[referrerAddress].x6Matrix[level].closedPart != address(0)) {
            if ((users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] ==
            users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]) &&
                (users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].x6Matrix[level].closedPart)) {

                updateX6(userAddress, referrerAddress, level, true);
                return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else if (users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] ==
                users[referrerAddress].x6Matrix[level].closedPart) {
                updateX6(userAddress, referrerAddress, level, true);
                return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            } else {
                updateX6(userAddress, referrerAddress, level, false);
                return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
            }
        }

        if (users[referrerAddress].x6Matrix[level].firstLevelReferrals[1] == userAddress) {
            updateX6(userAddress, referrerAddress, level, false);
            return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
        } else if (users[referrerAddress].x6Matrix[level].firstLevelReferrals[0] == userAddress) {
            updateX6(userAddress, referrerAddress, level, true);
            return updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
        }

        if (users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.length <=
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.length) {
            updateX6(userAddress, referrerAddress, level, false);
        } else {
            updateX6(userAddress, referrerAddress, level, true);
        }

        updateX6ReferrerSecondLevel(userAddress, referrerAddress, level);
    }

    function updateX6(address userAddress, address referrerAddress, uint8 level, bool x2) private {
        if (!x2) {
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].x6Matrix[level].firstLevelReferrals[0], 2, level, uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.length), IERC20(_token).balanceOf(address(this)));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 2 + uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[0]].x6Matrix[level].firstLevelReferrals.length), IERC20(_token).balanceOf(address(this)));
            //set current level
            users[userAddress].x6Matrix[level].currentReferrer = users[referrerAddress].x6Matrix[level].firstLevelReferrals[0];
        } else {
            users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.push(userAddress);
            emit NewUserPlace(userAddress, users[referrerAddress].x6Matrix[level].firstLevelReferrals[1], 2, level, uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.length), IERC20(_token).balanceOf(address(this)));
            emit NewUserPlace(userAddress, referrerAddress, 2, level, 4 + uint8(users[users[referrerAddress].x6Matrix[level].firstLevelReferrals[1]].x6Matrix[level].firstLevelReferrals.length), IERC20(_token).balanceOf(address(this)));
            //set current level
            users[userAddress].x6Matrix[level].currentReferrer = users[referrerAddress].x6Matrix[level].firstLevelReferrals[1];
        }
    }

    function updateX6ReferrerSecondLevel(address userAddress, address referrerAddress, uint8 level) private {
        if (users[referrerAddress].x6Matrix[level].secondLevelReferrals.length < 4) {

            return sendTokenDividends(referrerAddress);
        }

        address[] memory x6 = users[users[referrerAddress].x6Matrix[level].currentReferrer].x6Matrix[level].firstLevelReferrals;

        if (x6.length == 2) {
            if (x6[0] == referrerAddress ||
                x6[1] == referrerAddress) {
                users[users[referrerAddress].x6Matrix[level].currentReferrer].x6Matrix[level].closedPart = referrerAddress;
            } else if (x6.length == 1) {
                if (x6[0] == referrerAddress) {
                    users[users[referrerAddress].x6Matrix[level].currentReferrer].x6Matrix[level].closedPart = referrerAddress;
                }
            }
        }

        users[referrerAddress].x6Matrix[level].firstLevelReferrals = new address[](0);
        users[referrerAddress].x6Matrix[level].secondLevelReferrals = new address[](0);
        users[referrerAddress].x6Matrix[level].closedPart = address(0);

        users[referrerAddress].x6Matrix[level].reinvestCount++;

        if (referrerAddress != idToAddress[1]) {
            address freeReferrerAddress = findFreeX6Referrer(referrerAddress, level);

            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 2, level);
            emit Invest(referrerAddress, levelPrice[level]);
            updateX6Referrer(referrerAddress, freeReferrerAddress, level);
        } else {
            emit Reinvest(idToAddress[1], address(0), userAddress, 2, level);
            emit Invest(idToAddress[1], levelPrice[level]);
            sendTokenDividends(idToAddress[1]);
        }
    }

    function findFreeX3Referrer(address userAddress, uint8 level) public view returns (address) {
        while (true) {
            // Get the address of the user's referrer at the same level as the current level
            if (users[users[userAddress].referrer].activeX3Levels[level]) {
                return users[userAddress].referrer;
            }

            userAddress = users[userAddress].referrer;
        }
    }

    function findFreeX6Referrer(address userAddress, uint8 level) public view returns (address) {
        while (true) {
            // Get the address of the user's referrer at the same level as the current level
            if (users[users[userAddress].referrer].activeX6Levels[level]) {
                return users[userAddress].referrer;
            }

            userAddress = users[userAddress].referrer;
        }
    }

    function usersActiveX3Levels(address userAddress, uint8 level) public view returns (bool) {
        return users[userAddress].activeX3Levels[level];
    }

    function usersActiveX6Levels(address userAddress, uint8 level) public view returns (bool) {
        return users[userAddress].activeX6Levels[level];
    }

    function usersX3Matrix(address userAddress, uint8 level) public view returns (address, address[] memory) {
        return (
        users[userAddress].x3Matrix[level].currentReferrer,
        users[userAddress].x3Matrix[level].referrals
        );
    }

    function usersX6Matrix(address userAddress, uint8 level) public view returns (address, address[] memory, address[] memory, address) {
        return (
        users[userAddress].x6Matrix[level].currentReferrer,
        users[userAddress].x6Matrix[level].firstLevelReferrals,
        users[userAddress].x6Matrix[level].secondLevelReferrals,
        users[userAddress].x6Matrix[level].closedPart
        );
    }

    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }

    function sendTokenDividends(address userAddress) private {
        // Transfer tokens to the reward recipient
        uint left = IERC20(_token).balanceOf(address(this));
        if (left > 0) {
            uint balance = IERC20(_token).balanceOf(address(userAddress));
            IERC20(_token).safeTransfer(address(userAddress), left);
            left = IERC20(_token).balanceOf(address(userAddress)) - balance;
        }
        userRewards[userAddress] += left;
        emit Reward(left);
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    // Get the total investment amount of the user in the entire network
    function userInvestTotal(address account) external view returns (uint total) {
        if (idToAddress[1] != account) {
            for (uint8 i = 1; i <= LAST_LEVEL; i++) {
                if (i == 1 ? users[account].activeX3Levels[i] : users[account].activeX6Levels[i]) {
                    total += levelPrice[i];
                    // Add reinvestment
                    total += (i == 1 ? levelPrice[i] * users[account].x3Matrix[i].reinvestCount : levelPrice[i] * users[account].x6Matrix[i].reinvestCount);
                }
            }
        }
    }

    // Get the contract issuance quota for the user
    function userQuota(address account) external view returns (uint total) {
        if (idToAddress[1] != account) {
            for (uint8 i = 2; i <= LAST_LEVEL; i++) {
                if (users[account].activeX6Levels[i]) {
                    total += levelPrice[i];
                }
            }
        }
    }

    // Pay the corresponding 'u' and exchange for tokens
    function _pay(uint uAmount) internal {
        IERC20(_usdt).safeTransferFrom(msg.sender, address(this), uAmount);
        // Exchange tokens for team leaders
        IERC20(_usdt).safeIncreaseAllowance(address(_uniswapV2Router), uAmount);
        address[] memory path = new address[](2);
        path[0] = _usdt;
        path[1] = _token;
        _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            uAmount,
            0, // accept any amount
            path,
            address(this),
            block.timestamp
        );
    }

    // Get the level of the user
    function getLevel(address account) public view returns (uint8) {
        for (uint8 i = LAST_LEVEL; i >= 1; i--) {
            if (users[account].activeX6Levels[i] == true) {
                return i;
            }
        }
        return 0;
    }

    // Get the number of reinvestments for the user at the current level
    function getReinvestCount(address account, uint8 level) external view returns (uint count) {
        if (level == 1) {
            return users[account].x3Matrix[level].reinvestCount + 1;
        }
        return users[account].x6Matrix[level].reinvestCount + 1;
    }

    // Get the number of product packages sold at the current level and round for the user
    function getProductCount(address account, uint8 level, uint reinvest) external view returns (uint) {
        require(reinvest > 0 && level > 0);
        uint8 _level = getLevel(account);
        if (_level < level) {
            return 0;
        } else if (level == 1) {
            return users[account].x3Matrix[level].reinvestCount + 1;
        } else {
            return users[account].x6Matrix[level].reinvestCount + 1;
        }
    }

    // Get the number of product packages sold at the current level and round for the user
    function getSellCount(address account, uint8 level, uint reinvest) external view returns (uint) {
        require(reinvest > 0 && level > 0);
        uint8 _level = getLevel(account);
        if (_level < level) {
            return 0;
        } else if (level == 1) {
            if (reinvest <= users[account].x3Matrix[level].reinvestCount) {
                return 3;
            } else {
                return users[account].x3Matrix[level].referrals.length;
            }
        } else {
            if (reinvest <= users[account].x6Matrix[level].reinvestCount) {
                return 6;
            } else {
                return users[account].x6Matrix[level].firstLevelReferrals.length + users[account].x6Matrix[level].secondLevelReferrals.length;
            }
        }
    }
}