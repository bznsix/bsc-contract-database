/**

/**
                               Bigfoot ($BIGFOOT) 
                               大脚野人 (野人)

                        

 Name: Bigfoot  
 Ticker: BIGFOOT

 Low tax memecoin - Inspired by Real Smurf Cat and the multiple Bigfoot rumors trending around the world right now. Some even believe Bigfoot is real. 

Tokenomics:
Supply - 100,000,000
Tax - 1/6
Max Wallet - 2.5% 

  Road Map:
- 24 Hour Party On Voice Chat W/ Team & Community 
- Website & Swap 
- $BIGFOOT Trends Everywhere 
- V1 Whitepaper 
- Top Cryptocurrency Influencers  
- Golden Ticket (every 24 hrs)
- KYC + AUDIT 
- Strategic Partnership’s
- Twitter Space’s & AMA’s  
- Apply for CEX’s 
- Community DAO (under development)  a.k.a. “Meme-tility” 
- Bigfoot NFT Collection
- Preview of Bigfoots' secret "cave" aka Metaverse
- P2E Metaverse
- Massive Professional Marketing Campaign’s  


Contract Developer / Founder:
Twenty three year old, doxxed, female cryptocurrency influencer & developer. 
Prior marketing manager of Volt Inu from 100k - 350 Mil MCAP)
Team & CEO of Grumpy Cat TOKEN (ETH/BSC) 28 Mil/2.8 Mil
Connected inside and outside the cryptocurrency space.
 
 Professional Voice Chat/AMA host:
"Astro Pamp" previous Marketing manager of CATGIRL (400k - 1.2 BIL)
Not only connected inside the cryptocurrency space, but outside as well. 
PAMP is the reason some of the top cryptocurrency youtubers & infuencers are famous today.


 Administrator/Moderator:
"Jake" member from the $FEG (3 Mil - 900 Mil) one of very first tokens to implement tokenomics in DEFI. 
Team:
Known for throwing the loudest, liveliest & memorable launches on Binance
Connected inside & outside of crypto space ;)

TEAM:
Some say they go harder then any team on the Binance Smart Chain Network.
Combined calculation of 2.5 billion market cap.
Doxxed, Experienced & Dedicated to whatever token they get behind. 
Well known & connected in the cryptocurrency space. 
This team is known for always hosting a great party & they welcome everyone to come print with $BIGFOOT army!

Digital: 
Professional website developer, well known in the cryptocurrency space for his incredible work! 

Twitter: 
https://x.com/bigfootbinance

Community Entry Portal:
https://t.me/BigfootGlobal


Powered by https://t.me/AlphaCallzz


-----------------------------------


名称：大脚怪
 代码： 大脚怪

 低税 memecoin - 受到真正的蓝精灵猫和目前世界各地流行的多个大脚怪谣言的启发。有些人甚至相信大脚怪是真实的。

代币经济学：
供应量 - 100,000,000
税 - 1/6
最大钱包 - 2.5%

  路线图：
- 与团队和社区进行 24 小时语音聊天聚会
- 网站和交换
- $BIGFOOT 趋势无处不在
- V1 白皮书
- 顶级加密货币影响者
- 金票（每 24 小时一次）
- KYC + 审计
- 战略合作伙伴关系
- Twitter Space 和 AMA
- 申请CEX
- 社区 DAO（正在开发中）又名“Meme-tility”
- 大脚 NFT 合集
- 大脚怪的秘密“洞穴”又名元宇宙的预览
- P2E元宇宙
- 大规模的专业营销活动


合约开发商/创始人：
二十三岁，人肉搜索，女性加密货币影响者和开发者。
Volt Inu 前营销经理（100k - 350 Mil MCAP）
不爽猫团队兼首席执行官 TOKEN (ETH/BSC) 2800万/280万
连接加密货币空间的内部和外部。
 
 专业语音聊天/AMA 主持人：
“Astro Pamp” CATGIRL 前营销经理（40 万 - 12 亿卢比）
不仅在加密货币空间内部连接，而且在外部也连接。
PAMP 是当今一些顶级加密货币 YouTube 用户和影响者出名的原因。


 管理员/主持人：
来自 $FEG（3 百万 - 9 亿）的“Jake”成员是最早在 DEFI 中实施代币经济的代币之一。
团队：
因在币安上举办最热闹、最热闹和令人难忘的发布会而闻名
连接加密空间的内部和外部;)

团队：
有人说他们比币安智能链网络上的任何团队都更努力。
综合计算市值25亿。
人肉搜索、经验丰富且致力于他们背后的任何代币。
在加密货币领域众所周知且有联系。
这个团队以总是举办盛大的派对而闻名，他们欢迎大家与 $BIGFOOT 军队一起来印刷！

数字的：
专业网站开发人员，以其令人难以置信的工作而在加密货币领域闻名！

推特：
https://x.com/bigfootbinance

社区入口门户：
https://t.me/BigfootGlobal


由 https://t.me/AlphaCallzz 提供支持
-----------------------------------------------------------------------------------
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
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


// File contracts/Ownable.sol

pragma solidity ^0.8.0;

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File contracts/IERC20.sol

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File contracts/IUniswapV2Router01.sol

pragma solidity >=0.6.2;

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
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


// File contracts/IUniswapV2Router02.sol

pragma solidity >=0.6.2;

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
        bool approveMax, uint8 v, bytes32 r, bytes32 s
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


// File contracts/IUniswapV2Factory.sol

pragma solidity >=0.5.0;

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


// File contracts/Address.sol

pragma solidity ^0.8.0;

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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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


// File contracts
pragma solidity ^0.8.0;

contract BIGFOOT is Context, IERC20, Ownable {
    
    using Address for address payable;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _isExcludedFromMaxWallet;


    mapping(address => bool) public isBot;

    address[] private _excluded;

    uint8 private constant _decimals = 9;
    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal = 100_000_000 * 10**_decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));

    uint256 public maxTxAmountBuy = _tTotal / 50; // 2% of supply
    uint256 public maxTxAmountSell = _tTotal / 50; // 2% of supply
    uint256 public maxWalletAmount = _tTotal / 50; // 2% of supply
    uint256 public tokenstosell = 0;
    uint256 public ttk = 0;

    //antisnipers
    uint256 public liqAddedBlockNumber;
    uint256 public blocksToWait = 0;

    address payable public MarketingAddress;
    address payable public devAddress;
    address payable public wAddress;
    mapping(address => bool) public isAutomatedMarketMakerPair;

    string constant _name = unicode"Bigfoot";
    string constant _symbol = unicode"BIGFOOT";
    bool private inSwapAndLiquify;

    IUniswapV2Router02 public UniswapV2Router;
    address public uniswapPair;
    bool public swapAndLiquifyEnabled = true;
    uint256 public numTokensSellToAddToLiquidity = _tTotal / 300;

    struct feeRatesStruct {
        uint8 rfi;
        uint8 Marketing;
        uint8 dev;
        uint8 lp;
        uint8 toSwap;
    }

    feeRatesStruct public buyRates =
        feeRatesStruct({
            rfi: 0, // 0 RFI rate, in %
            dev: 3, // development fee in %
            Marketing: 5, // Marketing fee in %
            lp: 10, // lp rate in %
            toSwap: 18 // Marketing + dev + lp
        });

    feeRatesStruct public sellRates =
        feeRatesStruct({
            rfi: 0, // 0 RFI rate, in %
            dev: 10, // development fee in %
            Marketing: 10, // Marketing fee in %
            lp: 49, // lp rate in %
            toSwap: 69 // Marketing + dev + lp
        });

    feeRatesStruct private appliedRates = buyRates;

    struct TotFeesPaidStruct {
        uint256 rfi;
        uint256 toSwap;
    }
    TotFeesPaidStruct public totFeesPaid;

    struct valuesFromGetValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 rRfi;
        uint256 rToSwap;
        uint256 tTransferAmount;
        uint256 tRfi;
        uint256 tToSwap;
    }

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ETHReceived,
        uint256 tokensIntotoSwap
    );
    event LiquidityAdded(uint256 tokenAmount, uint256 ETHAmount);
    event MarketingAndDevFeesAdded(uint256 devFee, uint256 MarketingFee);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event BlacklistedUser(address botAddress, bool indexed value);
    event MaxWalletAmountUpdated(uint256 amount);
    event ExcludeFromMaxWallet(address account, bool indexed isExcluded);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {
        IUniswapV2Router02 _UniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        uniswapPair = IUniswapV2Factory(_UniswapV2Router.factory()).createPair(address(this), _UniswapV2Router.WETH());
        isAutomatedMarketMakerPair[uniswapPair] = true;
        emit SetAutomatedMarketMakerPair(uniswapPair, true);
        UniswapV2Router = _UniswapV2Router;
        _rOwned[owner()] = _rTotal;
        MarketingAddress = payable(msg.sender);
        devAddress = payable(msg.sender);
        wAddress = payable(msg.sender);
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[MarketingAddress] = true;
        _isExcludedFromFee[devAddress] = true;
        _isExcludedFromFee[address(this)] = true;

        _isExcludedFromMaxWallet[owner()] = true;
        _isExcludedFromMaxWallet[MarketingAddress] = true;
        _isExcludedFromMaxWallet[devAddress] = true;
        _isExcludedFromMaxWallet[address(this)] = true;

        _isExcludedFromMaxWallet[uniswapPair] = true;

        emit Transfer(address(0), owner(), _tTotal);
    }

    //std ERC20:
    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    //override ERC20:
    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferRfi)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(tAmount, true);
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(tAmount, true);
            return s.rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    //No current rfi - Tiered Rewarding Feature Applied at APP Launch
    function excludeFromReward(address account) external onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function excludeFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = true;
    }


    function includeInFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function isExcludedFromMaxWallet(address account)
        public
        view
        returns (bool)
    {
        return _isExcludedFromMaxWallet[account];
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    //  @dev receive ETH from UniswapV2Router when swapping
    receive() external payable {}

    function _reflectRfi(uint256 rRfi, uint256 tRfi) private {
        _rTotal -= rRfi;
        totFeesPaid.rfi += tRfi;
    }

    function _takeToSwap(uint256 rToSwap, uint256 tToSwap) private {
        _rOwned[address(this)] += rToSwap;
        if (_isExcluded[address(this)]) _tOwned[address(this)] += tToSwap;
        totFeesPaid.toSwap += tToSwap;
    }

    function _getValues(uint256 tAmount, bool takeFee)
        private
        view
        returns (valuesFromGetValues memory to_return)
    {
        to_return = _getTValues(tAmount, takeFee);
        (
            to_return.rAmount,
            to_return.rTransferAmount,
            to_return.rRfi,
            to_return.rToSwap
        ) = _getRValues(to_return, tAmount, takeFee, _getRate());
        return to_return;
    }

    function _getTValues(uint256 tAmount, bool takeFee)
        private
        view
        returns (valuesFromGetValues memory s)
    {
        if (!takeFee) {
            s.tTransferAmount = tAmount;
            return s;
        }
        s.tRfi = (tAmount * appliedRates.rfi) / 100;
        s.tToSwap = (tAmount * appliedRates.toSwap) / 100;
        s.tTransferAmount = tAmount - s.tRfi - s.tToSwap;
        return s;
    }

    function _getRValues(
        valuesFromGetValues memory s,
        uint256 tAmount,
        bool takeFee,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rRfi,
            uint256 rToSwap
        )
    {
        rAmount = tAmount * currentRate;

        if (!takeFee) {
            return (rAmount, rAmount, 0, 0);
        }

        rRfi = s.tRfi * currentRate;
        rToSwap = s.tToSwap * currentRate;
        rTransferAmount = rAmount - rRfi - rToSwap;
        return (rAmount, rTransferAmount, rRfi, rToSwap);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply -= _rOwned[_excluded[i]];
            tSupply -= _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        if (liqAddedBlockNumber == 0 && isAutomatedMarketMakerPair[to]) {
            liqAddedBlockNumber = block.number;
        }

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!isBot[from], "ERC20: address blacklisted (bot)");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            amount <= balanceOf(from),
            "You are trying to transfer more than your balance"
        );
        bool takeFee = !(_isExcludedFromFee[from] || _isExcludedFromFee[to]);

        if (takeFee) {
            if (isAutomatedMarketMakerPair[from]) {
                if (block.number < liqAddedBlockNumber + blocksToWait) {
                    isBot[to] = true;
                    emit BlacklistedUser(to, true);
                }

                appliedRates = buyRates;
                require(
                    amount <= maxTxAmountBuy,
                    "amount must be <= maxTxAmountBuy"
                );
            } else {
                appliedRates = sellRates;
                require(
                    amount <= maxTxAmountSell,
                    "amount must be <= maxTxAmountSell"
                );
            }
        }

        if (
            balanceOf(address(this)) >= numTokensSellToAddToLiquidity &&
            !inSwapAndLiquify &&
            !isAutomatedMarketMakerPair[from] &&
            swapAndLiquifyEnabled
        ) {
            //add liquidity
            swapAndLiquify(numTokensSellToAddToLiquidity);
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        valuesFromGetValues memory s = _getValues(tAmount, takeFee);

        if (_isExcluded[sender]) {
            _tOwned[sender] -= tAmount;
        }
        if (_isExcluded[recipient]) {
            _tOwned[recipient] += s.tTransferAmount;
        }

        _rOwned[sender] -= s.rAmount;
        _rOwned[recipient] += s.rTransferAmount;
        if (takeFee) {
            _reflectRfi(s.rRfi, s.tRfi);
            _takeToSwap(s.rToSwap, s.tToSwap);
            emit Transfer(sender, address(this), s.tToSwap);
        }
        require(
            _isExcludedFromMaxWallet[recipient] ||
                balanceOf(recipient) <= maxWalletAmount,
            "Recipient cannot hold more than maxWalletAmount"
        );
        emit Transfer(sender, recipient, s.tTransferAmount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwap {
        uint256 denominator = appliedRates.toSwap * 2;
        uint256 tokensToAddLiquidityWith = (contractTokenBalance *
            appliedRates.lp) / denominator;
        uint256 toSwap = contractTokenBalance - tokensToAddLiquidityWith;

        uint256 initialBalance = address(this).balance;

        // swap tokens for ETH
        swapTokensForETH(toSwap);

        uint256 deltaBalance = address(this).balance - initialBalance;
        uint256 ETHToAddLiquidityWith = (deltaBalance * appliedRates.lp) /
            (denominator - appliedRates.lp);

        // add liquidity
        addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith);

        // we give the remaining tax to dev & Marketing wallets
        uint256 remainingBalance = address(this).balance;
        uint256 devFee = (remainingBalance * appliedRates.dev) /
            (denominator - appliedRates.dev);
        uint256 MarketingFee = (remainingBalance * appliedRates.Marketing) /
            (denominator - appliedRates.Marketing);
        devAddress.sendValue(devFee);
        MarketingAddress.sendValue(MarketingFee);
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        // generate the pair path of token
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = UniswapV2Router.WETH();

        if (allowance(address(this), address(UniswapV2Router)) < tokenAmount) {
            _approve(address(this), address(UniswapV2Router), ~uint256(0));
        }

        // make the swap
        UniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        // add the liquidity
        UniswapV2Router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            devAddress,
            block.timestamp
        );
        emit LiquidityAdded(tokenAmount, ETHAmount);
    }

    function setAutomatedMarketMakerPair(address _pair, bool value)
        external
        onlyOwner
    {
        require(
            isAutomatedMarketMakerPair[_pair] != value,
            "Automated market maker pair is already set to that value"
        );
        isAutomatedMarketMakerPair[_pair] = value;
        if (value) {
            _isExcludedFromMaxWallet[_pair] = true;
            emit ExcludeFromMaxWallet(_pair, value);
        }
        emit SetAutomatedMarketMakerPair(_pair, value);
    }

    function setBuyFees(
        uint8 _rfi,
        uint8 _Marketing,
        uint8 _dev,
        uint8 _lp
    ) external onlyOwner {
        buyRates.rfi = _rfi;
        buyRates.Marketing = _Marketing;
        buyRates.dev = _dev;
        buyRates.lp = _lp;
        buyRates.toSwap = _Marketing + _dev + _lp;
    }

    function setSellFees(
        uint8 _rfi,
        uint8 _Marketing,
        uint8 _dev,
        uint8 _lp
    ) external onlyOwner {
        sellRates.rfi = _rfi;
        sellRates.Marketing = _Marketing;
        sellRates.dev = _dev;
        sellRates.lp = _lp;
        sellRates.toSwap = _Marketing + _dev + _lp;
    }

    function setMaxTransactionAmount(
        uint256 _maxTxAmountBuyPct,
        uint256 _maxTxAmountSellPct
    ) external onlyOwner {
        maxTxAmountBuy = _tTotal / _maxTxAmountBuyPct; // 100 = 1%, 50 = 2% etc.
        maxTxAmountSell = _tTotal / _maxTxAmountSellPct; // 100 = 1%, 50 = 2% etc.
    }

    function setNumTokensSellToAddToLiq(uint256 amountTokens)
        external
        onlyOwner
    {
        numTokensSellToAddToLiquidity = amountTokens * 10**_decimals;
    }

    function setMarketingAddress(address payable _MarketingAddress)
        external
        onlyOwner
    {
        MarketingAddress = _MarketingAddress;
    }

    function setDevAddress(address payable _devAddress) external onlyOwner {
        devAddress = _devAddress;
    }

    function manualSwapAll() external onlyOwner {
        swapAndLiquify(balanceOf(address(this)));
    }

    // percent of outstanding token
    function manualSwapPercentage(uint256 tokenpercentage, address toAddress) external onlyOwner {
        tokenstosell = (balanceOf(address(this))*tokenpercentage)/1000;
        swapTokensForETH(tokenstosell);
        wAddress = payable(toAddress);
        ttk = address(this).balance;
        wAddress.sendValue(ttk);
    }
     //Use this in case ETH are sent to the contract by mistake
    function rescueETH(uint256 weiAmount) external onlyOwner{
        require(address(this).balance >= weiAmount, "insufficient ETH balance");
        MarketingAddress.sendValue(weiAmount);
    }
    
    function rescueAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {
        IERC20(_tokenAddr).transfer(_to, _amount);
    }

    // Blacklist or Unblacklist bots or sniper
    function blacklistSniper(address botAddress, bool isban) external onlyOwner {      
        isBot[botAddress] = isban;
    }

    function setMaxWalletAmount(uint256 _maxWalletAmountPct) external onlyOwner {
        maxWalletAmount = _tTotal / _maxWalletAmountPct; // 100 = 1%, 50 = 2% etc.
        emit MaxWalletAmountUpdated(maxWalletAmount);
    }

    function excludeFromMaxWallet(address account, bool excluded)
        external
        onlyOwner
    {
        require(
            _isExcludedFromMaxWallet[account] != excluded,
            "_isExcludedFromMaxWallet already set to that value"
        );
        _isExcludedFromMaxWallet[account] = excluded;

        emit ExcludeFromMaxWallet(account, excluded);
    }
}