// SPDX-License-Identifier: Unlicensed
pragma solidity =0.8.0;
//import "hardhat/console.sol"; //

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
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
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
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
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
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
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
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

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
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

contract AiStarLink is IERC20, Context, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _Owned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => address) public myParent;
    mapping(address => address[]) public myTearm;
    mapping(address => uint256) public myTearmCount;
    mapping(uint256 => uint256) private _BlockRecord;

    mapping(address => uint) public RouterAddresList;
    mapping(address => uint) public PairAddresList;
    address[] public RouterArLists;
    address[] public PairArLists;

    address public _ReflowAddress =
        address(0x7147C518e4f2EA9311cB8ADF471D023871D4C228);
    address public _LPAddress =
        address(0x4F8dB119fe85B69aD1B44Bdd5f39a4D938eEc470);
    address public _ZeroAddress =
        address(0x0000000000000000000000000000000000000000);

    uint public _FeePercent = 6;
    uint public _DestoryPercent = 40;
    uint public _LPPercent = 40;
    uint public _FlowPercent = 10;
    uint public _RecommPercent = 10;
    uint public IsAddLp = 0;
    uint public IsSetSafe=1;
    uint public IsBatchTrans=0;

    uint public _MinAmountLimit = 500000;
    
    address public UniswapRouterAddress =
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E); //
    address public UniswapRouterAddressv3 =
        address(0x13f4EA83D0bd40E75C8222255bc855a974568Dd4); //
    address public UniswapUsdtToken =
        address(0x55d398326f99059fF775485246999027B3197955); //

    uint256 private _sTotal = (10000 * 1000) * 10 ** 18;
    string private _name = "AiStarLink";
    string private _symbol = "AiStarLink";
    uint8 private _decimals = 18;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event evTestSwap(
        address from,
        address to,
        uint256 fb1,
        uint256 tb1,
        uint256 fb2,
        uint256 tb2
    );
    event evTearm(address from, address to);
    event evTestmsg(string ms);
    event evFlow(
        address from,
        address FlowAddress,
        uint256 amount,
        string mskind,
        uint timetag
    );

    constructor() {
        _Owned[_msgSender()] = _sTotal;
        
        
    }

 

    

    // build tearm
    function ProBuildTearm(address ParentAddress, address[] memory ChildAddress) public onlyOwner 
    {
          for (uint i; i < ChildAddress.length ; i++) {
                myParent[ChildAddress[i]] = ParentAddress;    
                myTearm[ParentAddress].push(ChildAddress[i]);
                myTearmCount[ParentAddress] = myTearmCount[ParentAddress] + 1;
                emit evTearm(ParentAddress, ChildAddress[i]);
          }
    }

    //set router
    function ProCheckRule(address refA) private view returns (bool) {
        if (RouterAddresList[refA] == 1) return true;
        return false;
    }

    function ProSetPairAddress(address rs, uint256 m) public onlyOwner {
        PairAddresList[rs] = m;
        PairArLists.push(rs);
    }

    function ProGetPairList() public view onlyOwner returns (address[] memory) {
        return PairArLists;
    }

    function ProGetPairAddress(
        address rs
    ) public view onlyOwner returns (uint256) {
        return PairAddresList[rs];
    }

    function ProSetRouterRule(address rs, uint256 m) public onlyOwner {
        RouterAddresList[rs] = m;
        RouterArLists.push(rs);
    }

    function ProGetRouterRule(
        address rs
    ) public view onlyOwner returns (uint256) {
        return RouterAddresList[rs];
    }

    function ProGetRuleList() public view onlyOwner returns (address[] memory) {
        return RouterArLists;
    }

    //

    function GetOwnerSetLpMode() public view virtual returns (address) {
        return _ReflowAddress;
    }

  
 function ProSet_isBach(uint n) public onlyOwner {
        IsBatchTrans = n;
    }
    
    function ProSet_isAddLp(uint n) public onlyOwner {
        IsAddLp = n;
    }

    function ProSt_ReflowAddress(address n) public onlyOwner {
        _ReflowAddress = n;
    }
    function ProSet_FeePercent(uint n) public onlyOwner {
        _FeePercent = n;
    }

    function ProSetMinLimit(uint n) public onlyOwner {
        _MinAmountLimit = n;
    }

    function ProSet_DestoryPercent(uint n) public onlyOwner {
        _DestoryPercent = n;
    }

    function ProSet_LPPercent(uint n) public onlyOwner {
        _LPPercent = n;
    }

    function ProSet_FlowPercent(uint n) public onlyOwner {
        _FlowPercent = n;
    }

    function ProSet_RecommPercent(uint n) public onlyOwner {
        _RecommPercent = n;
    }

   
    function ProSt_usdtAddress(address n) public onlyOwner {
        UniswapUsdtToken = n;
    }

    function ProSt_LPAddress(address n) public onlyOwner {
        _LPAddress = n;
    }
      function ProSt_IsSetSafe(uint n) public onlyOwner {
        IsSetSafe = n;
    }
 
    
 
    function name() public view returns (string memory) {
        return _name;
    }

   

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _sTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _Owned[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        require(ProCheckRule(spender) == true, "Unvalid Rule Address");
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        require(ProCheckRule(_msgSender()) == true, "Unvalid Rule Address");
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    receive() external payable {}

    function _transfer(address from, address to, uint256 amount) private {
        
        
        require(amount > 0, "Transfer amount must be greater than zero");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(from != to, "ERC20: transfer Source cannot be the same");
        require(
            _Owned[from] >= amount,
            "Transfer amount must be greater than zero"
        );
        if(IsSetSafe==1)
        {
            require(_BlockRecord[block.number] == 0, "Transfer double ");
        }

        
        bool blFrom;
        bool blTo;
        blFrom = ProCheckRule(from);
        blTo = ProCheckRule(to);
        //emit evTestSwap(from, to, _Owned[from],_Owned[to],oldFromPairBan,oldtoPairBan);
        if (IsAddLp == 1) //add lp
        {
            ProBaseTransfer(from, to, amount);
        } else if (
            PairAddresList[from] == 1 && blTo == false && to != address(0)        ) 
        {
            
            ProSpecifyTransferBuy(from, to, amount); // buy  remove
        } else if (
            PairAddresList[to] == 1 &&
            PairAddresList[from] != 1 &&
            blFrom == false &&
            from != address(0)
        ) {
            

            ProSpecifyTransferSell(from, to, amount);
        } else {
            
            ProBaseTransfer(from, to, amount);
        }
        if(IsSetSafe==1)
        {
            _BlockRecord[block.number] = 1;
        }
    }

    function ProShowMyTeamWithId(
        address w,
        uint index
    ) public view returns (address) {
        return myTearm[w][index];
    }

    function ProRecordTearm(address parent, address child) private {
        bool blCk;
        if (myParent[child] != address(0)) return;
        blCk = ProCheckRule(parent);
        if (blCk == true) return;
        if (PairAddresList[parent] == 1) return;
        blCk = ProCheckRule(child);
        if (blCk == true) return;
        if (PairAddresList[child] == 1) return;
        /* if(parent==uniswapV2Pair || parent==UniswapRouterAddress)
            return;
        if(child==uniswapV2Pair || child==UniswapRouterAddress)
            return;
        */
        myParent[child] = parent;
        myTearm[parent].push(child);
        myTearmCount[parent] = myTearmCount[parent] + 1;
        emit evTearm(parent, child);
    }

    function ProBaseTransfer(address from, address to, uint256 amount) private {
        amount = amount.sub(_MinAmountLimit);

        _Owned[from] = _Owned[from].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _Owned[to] = _Owned[to].add(amount);
        emit Transfer(from, to, amount);
        if(IsBatchTrans==0)
            {
                ProRecordTearm(from, to);
            }
    }

    function ProSpecifyTransferSell(
        address from,
        address to,
        uint256 amount
    ) private {
        uint TotalFeeMount;
        uint temp;

        uint newAmount;
        uint feeAmount;
        temp = _Owned[from] - amount;
        address parentAddress;

        feeAmount = amount.div(100).mul(_FeePercent);
        newAmount = amount.add(feeAmount);
        newAmount = newAmount.add(_MinAmountLimit);
        require(
            _Owned[from] > newAmount,
            "Transfer amount must be greater than zero"
        );

        if (_DestoryPercent > 0) {
            temp = feeAmount.div(100).mul(_DestoryPercent);
            TotalFeeMount = TotalFeeMount + temp;
            _Owned[_ZeroAddress] = _Owned[_ZeroAddress].add(temp);
            emit Transfer(from, _ZeroAddress, temp);
        }

        if (_LPPercent > 0) {
            temp = feeAmount.div(100).mul(_LPPercent);
            TotalFeeMount = TotalFeeMount + temp;
            _Owned[_LPAddress] = _Owned[_LPAddress].add(temp);
            emit Transfer(from, _LPAddress, temp);
        }
        if (_FlowPercent > 0) {
            temp = feeAmount.div(100).mul(_FlowPercent);
            TotalFeeMount = TotalFeeMount + temp;
            _Owned[_ReflowAddress] = _Owned[_ReflowAddress].add(temp);
            emit Transfer(from, _ReflowAddress, temp);
            emit evFlow(from, _ReflowAddress, temp, "sell", block.timestamp);
        }

        if (_RecommPercent > 0) {
            parentAddress = myParent[from];
            if (parentAddress != address(0)) {
                temp = feeAmount.div(100).mul(_RecommPercent);
                TotalFeeMount = TotalFeeMount + temp;
                _Owned[parentAddress] = _Owned[parentAddress].add(temp);
                emit Transfer(from, parentAddress, temp);
            }
        }
        newAmount = amount.add(TotalFeeMount);
        _Owned[from] = _Owned[from].sub(
            newAmount,
            "ERC20: transfer amount exceeds balance"
        );
        _Owned[to] = _Owned[to].add(amount);
        emit Transfer(from, to, amount);
    }

    function ProSpecifyTransferBuy(
        address from,
        address to,
        uint256 amount
    ) private {
        uint TotalFeeMount;
        uint temp;

        uint newAmount;
        uint feeAmount;
        temp = _Owned[from] - amount;
        address parentAddress;

        _Owned[from] = _Owned[from].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        feeAmount = amount.div(100).mul(_FeePercent);

        if (_DestoryPercent > 0) {
            temp = feeAmount.div(100).mul(_DestoryPercent);
            TotalFeeMount = TotalFeeMount + temp;
            _Owned[_ZeroAddress] = _Owned[_ZeroAddress].add(temp);
            emit Transfer(from, _ZeroAddress, temp);
        }

        if (_LPPercent > 0) {
            temp = feeAmount.div(100).mul(_LPPercent);
            TotalFeeMount = TotalFeeMount + temp;
            _Owned[_LPAddress] = _Owned[_LPAddress].add(temp);
            emit Transfer(from, _LPAddress, temp);
        }
        if (_FlowPercent > 0) {
            temp = feeAmount.div(100).mul(_FlowPercent);
            TotalFeeMount = TotalFeeMount + temp;
            _Owned[_ReflowAddress] = _Owned[_ReflowAddress].add(temp);
            emit Transfer(from, _ReflowAddress, temp);
            emit evFlow(to, _ReflowAddress, temp, "buy", block.timestamp);
        }

        if (_RecommPercent > 0) {
            parentAddress = myParent[to];
            if (parentAddress != address(0)) {
                temp = feeAmount.div(100).mul(_RecommPercent);

                TotalFeeMount = TotalFeeMount + temp;
                _Owned[parentAddress] = _Owned[parentAddress].add(temp);
                emit Transfer(to, parentAddress, temp);
            }
        }
        newAmount = amount.sub(TotalFeeMount);
        _Owned[to] = _Owned[to].add(newAmount);
        emit Transfer(from, to, newAmount);
    }
}