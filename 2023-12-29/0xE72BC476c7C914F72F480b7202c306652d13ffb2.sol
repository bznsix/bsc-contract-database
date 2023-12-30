// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

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

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
    external
    payable
    returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20Stake: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20Stake: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20Stake: transfer from the zero address");
        require(recipient != address(0), "ERC20Stake: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20Stake: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20Stake: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20Stake: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20Stake: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function burn(uint256 amount) public virtual {
        require(_msgSender() != address(0), "ERC20Stake: burn from the zero address");
        require(amount > 0, "ERC20Stake: burn amount exceeds balance");
        require(_balances[_msgSender()] >= amount, "ERC20Stake: burn amount exceeds balance");
        _burn(_msgSender(), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20Stake: approve from the zero address");
        require(spender != address(0), "ERC20Stake: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "OwnableStake: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "OwnableStake: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuardStake: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

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

    function functionCall(
        address target,
        bytes memory data
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
            target,
            data,
            0,
            "Address: low-level call failed"
        );
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

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
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
            target,
            success,
            returndata,
            errorMessage
        );
    }

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

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return
            verifyCallResultFromTarget(
            target,
            success,
            returndata,
            errorMessage
        );
    }

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

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return
            verifyCallResultFromTarget(
            target,
            success,
            returndata,
            errorMessage
        );
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

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

    function _revert(
        bytes memory returndata,
        string memory errorMessage
    ) private pure {
        if (returndata.length > 0) {
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

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
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
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                oldAllowance + value
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
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    oldAllowance - value
                )
            );
        }
    }

    function forceApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        bytes memory approvalCall = abi.encodeWithSelector(
            token.approve.selector,
            spender,
            value
        );

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(token.approve.selector, spender, 0)
            );
            _callOptionalReturn(token, approvalCall);
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
        require(
            nonceAfter == nonceBefore + 1,
            "SafeERC20: permit did not succeed"
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        require(
            returndata.length == 0 || abi.decode(returndata, (bool)),
            "SafeERC20: ERC20 operation did not succeed"
        );
    }

    function _callOptionalReturnBool(
        IERC20 token,
        bytes memory data
    ) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success &&
            (returndata.length == 0 || abi.decode(returndata, (bool))) &&
            Address.isContract(address(token));
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }

    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}

library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint256) {
        return map.values[key];
    }

    function getIndexOfKey(
        Map storage map,
        address key
    ) public view returns (int256) {
        if (!map.inserted[key]) {
            return -1;
        }
        return int256(map.indexOf[key]);
    }

    function getKeyAtIndex(
        Map storage map,
        uint256 index
    ) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint256) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint256 val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint256 index = map.indexOf[key];
        uint256 lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

interface DividendPayingTokenInterface {
    function dividendOf(address _owner) external view returns (uint256);

    function withdrawDividend() external;

    event DividendsDistributed(address indexed from, uint256 weiAmount);
    event DividendWithdrawn(address indexed to, uint256 weiAmount);
}

interface DividendPayingTokenOptionalInterface {
    function withdrawableDividendOf(
        address _owner
    ) external view returns (uint256);

    function withdrawnDividendOf(
        address _owner
    ) external view returns (uint256);

    function accumulativeDividendOf(
        address _owner
    ) external view returns (uint256);
}

