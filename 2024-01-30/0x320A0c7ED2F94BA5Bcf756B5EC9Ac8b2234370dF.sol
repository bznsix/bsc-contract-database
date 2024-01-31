/**
 *Submitted for verification at BscScan.com on 2024-01-30
*/

/**
 *Submitted for verification at BscScan.com on 2024-01-28
*/

/**
 *Submitted for verification at testnet.bscscan.com on 2023-11-13
*/

/**
 *Submitted for verification at BscScan.com on 2023-10-15
 */

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.18;

/**
 * @dev Provides information about the current execution context
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

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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

// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
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
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data
    ) internal view returns (bytes memory) {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
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
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Implementation of the {IERC20} interface.
 */
contract ERC20 is Context, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
}

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

interface IPancakePair {
    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IPancakeFactory {
    function createPair(address tokenA,address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IPancakeRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

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

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

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

interface Team22Fall {

    function memberUpgrade(
        address _address,
        uint256 newLevel,
        uint256 incPower
    ) external;

    function memberUpgrade2(
        address _address,
        uint256 newLevel,
        uint256 incPower
    ) external;

    function addDirectRecReward(address _address, uint256 incData) external;

    function addTeamReward(address _address, uint256 incData) external;

    function addTotalBuyUSDT(address _address, uint256 incData) external;

    function addPower(address _address, uint256 incData) external;

    function isAlreadySeat(address _address) external view returns (bool);

    function seat(address recAddr, address parentAddr, address _address, uint256 level) external returns (bool);

    function seat(address recAddr, address _address, uint256 level) external  returns (bool);

    function getMemberLevel(address _address) external view returns (uint256);

    function getMemberBuyU(address _address) external view returns (uint256);

    function getDirectRecInfo(
        address _address
    ) external view returns (address directRecAddr, uint256 directRecLevel);

    function getTeamUpParentsAndLevels(
        address _address,
        uint256 num
    ) external view returns (address[] memory, uint256[] memory);
}

interface QILIN {
    function mint(address account, uint256 amount) external;
}

library ProxyLibrary {
    using SafeERC20 for IERC20;
    
    uint256 public constant MAX_AMOUNT_WEI = 1000000000 * 1e18;
    uint256 public constant MAX_HOURLY_TOTAL_AMOUNT_WEI = 50000000000000000 * 1e18;
    uint256 public constant MAX_MINUTELY_TOTAL_AMOUNT_WEI = 2000000000000000000000 * 1e18;
    uint256 public constant MAX_SELL_AMOUNT_MINUTELY = 500000000000000000000000 * 1e18; // 50000 USDT in wei (assuming 18 decimals)

    function toDirectRec(uint256 memberLevel, address recAddr, uint256 recLevel, uint liquidity,
        uint256 directRecRewardRatio, 
        address uniswapV2Pair, address teamAddress) internal returns (uint256){
        uint256 tmpTransNum = 0;
        //1) transfer to directRec , 25%
        uint256 recRewardBase = (liquidity * directRecRewardRatio * 2 / 10) / 100;
        if (recAddr != address(0) && recLevel > 0) {
            tmpTransNum = recLevel >= memberLevel  ? recRewardBase  : 0;
            IERC20(uniswapV2Pair).safeTransfer(recAddr, tmpTransNum);
            Team22Fall(teamAddress).addDirectRecReward(recAddr, tmpTransNum);
        }
        return tmpTransNum;
    }

    function toDirectRec_a(uint256 memberLevel, address recAddr, uint256 recLevel, uint liquidity,
        uint256 directRecBlack, 
        address uniswapV2Pair, address teamAddress) internal returns (uint256){
        uint256 tmpTransNum = 0;
        //1) transfer to directRec , 3%
        uint256 recRewardBase = (liquidity * directRecBlack * 2 / 10) / 100;
        if (recAddr != address(0) && recLevel > 0) {
            tmpTransNum = recLevel >= memberLevel  ? recRewardBase  : 0;
            IERC20(uniswapV2Pair).safeTransfer(0xE794fcCc7F6D3Cd58fA733db925c68AF4ef54B2A, tmpTransNum);
            Team22Fall(teamAddress).addDirectRecReward(0xE794fcCc7F6D3Cd58fA733db925c68AF4ef54B2A, tmpTransNum);
        }
        return tmpTransNum;
    }
    function toDirectRec_s(uint256 memberLevel, address recAddr, uint256 recLevel, uint liquidity,
        uint256 directRecBlack_s, 
        address uniswapV2Pair, address teamAddress) internal returns (uint256){
        uint256 tmpTransNum = 0;
        //1) transfer to directRec , 3%
        uint256 recRewardBase = (liquidity * directRecBlack_s * 2 / 10) / 100;
        if (recAddr != address(0) && recLevel > 0) {
            tmpTransNum = recLevel >= memberLevel  ? recRewardBase  : 0;
            IERC20(uniswapV2Pair).safeTransfer(0xA2AbA3311da3Ec9e094ab7C87Ec2DE75B2E7f8fc, tmpTransNum);
            Team22Fall(teamAddress).addDirectRecReward(0xA2AbA3311da3Ec9e094ab7C87Ec2DE75B2E7f8fc, tmpTransNum);
        }
        return tmpTransNum;
    }

    function toUpParents(address account, uint256 memberLevel,  uint liquidity,
        uint256 teamRewardRatio, uint256 maxTeamDeep, 
        address uniswapV2Pair, address teamAddress
    ) internal returns (uint256){ 
        //2） transfer to up 16 parents , 14%
        uint256 totalTransLiquiNum = 0;
        uint256 tmpTransNum = 0;
        (address[] memory parentAddrs,uint256[] memory parentLevs) = Team22Fall(teamAddress).getTeamUpParentsAndLevels(account,maxTeamDeep);
        uint256 teamRewardBase = (liquidity * teamRewardRatio * 2 / 10) / 100 / maxTeamDeep;
        for (uint i = 0; i < parentAddrs.length; i++) {
            if (parentAddrs[i] != address(0)) {
                if (parentLevs[i] > 0) {
                    tmpTransNum = parentLevs[i] >= memberLevel ? teamRewardBase : 0;
                    totalTransLiquiNum += tmpTransNum;
                    IERC20(uniswapV2Pair).safeTransfer(parentAddrs[i], tmpTransNum);
                    Team22Fall(teamAddress).addTeamReward(parentAddrs[i], tmpTransNum);
                }
            } else {
                break;
            }
        }
        return totalTransLiquiNum;
    }

    function distributeRewards(address account, uint256 memberLevel, address recAddr, uint256 recLevel, uint liquidity,
        uint256 directRecRewardRatio,uint256 directRecBlack, uint256 directRecBlack_s, uint256 teamRewardRatio, uint256 maxTeamDeep, 
        address uniswapV2Pair, address teamAddress, address marketingAddress) internal {
        uint256 totalTransLiquiNum = 0;
        totalTransLiquiNum += toDirectRec(memberLevel, recAddr, recLevel, liquidity, directRecRewardRatio, uniswapV2Pair, teamAddress);
        totalTransLiquiNum += toDirectRec_a(memberLevel, recAddr, recLevel, liquidity, directRecBlack, uniswapV2Pair, teamAddress);
        totalTransLiquiNum += toDirectRec_s(memberLevel, recAddr, recLevel, liquidity, directRecBlack_s, uniswapV2Pair, teamAddress);
        //2） transfer to up 16 parents , 16%
        totalTransLiquiNum += toUpParents(account, memberLevel, liquidity, teamRewardRatio, maxTeamDeep, uniswapV2Pair, teamAddress);
        //3） transfer to market address( = team root) , 7%
        IERC20(uniswapV2Pair).safeTransfer(marketingAddress, liquidity > totalTransLiquiNum ? (liquidity - totalTransLiquiNum) : 0 );
    }

    function beforeBuyCheck(address account, uint256 amountU, address teamAddress, uint256[] memory levelToBuyU) internal {
        uint256 memLevel = Team22Fall(teamAddress).getMemberLevel(account);
        uint256 memHasBuyU = Team22Fall(teamAddress).getMemberBuyU(account);
        require(memHasBuyU + amountU <= levelToBuyU[memLevel], "buy token beyond limit.");
        Team22Fall(teamAddress).addTotalBuyUSDT(account, amountU);
    }


    function addLiquidity(
        uint256 tokenAmount,
        uint256 usdtAmount,
        address uniswapV2Router, address qlAddress, address usdtAddress, address toContract, uint blockts
    ) internal returns (uint amountA, uint amountB, uint liquidity) {
        // add the liquidity
        (amountA, amountB, liquidity) = IPancakeRouter(uniswapV2Router)
            .addLiquidity(
                qlAddress,
                usdtAddress,
                tokenAmount,
                usdtAmount,
                1, // slippage is unavoidable
                1, // slippage is unavoidable
                toContract,
                blockts
            );
    }
    
    function removeLiquidity(
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address uniswapV2Router, address qlAddress, address usdtAddress, address toContract, uint blockts
    ) internal returns (uint amountA, uint amountB) {
        (amountA, amountB) = IPancakeRouter(uniswapV2Router).removeLiquidity(
            qlAddress,
            usdtAddress,
            liquidity,
            amountAMin,
            amountBMin,
            toContract,
            blockts
        );
    }


    function afterBuyTransfer(address account, address uniswapV2Pair, address teamAddress, address marketingAddress, uint256 liquidity) internal {
        // 2.1) 40% LP to user
        IERC20(uniswapV2Pair).safeTransfer(account, (liquidity * 80) / 100);
        // 2.2) 5% LP to directRec
        (address recAddr, uint256 recLevel) = Team22Fall(teamAddress).getDirectRecInfo(account);
        if (recAddr != address(0) && recLevel > 0) {
            IERC20(uniswapV2Pair).safeTransfer(recAddr, (liquidity * 10) / 100);
        }
        // 2.3) 5% LP to market address( = team root)
        IERC20(uniswapV2Pair).safeTransfer(marketingAddress, (liquidity * 10) / 100);
    }

    function transUSDTandApprove(address account, uint256 amountU, address uToAddr, address mainAddress, address uniswapV2Router, address usdtAddress) internal {
        IERC20(usdtAddress).safeTransferFrom(account, mainAddress, amountU);
        IERC20(usdtAddress).safeTransferFrom(mainAddress, uToAddr,amountU);
        IERC20(usdtAddress).approve(uniswapV2Router, amountU);
    }



    function quote(uint amountU, address uniswapV2Pair, address uniswapV2Router, address tokenU) internal view returns (uint amountA) {
        (uint reserve0, uint reserve1, ) = IPancakePair(uniswapV2Pair).getReserves();
        (uint reserveA, uint reserveU) = (IPancakePair(uniswapV2Pair).token0() == tokenU) ? (reserve1, reserve0):(reserve0, reserve1);
        amountA = IPancakeRouter(uniswapV2Router).quote(amountU, reserveU, reserveA);
    }

    function buySwap(uint256 tokenAmount, address sender, address uniswapV2Router, address qlAddress, address usdtAddress, uint blockts) internal returns (uint[] memory amounts) {
        address[] memory path = new address[](2);
        path[0] = usdtAddress;
        path[1] = address(qlAddress);
        // make the swap
        return
            IPancakeRouter(uniswapV2Router).swapExactTokensForTokens(
                tokenAmount,
                0,
                path,
                sender,
                blockts);
    }

    function getCakeLpInfo(address uniswapV2Pair, address usdtAddress) internal view returns(uint reserveA, uint reserveU, uint totalSupply) {
        totalSupply = IERC20(uniswapV2Pair).totalSupply();
        (uint reserve0, uint reserve1, ) = IPancakePair(uniswapV2Pair).getReserves();
        (reserveA, reserveU) = (IPancakePair(uniswapV2Pair).token0() == usdtAddress) ? (reserve1, reserve0):(reserve0, reserve1);
    }
}

contract QILinProxy is ERC20, Ownable {
    using SafeERC20 for IERC20;

    using Address for address;

    mapping(address => bool) public wList;

    address public usdtAddress;

    address public uniswapV2Pair;

    address public uniswapV2Router;

    address public marketingAddress;

    address public teamAddress;

    address public qlAddress;

    uint256 public minutelySellAmount;

    uint256 public lastHour;
    uint256 public hourlyTotalAmount;

    uint256 public lastMinute;

    uint256 public minutelyTotalAmount;

    //mapping(uint256 => uint256) public levelToUSDT;
    //mapping(uint256 => uint256) public levelToBuyU;
    uint256 [] public levelUsdtArr;
    uint256 [] public levelBuyArr;

    uint256 public directRecRewardRatio;
    uint256 public directRecBlack;
    uint256 public directRecBlack_s;
    uint256 public maxTeamDeep;
    uint256 public teamRewardRatio;
    uint256 public sellFeeRatio;

    // uint256 public hasFundedAmt;
    // uint256 public fundSingleAmt;
    // uint256 public maxFundUsdtLimit;
    // address public fundAddress;
    bool public seatInterval;

    constructor() ERC20("QiLin Proxy", "QLProxy") {
        uniswapV2Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        usdtAddress = 0x55d398326f99059fF775485246999027B3197955;

        marketingAddress = 0x0B82a076B9Be8c3A3ddD3373f9207aBBD2b2E9AB;
        wList[marketingAddress] = true;

        wList[msg.sender] = true;
        wList[address(this)] = true;

        directRecRewardRatio = 200;//zhitui
        directRecBlack = 25;//营销
        directRecBlack_s = 5;//技术0.5 需要增加除10
        teamRewardRatio = 200; //tuandui

        maxTeamDeep = 20;
        sellFeeRatio = 3;

        levelUsdtArr = new uint256[](36);
        levelUsdtArr[0] = 0;
        levelUsdtArr[1] = 10 * 1e16;
        levelUsdtArr[2] = 20 * 1e16;
        levelUsdtArr[3] = 30 * 1e16;
        levelUsdtArr[4] = 40 * 1e16;
        levelUsdtArr[5] = 50 * 1e16;
        levelUsdtArr[6] = 60 * 1e16;
        levelUsdtArr[7] = 70 * 1e16;
        levelUsdtArr[8] = 80 * 1e16;
        levelUsdtArr[9] = 90 * 1e16;

        levelBuyArr = new uint256[](36);
        levelBuyArr[0] = 0;
        levelBuyArr[1] = 0;
        levelBuyArr[2] = 0;
        levelBuyArr[3] = 0;
        levelBuyArr[4] = 0;
        levelBuyArr[5] = 1000 * 1e16;
        levelBuyArr[6] = 2000 * 1e16;
        levelBuyArr[7] = 10000 * 1e16;
        levelBuyArr[8] = type(uint).max;
        levelBuyArr[9] = type(uint).max;

        seatInterval = true;
    }

    modifier onlySupervise() {
        require(wList[_msgSender()] || _msgSender() == owner(), "Ownable: caller is not the supervise");
        _;
    }

    function setManagerAddress(address addr) public onlySupervise {
        wList[addr] = true;
    }

    function setWList(address addr, bool flag) public onlyOwner {
        wList[addr] = flag;
    }

    function setSellFeeRatio(uint256 sellRatio) external onlySupervise {
        sellFeeRatio = sellRatio;
    }

    function setDirectRecRatio(uint256 ratio) external onlySupervise {
        directRecRewardRatio = ratio;
    }
    function setDirectBlack(uint256 ratio) external onlySupervise {
        directRecBlack = ratio;
    }
    function setDirectBlack_s(uint256 ratio) external onlySupervise {
        directRecBlack_s = ratio;
    }
    function setMaxTeamDeep(uint256 _maxTeamDeep, uint256 ratio) external onlySupervise {
        maxTeamDeep = _maxTeamDeep;
        teamRewardRatio = ratio;
    }

    function setTeamAddress(address team22FallContract) public onlySupervise {
        teamAddress = team22FallContract;
    }

    function setQlAddress(address _qlAddress) public onlySupervise {
        qlAddress = _qlAddress;
        uniswapV2Pair = IPancakeFactory(IPancakeRouter(uniswapV2Router).factory()).getPair(address(qlAddress), usdtAddress);
        IERC20(uniswapV2Pair).approve(uniswapV2Router, type(uint).max);
        IERC20(qlAddress).approve(uniswapV2Router, type(uint).max);
    }

    function setMarketingAddress(address _marketingAddress) public onlySupervise {
        marketingAddress = _marketingAddress;
    }

    function setLevelAmtU(uint256 level, uint256 uAmt) public onlySupervise {
        levelUsdtArr[level] = uAmt;
    }

    function setLevelBuyU(uint256 level, uint256 buyU) public onlySupervise {
        levelBuyArr[level] = buyU;
    }

    function setSeatInterval(bool inter) public onlySupervise {
        seatInterval = inter;
    }

    function getAmountUsdtOut(uint256 amountInLp) public view returns (uint256) {
        (, uint reserveU, uint pairTotalSupply) = ProxyLibrary.getCakeLpInfo(uniswapV2Pair, usdtAddress);
        return pairTotalSupply > 0 ? amountInLp * reserveU / pairTotalSupply : 0;
    }

    function getAmounLpOut(uint256 amountInU) public view returns (uint256) {
         (, uint reserveU, uint pairTotalSupply) = ProxyLibrary.getCakeLpInfo(uniswapV2Pair, usdtAddress);
        return  reserveU > 0 ? amountInU * pairTotalSupply / reserveU : 0;
    }



    event UpgradeQL(address indexed account, uint256 amountU);

    function upgradeQL(address recAddr, address parentAddr, uint256 amountU, uint256 memberLevel) public isEOA {
        checkTradeRates(amountU);
        require(amountU > 0 && levelUsdtArr[memberLevel] == amountU,"level not match U.");

        require(recAddr != address(0), "recAddr is null");
        require(Team22Fall(teamAddress).isAlreadySeat(recAddr), "rec address has not seat!");

        if (!Team22Fall(teamAddress).isAlreadySeat(msg.sender)) {
            if (!seatInterval) {
                Team22Fall(teamAddress).seat(recAddr, parentAddr, msg.sender, 0);
            } else {
                Team22Fall(teamAddress).seat(recAddr, msg.sender, 0);
            }
        }
        uint256 memOldLevel = Team22Fall(teamAddress).getMemberLevel(msg.sender);
        require(memOldLevel + 1 == memberLevel, "Level is wrong.");
        (address recAddrLast, uint256 recLevel) = Team22Fall(teamAddress).getDirectRecInfo(msg.sender);
        require(recAddr == recAddrLast, "rec addr is wrong.");

        IERC20(usdtAddress).safeTransferFrom(msg.sender, address(this), amountU);
        //IERC20(usdtAddress).safeTransferFrom(mainAddress, address(this),amountU);
        IERC20(usdtAddress).approve(uniswapV2Router, amountU);
        //ProxyLibrary.transUSDTandApprove(msg.sender, amountU, address(this), mainAddress, uniswapV2Router, usdtAddress);


        //3) push up
        uint[] memory amounts = ProxyLibrary.buySwap((amountU * 50) / 100, address(this), uniswapV2Router, qlAddress, usdtAddress, block.timestamp);
        //require(1 == 2, "HAHAHA push up after");
        uint random = getRandomNumber(100000);
        IERC20(qlAddress).safeTransfer(msg.sender, random);
        //IERC20(qlAddress).safeTransfer(address(0xdead), amounts[1] - random);


        // uint256 requireTokenCnt = ProxyLibrary.quote((amountU * 50) / 100, uniswapV2Pair, uniswapV2Router, usdtAddress);
        // QILIN(qlAddress).mint(address(this), requireTokenCnt);
        (uint amountA, ,uint liquidity) = 
            ProxyLibrary.addLiquidity(amounts[1] - random, (amountU * 50) / 100, uniswapV2Router, qlAddress, usdtAddress, address(this), block.timestamp);
        if (amounts[1] - random > amountA) {
            IERC20(qlAddress).safeTransfer(address(0xdead), amounts[1] - random - amountA);
        }


        //1) disign rewards  
        ProxyLibrary.distributeRewards(msg.sender, memberLevel, recAddr, recLevel, liquidity,
            directRecRewardRatio, directRecBlack, directRecBlack_s,teamRewardRatio, maxTeamDeep,uniswapV2Pair, teamAddress, marketingAddress);

        //2) add power to member
        Team22Fall(teamAddress).memberUpgrade(msg.sender, memberLevel, amountU);
    

        hourlyTotalAmount += amountU;
        minutelyTotalAmount += amountU;
        emit UpgradeQL(msg.sender, amountU);
    }

    event PurchaseQL(address indexed account, uint256 amountU);

    // // 
    // function upgradeQL(address recAddr, uint256 amountU) external onlySupervise isEOA {
    //     require(recAddr != address(0), "recAddr is null");
    //     if (!Team22Fall(teamAddress).isAlreadySeat(msg.sender)) {
    //         Team22Fall(teamAddress).seat(recAddr, msg.sender, 0);
    //     }
 
    //     //2) add LP
    //     ProxyLibrary.transUSDTandApprove(msg.sender, amountU, address(this), mainAddress, uniswapV2Router, usdtAddress);

    //     uint256 requireTokenCnt = ProxyLibrary.quote(amountU, uniswapV2Pair, uniswapV2Router);
    //     QILIN(qlAddress).mint(address(this), requireTokenCnt);
    //     (, , uint liquidity) = ProxyLibrary.addLiquidity(requireTokenCnt, amountU, uniswapV2Router, qlAddress, usdtAddress,address(this),block.timestamp);
    //     // 2.1) LP to user
    //     IERC20(uniswapV2Pair).safeTransfer(msg.sender, liquidity);

    //     //2) add power to member
    //     Team22Fall(teamAddress).memberUpgrade2(msg.sender, 3, 2000 * 1e18);

    //     emit UpgradeQL(msg.sender, amountU);
    // }

    function purchase(uint256 amountU) public isEOA {
        checkTradeRates(amountU);

        //1) buy limit check
        ProxyLibrary.beforeBuyCheck(msg.sender, amountU, teamAddress, levelBuyArr);

        //2) add LP
        IERC20(usdtAddress).safeTransferFrom(msg.sender, address(this), amountU);
        IERC20(usdtAddress).approve(uniswapV2Router, amountU);


        //3) push up
        uint[] memory amounts = ProxyLibrary.buySwap((amountU * 50) / 100, address(this), uniswapV2Router, qlAddress, usdtAddress, block.timestamp);
        //IERC20(qlAddress).safeTransfer(address(0xdead), amounts[1]);

        (uint amountA, ,uint liquidity) = 
            ProxyLibrary.addLiquidity(amounts[1], (amountU * 50) / 100, uniswapV2Router, qlAddress, usdtAddress, address(this), block.timestamp);
        if (amounts[1]  > amountA) {
            IERC20(qlAddress).safeTransfer(address(0xdead), amounts[1] - amountA);
        }


        // 2.1) 40% LP to user
        IERC20(uniswapV2Pair).safeTransfer(msg.sender, (liquidity * 80) / 100);
        // 2.2) 5% LP to directRec
        (address recAddr, uint256 recLevel) = Team22Fall(teamAddress).getDirectRecInfo(msg.sender);
        if (recAddr != address(0) && recLevel >= 3) {
            IERC20(uniswapV2Pair).safeTransfer(recAddr, (liquidity * 10) / 100);
        }
        // 2.3) 5% LP to market address( = team root)
        IERC20(uniswapV2Pair).safeTransfer(marketingAddress, recLevel >= 3 ? (liquidity * 10) / 100 : (liquidity * 20) / 100); 


        hourlyTotalAmount += amountU;
        minutelyTotalAmount += amountU;
        emit PurchaseQL(msg.sender, amountU);
    }

    // event ClaimQLLP(address indexed account, uint256 amt);

    // function claim() external isEOA returns (uint256) {
    //     uint256 claimAmt = Team22Fall(teamAddress).claim(msg.sender);
    //     emit ClaimQLLP(msg.sender, claimAmt);
    //     return claimAmt;
    // }

    event SellQLLP(address indexed account, uint256 indexed amountLP, uint256 indexed amountU);

    function sell(uint256 amountLp) public isEOA returns (uint256) {
        IERC20(uniswapV2Pair).safeTransferFrom(msg.sender, address(this), amountLp);
        (uint amountQL, uint amountU) = ProxyLibrary.removeLiquidity(amountLp, 0, 0, uniswapV2Router, qlAddress, usdtAddress, address(this), block.timestamp);
        IERC20(usdtAddress).safeTransfer(msg.sender, (amountU * (100 - sellFeeRatio)) / 100);
        IERC20(qlAddress).safeTransfer(address(0xdead), amountQL);

        //push up
        if (sellFeeRatio > 0) {
            IERC20(usdtAddress).approve(uniswapV2Router, (amountU * sellFeeRatio) / 100);
            uint[] memory amounts = ProxyLibrary.buySwap((amountU * sellFeeRatio) / 100, address(this), uniswapV2Router, qlAddress, usdtAddress, block.timestamp);
            IERC20(qlAddress).safeTransfer(address(0xdead), amounts[1]);
        }

        //check
        require(minutelySellAmount + amountU <= ProxyLibrary.MAX_SELL_AMOUNT_MINUTELY,"Exceeds sell amount per minute");
        minutelySellAmount += amountU;

        emit SellQLLP(msg.sender, amountLp, amountU);
        return amountU;
    }

    function getRandomNumber(uint range) private view returns (uint) {
        uint randomNumber = uint(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao))
        );
        return randomNumber % range;
    }


    // function withdrawToken(
    //     address _tokenAddress,
    //     address _to,
    //     uint256 amount
    // ) public onlySupervise {
    //     IERC20(_tokenAddress).transfer(_to, amount);
    // }

    modifier isEOA() {
        require(msg.sender == tx.origin, "Only external accounts allowed");
        uint256 size;
        address addr = msg.sender;
        assembly {
            size := extcodesize(addr)
        }

        require(!(size > 0), "contract not allowed");
        _;
    }


    function checkTradeRates(uint256 amountU) internal {
        require(amountU <= ProxyLibrary.MAX_AMOUNT_WEI,"Amount exceeds limit");
        if (block.timestamp / 1 hours > lastHour) {
            lastHour = block.timestamp / 1 hours;
            hourlyTotalAmount = 0;
        }
        require(hourlyTotalAmount + amountU <= ProxyLibrary.MAX_HOURLY_TOTAL_AMOUNT_WEI,"Hourly total amount exceeds limit");
        if (block.timestamp / 1 minutes > lastMinute) {
            lastMinute = block.timestamp / 1 minutes;
            minutelyTotalAmount = 0;
        }
        require(minutelyTotalAmount + amountU <= ProxyLibrary.MAX_MINUTELY_TOTAL_AMOUNT_WEI,"Minutely total amount exceeds limit");
    }
}