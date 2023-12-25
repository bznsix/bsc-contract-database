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

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Pair {
    function token0() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

// TokenDistributor contract to receive tokens exchanged in DEX swaps
// This contract is used as an intermediate contract to receive tokens that cannot be directly transferred to token contracts, such as USDT.
contract TokenDistributor {
    constructor (address token) {
        // Approve the token to be spent by the contract deployer (the token contract) to distribute the exchanged tokens.
        IERC20(token).approve(msg.sender, type(uint256).max);
    }
}

contract GoldenBambooToken is IERC20, Context, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    string public Website = "https://gbt.gold";
    string public Telegram = "https://t.me/gbt_gold";
    string public Twitter = "https://twitter.com/gbt_gold";
    string public X = "https://twitter.com/gbt_gold";
    string public Email = "gbt@gbt.im";

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool[4]) public _whites;

    IUniswapV2Router02 public _uniswapV2Router;
    address public _uniswapV2Pair;

    uint[3] public _fees;
    uint[3] public _scales;
    address public _marketing;
    address public _liquidity;
    address public _issunance;
    uint public _absolutePrice;
    uint public _discountMultiple;
    uint public _discountProportion;
    uint public _minFee;

    TokenDistributor private _tokenDistributor;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;
    address public _usdt;
    address public _dead;
    bool _swapping;
    uint public _startSwapTime;
    uint public _sellCondition;

    constructor() {

        _name = "GoldenBambooToken";
        _symbol = "GBT";
        _decimals = 18;
        _totalSupply = 1 * 10 ** 5 * 10 ** uint256(_decimals);
        address _main = address(0xa9cF0d25eAdf7Ee6cd5882Fdd7FaD29999999999);
        _usdt = 0x55d398326f99059fF775485246999027B3197955;
        _dead = 0x0000000000000000000000000000000000000000;
        _minFee = 200;
        _discountMultiple = 10;
        _discountProportion = 200;
        uint decimal = uint(IERC20(_usdt).decimals());
        _absolutePrice = 1 * 10 ** uint256(decimal);
        _sellCondition = 1 * 10 ** uint256(decimal);

        _uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        _tokenDistributor = new TokenDistributor(_usdt);

        _balances[_main] = _totalSupply;
        emit Transfer(address(0), _main, _balances[_main]);

        _whites[_main][0] = true;
        _whites[_main][1] = true;
        _whites[_main][2] = true;
        _whites[_main][3] = true;

        _fees[0] = 1200;
        _fees[1] = 1200;
        _fees[2] = 1200;
        _scales[0] = 1000;
        _scales[1] = 4000;
        _scales[2] = 5000;
        _startSwapTime = 1704067200;
        //

        _marketing = 0x91578Ae113eB89A254E54F345f4344AbEEEEEEEE;
        _liquidity = 0x91578Ae113eB89A254E54F345f4344AbEEEEEEEE;
        _issunance = 0x91578Ae113eB89A254E54F345f4344AbEEEEEEEE;
    }

    function setWhites(address[] calldata accounts, bool transIn, bool transOut, bool buy, bool sell) external onlyOwner {
        for (uint i; i < accounts.length; i++) {
            _whites[accounts[i]][0] = transIn;
            _whites[accounts[i]][1] = transOut;
            _whites[accounts[i]][2] = buy;
            _whites[accounts[i]][3] = sell;
        }
    }

    function setAddress(address param, uint status) external onlyOwner {
        if (status == 0) {
            _marketing = param;
        } else if (status == 1) {
            _liquidity = param;
            _whites[_liquidity][0] = true;
            _whites[_liquidity][1] = true;
            _whites[_liquidity][2] = true;
            _whites[_liquidity][3] = true;
        } else if (status == 2) {
            _issunance = param;
        } else if (status == 3) {
            _uniswapV2Pair = param;
        }
    }

    function setUint(uint param, uint status) external onlyOwner {
        if (status == 0) {
            _fees[0] = param;
        } else if (status == 1) {
            _fees[1] = param;
        } else if (status == 2) {
            _fees[2] = param;
        } else if (status == 3) {
            _scales[0] = param;
        } else if (status == 4) {
            _scales[1] = param;
        } else if (status == 5) {
            _scales[2] = param;
        } else if (status == 6) {
            _minFee = param;
        } else if (status == 7) {
            require(param > 1);
            _discountMultiple = param;
        } else if (status == 8) {
            require(param < 10000);
            _discountProportion = param;
        } else if (status == 9) {
            _startSwapTime = param;
        }
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        _tokenTransferBefore(sender, recipient, amount);
    }

    function backstopPrice() public view returns (uint) {
        uint uAmount = IERC20(_usdt).balanceOf(address(this));
        return uAmount.mul(1 * 10 ** _decimals).div(_totalSupply.sub(_balances[_dead]).sub(_balances[_issunance]));
    }

    modifier manageSwapping {
        _;
        _swapping = false;
    }

    function _tokenTransferBefore(
        address sender,
        address recipient,
        uint256 amount
    ) internal manageSwapping{
        uint feeAmount;
        address pairAddress;
        if(_uniswapV2Pair!=address(0)){
            pairAddress = _uniswapV2Pair;
        }else{
            pairAddress = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(address(this),_usdt);
        }
        uint pairAmount = _balances[pairAddress];
        if (!_swapping && sender != address(this) && recipient != address(this) && recipient != _dead && pairAmount > 0) {
            _swapping = true;
            if ((pairAddress == sender || pairAddress == recipient)) {
                if (pairAddress == sender && _whites[recipient][2] != true) {
                    require(_startSwapTime <= block.timestamp, "ERC20:It's not yet open time");
                    //buy
                    feeAmount = amount.mul(realFee(1)).div(10000);
                } else if (pairAddress == recipient && _whites[sender][3] != true) {
                    //sell
                    feeAmount = amount.mul(realFee(2)).div(10000);
                }
            } else if (_whites[sender][1] != true && _whites[recipient][0] != true) {
                //transfer
                feeAmount = amount.mul(realFee(0)).div(10000);
            }
        }
        if (feeAmount > 0) {
            if (pairAddress != sender && pairAmount > 0) {
                if (_sellToken() == true) {
                    _backstop();
                }
            }
            _tokenTransfer(sender, address(this), feeAmount);
        }
        _tokenTransfer(sender, recipient, amount.sub(feeAmount));
    }

    event SellToken(address account1, uint profit1, address account2, uint profit2, address account3, uint profit3);

    function _sellToken() internal returns (bool) {
        uint tokenAmount = _balances[address(this)];
        if (tokenAmount == 0) return false;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdt;

        uint[] memory amounts = _uniswapV2Router.getAmountsOut(tokenAmount, path);
        if (_sellCondition > amounts[1]) return false;

        _approve(address(this), address(_uniswapV2Router), tokenAmount);

        _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(_tokenDistributor),
            block.timestamp
        );
        uint profit = IERC20(_usdt).balanceOf(address(_tokenDistributor));

        if (profit > 0) {
            uint profit1 = profit.mul(_scales[0]).div(_scales[0] + _scales[1] + _scales[2]);
            uint profit2 = profit.mul(_scales[1]).div(_scales[0] + _scales[1] + _scales[2]);
            IERC20(_usdt).transferFrom(address(_tokenDistributor), _marketing, profit1);
            IERC20(_usdt).transferFrom(address(_tokenDistributor), _liquidity, profit2);
            IERC20(_usdt).transferFrom(address(_tokenDistributor), address(this), profit.sub(profit1).sub(profit2));
            emit SellToken(_marketing, profit1, _liquidity, profit2, address(this), profit.sub(profit1).sub(profit2));
            return true;
        }
        return false;
    }
    // backstop
    function _backstop() internal returns (bool) {
        uint uAmount = IERC20(_usdt).balanceOf(address(this));
        if (uAmount == 0) return false;
        (uint reserves0, uint reserves1,) = IUniswapV2Pair(_uniswapV2Pair).getReserves();
        if (IUniswapV2Pair(_uniswapV2Pair).token0() != address(this)) {
            uint temp;
            temp = reserves1;
            reserves1 = reserves0;
            reserves0 = temp;
        }
        uint price = reserves1.mul(1 * 10 ** uint(_decimals)).div(reserves0);
        uint _backstopPrice = backstopPrice();

        if (price > 0 && price < _backstopPrice) {
            // Below the backstop price

            (, uint newReserves1) = _targetPrice(_backstopPrice, reserves0, reserves1);
            if (newReserves1 <= reserves1) return false;
            uint needPay = newReserves1.sub(reserves1);
            if (needPay > 0) {
                needPay = needPay.mul(10025).div(10000);
                if (needPay > uAmount) {
                    needPay = uAmount;
                }
                // Buy tokens to burn
                IERC20(_usdt).safeIncreaseAllowance(address(_uniswapV2Router), needPay);
                address[] memory path = new address[](2);
                path[0] = _usdt;
                path[1] = address(this);
                _uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    needPay,
                    0,
                    path,
                    _dead,
                    block.timestamp
                );
            }
        }
        return true;
    }

    // Get the real fee proportion
    function realFee(uint index) public view returns (uint fee){
        uint _backstopPrice = backstopPrice();
        fee = _fees[index];
        if (_absolutePrice > 0 && _backstopPrice > _absolutePrice) {
            if (_backstopPrice.div(_absolutePrice) >= _discountMultiple) {
                uint temp = _backstopPrice.div(_absolutePrice);
                uint multiple;
                while (temp >= _discountMultiple) {
                    multiple++;
                    temp = temp.div(_discountMultiple);
                }
                if (_discountProportion.mul(multiple) >= fee.sub(_minFee)) {
                    fee = _minFee;
                } else {
                    fee = fee.sub(_discountProportion.mul(multiple));
                }
            }
        }
    }

    // price: target price, reserves0: token amount, reserves1: USDT amount
    function _targetPrice(uint price, uint reserves0, uint reserves1) internal view returns (uint newReserves0, uint newReserves1) {
        uint k = reserves0.mul(reserves1);
        newReserves0 = k.mul(1 * 10 ** uint(_decimals)).div(price).sqrt();
        newReserves1 = k.div(newReserves0);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}