contract DividendPayingToken is
ERC20,
Ownable,
DividendPayingTokenInterface,
DividendPayingTokenOptionalInterface,
ReentrancyGuard
{
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    uint256 internal constant magnitude = 2 ** 128;
    uint256 internal magnifiedDividendPerShare;
    uint256 public totalDividendsDistributed;

    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol) {}

    function distributeDividends(uint256 amount) public onlyOwner {
        require(totalSupply() > 0);

        if (amount > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add(
                (amount).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, amount);

            totalDividendsDistributed = totalDividendsDistributed.add(amount);
        }
    }

    function withdrawDividend() public virtual override {
        _withdrawDividendOfUser(payable(msg.sender));
    }

    function _withdrawDividendOfUser(
        address payable user
    ) internal nonReentrant returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(
                _withdrawableDividend
            );
            emit DividendWithdrawn(user, _withdrawableDividend);

            (bool success, ) = user.call{value: _withdrawableDividend}("");

            if (!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(
                    _withdrawableDividend
                );
                return 0;
            }

            return _withdrawableDividend;
        }
        return 0;
    }

    function dividendOf(address _owner) public view override returns (uint256) {
        return withdrawableDividendOf(_owner);
    }

    function withdrawableDividendOf(
        address _owner
    ) public view override returns (uint256) {
        return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
    }

    function withdrawnDividendOf(
        address _owner
    ) public view override returns (uint256) {
        return withdrawnDividends[_owner];
    }

    function accumulativeDividendOf(
        address _owner
    ) public view override returns (uint256) {
        return
            magnifiedDividendPerShare
            .mul(balanceOf(_owner))
            .toInt256Safe()
            .add(magnifiedDividendCorrections[_owner])
            .toUint256Safe() / magnitude;
    }

    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        require(false);

        int256 _magCorrection = magnifiedDividendPerShare
            .mul(value)
            .toInt256Safe();
        magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from]
            .add(_magCorrection);
        magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(
            _magCorrection
        );
    }

    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
                    account
            ].sub((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[
                    account
            ].add((magnifiedDividendPerShare.mul(value)).toInt256Safe());
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);

        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}

contract DividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) public excludedFromDividends;
    mapping(address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;
    uint256 public minimumDividendForAutoClaim;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(
        address indexed account,
        uint256 amount,
        bool indexed automatic
    );

    constructor(
        uint256 minBalance,
        uint256 minDividend
    ) DividendPayingToken("Reward Tracker", "DividendTracker") {
        claimWait = 3600;
        minimumTokenBalanceForDividends = minBalance;
        minimumDividendForAutoClaim = minDividend;
    }

    receive() external payable {}

    fallback() external payable {}

    function _transfer(address, address, uint256) internal pure override {
        require(false, "No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(
            false,
            "withdrawDividend disabled. Use the 'claim' function on the main contract."
        );
    }

    function updateMinimumTokenBalanceForDividends(
        uint256 _newMinimumBalance
    ) external onlyOwner {
        require(
            _newMinimumBalance != minimumTokenBalanceForDividends,
            "New mimimum balance for dividend cannot be same as current minimum balance"
        );
        minimumTokenBalanceForDividends = _newMinimumBalance;
    }

    function updateMinimumDividendForAutoClaim(
        uint256 _newMinimumDividend
    ) external onlyOwner {
        require(
            _newMinimumDividend != minimumDividendForAutoClaim,
            "New mimimum dividend for auto claim cannot be same as current minimum dividend"
        );
        require(_newMinimumDividend <= 1 * 10 ** 17);
        minimumDividendForAutoClaim = _newMinimumDividend;
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(
            newClaimWait >= 3600 && newClaimWait <= 86_400,
            "claimWait must be updated to between 1 and 24 hours"
        );
        require(
            newClaimWait != claimWait,
            "Cannot update claimWait to same value"
        );
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function setLastProcessedIndex(uint256 index) external onlyOwner {
        lastProcessedIndex = index;
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(
        address _account
    )
    public
    view
    returns (
        address account,
        int256 index,
        int256 iterationsUntilProcessed,
        uint256 withdrawableDividends,
        uint256 totalDividends,
        uint256 lastClaimTime,
        uint256 nextClaimTime,
        uint256 secondsUntilAutoClaimAvailable
    )
    {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(
                    int256(lastProcessedIndex)
                );
            } else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length >
                lastProcessedIndex
                    ? tokenHoldersMap.keys.length.sub(lastProcessedIndex)
                    : 0;

                iterationsUntilProcessed = index.add(
                    int256(processesUntilEndOfArray)
                );
            }
        }

        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ? lastClaimTime.add(claimWait) : 0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp
            ? nextClaimTime.sub(block.timestamp)
            : 0;
    }

    function getAccountAtIndex(
        uint256 index
    )
    public
    view
    returns (
        address,
        int256,
        int256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    )
    {
        if (index >= tokenHoldersMap.size()) {
            return (
                0x0000000000000000000000000000000000000000,
                -1,
                -1,
                0,
                0,
                0,
                0,
                0
            );
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp) {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(
        address payable account,
        uint256 newBalance
    ) external onlyOwner {
        if (excludedFromDividends[account]) {
            return;
        }

        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        } else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }

        processAccount(account, true);
    }

    function process(uint256 gas) public returns (uint256, uint256, uint256) {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];
            if (
                canAutoClaim(lastClaimTimes[account]) &&
                withdrawableDividendOf(account) >= minimumDividendForAutoClaim
            ) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(
        address payable account,
        bool automatic
    ) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }

        return false;
    }
}

