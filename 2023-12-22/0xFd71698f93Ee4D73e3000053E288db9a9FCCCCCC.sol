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

interface Broker {
    function userInvestTotal(address) external view returns (uint256);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

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

contract Context {
    constructor () {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function changeOwner(address newOwner) public onlyOwner {
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
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


    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

contract GbtLiquidity is Context, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public _usdt;
    address public _token;
    address public _broker;
    address public _broker1;
    uint private _decimals;
    // Reward multiplier
    uint public _rewardTimes;
    //Minimum added liquidity amount
    uint public _minAdd;
    // Minimum LP for entry
    uint public _minLp;
    // LP amount to trigger stop of new entries
    uint public _helpLp;
    // Number of online orders
    uint public _currentOrderNum;

    // Virtual U Pool quantity
    uint public virtualUPool;
    // Virtual LP Pool quantity
    uint public virtualLPPool;
    // Total dividends already distributed for online orders
    uint public totalDividends;
    // Default precision of virtual lp pool
    uint public _calculateVirtualDecimals;

    // Router for Uniswap V2
    IUniswapV2Router02 public _uniswapV2Router;
    // User's liquidity pool information
    mapping(uint => LiquidityInfo) public _userLiquidityInfos;
    uint public _lastLiquidityId;
    mapping(address => uint[]) public _userLiquidityIds;
    mapping(address => uint) public _userInAmountTotal;
    mapping(uint => ClaimInfo[]) public _userClaimInfos;

    struct ClaimInfo {
        uint time;
        uint amount;
    }

    struct LiquidityInfo {
        uint id;
        uint time;
        uint amount;
        uint liquify;
        // Status: 0 - waiting for rewards, 1 - rewards ended, 2 - withdrawn
        uint status;
        // Pending rewards to be claimed
        uint interest;
        // Claimed rewards
        uint claim;
        // Number of times rewards have been claimed
        uint claimTimes;
        // Withdrawal time
        uint remove_time;
        // Virtual LP
        uint virtualLP;
        // User's address
        address account;
    }

    event AddLiquidity(
        address account,
        uint amount
    );
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    bool private locked;
    modifier nonReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        _lastLiquidityId = 1;
        _rewardTimes = 2;
        _usdt = 0x55d398326f99059fF775485246999027B3197955;
        _token = 0xb0d22255889850F41D3ffA5BA4152f8865AAAAAA;
        _broker = 0xF089427b2e862f419A6063336D3060096FBBBBBB;
        _broker1 = 0x2460064f68DFED945136341F4e3109D2f0BBBBBB;
        _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _decimals = uint(IERC20(_usdt).decimals());
        _minAdd = 100 * 10 ** _decimals;
        // Minimum LP amount for stopping all new entries across the network
        _helpLp = 1 * 10 ** _decimals;
        _calculateVirtualDecimals = 40;
    }

    function setAddress(address param, uint status) external onlyOwner {
        if (status == 0) {
            _token = param;
        } else if (status == 1) {
            _broker = param;
        } else if (status == 2) {
            _broker1 = param;
        }
    }

    function setUint(uint param, uint status) external onlyOwner {
        if (status == 0) {
            _rewardTimes = param;
        } else if (status == 1) {
            _minAdd = param;
        } else if (status == 2) {
            _helpLp = param;
        } else if (status == 3) {
            _calculateVirtualDecimals = param;
        }
    }
    // Check if current entry is allowed
    function canAddLiquidity() public view returns (bool){
        return _minLp == 0 || _minLp > _helpLp;
    }

    // Add liquidity
    function addLiquidity(uint amount) external nonReentrant(){
        require(amount >= _minAdd, "Liquidity:The admission amount is too low");
        uint realAmount = amount.div(1 * 10 ** _decimals);
        require(realAmount.mul(1 * 10 ** _decimals) == amount, "Liquidity:Add only integers");
        address account = _msgSender();
        uint invest = Broker(_broker).userInvestTotal(account) + Broker(_broker1).userInvestTotal(account);
        uint liquiditied = _userInAmountTotal[account];

        // Check if the limit is sufficient
        require(liquiditied.add(amount) <= invest, "Liquidity:over invest amount");
        // Check if current entry is allowed
        require(canAddLiquidity(), "Liquidity:over invest amount");
        IERC20(_usdt).safeTransferFrom(account, address(this), amount);
        // Exchange and add to liquidity pool
        uint addLiquidityNum = _swapAndLiquify(amount);
        // Liquidity record
        LiquidityInfo storage info = _userLiquidityInfos[_lastLiquidityId];
        info.id = _lastLiquidityId;
        info.time = block.timestamp;
        info.amount = amount;
        info.liquify = addLiquidityNum;
        info.status = 0;
        info.interest = 0;
        info.claim = 0;
        info.claimTimes = 0;
        info.remove_time = 0;
        info.account = account;

        // User information
        _userInAmountTotal[account] += amount;
        _userLiquidityIds[account].push(_lastLiquidityId);
        // Increment the liquidity ID
        _lastLiquidityId++;
        uint balance = IERC20(_token).balanceOf(address(this));
        if (balance > 0) {
            IERC20(_token).safeTransfer(_token, balance);
        }
        // Calculate virtual LP quantity based on the ratio of virtual LP pool to virtual U pool
        uint virtualLP = calculateVirtualLP(realAmount);
        if (_minLp == 0 || virtualLP < _minLp) {
            // Record the minimum LP
            _minLp = virtualLP;
        }
        // Update virtual U pool quantity
        virtualUPool += realAmount;
        // Update virtual LP pool quantity
        virtualLPPool += virtualLP;
        // Record virtual LP quantity
        info.virtualLP = virtualLP;
        _currentOrderNum++;
        emit AddLiquidity(account, amount);
    }

    // Remove liquidity
    function removeLiquidity(uint liquidityId) external nonReentrant(){
        address account = _msgSender();
        require(_inArray(liquidityId, _userLiquidityIds[account]), "no permission");

        LiquidityInfo storage info = _userLiquidityInfos[liquidityId];
        require(info.status != 2, "the order is over");
        // Claim rewards
        _claim(account, info);
        // Calculate LP value
        uint uAmount = _lpValue(info.liquify, true);
        if (uAmount > 0) {
            // If the value increased, distribute the original U-value LP; If it decreased, distribute the original LP
            if (uAmount.mul(2) > info.amount) {
                // If the value increased
                uint lp = _lpValue(info.amount, false);
                if (lp > 0) {
                    _removeLiquidity(lp, account);
                }
            } else {
                _removeLiquidity(info.liquify, account);
            }
        }
        if (info.status == 0) {
            // Remove virtual information
            _removeVirtuals(info);
        }
        // Set to completed status
        info.status = 2;
        info.remove_time = block.timestamp;
        if (_currentOrderNum == 0) {
            // Reset the minimum LP
            _minLp = 0;
        }
    }

    // Remove virtual information
    function _removeVirtuals(LiquidityInfo storage info) internal {
        uint amount = info.amount.div(1 * 10 ** _decimals);
        if (virtualUPool >= amount) {
            virtualUPool -= amount;
        } else {
            virtualUPool = 0;
        }
        // Update virtual LP pool quantity
        if (virtualLPPool >= info.virtualLP) {
            virtualLPPool -= info.virtualLP;
        } else {
            virtualLPPool = 0;
        }
        // Deduct totalDividends for the whole network
        totalDividends -= info.claim;
        _currentOrderNum = _currentOrderNum >= 1 ? _currentOrderNum - 1 : 0;
    }

    // Get a collection of order IDs that are eligible for removal
    function getRemoveIds(uint start, uint end) external view returns (uint[] memory){
        require(start <= end && _lastLiquidityId > 1, "Order does not exist");
        uint len = 0;
        if (start == 0 && end == 0) {
            len = _lastLiquidityId - 1;
            start = 1;
            end = len;
        } else {
            len = end - start > 0 ? (end - start) : 1;
        }
        uint success;
        uint[] memory ids = new uint[](len);
        for (uint i = start; i <= end; i++) {
            LiquidityInfo memory info = _userLiquidityInfos[i];
            if (info.status == 0 && info.amount > 0) {
                // Only check orders that meet the conditions for elimination
                if (getInterest(i).add(info.claim) >= info.amount.mul(_rewardTimes)) {
                    ids[success++] = i;
                }
            }
        }
        return ids;
    }

    // Help all orders on the network to be removed
    function helpRemove(uint[] calldata ids) external nonReentrant() {
        require(_lastLiquidityId > 1, 'No order execution');
        uint successed;
        for (uint i; i < ids.length; i++) {
            LiquidityInfo storage info = _userLiquidityInfos[ids[i]];
            require(info.amount > 0 && info.status == 0, "The order does not meet the conditions");
            // Only check orders that meet the conditions for elimination
            if (getInterest(ids[i]).add(info.claim) >= info.amount.mul(_rewardTimes)) {
                _claim(info.account, info);
                successed++;
            }
        }
        if (successed == 0) {
            revert('Orders that have not been eliminated');
        }
    }

    // Get the actual virtual U pool quantity
    function _realVirtualUPool() public view returns (uint){
        uint balance = IERC20(_usdt).balanceOf(address(this));
        if (balance > 0) {
            balance = balance.div(1 * 10 ** _decimals);
        }
        uint _totalDividends = totalDividends;
        if (_totalDividends > 0) {
            _totalDividends = _totalDividends.div(1 * 10 ** _decimals);
        }
        return virtualUPool.add(balance).add(_totalDividends);
    }

    // Transfer tokens
    function _transfer(address token, address account, uint amount) internal {
        if (IERC20(token).balanceOf(address(this)) < amount) {
            amount = IERC20(token).balanceOf(address(this));
        }
        if (amount > 0) {
            IERC20(token).safeTransfer(account, amount);
        }
    }

    // Remove specific liquidity
    function _removeLiquidity(uint lp, address account) internal {
        uint amount = IERC20(_lpToken()).balanceOf(address(this));
        if (lp > amount) {
            lp = amount;
        }
        if (lp > 0) {
            IERC20(_lpToken()).safeIncreaseAllowance(address(_uniswapV2Router), lp);
            _uniswapV2Router.removeLiquidity(_usdt, _token, lp, 0, 0, account, block.timestamp);
        }
    }

    // Calculate the virtual LP quantity of the order
    function calculateVirtualLP(uint enterAmount) private view returns (uint) {
        if (virtualLPPool == 0) {
            // If there is no LP in the virtual LP pool, the virtual LP quantity is equal to the USDT amount of the order (with 18 decimals by default)
            return enterAmount * 10 ** _calculateVirtualDecimals;
        } else {
            // If there is LP in the virtual LP pool, calculate the virtual LP quantity based on the formula
            return enterAmount.mul(virtualLPPool).div(_realVirtualUPool());
        }
    }
    // Calculate the withdrawable amount for an order
    function calculateDividends(uint liquidityId) private view returns (uint) {
        LiquidityInfo memory info = _userLiquidityInfos[liquidityId];
        if (info.status == 1 || info.status == 2 || info.account == address(0)) {
            return 0;
        }
        // Calculate the withdrawable amount: order amount * 2 - claimed - (current market value - entry amount)
        uint realVirtualUPool = _realVirtualUPool();
        uint uAmount = info.virtualLP.mul(realVirtualUPool).mul(1 * 10 ** _decimals).div(virtualLPPool);
        uint withdrawableAmount = uAmount < info.amount ? 0 : uAmount.sub(info.amount);
        if (withdrawableAmount > 0 && withdrawableAmount > info.amount.mul(_rewardTimes)) {
            withdrawableAmount = info.amount.mul(_rewardTimes);
        }
        if (withdrawableAmount >= info.claim) {
            withdrawableAmount = withdrawableAmount.sub(info.claim);
        } else {
            withdrawableAmount = 0;
        }

        return withdrawableAmount;
    }

    // Get the U value of LP
    function _lpValue(uint amount, bool status) internal view returns (uint){
        address pair = _lpToken();
        (uint reserve1,uint reserve2,) = IUniswapV2Pair(pair).getReserves();
        if (IUniswapV2Pair(pair).token0() == _token) {
            reserve1 = reserve2;
        }
        if (status == true) {
            // Calculate how much U for a certain LP value
            return amount.mul(reserve1).div(IUniswapV2Pair(pair).totalSupply());
        } else {
            // Calculate how much LP for a certain U value; divide by 2 because the trading pair is 2 times U
            return amount.mul(IUniswapV2Pair(pair).totalSupply()).div(reserve1).div(2);
        }
    }

    function _lpToken() internal view returns (address){
        return IUniswapV2Factory(_uniswapV2Router.factory()).getPair(_token, _usdt);
    }

    // Claim rewards
    function claim(uint liquidityId) external nonReentrant(){
        address account = _msgSender();
        require(_inArray(liquidityId, _userLiquidityIds[account]), "no permission");

        LiquidityInfo storage info = _userLiquidityInfos[liquidityId];
        require(info.status != 2, "the order is over");
        // Claim rewards
        _claim(account, info);
    }

    function _claim(address account, LiquidityInfo storage info) internal {
        uint amount = calculateDividends(info.id);
        if (amount > 0) {
            _transfer(_usdt, account, amount);
            info.claim += amount;
            // Total dividends
            totalDividends += amount;
            info.claimTimes++;
            if (info.status == 0 && info.claim >= info.amount.mul(_rewardTimes)) {
                // End the order
                info.status = 1;
                // Remove virtual information
                _removeVirtuals(info);
            }
            _userClaimInfos[info.id].push(ClaimInfo(block.timestamp, amount));
            if (_currentOrderNum == 0) {
                // Reset the minimum LP
                _minLp = 0;
            }
        }
    }

    function _inArray(uint id, uint[] memory ids) internal pure returns (bool){
        for (uint i; i < ids.length; i++) {
            if (ids[i] == id) {
                return true;
            }
        }
        return false;
    }

    event SendReward(uint reward);

    // Get the real withdrawable interest for the current order
    function getInterest(uint infoId) public view returns (uint amount){
        return calculateDividends(infoId);
    }

    // Exchange and add to the liquidity pool
    function _swapAndLiquify(uint256 tokens) private returns (uint){
        // Split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // Swap tokens for USDT
        _swapTokensForTokensTo(half, address(this));
        // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        uint256 newBalance = IERC20(_token).balanceOf(address(this));
        // Add liquidity to Uniswap
        emit SwapAndLiquify(half, newBalance, otherHalf);
        return _addLiquidityTokens(otherHalf, newBalance);
    }

    function _swapTokensForTokensTo(uint256 tokenAmount, address to) private {
        // Generate the Uniswap pair path of token -> USDT
        address[] memory path = new address[](2);
        path[0] = _usdt;
        path[1] = _token;

        IERC20(_usdt).safeIncreaseAllowance(address(_uniswapV2Router), tokenAmount);

        // Make the swap
        _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // Accept any amount of ETH
            path,
            to,
            block.timestamp
        );

    }

    function _addLiquidityTokens(uint256 uAmount, uint256 tokenAmount) private returns (uint liquidityNum){
        // Approve token transfer to cover all possible scenarios
        IERC20(_token).safeIncreaseAllowance(address(_uniswapV2Router), tokenAmount);
        IERC20(_usdt).safeIncreaseAllowance(address(_uniswapV2Router), uAmount);
        // Add the liquidity
        (,, liquidityNum) = _uniswapV2Router.addLiquidity(
            _usdt,
            _token,
            uAmount,
            tokenAmount,
            0, // Slippage is unavoidable
            0, // Slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    // Get the total principal amount
    function userInAmountSum(address account) external view returns (uint sum){
        for (uint i; i < _userLiquidityIds[account].length; i++) {
            LiquidityInfo memory info = _userLiquidityInfos[_userLiquidityIds[account][i]];
            if (info.status == 0) {
                sum += info.amount;
            }
        }
    }

    // Get the user's liquidity IDs collection
    function getUserLiquidityIds(address account) public view returns (uint[] memory ids){
        uint[] memory temp = new uint[](_userLiquidityIds[account].length);
        for (uint i; i < _userLiquidityIds[account].length; i++) {
            temp[i] = _userLiquidityIds[account][i];
        }
        ids = temp;
    }
}