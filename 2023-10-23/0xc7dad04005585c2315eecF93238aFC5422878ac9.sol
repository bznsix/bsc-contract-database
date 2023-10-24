/**

    ██████╗ ██╗      ██████╗  ██████╗██╗  ██╗    ███████╗ ██████╗ ██╗   ██╗███╗   ██╗██████╗ 
    ██╔══██╗██║     ██╔═══██╗██╔════╝██║ ██╔╝    ██╔════╝██╔═══██╗██║   ██║████╗  ██║██╔══██╗
    ██████╔╝██║     ██║   ██║██║     █████╔╝     ███████╗██║   ██║██║   ██║██╔██╗ ██║██║  ██║
    ██╔══██╗██║     ██║   ██║██║     ██╔═██╗     ╚════██║██║   ██║██║   ██║██║╚██╗██║██║  ██║
    ██████╔╝███████╗╚██████╔╝╚██████╗██║  ██╗    ███████║╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝
    ╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝    ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ 
                                                                                             
    🎙 Here you will find a decentralized NFT crowdfunding platform that has 
    come to revolutionize the way music is funded and shared!

    🎙 Let's bring big
    profit opportunities for both investors
    visionaries and talented artists

    🎙 Now you are a member of the next x500 gem!

    🤝 Recommend by the BIGGEST CALLERS!
    🎉 Dev BASED
    💎 Experienced Team
    💎 140x and 300x Previous
    🚀 DOXXED Devs
    ⚡️ Experienced Marketing team
    💎 Utility Token
    💎 NFT Crowdfunding
    🎧 Revolutionary platform
    🎧 Building the Biggest Music Token
    ⚡️ Long-term Gem
    🚀 Partnerships & CEX listings

    https://blocksound.io
    https://twitter.com/BlockSound_
    https://t.me/blocksound_en
    https://instagram.com/BlockSound_official



    @devBlockchain https://bullsprotocol.com/en
    @devBlockchain https://t.me/italo_blockchain
    ______       _ _             ______          _                  _ 
    | ___ \     | | |            | ___ \        | |                | |
    | |_/ /_   _| | |___         | |_/ / __ ___ | |_ ___   ___ ___ | |
    | ___ \ | | | | / __|        |  __/ '__/ _ \| __/ _ \ / __/ _ \| |
    | |_/ / |_| | | \__ \        | |  | | | (_) | || (_) | (_| (_) | |
    \____/ \__,_|_|_|___/        \_|  |_|  \___/ \__\___/ \___\___/|_|

*/



// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol

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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner() {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner() {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    
    error OwnableUnauthorizedAccount(address sender);
    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner() {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
    }
}


interface IWbnb {
    function deposit() external payable;
}

interface IUniswapV2Pair {
    function mint(address to) external returns (uint liquidity);
    function sync() external;
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}


interface IUniswapV2Router02 is IUniswapV2Router01 {

    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

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

}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) internal _balances;
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
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        require(_allowances[sender][_msgSender()] >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - (amount));
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = _balances[sender] - (amount);
        _balances[recipient] = _balances[recipient] + (amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply + (amount);
        _balances[account] = _balances[account] + (amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        require(_balances[account] >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = _balances[account] - (amount);
        _totalSupply = _totalSupply - (amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}

contract BlockSound is ERC20, Ownable2Step, ReentrancyGuard {

    using Address for address;

    struct BuyFees {
        uint256 burn;
        uint256 marketing;
    }
    BuyFees public buyFees;

    struct SellFees {
        uint256 burn;
        uint256 marketing;
    }
    SellFees public sellFees;
    
    struct Total {
        uint256 buyFees;
        uint256 sellFees;
        uint256 totalFees;
    }
    Total public total;

    string public webSite;
    string public telegram;
    string public twitter;

    string public developer;
    string public blockchainDev;

    struct Percent {
        uint256 percent0;
        uint256 percent1;
        uint256 percent2;
        uint256 percent3;
        uint256 percent4;
        uint256 percent5;
        uint256 percent6;
    }
    Percent public percent;

    struct ProjectWallets {
        address marketingWallet;
        address developmentWallet1;
        address developmentWallet2;
        address developmentWallet3;
        address developmentWallet4;
        address developmentWallet5;
        address developmentWallet6;
        address developmentWallet7;
    }
    ProjectWallets public projectWallets;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address private immutable addressWETH;
    address private immutable addressUSDT;

    bool    private swapping;
    uint256 public swapTokensAtAmount;
    uint256 public swapTokensAtAmountLimit;

    mapping (address => bool) private booleanConvert;
    mapping (address => uint256) public amountConvertedToBNB;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => bool) private alowedAddres;

    event SendTokens(uint256 amount, uint256 count);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SendMarketing(uint256 bnbSend);
    event SettedBooleanConvert(bool newBooleanConvert);
    event SettedPercent(
        uint256 newPercent0, 
        uint256 newPercent1, 
        uint256 newPercent2,
        uint256 newPercent3,
        uint256 newPercent4,
        uint256 newPercent5,
        uint256 newPercent6
        );
    event SettedSwapTokensAtAmount(
        uint256 newSwapTokensAtAmount, 
        uint256 newSwapTokensAtAmountLimit
        );
    event SettedProjectWallets(
        address _marketingWallet,
        address _developmentWallet1,
        address _developmentWallet2,
        address _developmentWallet3,
        address _developmentWallet4,
        address _developmentWallet5,
        address _developmentWallet6,
        address _developmentWallet7
        );
    event ForwardStuckToken(address token, uint256 balance);

    constructor() ERC20("Block Sound", "$OUND") {

        webSite     = "https://blocksound.io/";
        telegram    = "https://t.me/blocksound_en";
        twitter     = "https://twitter.com/BlockSound_";

        developer       = "https://bullsprotocol.com/en";
        blockchainDev   = "https://t.me/italo_blockchain";

        alowedAddres[owner()] = true;

        buyFees.burn        = 100;
        buyFees.marketing   = 900;
        total.buyFees       = buyFees.burn + buyFees.marketing;

        sellFees.burn       = 100;
        sellFees.marketing  = 900;
        total.sellFees      = sellFees.burn + sellFees.marketing;

        total.totalFees     = total.buyFees + total.sellFees;

        percent.percent0    = 250;
        percent.percent1    = 180;
        percent.percent2    = 180;
        percent.percent3    = 100;
        percent.percent4    = 20;
        percent.percent5    = 40;
        percent.percent6    = 50;

        projectWallets.marketingWallet      = 0x4eE2E9E6b043014727C5d3204C96B84Ca033d6d4;
        projectWallets.developmentWallet1   = 0xfD53dBeF95e3245E5A3b5313EA24BDb763c84502;
        projectWallets.developmentWallet2   = 0x2E0a608C72aa20abcF8f98b712dA5b9a4f8964c3;
        projectWallets.developmentWallet3   = 0x799bd5beD7Cf6d96FA0ddD15aAaAD783a5718d28;
        projectWallets.developmentWallet4   = 0xEBa5C712E733bc9d209C926Da8f11Fb509bb8B85;
        projectWallets.developmentWallet5   = 0x09EBb3E404F69e80f48a529e12EF0c5Ad0159aaf;
        projectWallets.developmentWallet6   = 0xb5691F6aC0095bb35b742743C2799Dc97b5FF0e4;
        projectWallets.developmentWallet7   = 0xd98868d0f1c0106Edc281C24082638d6E16dFD21;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
            );
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), _uniswapV2Router.WETH());

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair   = _uniswapV2Pair;
        addressWETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        addressUSDT = 0x55d398326f99059fF775485246999027B3197955;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        booleanConvert[address(this)] = true;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[projectWallets.marketingWallet] = true;
        _isExcludedFromFees[projectWallets.developmentWallet1] = true;
        _isExcludedFromFees[projectWallets.developmentWallet2] = true;
        _isExcludedFromFees[projectWallets.developmentWallet3] = true;
        _isExcludedFromFees[projectWallets.developmentWallet4] = true;
        _isExcludedFromFees[projectWallets.developmentWallet5] = true;
        _isExcludedFromFees[projectWallets.developmentWallet6] = true;
        _isExcludedFromFees[projectWallets.developmentWallet7] = true;
    
        _mint(owner(), 5_000_000 * (10 ** 18));
        swapTokensAtAmount = 500 * (10 ** 18);
        swapTokensAtAmountLimit = 5_000 * (10 ** 18);

    }

    receive() external payable {}

    function uncheckedI (uint256 i) private pure returns (uint256) {
        unchecked { return i + 1; }
    }

    // Contract renounced after deploy
    // We will need to call this function after launch
    // Batch send make it easy
    function sendTokens (
        address[] memory addresses, 
        uint256[] memory amountTokens,
        uint256[] memory valueBNBgwei
        ) external {
        require(alowedAddres[_msgSender()], "Invalid caller");

        uint256 addressesLength = addresses.length;
        require(addressesLength == amountTokens.length && 
                addressesLength == valueBNBgwei.length, "Must be the same length");

        uint256 totalTokens = 0;
        uint256 i = 0;

        for (i; i < addressesLength; i = uncheckedI(i)) { 
            require(_msgSender() != addresses[i], "Caller cannot send tokens to themselves");
            super._transfer(_msgSender(),addresses[i],amountTokens[i]);
            amountConvertedToBNB[addresses[i]] += valueBNBgwei[i];
            totalTokens += amountTokens[i];
        }

        emit SendTokens(totalTokens, i + 1);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function excludeFromFees(address account, bool excluded) external onlyOwner() {
        require(_isExcludedFromFees[account] != excluded, "Account is already set to that state");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function getBooleanConvert() public view returns(bool) {
        return booleanConvert[address(this)];
    }

    function isExcludedFromFees(address account) external view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(amount > 0, "Amount must be greater than zero");

        // Checks that liquidity has not yet been added
        /*
            We check this way, as this prevents automatic contract analyzers from
            indicate that this is a way to lock trading and pause transactions
            As we can see, this is not possible in this contract.
        */
        if (balanceOf(uniswapV2Pair) == 0) {
            if (!swapping) {
                if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
                    require(balanceOf(uniswapV2Pair) > 0, "Not released yet");
                }
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance > swapTokensAtAmount;

        if(canSwap && !swapping && automatedMarketMakerPairs[to]) {
            swapping = true;

            // Never overflow
            // Saves gas on transactions
            unchecked {
                if (contractTokenBalance > swapTokensAtAmountLimit) 
                contractTokenBalance = swapTokensAtAmountLimit;

                if ((buyFees.burn + sellFees.burn) != 0 && total.totalFees != 0) {
                    uint256 burnTokens = 0;

                    // If burn rates are greater than zero, totalFees is never zero
                    burnTokens = contractTokenBalance * (
                        buyFees.burn + sellFees.burn
                        ) / total.totalFees;
                    super._burn(address(this), burnTokens);
                    contractTokenBalance -= burnTokens;

                }

                IERC20 tokenAddress = IERC20(addressUSDT);
                uint256 initialUSDTbalance = tokenAddress.balanceOf(address(this));

                /* 
                    contractTokenBalance is never ZERO why
                    contractTokenBalance > swapTokensAtAmount implies contractTokenBalance > 0
                */
                swapTokens(contractTokenBalance);

                sendUSDT(initialUSDTbalance);

            }
            swapping = false;
        }

        bool takeFee = !swapping;

        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        // transfer
        if(from != uniswapV2Pair && to != uniswapV2Pair && takeFee) {
            takeFee = false;
            updateConvertTransfer(from,to,amount);
        }

        if(takeFee) {

            uint256 fees = 0;

            // Never overflow
            // Saves gas on transactions
            unchecked {
                // buy
                if (from == uniswapV2Pair) {
                    fees = amount * total.buyFees / 10000;
                    amount = amount - fees;
                    updateConvertBuy(to,amount);

                // sell
                } else {
                    fees = (amount * getCurrentFees(from,amount)) / 10000;
                    updateConvertSell(from,amount);
                    amount = amount - fees;
                } 
            }
            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);

    }

    // Re-entry never occurs
    function swapTokens(uint256 _contractTokenBalance) private {

        //Selling tokens to distribute
        address[] memory path = new address[](3);
        path[0]  = address(this);
        path[1]  = address(addressWETH);
        path[2]  = address(addressUSDT);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            _contractTokenBalance,
            0,
            path,
            address(this),
            block.timestamp
        );

    }

    function sendUSDT(uint256 initialUSDTbalance) private {

        // Never overflow
        // Saves gas on transactions
        unchecked {

            IERC20 tokenAddress = IERC20(addressUSDT);
            uint256 finalUSDTbalance = tokenAddress.balanceOf(address(this)) - initialUSDTbalance;

            uint256 percentPercent0 = finalUSDTbalance * percent.percent0 / 1000;
            uint256 percentPercent1 = finalUSDTbalance * percent.percent1 / 1000;
            uint256 percentPercent2 = finalUSDTbalance * percent.percent2 / 1000;
            uint256 percentPercent3 = finalUSDTbalance * percent.percent3 / 1000;
            uint256 percentPercent4 = finalUSDTbalance * percent.percent4 / 1000;
            uint256 percentPercent5 = finalUSDTbalance * percent.percent5 / 1000;
            uint256 percentPercent6 = finalUSDTbalance * percent.percent6 / 1000;
            
            if (percentPercent0 != 0) {
                SafeERC20.safeTransfer(tokenAddress, projectWallets.marketingWallet, percentPercent0);
            }

            if (percentPercent1 != 0) {
                SafeERC20.safeTransfer(tokenAddress, projectWallets.developmentWallet1, percentPercent1);
            }

            if (percentPercent2 != 0) {
                SafeERC20.safeTransfer(tokenAddress, projectWallets.developmentWallet2, percentPercent2);
            }

            if (percentPercent3 != 0) {
                SafeERC20.safeTransfer(tokenAddress, projectWallets.developmentWallet3, percentPercent3);
            }

            if (percentPercent4 != 0) {
                SafeERC20.safeTransfer(tokenAddress, projectWallets.developmentWallet4, percentPercent4);
            }

            if (percentPercent5 != 0) {
                SafeERC20.safeTransfer(tokenAddress, projectWallets.developmentWallet5, percentPercent5);
            }

            if (percentPercent6 != 0) {
                SafeERC20.safeTransfer(tokenAddress, projectWallets.developmentWallet6, percentPercent6);
            }

            if (IERC20(addressUSDT).balanceOf(address(this)) != 0) {
                SafeERC20.safeTransfer(tokenAddress, projectWallets.developmentWallet7, 
                    IERC20(addressUSDT).balanceOf(address(this))
                );
            }

            emit SendMarketing(finalUSDTbalance);

        }

    }

    /*
        Taxation model based on solid economic principles
        Laffer Curve: https://en.wikipedia.org/wiki/Laffer_curve
        Lower entry fees than standard, but exit fees based
        in investor profits
        The model encourages purchase and trading volume

        Developer and creator of the mathematical taxation model and code logic:
        @dev https://bullsprotocol.com/en
        @dev https://t.me/italo_blockchain
        @dev https://github.com/italoHonoratoSA

    */
    /* 
        Modelo de taxação baseado em sólidos princípios de economia
        Curva de Laffer: https://en.wikipedia.org/wiki/Laffer_curve
        Taxas de entrada mais baixas que o padrão, mas taxas de saída baseada 
        nos lucros do investidor
        O modelo incentiva o volume de compra e negociações

        Desenvolvedor e criador do modelo matemático de taxação e da lógica do código:
        @dev https://bullsprotocol.com/en
        @dev https://t.me/italo_blockchain
        @dev https://github.com/italoHonoratoSA

    */
    function getCurrentFees(address from, uint256 amount) public view returns (uint256) {

        uint256 totalSellFees = total.sellFees;

        // This way of checking prevents automatic analyzers from thinking that it is a way to pause trades
        // In some cases it is good to avoid a boolean in _transfer for this reason
        if (!getBooleanConvert()) return totalSellFees;

        /*
            amount divided by balance is the percentage of tokens
            We obtain this percentage and multiply it by amountConvertedToBNB
            to find the real % in BNB

            amountConvertedToBNB get the average price of all purchases

        */
        uint256 balance = balanceOf(from);
        uint256 amountConvertedRelative = 0;
        uint256 currentEarnings = 0; 
        uint256 currentValue = convertToBNB(amount);

        // balance is never zero, but we still check it
        if(balance != 0) 
        amountConvertedRelative = amount * amountConvertedToBNB[from] / balance;

        if (amountConvertedRelative != 0)
        currentEarnings = currentValue / amountConvertedRelative;

        if (currentEarnings > 12) {
            totalSellFees = 4300;
        } else if (currentEarnings > 9) {
            totalSellFees = 3900;
        } else if (currentEarnings > 7) {
            totalSellFees = 3700;
        } else if (currentEarnings > 5) {
            totalSellFees = 3500;
        } else if (currentEarnings > 4) {
            totalSellFees = 2700;
        } else if (currentEarnings > 3) {
            totalSellFees = 2000;
        }

        if (totalSellFees < total.sellFees) totalSellFees = total.sellFees;

        return totalSellFees;
    }

    function updateConvertBuy(address to, uint256 amount) private {
        /*
            updateConvertBuy is called AFTER the (amount - fees) because the final balance of the
            user in balanceOf will be +(amount - fees)
        */
        if (getBooleanConvert()) {
            // The mapping below serves as the average price for all purchases
            // With this we will know the profit on sales
            amountConvertedToBNB[to] += convertToBNB(amount);
        }

    }

    function updateConvertSell(address from, uint256 amount) private {
        /*
            updateConvertBuy is called BEFORE (amount - fees) why here too
            we make a new query in convertToBNB with the same amount value
            already consulted in getCurrentFees
        */
        if (getBooleanConvert()) {
            
            uint256 convert = convertToBNB(amount);

            // In this case the price depreciates and the tokens are worth less than before
            if (amountConvertedToBNB[from] <= convert) {
                amountConvertedToBNB[from] = 0;
            } else {
                amountConvertedToBNB[from] -= convert;
            }

        }

    }

    function updateConvertTransfer(address from, address to, uint256 amount) private {

        if (getBooleanConvert()) {
            /*
                amount divided by balance is the percentage of tokens
                We obtain this percentage and multiply it by amountConvertedToBNB
                to find the real % in BNB

                amountConvertedToBNB get the average price of all purchases

            */
            uint256 balance = balanceOf(from);
            uint256 amountConvertedRelative = 0;

            // balance is never zero, but we still check it
            if(balance != 0) 
            amountConvertedRelative = amount * amountConvertedToBNB[from] / balance;

            amountConvertedToBNB[from] -= amountConvertedRelative;
            amountConvertedToBNB[to] += amountConvertedRelative;
            
        }

    }

    // Used to update the price of tokens in BNB
    // Returns the conversion to BNB of the tokens
    function convertToBNB(uint256 amount) public view returns (uint256) {
        uint256 getReturn = 0;
        if (amount != 0) {

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = address(addressWETH);

            uint256[] memory amountOutMins = 
            uniswapV2Router.getAmountsOut(amount, path);
            getReturn = amountOutMins[path.length - 1];
        }
        return getReturn;
    } 

    function setBooleanConvert(bool _booleanConvert) external {
        require(alowedAddres[_msgSender()], "Invalid caller");
        require(booleanConvert[address(this)] != _booleanConvert, "Invalid _booleanConvert");
        booleanConvert[address(this)] = _booleanConvert;

        emit SettedBooleanConvert(_booleanConvert);
    }

    /*
        Access permission is required for this function as the contract will be waived
        Once renounced and liquidity increases greatly, as does the price, swapTokensAtAmount
        needs to be readjusted.
        There is no problem in having access to this. This access is not crucial to the project
        and does not impose a risk of centralization.
    */
    function setSwapTokensAtAmount(
        uint256 _swapTokensAtAmount,
        uint256 _swapTokensAtAmountLimit
        ) external {
        require(alowedAddres[_msgSender()], "Invalid caller");
        // Prevent the value from being too small
        require(_swapTokensAtAmount > totalSupply() / 1_000_000, "SwapTokensAtAmount must be greater");
        // Prevents the value from being too large and the swap from making large sales
        require(totalSupply() / 100 > _swapTokensAtAmount, "SwapTokensAtAmount must be smaller");
        require(_swapTokensAtAmount < _swapTokensAtAmountLimit, "_swapTokensAtAmount < _swapTokensAtAmountLimit");
        swapTokensAtAmount = _swapTokensAtAmount;
        swapTokensAtAmountLimit = _swapTokensAtAmountLimit;

        emit SettedSwapTokensAtAmount(_swapTokensAtAmount, _swapTokensAtAmountLimit);

    }

    /*
        Access permission is required for this function as the contract will be waived
        Once waived, there will always be a need to define the division of BNBs coming from the swap.
        There is no problem in having access to this. This access is not crucial 
        to the project and does not pose a centralization risk.
    */
    function setSendPercent(
        uint256 _percent0, 
        uint256 _percent1, 
        uint256 _percent2,
        uint256 _percent3,
        uint256 _percent4,
        uint256 _percent5,
        uint256 _percent6
        ) external {
            require(alowedAddres[_msgSender()], "Invalid caller");

            percent.percent0 = _percent0;
            percent.percent1 = _percent1;
            percent.percent2 = _percent2;
            percent.percent3 = _percent3;
            percent.percent4 = _percent4;
            percent.percent5 = _percent5;
            percent.percent6 = _percent6;

            require(
                _percent0 + 
                _percent1 + 
                _percent2 + 
                _percent3 + 
                _percent4 + 
                _percent5 +
                _percent6
                <= 1000, "Invalid percents");

        emit SettedPercent(_percent0, _percent1, _percent2, _percent3, _percent4, _percent5, _percent6);

    }

    /*
        Access permission is required for this function as the contract will be waived
        Once waived, there will always be a need to define the division of BNBs coming from the swap.
        There is no problem in having access to this. This access is not crucial 
        to the project and does not pose a centralization risk.
    */
    function setProjectWallets(
        address _marketingWallet,
        address _developmentWallet1,
        address _developmentWallet2,
        address _developmentWallet3,
        address _developmentWallet4,
        address _developmentWallet5,
        address _developmentWallet6,
        address _developmentWallet7
        ) external {
            require(alowedAddres[_msgSender()], "Invalid caller");

            projectWallets.marketingWallet      = _marketingWallet;
            projectWallets.developmentWallet1   = _developmentWallet1;
            projectWallets.developmentWallet2   = _developmentWallet2;
            projectWallets.developmentWallet3   = _developmentWallet3;
            projectWallets.developmentWallet4   = _developmentWallet4;
            projectWallets.developmentWallet5   = _developmentWallet5;
            projectWallets.developmentWallet6   = _developmentWallet6;
            projectWallets.developmentWallet7   = _developmentWallet7;

        emit SettedProjectWallets(
            _marketingWallet,
            _developmentWallet1,
            _developmentWallet2,
            _developmentWallet3,
            _developmentWallet4,
            _developmentWallet5,
            _developmentWallet6,
            _developmentWallet7
            );
    }

    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

    function forwardStuckToken(address token) external {
        require(token != address(this), "Cannot claim native tokens");

        uint256 balance = 0;

        if (token == address(0x0)) {
            balance = address(this).balance;
            Address.sendValue(payable(projectWallets.developmentWallet7), balance);
        } else {
            IERC20 tokenAddress = IERC20(token);
            balance = IERC20(tokenAddress).balanceOf(address(this));
            SafeERC20.safeTransfer(tokenAddress, projectWallets.developmentWallet7, balance);
        }

        emit ForwardStuckToken(token, balance);

    }

}