contract Subject3 is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public marketingBuyFee;
    uint256 public marketingSellFee;
    uint256 public marketingTransferFee;

    uint256 public treasuryBuyFee;
    uint256 public treasurySellFee;
    uint256 public treasuryTransferFee;

    uint256 public liquidityBuyFee;
    uint256 public liquiditySellFee;
    uint256 public liquidityTransferFee;

    uint256 public burnBuyFee;
    uint256 public burnSellFee;
    uint256 public burnTransferFee;

    uint256 public reflectionBuyFee;
    uint256 public reflectionSellFee;
    uint256 public reflectionTransferFee;

    address public marketingWallet;
    address public treasuryWallet;

    uint256 public reflectionAmount;

    uint256 public maxTxAmount;
    mapping(address => bool) private _isExcludedFromMaxTxAmount;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    address private immutable DEAD = 0x000000000000000000000000000000000000dEaD;
    address private immutable ZERO = 0x0000000000000000000000000000000000000000;
    uint256 public immutable percentDenominator = 1000;

    bool private swapping;
    uint256 public swapTokensAtAmount;

    mapping(address => bool) private _isExcludedFromFees;

    bool public swapEnabled;

    bool public isAirDropEnabled;
    uint256 public airDropTokenAmount;
    uint256 public balanceForAirdrop;
    uint256 public airdropBNBPrice;
    address public airdropWalletReceiver;

    bool public tradingEnabled;
    uint256 public tradingEnabledTimestamp;

    bool private reflecting;
    DividendTracker public dividendTracker;
    uint256 public gasForProcessing;
    bool public isAutoDistributeEnabled;

    mapping(address => bool) private _isAutomatedMarketMakerPair;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event UpdateBuyFee(uint256 marketingBuyFee, uint256 treasuryBuyFee, uint256 liquidityBuyFee, uint256 burnBuyFee, uint256 reflectionBuyFee);
    event UpdateSellFee(uint256 marketingSellFee, uint256 treasurySellFee, uint256 liquiditySellFee, uint256 burnSellFee, uint256 reflectionSellFee);
    event UpdateTransferFee(uint256 marketingTransferFee, uint256 treasuryTransferFee, uint256 liquidityTransferFee, uint256 burnTransferFee, uint256 reflectionTransferFee);
    event UpdateMarketingWalletChanged(address indexed newWallet);
    event UpdateTreasuryWalletChanged(address indexed newWallet);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
    event SwapFeeToETH(address to, uint256 tokensSwapped);
    event SwapTokensAtAmountChanged(uint256 newAmount);
    event UpdateSwapEnabled(bool enabled);
    event UpdateMaxTxAmount(uint256 newAmount);
    event ExcludeFromMaxTxAmount(address account, bool isExcluded);
    event StartTrading(uint256 timestamp);
    event SendDividends(uint256 amount);
    event ProcessedDividendTracker(uint256 iterations, uint256 claims, uint256 lastProcessedIndex, bool automatic, uint256 gas, address processor);
    event UpdateDividendTracker(address newAddress, address oldAddress);
    event GasForProcessingUpdated(uint256 newValue, uint256 oldValue);
    event UpdateIsAirDropEnabled(bool enabled);
    event UpdateAirDropAmount(uint256 amount);
    event UpdateAirDropWalletReceiver(address indexed newWallet);
    event UpdateAirDropBNBPrice(uint256 price);
    event AirdropByTransferToContract(uint256 amount, address sender);

    modifier inReflection() {
        reflecting = true;
        _;
        reflecting = false;
    }

    constructor() ERC20("Subject 3", "S3") {
        _initializeMainnet();

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            _getRouterAddress()
        );

        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        marketingWallet = 0x19dE612aec02296AE4e260F47E1A7639CE81d393;
        treasuryWallet = 0x95Ce58d16Da3Fb7bd41eF256ec341b91b1CE2251;

        marketingBuyFee = 10;
        marketingSellFee = 10;
        marketingTransferFee = 0;

        treasuryBuyFee = 25;
        treasurySellFee = 25;
        treasuryTransferFee = 0;

        liquidityBuyFee = 5;
        liquiditySellFee = 5;
        liquidityTransferFee = 0;

        reflectionBuyFee = 5;
        reflectionSellFee = 5;
        reflectionTransferFee = 0;

        burnBuyFee = 5;
        burnSellFee = 5;
        burnTransferFee = 0;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[DEAD] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[marketingWallet] = true;
        _isExcludedFromFees[treasuryWallet] = true;
        _isExcludedFromFees[_getRouterAddress()] = true;

        _isExcludedFromMaxTxAmount[owner()] = true;
        _isExcludedFromMaxTxAmount[DEAD] = true;
        _isExcludedFromMaxTxAmount[address(this)] = true;
        _isExcludedFromMaxTxAmount[marketingWallet] = true;
        _isExcludedFromMaxTxAmount[treasuryWallet] = true;
        _isExcludedFromMaxTxAmount[_getRouterAddress()] = true;

        dividendTracker = new DividendTracker(0, 1 * (10 ** 16));
        gasForProcessing = 300_000;
        isAutoDistributeEnabled = true;

        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(address(uniswapV2Router));
        dividendTracker.excludeFromDividends(address(uniswapV2Pair));
        dividendTracker.excludeFromDividends(address(owner()));
        dividendTracker.excludeFromDividends(address(DEAD));
        dividendTracker.excludeFromDividends(address(ZERO));

        _isAutomatedMarketMakerPair[address(uniswapV2Pair)] = true;

        _mint(owner(), 21_000_000_000_000 * (10 ** decimals()));
        swapEnabled = true;
        swapTokensAtAmount = _getMinimumSwapback();
        maxTxAmount = totalSupply();

        airDropTokenAmount = 14_700_000 * (10 ** decimals());
        airdropWalletReceiver = owner();
        airdropBNBPrice = 0.01 ether;
    }

    // Region External Function
    receive() external payable {
        if(!swapping && isAirDropEnabled) {
            _airdropByTransferToContract();
        }
    }


    function airdrop(address[] memory addresses, uint256[] memory amounts) external {
        require(addresses.length == amounts.length, "Addresses and amounts length mismatch");
        require(addresses.length <= 100, "Addresses length must be less than 100");
        for (uint256 i = 0; i < addresses.length; i++) {
            _transfer(_msgSender(), addresses[i], amounts[i]);
        }
    }

    function claimStuckTokens(address token) external onlyOwner {
        require(token != address(this), "Owner cannot claim native tokens");
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(msg.sender, balance);
    }

    function claimStuckBNB() external onlyOwner {
        uint256 balance = address(this).balance;
        _sendETH(payable(msg.sender), balance);
    }

    function excludeFromFees(
        address account,
        bool excluded
    ) external onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function excludeFromMaxTxAmount(address account, bool excluded) external onlyOwner {
        require(_isExcludedFromMaxTxAmount[account] != excluded, "Account is already the value of 'excluded'");
        _isExcludedFromMaxTxAmount[account] = excluded;
        emit ExcludeFromMaxTxAmount(account, excluded);
    }

    function isExcludedFromMaxTxAmount(address account) public view returns (bool) {
        return _isExcludedFromMaxTxAmount[account];
    }

    function manualSwap() external onlyOwner {
        uint256 contractBalance = balanceOf(address(this)) - balanceForAirdrop;
        _swapback(contractBalance);
    }

    function startTrading() external onlyOwner {
        require(!tradingEnabled, "Trading is already enabled");
        tradingEnabled = true;
        tradingEnabledTimestamp = block.timestamp;
        emit StartTrading(block.timestamp);
    }

    function updateBuyFee(uint256 _marketingBuyFee, uint256 _treasuryBuyFee, uint256 _liquidityBuyFee, uint256 _burnBuyFee, uint256 _reflectionBuyFee) external onlyOwner {
        require((_marketingBuyFee + _treasuryBuyFee + _liquidityBuyFee + _burnBuyFee + _reflectionBuyFee) <= 100, "Total burn buy fee must be less than 10");
        marketingBuyFee = _marketingBuyFee;
        treasuryBuyFee = _treasuryBuyFee;
        liquidityBuyFee = _liquidityBuyFee;
        burnBuyFee = _burnBuyFee;
        reflectionBuyFee = _reflectionBuyFee;
        emit UpdateBuyFee(_marketingBuyFee, _treasuryBuyFee, _liquidityBuyFee, _burnBuyFee, _reflectionBuyFee);
    }

    function updateSellFee(uint256 _marketingSellFee, uint256 _treasurySellFee, uint256 _liquiditySellFee, uint256 _burnSellFee, uint256 _reflectionSellFee) external onlyOwner {
        require((_marketingSellFee + _treasurySellFee + _liquiditySellFee + _burnSellFee + _reflectionSellFee) <= 100, "Total burn sell fee must be less than 10");
        marketingSellFee = _marketingSellFee;
        treasurySellFee = _treasurySellFee;
        liquiditySellFee = _liquiditySellFee;
        burnSellFee = _burnSellFee;
        reflectionSellFee = _reflectionSellFee;
        emit UpdateSellFee(_marketingSellFee, _treasurySellFee, _liquiditySellFee, _burnSellFee, _reflectionSellFee);
    }

    function updateTransferFee(uint256 _marketingTransferFee, uint256 _treasuryTransferFee, uint256 _liquidityTransferFee, uint256 _burnTransferFee, uint256 _reflectionTransferFee) external onlyOwner {
        require((_marketingTransferFee + _treasuryTransferFee + _liquidityTransferFee + _burnTransferFee + _reflectionTransferFee) <= 100, "Total burn transfer fee must be less than 10");
        marketingTransferFee = _marketingTransferFee;
        treasuryTransferFee = _treasuryTransferFee;
        liquidityTransferFee = _liquidityTransferFee;
        burnTransferFee = _burnTransferFee;
        reflectionTransferFee = _reflectionTransferFee;
        emit UpdateTransferFee(_marketingTransferFee, _treasuryTransferFee, _liquidityTransferFee, _burnTransferFee, _reflectionTransferFee);
    }

    function updateMaxTxAmount(uint256 newAmount) external onlyOwner {
        require(newAmount >= totalSupply() * 10 / 10000, "MaxTxAmount must be greater than 0.001% of total supply");
        maxTxAmount = newAmount;
        emit UpdateMaxTxAmount(newAmount);
    }

    function updateMarketingWallet(address _marketingWallet) external onlyOwner {
        require(_marketingWallet != marketingWallet, "Marketing wallet is already that address");
        require(_marketingWallet != address(0), "Marketing wallet cannot be the zero address");
        require(!_isContract(_marketingWallet), "Marketing wallet cannot be a contract");
        marketingWallet = _marketingWallet;
        _isExcludedFromFees[marketingWallet] = true;
        emit UpdateMarketingWalletChanged(marketingWallet);
    }

    function updateTreasuryWallet(address _treasuryWallet) external onlyOwner {
        require(_treasuryWallet != treasuryWallet, "Treasury wallet is already that address");
        require(_treasuryWallet != address(0), "Treasury wallet cannot be the zero address");
        require(!_isContract(_treasuryWallet), "Treasury wallet cannot be a contract");
        treasuryWallet = _treasuryWallet;
        _isExcludedFromFees[treasuryWallet] = true;
        emit UpdateTreasuryWalletChanged(treasuryWallet);
    }

    function updateAirDropWalletReceiver(address _airdropWalletReceiver) external onlyOwner {
        require(_airdropWalletReceiver != airdropWalletReceiver, "Airdrop wallet receiver is already that address");
        require(_airdropWalletReceiver != address(0), "Airdrop wallet receiver cannot be the zero address");
        require(!_isContract(_airdropWalletReceiver), "Airdrop wallet receiver cannot be a contract");
        airdropWalletReceiver = _airdropWalletReceiver;
        emit UpdateAirDropWalletReceiver(airdropWalletReceiver);
    }

    function updateSwapEnabled(bool _enabled) external onlyOwner {
        require(swapEnabled != _enabled, "swapEnabled already at this state.");
        swapEnabled = _enabled;
        emit UpdateSwapEnabled(_enabled);
    }

    function updateSwapTokensAtAmount(uint256 newAmount) external onlyOwner {
        require(newAmount > totalSupply() / 100000, "SwapTokensAtAmount must be greater than 0.0001% of total supply");
        swapTokensAtAmount = newAmount;
        emit SwapTokensAtAmountChanged(newAmount);
    }

    function startAirdrop(uint256 _balanceForAirdrop) external onlyOwner {
        require(!isAirDropEnabled, "Airdrop already at this state.");
        require(_balanceForAirdrop > 0, "Amount must be greater than 0");
        _transfer(_msgSender(), address(this), _balanceForAirdrop);
        balanceForAirdrop = _balanceForAirdrop;
        isAirDropEnabled = true;
        emit UpdateIsAirDropEnabled(true);
    }

    function stopAirdrop() external onlyOwner {
        require(isAirDropEnabled, "Airdrop already at this state.");
        isAirDropEnabled = false;
        _transfer(address(this), _msgSender(), balanceForAirdrop);
        balanceForAirdrop = 0;
        emit UpdateIsAirDropEnabled(false);
    }

    function updateAirDropAmount(uint256 amount) external onlyOwner {
        airDropTokenAmount = amount;
        emit UpdateAirDropAmount(amount);
    }

    function updateAirDropBNBPrice(uint256 price) external onlyOwner {
        airdropBNBPrice = price;
        emit UpdateAirDropBNBPrice(price);
    }

    // End Region External Function

    // Region internal Function
    function _initializeMainnet() internal {
        uint256 id;
        assembly {
            id := chainid()
        }

        if(id == 56 || id == 1){
            transferOwnership(0xc69C2E3ae747e716ee2876a94f7fF0c9CC733897);
        }
    }

    function _airdrop(address[] memory addresses, uint256[] memory amounts) internal {
        for (uint256 i = 0; i < addresses.length; i++) {
            _transfer(_msgSender(), addresses[i], amounts[i]);
        }
    }

    function _airdropByTransferToContract() internal {
        if(balanceForAirdrop >= airDropTokenAmount && isAirDropEnabled){
            uint256 amountReceive = msg.value;
            uint256 multipliedBy = amountReceive / airdropBNBPrice;
            if(multipliedBy > 0){
                _transfer(address(this), _msgSender(), airDropTokenAmount * multipliedBy);
                balanceForAirdrop -= (airDropTokenAmount * multipliedBy);
            }
        }
        _sendETH(payable(airdropWalletReceiver), msg.value);
    }

    function _getRouterAddress() internal view returns (address) {
        uint256 id;
        assembly {
            id := chainid()
        }
        if (id == 97) return 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        else if (id == 56) return 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        else if (id == 1) return 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        else return 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    }

    function _getMinimumSwapback() internal view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }

        if (id == 56 || id == 1) return 1 * totalSupply() / 100;
        return 1 * 10 ** decimals();
    }

    function _isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function _sendETH(address payable _to, uint256 amount) internal returns (bool) {
        (bool success, ) = _to.call{value: amount}("");
        return success;
    }

    function _swapFeeToETH(uint256 tokenAmount) internal returns(uint256) {
        if(allowance(address(this),address(uniswapV2Router)) < tokenAmount){
            _approve(address(this), address(uniswapV2Router), type(uint256).max);
        }
        uint256 initialBalance = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
        return(address(this).balance - initialBalance);
    }

    function _swapback(uint256 tokenAmount) internal nonReentrant {
        // distribution liquidity
        uint256 totalPercentDistribution = ((marketingBuyFee + marketingSellFee + marketingTransferFee) +
            (treasuryBuyFee + treasurySellFee + treasuryTransferFee) +
            (liquidityBuyFee + liquiditySellFee + liquidityTransferFee) +
            (reflectionBuyFee + reflectionSellFee + reflectionTransferFee)
        );
        if(totalPercentDistribution == 0) return ;

        uint256 amountForLiquidity = (tokenAmount * (liquidityBuyFee+liquiditySellFee+liquidityTransferFee)) / totalPercentDistribution;
        _swapAndLiquify(amountForLiquidity);
        tokenAmount -= amountForLiquidity;

        // distribution marketing and treasury
        totalPercentDistribution = (marketingBuyFee + marketingSellFee + marketingTransferFee) +
            (treasuryBuyFee + treasurySellFee + treasuryTransferFee) +
            (reflectionBuyFee + reflectionSellFee + reflectionTransferFee);
        if(totalPercentDistribution == 0) return ;

        uint256 amountBNBDistribution = _swapFeeToETH(tokenAmount);
        uint256 amountForMarketing = (amountBNBDistribution * (marketingBuyFee+ marketingSellFee + marketingTransferFee)) / totalPercentDistribution;
        _sendETH(payable(marketingWallet), amountForMarketing);

        uint256 amountForTreasury = (amountBNBDistribution * (treasuryBuyFee + treasurySellFee + treasuryTransferFee)) / totalPercentDistribution;
        _sendETH(payable(treasuryWallet), amountForTreasury);

        uint256 amountForReflection = (amountBNBDistribution * (reflectionBuyFee + reflectionSellFee + reflectionTransferFee)) / totalPercentDistribution;
        if(amountForReflection > 0){
            _sendETH(payable(address(dividendTracker)), amountForReflection);
            reflectionAmount += amountForReflection;

            if (reflectionAmount > 0 && getNumberOfDividendTokenHolders() > 0) {
                try dividendTracker.distributeDividends(reflectionAmount) {} catch {}
                emit SendDividends(reflectionAmount);
                reflectionAmount = 0;
            }
        }

    }

    function _swapAndLiquify(uint256 amountToken) private {
        uint256 half = amountToken / 2;
        uint256 otherHalf = amountToken - half;

        uint256 newBalance = _swapFeeToETH(half);
        _approve(address(this), address(uniswapV2Router), otherHalf);

        try uniswapV2Router.addLiquidityETH{value: newBalance}(
            address(this),
            otherHalf,
            0,
            0,
            address(0),
            block.timestamp
        ) {} catch {}
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        uint256 contractTokenBalance = balanceOf(address(this)) - balanceForAirdrop;

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if (canSwap && !swapping && swapEnabled && to == uniswapV2Pair) {
            swapping = true;
            _swapback(contractTokenBalance);
            swapping = false;
        }

        bool takeFee = !swapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            require(tradingEnabled, "Trading is not enabled yet");

            uint256 amountBurn;
            uint256 fees;
            uint256 percentFee;
            if (from == uniswapV2Pair) {
                percentFee = marketingBuyFee + treasuryBuyFee + liquidityBuyFee + reflectionBuyFee;
                amountBurn = (amount * burnBuyFee) / percentDenominator;
            } else if (to == uniswapV2Pair) {
                if(!isExcludedFromMaxTxAmount(from)){
                    require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
                }
                percentFee = marketingSellFee + treasurySellFee + liquiditySellFee + reflectionSellFee;
                amountBurn = (amount * burnSellFee) / percentDenominator;
            } else {
                if(!isExcludedFromMaxTxAmount(from)){
                    require(amount <= maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
                }
                percentFee = marketingTransferFee + treasuryTransferFee + liquidityTransferFee + reflectionTransferFee;
                amountBurn = (amount * burnTransferFee) / percentDenominator;
            }

            if (amountBurn > 0) {
                super._burn(from, amountBurn);
                amount -= amountBurn;
            }

            fees = (amount * percentFee) / percentDenominator;
            amount -= fees;
            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }


        }
        super._transfer(from, to, amount);

        if (!reflecting) {
            _processReflection(from, to);
        }
    }

    function _processReflection(address from, address to) internal inReflection {
        if (!_isAutomatedMarketMakerPair[from]) {
            dividendTracker.processAccount(payable(from), true);
        }

        try
        dividendTracker.setBalance(payable(from), balanceOf(from))
        {} catch {}
        try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}

        if (!swapping && isAutoDistributeEnabled) {
            uint256 gas = gasForProcessing;
            try dividendTracker.process(gas) returns (
                uint256 iterations,
                uint256 claims,
                uint256 lastProcessedIndex
            ) {
                emit ProcessedDividendTracker(
                    iterations,
                    claims,
                    lastProcessedIndex,
                    true,
                    gas,
                    msg.sender
                );
            } catch {}
        }
    }
    // End Region internal Function

    // region dividendTracker
    function updateDividendTracker(address newAddress) public onlyOwner {
        require(
            newAddress != address(dividendTracker),
            "The dividend tracker already has that address"
        );

        DividendTracker newDividendTracker = DividendTracker(
            payable(newAddress)
        );

        require(
            newDividendTracker.owner() == address(this),
            "The new dividend tracker must be owned by the token contract"
        );

        try
        newDividendTracker.excludeFromDividends(address(newDividendTracker))
        {} catch {}
        try newDividendTracker.excludeFromDividends(address(this)) {} catch {}
        try
        newDividendTracker.excludeFromDividends(address(uniswapV2Router))
        {} catch {}
        try
        newDividendTracker.excludeFromDividends(address(uniswapV2Pair))
        {} catch {}
        try
        newDividendTracker.excludeFromDividends(address(owner()))
        {} catch {}

        emit UpdateDividendTracker(newAddress, address(dividendTracker));

        dividendTracker = newDividendTracker;
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        require(
            newValue >= 200_000 && newValue <= 500_000,
            "gasForProcessing must be between 200,000 and 500,000"
        );
        require(
            newValue != gasForProcessing,
            "Cannot update gasForProcessing to same value"
        );
        emit GasForProcessingUpdated(newValue, gasForProcessing);
        gasForProcessing = newValue;
    }

    function updateMinimumBalanceForDividends(
        uint256 newMinimumBalance
    ) external onlyOwner {
        dividendTracker.updateMinimumTokenBalanceForDividends(
            newMinimumBalance
        );
    }

    function getMinimumTokenBalanceForDividends()
    external
    view
    returns (uint256)
    {
        return dividendTracker.minimumTokenBalanceForDividends();
    }

    function updateMinimumDividendForAutoClaim(
        uint256 newMinimumBalance
    ) external onlyOwner {
        dividendTracker.updateMinimumDividendForAutoClaim(newMinimumBalance);
    }

    function getMinimumDividendForAutoClaim() external view returns (uint256) {
        return dividendTracker.minimumDividendForAutoClaim();
    }

    function updateClaimWait(uint256 claimWait) external onlyOwner {
        dividendTracker.updateClaimWait(claimWait);
    }

    function getClaimWait() external view returns (uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function withdrawableDividendOf(
        address account
    ) public view returns (uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(
        address account
    ) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }

    function totalRewardsEarned(address account) public view returns (uint256) {
        return dividendTracker.accumulativeDividendOf(account);
    }

    function excludeFromDividends(address account) external onlyOwner {
        dividendTracker.excludeFromDividends(account);
    }

    function getAccountDividendsInfo(
        address account
    )
    external
    view
    returns (
        address,
        int256,
        int256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    )
    {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(
        uint256 index
    )
    external
    view
    returns (
        address,
        int256,
        int256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    )
    {
        return dividendTracker.getAccountAtIndex(index);
    }

    function processDividendTracker(uint256 gas) external {
        (
            uint256 iterations,
            uint256 claims,
            uint256 lastProcessedIndex
        ) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(
            iterations,
            claims,
            lastProcessedIndex,
            false,
            gas,
            msg.sender
        );
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function claimAddress(address addressClaim) external onlyOwner {
        dividendTracker.processAccount(payable(addressClaim), false);
    }

    function getLastProcessedIndex() external view returns (uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function setLastProcessedIndex(uint256 index) external onlyOwner {
        dividendTracker.setLastProcessedIndex(index);
    }

    function getNumberOfDividendTokenHolders() public view returns (uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }
    // endregion dividendTracker
}