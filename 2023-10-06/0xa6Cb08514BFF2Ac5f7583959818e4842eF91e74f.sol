// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/ITurtleFinanceTokenPoolBank.sol";
import "./interfaces/ITurtleFinanceMainV1.sol";

library ICoinWindStructs {

    // 每个池子的信息
    struct PoolCowInfo {
        //cow 收益数据
        uint256 accCowPerShare;
        // cow累计收益
        uint256 accCowShare;
        //每个块奖励cow
        uint256 blockCowReward;
        //每个块奖励mdx
        uint256 blockMdxReward;
    }

    struct PoolInfo {
        // 用户质押币种
        address token;
        // 上一次结算收益的块高
        uint256 lastRewardBlock;
        // 上一次结算的用户总收益占比
        uint256 accMdxPerShare;
        // 上一次结算的平台分润占比
        uint256 govAccMdxPerShare;
        // 上一次结算累计的mdx收益
        uint256 accMdxShare;
        // 所有用户质押总数量
        uint256 totalAmount;
        // 所有用户质押总数量上限，0表示不限
        uint256 totalAmountLimit;
        // 用户收益率，万分之几
        uint256 profit;
        // 赚钱的最低触发额度
        uint256 earnLowerlimit;
        // 池子留下的保留金 min为100 表示 100/10000 = 1/100 = 0.01 表示 0.01%
        uint256 min;
        //单币质押年华
        uint256 lastRewardBlockProfit;
        PoolCowInfo cowInfo;
    }
}

interface ICoinWind {

    function getDepositAsset(address token, address user) external view returns (uint256);

    function deposit(address token, uint256 quantity) external;

    function withdraw(address token, uint256 quantity) external;

    function poolInfo(uint256 pid) external view returns (ICoinWindStructs.PoolInfo memory);

    function poolLength() external view returns (uint256);

    function pending(uint256 pid, address user) external view returns (uint256, uint256, uint256);

    function pendingCow(uint256 pid, address user) external view returns (uint256);
}

contract BankCoinWind is ITurtleFinanceTokenPoolBank {

    using SafeERC20 for IERC20;

    ICoinWind public coinWind;
    ITurtleFinanceMainV1 public mainContract;

    constructor(address mainAddr_, address coinWind_) {
        require(mainAddr_ != address(0), "mainAddr_ address cannot be 0");
        require(coinWind_ != address(0), "coinWind_ address cannot be 0");
        coinWind = ICoinWind(coinWind_);
        mainContract = ITurtleFinanceMainV1(mainAddr_);
    }

    modifier onlyOwner() {
        bool isOwner = mainContract.owner() == msg.sender;
        require(isOwner, "caller is not the owner");
        _;
    }
    modifier onlyMain() {
        bool isMain = address(mainContract) == msg.sender;
        require(isMain, "caller is not the main");
        _;
    }

    function _poolInfo(address token) private view returns (ICoinWindStructs.PoolInfo memory, uint256){
        uint256 len = coinWind.poolLength();
        for (uint256 i = 0; i < len; i++) {
            ICoinWindStructs.PoolInfo memory info = coinWind.poolInfo(i);
            if (info.token == token)
                return (info, i);
        }
        require(false, "BankCoinWind: pool not found");
    }

    // ----------------------- public view functions ---------------------
    function mainContractAddress() override external view returns (address){
        return address(mainContract);
    }

    function name() override external view returns (string memory){
        return "BankCoinWind";
    }

    function getProfit(address token) public view returns (uint256, uint256){
        (ICoinWindStructs.PoolInfo memory info,uint256 pid) = _poolInfo(token);
        (uint256 mdxQuantity,uint256 a2,uint256 a3) = coinWind.pending(pid, address(this));
        uint256 cowQuantity = coinWind.pendingCow(pid, address(this));
        return (mdxQuantity, cowQuantity);
    }

    // ----------------------- end public view functions ---------------------



    // ----------------------- owner functions ---------------------

    function withdrawProfit(address token, address to, address[] calldata profitTokens) onlyOwner external {
        uint256[] memory beforeBalances = new uint256[](profitTokens.length);
        for (uint i = 0; i < profitTokens.length; i++) {
            IERC20 profitTokenContract = IERC20(profitTokens[i]);
            uint256 quantity = profitTokenContract.balanceOf(address(this));
            beforeBalances[i] = quantity;
        }
        coinWind.withdraw(token, 0);
        for (uint i = 0; i < profitTokens.length; i++) {
            IERC20 profitTokenContract = IERC20(profitTokens[i]);
            uint256 quantity = profitTokenContract.balanceOf(address(this)) - beforeBalances[i];
            if (quantity > 0)
                profitTokenContract.safeTransfer(to, quantity);
        }
    }

    function withdrawToken(address token, address payable to, uint256 quantity) public onlyOwner {
        if (token == address(0))
            to.transfer(quantity);
        else
            IERC20(token).safeTransfer(to, quantity);
    }

    // ----------------------- end owner functions ---------------------



    // ----------------------- main functions ---------------------
    function create(address token) onlyMain override external {

    }

    function balanceOf(address token) onlyMain override external view returns (uint256){
        return coinWind.getDepositAsset(token, address(this));
    }

    function save(address token, uint256 quantity) onlyMain override external {
        IERC20(token).approve(address(coinWind), quantity);
        coinWind.deposit(token, quantity);
    }

    function take(address token, uint256 quantity) onlyMain override external {
        coinWind.withdraw(token, quantity);
        IERC20(token).safeTransfer(address(mainContract), quantity);
    }

    function destroy(address token) onlyMain override external {

    }
    // ----------------------- end main functions ---------------------

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) {
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
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface ITurtleFinanceTokenPoolBank {

    function mainContractAddress() external view returns (address);

    function name() external view returns (string memory);

    function create(address token) external;

    function balanceOf(address token) external view returns (uint256);

    function save(address token, uint256 quantity) external;

    function take(address token, uint256 quantity) external;

    function destroy(address token) external;

}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;


interface ITurtleFinanceMainV1 {
    function treTokenAddr() external returns (address);

    function owner() external returns (address);

}// SPDX-License-Identifier: MIT

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/ITurtleFinanceMainV1.sol";
import "./interfaces/IUniswapRouterV2.sol";
import "./interfaces/IMdexSwapMining.sol";
import "./interfaces/IKswapDexMining.sol";
import "./TurtleFinanceTreRewardV1.sol";
import "./Utils.sol";

contract TurtleFinancePairV1 is Ownable {

    ITurtleFinanceMainV1 public mainContract;
    TurtleFinanceTreRewardV1 public reward;

    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 private _firstItemId;
    uint256 private _lastItemId;

    struct PairInfo {
        bool enabled;
        address addr;
        address token0;
        address token1;
        uint256 minToken0;
        uint256 minToken1;
        uint256 maxToken0;
        uint256 maxToken1;
        uint platformFeeRate;
    }

    struct PairStats {
        uint256 totalCostToken0;
        uint256 totalCostToken1;
        uint256 totalRealToken0;
        uint256 totalRealToken1;
        uint256 totalFeeToken0;
        uint256 totalFeeToken1;
        uint256 totalItemCount;
        uint256 activeItemCount;
    }

    struct SwapItem {
        uint256 id;
        uint256 extId;
        bool enabled;
        address maker;
        uint16 costIdx;
        uint256 costToken0Quantity;
        uint256 costToken1Quantity;
        uint16 holdIdx;
        uint256 token0Balance;
        uint256 token1Balance;
    }

    address public uniswapRouterV2Addr;

    mapping(uint256 => SwapItem) private swapItemMap;
    mapping(uint256 => uint256) private swapItemExtMap;
    EnumerableSet.UintSet private swapItems;

    PairInfo private _pairInfo;
    PairStats private _pairStats;

    event SetPairInfo(bool enabled, uint256 minToken0, uint256 minToken1, uint256 maxToken0, uint256 maxToken1, uint256 platformFeeRate);


    constructor (address main, address token0, address token1)  {
        mainContract = ITurtleFinanceMainV1(main);
        _pairInfo.addr = address(this);
        _pairInfo.token0 = token0;
        _pairInfo.token1 = token1;
        transferOwnership(main);
        reward = new TurtleFinanceTreRewardV1(mainContract.treTokenAddr());
    }

    function getSwapItemIdRange() public view returns (uint256, uint256){
        return (_firstItemId, _lastItemId);
    }

    function getSwapInfo(uint256 itemId) public view returns (SwapItem memory){
        return swapItemMap[itemId];
    }

    function pairInfo() public view returns (PairInfo memory){
        return _pairInfo;
    }

    function pairStats() public view returns (PairStats memory){
        return _pairStats;
    }

    function mdexSwapMiningGetUserReward(address addr, uint256 pid) public view returns (uint256, uint256){
        return IMdexSwapMining(addr).getUserReward(pid);
    }

    function setUniswapRouterV2Addr(address uniswapRouterV2Addr_) external onlyOwner {
        uniswapRouterV2Addr = uniswapRouterV2Addr_;
    }

    function setPairInfo(PairInfo calldata form) external onlyOwner {
        require(form.minToken0 <= form.maxToken0, 'minToken0 cannot larger than maxToken0');
        require(form.minToken1 <= form.maxToken1, 'minToken1 cannot larger than maxToken1');
        _pairInfo.enabled = form.enabled;
        _pairInfo.minToken0 = form.minToken0;
        _pairInfo.minToken1 = form.minToken1;
        _pairInfo.maxToken0 = form.maxToken0;
        _pairInfo.maxToken1 = form.maxToken1;
        _pairInfo.platformFeeRate = form.platformFeeRate;
        emit SetPairInfo(form.enabled, form.minToken0, form.minToken1, form.maxToken0, form.maxToken1, form.platformFeeRate);
    }

    function mdexSwapMiningTakerWithdraw(address addr, address to) external onlyOwner {
        require(addr != address(0), "add is zero");
        IMdexSwapMining c = IMdexSwapMining(addr);
        IERC20 mdx = IERC20(c.mdx());
        uint256 beforeMdxBalance = mdx.balanceOf(address(this));
        c.takerWithdraw();
        mdx.transfer(to, mdx.balanceOf(address(this)) - beforeMdxBalance);
    }

    function kswapMiningTakerWithdraw(address addr, uint256 pid, address to) external onlyOwner {
        require(addr != address(0), "add is zero");
        IKswapDexMining c = IKswapDexMining(addr);
        IERC20 kst = IERC20(c.kst());
        uint256 beforeKstBalance = kst.balanceOf(address(this));
        c.emergencyWithdraw(pid);
        kst.transfer(to, kst.balanceOf(address(this)) - beforeKstBalance);
    }

    function swap(uint256 itemId, bytes memory marketData) external onlyOwner returns (SwapItem memory, uint256){
        SwapItem storage item = swapItemMap[itemId];
        require(item.enabled, "disabled");
        IERC20 et0 = IERC20(_pairInfo.token0);
        IERC20 et1 = IERC20(_pairInfo.token1);
        uint256 platformFee = 0;
        if (item.holdIdx == 0) {
            item.holdIdx = 1;
            _pairStats.totalRealToken0 -= item.token0Balance;
            require(item.token0Balance > 0, "balance overflow");
            et0.approve(uniswapRouterV2Addr, item.token0Balance);
            uint256 beforeTotal1Balance = et1.balanceOf(address(mainContract));
            Utils.functionCall(uniswapRouterV2Addr, marketData, string(abi.encodePacked("swap 0 to 1 fail-> ", "balance: ", Strings.toString(beforeTotal1Balance))));
            uint256 balance1Changed = et1.balanceOf(address(mainContract)) - beforeTotal1Balance;
            if (balance1Changed > item.token1Balance)
                platformFee = (balance1Changed - item.token1Balance) * uint256(_pairInfo.platformFeeRate) / 10000;
            item.token1Balance = balance1Changed - uint256(platformFee);
            _pairStats.totalRealToken1 += item.token1Balance;
            _pairStats.totalFeeToken1 += uint256(platformFee);
        } else {
            item.holdIdx = 0;
            _pairStats.totalRealToken1 -= item.token1Balance;
            require(item.token1Balance > 0, "balance overflow");
            et1.approve(uniswapRouterV2Addr, item.token1Balance);
            uint256 beforeTotal0Balance = et0.balanceOf(address(mainContract));
            Utils.functionCall(uniswapRouterV2Addr, marketData, string(abi.encodePacked("swap 1 to 0 fail-> ", "balance: ", Strings.toString(beforeTotal0Balance))));
            uint256 balance0Changed = et0.balanceOf(address(mainContract)) - beforeTotal0Balance;
            if (balance0Changed > item.token0Balance)
                platformFee = (balance0Changed - item.token0Balance) * uint256(_pairInfo.platformFeeRate) / 10000;
            item.token0Balance = balance0Changed - uint256(platformFee);
            _pairStats.totalRealToken0 += item.token0Balance;
            _pairStats.totalFeeToken0 += uint256(platformFee);
        }
        return (item, uint256(platformFee));
    }

    function create(address maker, uint256 id, uint256 extId, uint16 holdIdx, uint256 token0Balance, uint256 token1Balance) external onlyOwner returns (SwapItem memory){
        //        uint256 id = _swap_id_seq++;
        require(id > 0 && extId > 0, "ID error");
        require(swapItemExtMap[extId] == 0, "Repeat create");
        require(swapItemMap[id].id == 0, "Repeat create");
        require(swapItemMap[id].maker == address(0), "Repeat create");
        SwapItem memory item;
        item.id = id;
        item.extId = extId;
        item.enabled = true;
        item.maker = maker;
        item.costIdx = holdIdx;
        item.holdIdx = holdIdx;
        item.costToken0Quantity = token0Balance;
        item.costToken1Quantity = token1Balance;
        item.token0Balance = token0Balance;
        item.token1Balance = token1Balance;
        swapItemMap[id] = item;
        swapItemExtMap[extId] = id;
        swapItems.add(id);
        if (item.holdIdx == 0) {
            _pairStats.totalCostToken0 += token0Balance;
            _pairStats.totalRealToken0 += token0Balance;
        } else {
            _pairStats.totalCostToken1 += token1Balance;
            _pairStats.totalRealToken1 += token1Balance;
        }
        reward.plusBalance(maker, token0Balance);
        _pairStats.totalItemCount += 1;
        _pairStats.activeItemCount += 1;
        if (_firstItemId == 0)
            _firstItemId = id;
        _lastItemId = id;
        return item;
    }

    function remove(uint256 itemId) external onlyOwner returns (SwapItem memory){
        SwapItem storage item = swapItemMap[itemId];
        require(item.enabled, "disabled");
        _pairStats.activeItemCount -= 1;
        if (item.holdIdx == 0) {
            _pairStats.totalRealToken0 -= item.token0Balance;
        } else {
            _pairStats.totalRealToken1 -= item.token1Balance;
        }
        item.enabled = false;
        item.token0Balance = 0;
        item.token1Balance = 0;
        reward.minusBalance(item.maker, item.costToken0Quantity);
        swapItems.remove(itemId);
        return item;
    }


    function rewardPools() external view returns (TurtleFinanceTreRewardV1.Pool[] memory) {
        return reward.getPools();
    }

    function rewardEarned(address account) external view returns (uint256) {
        return reward.earned(account);
    }

    function rewardGet(address account) external onlyOwner {
        return reward.getReward(account);
    }

    function rewardAddPool(address sender, uint256 totalRewardQuantity, uint256 startTime, uint256 periodTime) external onlyOwner {
        reward.addPool(sender, totalRewardQuantity, startTime, periodTime);
    }
}
// SPDX-License-Identifier: MIT

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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant alphabet = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = alphabet[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface IUniswapRouterV2 {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface IMdexSwapMining {

    function getUserReward(uint256 pid) external view returns (uint256, uint256);

    function takerWithdraw() external;

    function mdx() external returns (address);

}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

interface IKswapDexMining {

    function emergencyWithdraw(uint256 pid) external;

    function kst() external view returns (address);

}pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TurtleFinanceTreRewardV1 is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.UintSet;

    IERC20 public tre;
    uint256 private pool_id_seq_;
    uint256 public totalBalance;
    mapping(address => uint256) public balances;

    struct Pool {
        uint256 id;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
        uint256 totalRewardQuantity;
        uint256 startTime;
        uint256 endTime;
        uint256 totalPaidReward;
    }

    mapping(uint256 => mapping(address => uint256)) private userRewardPerTokenPaid;
    mapping(uint256 => mapping(address => uint256)) private unpaidRewards;
    mapping(uint256 => mapping(address => uint256)) private paidRewards;
    mapping(uint256 => Pool) private pools;

    EnumerableSet.UintSet private poolIdList;

    event RewardPaid(uint256 poolId, address indexed user, uint256 reward);
    event AddPool(uint256 poolId, uint256 totalRewardQuantity_, uint256 startTime, uint256 periodTime);

    constructor(address tre_) public {
        require(tre_ != address(0), "tre_ address cannot be 0");
        tre = IERC20(tre_);
        pool_id_seq_ = 1;
    }


    function updateReward(uint256 pid, address account) private {
        Pool storage pool = pools[pid];
        if (pool.startTime > block.timestamp) return;
        pool.rewardPerTokenStored = rewardPerToken(pid);
        pool.lastUpdateTime = lastTimeRewardApplicable(pid);
        if (account != address(0)) {
            unpaidRewards[pool.id][account] = earnedByPool(pid, account);
            userRewardPerTokenPaid[pool.id][account] = pool.rewardPerTokenStored;
        }
    }

    function addPool(address sender, uint256 totalRewardQuantity_, uint256 startTime, uint256 periodTime) nonReentrant external onlyOwner {
        require(startTime >= block.timestamp, "startTime < now");
        require(periodTime >= 60, "periodTime < 60");
        tre.transferFrom(sender, address(this), totalRewardQuantity_);
        Pool memory pool;
        pool.id = pool_id_seq_++;
        pool.totalRewardQuantity = totalRewardQuantity_;
        pool.rewardRate = totalRewardQuantity_ / periodTime;
        pool.startTime = startTime;
        pool.endTime = startTime + periodTime;
        pool.lastUpdateTime = startTime;
        pools[pool.id] = pool;
        poolIdList.add(pool.id);
        emit AddPool(pool.id, totalRewardQuantity_, startTime, periodTime);
    }

    // ---------------------- view functions -------------------------
    function getPools() public view returns (Pool[] memory){
        uint256 len = poolIdList.length();
        Pool[] memory _pools = new Pool[](len);
        for (uint i = 0; i < len; i++) {
            _pools[i] = pools[poolIdList.at(i)];
        }
        return _pools;
    }

    function lastTimeRewardApplicable(uint256 pid) public view returns (uint256) {
        if (block.timestamp < pools[pid].startTime) return pools[pid].startTime;
        return Math.min(block.timestamp, pools[pid].endTime);
    }

    function rewardPerToken(uint256 pid) public view returns (uint256) {
        if (totalBalance == 0) {
            return pools[pid].rewardPerTokenStored;
        }
        return pools[pid].rewardPerTokenStored + ((lastTimeRewardApplicable(pid) - pools[pid].lastUpdateTime) * pools[pid].rewardRate * 1e18 / totalBalance);
    }

    function earnedByPool(uint256 pid, address account) public view returns (uint256) {
        if (pools[pid].startTime > block.timestamp) return 0;
        uint256 urptp = userRewardPerTokenPaid[pid][account];
        uint256 amount = (balances[account] * (rewardPerToken(pid) - urptp)) / 1e18 + unpaidRewards[pid][account];
        return amount;
    }

    function earned(address account) public view returns (uint256) {
        uint256 earned_ = 0;
        uint256 len = poolIdList.length();
        for (uint i = 0; i < len; i++) {
            earned_ += earnedByPool(poolIdList.at(i), account);
        }
        return earned_;
    }
    // ---------------------- end view functions -------------------------

    function plusBalance(address account, uint256 quantity) onlyOwner external {
        require(account != address(0), "account address cannot be 0");
        uint256 len = poolIdList.length();
        for (uint i = 0; i < len; i++) {
            updateReward(poolIdList.at(i), account);
        }
        balances[account] = balances[account] + quantity;
        totalBalance = totalBalance + quantity;
    }

    function minusBalance(address account, uint256 quantity) onlyOwner external {
        require(account != address(0), "account address cannot be 0");
        uint256 len = poolIdList.length();
        for (uint i = 0; i < len; i++) {
            updateReward(poolIdList.at(i), account);
        }
        balances[account] = balances[account] - quantity;
        totalBalance = totalBalance - quantity;
    }

    function _getRewardByPool(uint256 pid, address account) private {
        updateReward(pid, account);
        uint256 reward = earnedByPool(pid, account);
        if (reward > 0) {
            unpaidRewards[pid][account] = 0;
            paidRewards[pid][account] = paidRewards[pid][account] + reward;
            pools[pid].totalPaidReward = pools[pid].totalPaidReward + reward;
            tre.safeTransfer(account, reward);
            emit RewardPaid(pid, account, reward);
        }
    }

    function getRewardByPool(uint256 pid, address account) onlyOwner nonReentrant external {
        _getRewardByPool(pid, account);
    }

    function getReward(address account) onlyOwner nonReentrant external {
        uint256 len = poolIdList.length();
        for (uint i = 0; i < len; i++) {
            _getRewardByPool(poolIdList.at(i), account);
        }
    }

}
pragma solidity ^0.8.5;

library Utils {

    function bytesToHexString(bytes memory bs) internal pure returns (string memory) {
        bytes memory tempBytes = new bytes(bs.length * 2);
        uint len = bs.length;
        for (uint i = 0; i < len; i++) {
            bytes1 b = bs[i];
            bytes1 nb = (b & 0xf0) >> 4;
            tempBytes[2 * i] = nb > 0x09 ? bytes1((uint8(nb) + 0x37)) : (nb | 0x30);
            nb = (b & 0x0f);
            tempBytes[2 * i + 1] = nb > 0x09 ? bytes1((uint8(nb) + 0x37)) : (nb | 0x30);
        }
        return string(tempBytes);
    }


    function char(bytes1 b) internal view returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function toAsciiString(address x) internal view returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2 ** (8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function functionCall(address addr, bytes memory data, string memory errMsg) internal {
        (bool success, bytes memory retData) = addr.call(data);
        require(success, string(abi.encodePacked(
                errMsg,
                ", addr: 0x", toAsciiString(addr),
                ", data: 0x", bytesToHexString(data),
                ", return: 0x", bytesToHexString(retData)
            )));
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}
// SPDX-License-Identifier: MIT

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

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./TurtleFinancePairV1.sol";
import "./interfaces/ITurtleFinanceTokenPoolBank.sol";
import "./interfaces/IUniswapRouterV2.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TurtleFinanceMainV1 is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    struct TokenPool {
        address addr;
        uint256 totalQuantity;
        uint256 mainBalance;
        address bankAddr;
        uint256 bankTotalSaveQuantity;
        uint256 bankTotalTakeQuantity;
        uint256 bankBalance;
        uint256 minHoldRate;
        uint256 expHoldRate;
        uint256 maxHoldRate;
    }

    struct UniswapRouterV2SwapTokenParams {
        uint256 amountIn;
        uint256 amountOutMin;
        address[] path;
        uint256 deadline;
    }

    mapping(address => TokenPool) tokenPoolMap;
    mapping(address => uint256) pairsSwapItemIdSEQMap;

    EnumerableSet.AddressSet pairs;
    EnumerableSet.AddressSet tokenPools;
    address public mdexSwapMiningAddr;
    address public kswapDexMiningAddr;
    address public treTokenAddr;
    address public uniswapRouterV2Addr;
    address payable public platformFeeReceiver;
    address private _operator;

    bool public lockOperator;

    event Action(address indexed pair, string act, address indexed maker, uint256 indexed itemId, uint16 holdIdx, uint256 token0quantity, uint256 token1quantity);

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    event SetTokenPool(address indexed token, address bank, uint256 minHoldRate, uint256 expHoldRate, uint256 maxHoldRate);

    event TokenBankTake(address indexed token, address bank, uint256 quantity);
    event TokenBankSave(address indexed token, address bank, uint256 quantity);

    event AddPair(address indexed pair);

    constructor(address treTokenAddr_, address uniswapRouterV2Addr_, address mdexSwapMiningAddr_, address kswapDexMiningAddr_){
        require(treTokenAddr_ != address(0), "treTokenAddr_ address cannot be 0");
        require(uniswapRouterV2Addr_ != address(0), "uniswapRouterV2Addr_ address cannot be 0");
        _operator = _msgSender();
        platformFeeReceiver = payable(msg.sender);
        treTokenAddr = treTokenAddr_;
        uniswapRouterV2Addr = uniswapRouterV2Addr_;
        mdexSwapMiningAddr = mdexSwapMiningAddr_;
        kswapDexMiningAddr = kswapDexMiningAddr_;
    }

    function _transferOperator(address newOperator_) internal {
        require(
            newOperator_ != address(0),
            'operator: zero address given for new operator'
        );
        emit OperatorTransferred(_operator, newOperator_);
        _operator = newOperator_;
    }

    function _autoCreateTokenPool(address token) private {
        if (!tokenPools.contains(token)) {
            TokenPool memory pool;
            pool.addr = token;
            tokenPoolMap[token] = pool;
            tokenPools.add(token);
        }
    }

    function _tokenBankSave(address token, uint256 quantity) private {
        TokenPool storage pool = tokenPoolMap[token];
        ITurtleFinanceTokenPoolBank bank = ITurtleFinanceTokenPoolBank(pool.bankAddr);
        IERC20 et = IERC20(token);
        et.safeTransfer(address(bank), quantity);
        bank.save(token, quantity);
        pool.bankTotalSaveQuantity += quantity;
        pool.bankBalance = bank.balanceOf(token);
        pool.mainBalance = et.balanceOf(address(this));
        emit TokenBankSave(token, address(bank), quantity);
    }

    function _tokenBankTake(address token, uint256 quantity) private {
        TokenPool storage pool = tokenPoolMap[token];
        ITurtleFinanceTokenPoolBank bank = ITurtleFinanceTokenPoolBank(pool.bankAddr);
        IERC20 et = IERC20(token);
        uint256 balance = et.balanceOf(address(this));
        bank.take(token, quantity);
        require(et.balanceOf(address(this)) - balance == quantity, "bank take fail.");
        pool.bankTotalTakeQuantity += quantity;
        pool.bankBalance = bank.balanceOf(token);
        pool.mainBalance = et.balanceOf(address(this));
        emit TokenBankTake(token, address(bank), quantity);
    }

    function _tokenPoolBalanceChange(address token) private {
        TokenPool storage pool = tokenPoolMap[token];
        IERC20 et = IERC20(token);
        if (pool.bankAddr == address(0)) {
            pool.bankBalance = 0;
            pool.mainBalance = et.balanceOf(address(this));
            return;
        }
        uint256 minHold = pool.totalQuantity * pool.minHoldRate / 1E4;
        uint256 expHold = pool.totalQuantity * pool.expHoldRate / 1E4;
        uint256 maxHold = pool.totalQuantity * pool.maxHoldRate / 1E4;
        if (pool.mainBalance <= minHold) {
            uint256 quantity = expHold - pool.mainBalance;
            if (quantity > 0) {
                _tokenBankTake(token, quantity);
            }
        } else if (pool.mainBalance >= maxHold) {
            uint256 quantity = pool.mainBalance - expHold;
            if (quantity > 0) {
                _tokenBankSave(token, quantity);
            }
        }
    }

    function _tokenPoolTransfer(address toAddr, address token, uint256 quantity) private {
        TokenPool storage pool = tokenPoolMap[token];
        pool.totalQuantity = pool.totalQuantity - quantity;
        IERC20 et = IERC20(token);
        if (pool.bankAddr != address(0)) {
            uint256 needTake = 0;
            if (quantity > pool.mainBalance)
                needTake = quantity - pool.mainBalance;
            if (needTake > 0) {
                _tokenBankTake(token, needTake);
            }
        }
        et.safeTransfer(toAddr, quantity);
        pool.mainBalance = et.balanceOf(address(this));
        _tokenPoolBalanceChange(token);
    }

    function _tokenPoolReceived(address token, uint256 quantity) private {
        TokenPool storage pool = tokenPoolMap[token];
        pool.totalQuantity = pool.totalQuantity + quantity;
        pool.mainBalance = IERC20(token).balanceOf(address(this));
        _tokenPoolBalanceChange(token);
    }

    function _getUniswapSwapFunctionData(UniswapRouterV2SwapTokenParams memory params, address to) private view returns (bytes memory){
        return abi.encodeWithSelector(
            bytes4(keccak256("swapExactTokensForTokens(uint256,uint256,address[],address,uint256)")), // 0x38ED1739
            params.amountIn,
            params.amountOutMin,
            params.path,
            address(this),
            params.deadline
        );
    }

    modifier onlyNotLocked(){
        require(!lockOperator, 'operator: locked');
        _;
    }

    modifier onlyOperator() {
        require(!lockOperator, 'operator: locked');
        require(
            _operator == msg.sender || owner() == msg.sender,
            'operator: caller is not the operator'
        );
        _;
    }

    // --------------- view functions -----------------------


    function operator() external view returns (address) {
        return _operator;
    }

    function getPairs() external view returns (TurtleFinancePairV1.PairInfo[] memory){
        uint256 len = pairs.length();
        TurtleFinancePairV1.PairInfo[] memory infos = new TurtleFinancePairV1.PairInfo[](len);
        for (uint256 i = 0; i < len; i++) {
            address pairAddr = pairs.at(i);
            TurtleFinancePairV1.PairInfo memory pi = TurtleFinancePairV1(pairAddr).pairInfo();
            infos[i] = pi;
        }
        return infos;
    }

    function getTokenPools() external view returns (TokenPool[] memory){
        uint256 len = tokenPools.length();
        TokenPool[] memory pools = new TokenPool[](len);
        for (uint256 i = 0; i < len; i++) {
            pools[i] = tokenPoolMap[tokenPools.at(i)];
        }
        return pools;
    }

    function pairMdexSwapMiningGetUserReward(address pairAddr, uint256 pid) external view returns (uint256, uint256){
        require(pairs.contains(pairAddr), "pair not exists");
        require(mdexSwapMiningAddr != address(0), "Not support");
        TurtleFinancePairV1 pair = TurtleFinancePairV1(pairAddr);
        return pair.mdexSwapMiningGetUserReward(mdexSwapMiningAddr, pid);
    }

    // --------------- view functions end -----------------------




    // --------------- admin functions -----------------------

    function transferOperator(address newOperator_) external onlyOwner {
        _transferOperator(newOperator_);
    }

    function setPlatformFeeReceiver(address payable platformFeeReceiver_) external onlyOwner {
        require(platformFeeReceiver_ != address(0), "platformFeeReceiver_ address cannot be 0");
        platformFeeReceiver = platformFeeReceiver_;
    }

    function pairMdexSwapMiningTakerWithdraw(address pairAddr, address to) external onlyOwner {
        require(pairs.contains(pairAddr), "pair not exists");
        require(mdexSwapMiningAddr != address(0), "Not support");
        TurtleFinancePairV1 pair = TurtleFinancePairV1(pairAddr);
        pair.mdexSwapMiningTakerWithdraw(mdexSwapMiningAddr, to);
    }

    function pairKswapDexMiningTakerWithdraw(address pairAddr, uint256 pid, address to) external onlyOwner {
        require(pairs.contains(pairAddr), "pair not exists");
        require(kswapDexMiningAddr != address(0), "Not support");
        TurtleFinancePairV1 pair = TurtleFinancePairV1(pairAddr);
        pair.kswapMiningTakerWithdraw(kswapDexMiningAddr, pid, to);
    }

    function tokenPoolSet(address addr, address bankAddr, uint256 min, uint256 exp, uint256 max) external onlyOwner {
        TokenPool storage pool = tokenPoolMap[addr];
        require(pool.addr == addr && addr != address(0), "token not exists.");
        require(min > 0 && min <= exp && exp <= max && max < 1E4, "rate error");
        pool.minHoldRate = min;
        pool.expHoldRate = exp;
        pool.maxHoldRate = max;
        if (pool.bankAddr != address(0) && pool.bankAddr != bankAddr) {
            if (pool.bankBalance > 0)
                _tokenBankTake(pool.addr, pool.bankBalance);
            ITurtleFinanceTokenPoolBank(pool.bankAddr).destroy(pool.addr);
            pool.bankTotalTakeQuantity = 0;
            pool.bankTotalSaveQuantity = 0;
            if (bankAddr != address(0)) {
                ITurtleFinanceTokenPoolBank newBank = ITurtleFinanceTokenPoolBank(bankAddr);
                require(newBank.mainContractAddress() == address(this), "Bank main contract not this");
                newBank.create(pool.addr);
            }
        }
        pool.bankAddr = bankAddr;
        _tokenPoolBalanceChange(pool.addr);
        emit SetTokenPool(pool.addr, bankAddr, min, exp, max);
    }


    function setLockOperator(bool is_lock) external onlyOwner {
        lockOperator = is_lock;
    }

    function withdrawToken(address token, address payable to, uint256 quantity) external onlyOwner {
        if (token == address(0))
            to.transfer(quantity);
        else
            IERC20(token).safeTransfer(to, quantity);
    }

    function addPair(address pairAddress, address uniswapRouterV2Addr_) external onlyOwner {
        require(!pairs.contains(pairAddress), "repeat add");
        TurtleFinancePairV1 pair = TurtleFinancePairV1(pairAddress);
        require(address(pair.mainContract()) == address(this), "Main address error.");
        if (uniswapRouterV2Addr_ != address(0))
            pair.setUniswapRouterV2Addr(uniswapRouterV2Addr_);
        else
            pair.setUniswapRouterV2Addr(uniswapRouterV2Addr);
        TurtleFinancePairV1.PairInfo memory info = pair.pairInfo();
        _autoCreateTokenPool(info.token0);
        _autoCreateTokenPool(info.token1);
        pairs.add(pairAddress);
        pairsSwapItemIdSEQMap[pairAddress] = pairs.length() * 1E10;
        emit AddPair(pairAddress);
    }

    function pairAddRewardPool(address pairAddress, uint256 totalRewardQuantity, uint256 startTime, uint256 periodTime) onlyOwner external {
        require(pairs.contains(pairAddress), "pair not exists");
        TurtleFinancePairV1 pair = TurtleFinancePairV1(pairAddress);
        pair.rewardAddPool(msg.sender, totalRewardQuantity, startTime, periodTime);
    }

    // --------------- admin functions end -----------------------





    // --------------- to pair functions -----------------------
    function pairSetInfo(address pairAddress, TurtleFinancePairV1.PairInfo calldata form) onlyOperator external {
        require(pairs.contains(pairAddress), "pair not exists");
        TurtleFinancePairV1 pair = TurtleFinancePairV1(pairAddress);
        pair.setPairInfo(form);
    }

    function pairSwap(address pairAddress, uint256 itemId, UniswapRouterV2SwapTokenParams memory swapParams) onlyOperator nonReentrant external {
        require(pairs.contains(pairAddress), "pair not exists");
        TurtleFinancePairV1 pair = TurtleFinancePairV1(pairAddress);
        TurtleFinancePairV1.PairInfo memory info = pair.pairInfo();
        TurtleFinancePairV1.SwapItem memory item = pair.getSwapInfo(itemId);
        require(item.enabled, "SwapItem disabled");
        if (item.holdIdx == 0) {
            uint pathLen = swapParams.path.length;
            require(swapParams.amountIn == item.token0Balance, "swap in amount error");
            require(swapParams.path[0] == info.token0, "swap from token error");
            require(swapParams.path[pathLen - 1] == info.token1, "swap to token error");
            _tokenPoolTransfer(pairAddress, info.token0, item.token0Balance);
        } else {
            uint pathLen = swapParams.path.length;
            require(swapParams.amountIn == item.token1Balance, "swap in amount error");
            require(swapParams.path[0] == info.token1, "swap from token error");
            require(swapParams.path[pathLen - 1] == info.token0, "swap to token error");
            _tokenPoolTransfer(pairAddress, info.token1, item.token1Balance);
        }
        uint256 platformFee = 0;

        bytes memory marketData = _getUniswapSwapFunctionData(swapParams, pairAddress);

        (item, platformFee) = pair.swap(itemId, marketData);

        if (item.holdIdx == 0) {
            if (platformFee > 0) {
                IERC20 et = IERC20(info.token0);
                et.safeTransfer(platformFeeReceiver, platformFee);
            }
            _tokenPoolReceived(info.token0, item.token0Balance);
        } else {
            if (platformFee > 0) {
                IERC20 et = IERC20(info.token1);
                et.safeTransfer(platformFeeReceiver, platformFee);
            }
            _tokenPoolReceived(info.token1, item.token1Balance);
        }
        emit Action(pairAddress, "swap", item.maker, item.id, item.holdIdx, item.token0Balance, item.token1Balance);
    }

    function pairCreate(address pairAddress, address maker, uint256 extId, uint16 holdIdx, uint256 token0Balance, uint256 token1Balance) onlyOperator nonReentrant external {
        require(pairs.contains(pairAddress), "pair not exists");
        TurtleFinancePairV1 pair = TurtleFinancePairV1(pairAddress);
        TurtleFinancePairV1.PairInfo memory info = pair.pairInfo();
        require(info.enabled, "Pair disabled");
        if (holdIdx == 0) {
            require(token0Balance >= info.minToken0, "0 too low");
            require(token0Balance <= info.maxToken0, "0 too high");
            IERC20 et = IERC20(info.token0);
            et.safeTransferFrom(maker, payable(address(this)), token0Balance);
            _tokenPoolReceived(info.token0, token0Balance);
        } else {
            require(token1Balance >= info.minToken1, "1 too low");
            require(token1Balance <= info.maxToken1, "1 too high");
            IERC20 et = IERC20(info.token1);
            et.safeTransferFrom(maker, payable(address(this)), token1Balance);
            _tokenPoolReceived(info.token1, token1Balance);
        }
        pairsSwapItemIdSEQMap[pairAddress] = pairsSwapItemIdSEQMap[pairAddress] + 1;
        uint256 itemId = pairsSwapItemIdSEQMap[pairAddress];
        TurtleFinancePairV1.SwapItem memory item = pair.create(maker, itemId, extId, holdIdx, token0Balance, token1Balance);
        emit Action(pairAddress, "create", item.maker, item.id, item.holdIdx, item.token0Balance, item.token1Balance);
    }

    function pairRemove(address pairAddress, uint256 itemId) onlyNotLocked nonReentrant external {
        require(pairs.contains(pairAddress), "pair not exists");
        TurtleFinancePairV1 pair = TurtleFinancePairV1(pairAddress);
        TurtleFinancePairV1.PairInfo memory info = pair.pairInfo();
        TurtleFinancePairV1.SwapItem memory item = pair.getSwapInfo(itemId);
        require(item.enabled, "not enable");
        require(item.maker == msg.sender, "not maker");
        if (item.holdIdx == 0) {
            _tokenPoolTransfer(msg.sender, info.token0, item.token0Balance);
        } else {
            _tokenPoolTransfer(msg.sender, info.token1, item.token1Balance);
        }
        item = pair.remove(itemId);
        emit Action(pairAddress, "remove", item.maker, item.id, item.holdIdx, item.token0Balance, item.token1Balance);
    }

    function pairRewardEarned() external view returns (uint256){
        uint256 len = pairs.length();
        uint256 earned = 0;
        for (uint256 i = 0; i < len; i++) {
            address pairAddr = pairs.at(i);
            TurtleFinancePairV1 pair = TurtleFinancePairV1(pairAddr);
            uint256 e = pair.rewardEarned(msg.sender);
            earned = earned + e;
        }
        return earned;
    }

    function pairRewardGet() onlyNotLocked nonReentrant external {
        uint256 len = pairs.length();
        for (uint256 i = 0; i < len; i++) {
            address pairAddr = pairs.at(i);
            TurtleFinancePairV1 pair = TurtleFinancePairV1(pairAddr);
            pair.rewardGet(msg.sender);
        }
    }

    function pairRewardGetOfPair(address pairAddr) onlyNotLocked nonReentrant external {
        require(pairs.contains(pairAddr), "pair not exists");
        TurtleFinancePairV1 pair = TurtleFinancePairV1(pairAddr);
        pair.rewardGet(msg.sender);
    }

    // --------------- to pair functions end -----------------------

}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping (uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping (address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor (string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155).interfaceId
            || interfaceId == type(IERC1155MetadataURI).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        _balances[id][from] = fromBalance - amount;
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            _balances[id][from] = fromBalance - amount;
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - If `account` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] += amount;
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `account`
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens of token type `id`.
     */
    function _burn(address account, uint256 id, uint256 amount) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 accountBalance = _balances[id][account];
        require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
        _balances[id][account] = accountBalance - amount;

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 accountBalance = _balances[id][account];
            require(accountBalance >= amount, "ERC1155: burn amount exceeds balance");
            _balances[id][account] = accountBalance - amount;
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        virtual
    { }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {

    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity >0.6.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/ITurtleFinanceTokenPoolBank.sol";
import "./interfaces/ITurtleFinanceMainV1.sol";
import "./interfaces/IERC20Token.sol";

interface ISolo {

    /**
     * @dev Get Pool infos
     * If you want to get the pool's available quota, let "avail = depositCap - accShare"
     */
    function pools(uint256 pid) external view returns (
        address token, // Address of token contract
        uint256 depositCap, // Max deposit amount
        uint256 depositClosed, // Deposit closed
        uint256 lastRewardBlock, // Last block number that reward distributed
        uint256 accRewardPerShare, // Accumulated rewards per share
        uint256 accShare, // Accumulated Share
        uint256 apy, // APY, times 10000
        uint256 used                // How many tokens used for farming
    );

    /**
    * @dev Get pid of given token
    */
    function pidOfToken(address token) external view returns (uint256 pid);

    /**
    * @dev Get User infos
    */
    function users(uint256 pid, address user) external view returns (
        uint256 amount, // Deposited amount of user
        uint256 rewardDebt  // Ignore
    );

    /**
     * @dev Get user unclaimed reward
     */
    function unclaimedReward(uint256 pid, address user) external view returns (uint256 reward);

    /**
     * @dev Get user total claimed reward of all pools
     */
    function userStatistics(address user) external view returns (uint256 claimedReward);

    /**
     * @dev Deposit tokens and Claim rewards
     * If you just want to claim rewards, call function: "deposit(pid, 0)"
     */
    function deposit(uint256 pid, uint256 amount) external;

    /**
     * @dev Withdraw tokens
     */
    function withdraw(uint256 pid, uint256 amount) external;

}

contract BankSoloTop is ITurtleFinanceTokenPoolBank {

    using SafeERC20 for IERC20Token;

    ISolo public solo;
    address public rewardTokenAddr;
    ITurtleFinanceMainV1 public mainContract;

    constructor(address mainAddr_, address solo_, address rewardTokenAddr_) {

        require(mainAddr_ != address(0), "mainAddr_ address cannot be 0");
        require(solo_ != address(0), "solo_ address cannot be 0");
        require(rewardTokenAddr_ != address(0), "rewardTokenAddr_ address cannot be 0");

        solo = ISolo(solo_);
        rewardTokenAddr = rewardTokenAddr_;
        mainContract = ITurtleFinanceMainV1(mainAddr_);
    }

    modifier onlyOwner() {
        bool isOwner = mainContract.owner() == msg.sender;
        require(isOwner, "caller is not the owner");
        _;
    }
    modifier onlyMain() {
        bool isMain = address(mainContract) == msg.sender;
        require(isMain, "caller is not the main");
        _;
    }

    function _pid(address token) private view returns (uint256){
        return solo.pidOfToken(token);
    }

    // ----------------------- public view functions ---------------------
    function getProfit(address token) external view returns (uint256){
        return solo.unclaimedReward(_pid(token), address(this));
    }

    function mainContractAddress() override external view returns (address){
        return address(mainContract);
    }

    function name() override external view returns (string memory){
        IERC20Token tc = IERC20Token(rewardTokenAddr);
        return string(abi.encodePacked("BankSoloTop-", tc.symbol()));
    }
    // ----------------------- end public view functions ---------------------



    // ----------------------- owner functions ---------------------
    function withdrawProfit(address token, address to) onlyOwner external {
        IERC20Token tc = IERC20Token(rewardTokenAddr);
        uint256 beforeQuantity = tc.balanceOf(address(this));
        solo.deposit(_pid(token), 0);
        uint256 quantity = tc.balanceOf(address(this)) - beforeQuantity;
        tc.safeTransfer(to, quantity);
    }

    function withdrawToken(address token, address payable to, uint256 quantity) public onlyOwner {
        if (token == address(0))
            to.transfer(quantity);
        else
            IERC20Token(token).safeTransfer(to, quantity);
    }

    // ----------------------- end owner functions ---------------------



    // ----------------------- main functions ---------------------
    function create(address token) onlyMain override external {

    }

    function balanceOf(address token) onlyMain override external view returns (uint256){
        (uint256 amount,uint256 rewardDebt) = solo.users(_pid(token), address(this));
        return amount;
    }

    function save(address token, uint256 quantity) onlyMain override external {
        IERC20Token(token).approve(address(solo), quantity);
        solo.deposit(_pid(token), quantity);
    }

    function take(address token, uint256 quantity) onlyMain override external {
        solo.withdraw(_pid(token), quantity);
        IERC20Token(token).safeTransfer(address(mainContract), quantity);
    }

    function destroy(address token) onlyMain override external {

    }
    // ----------------------- end main functions ---------------------

}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Token is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/ITurtleFinanceTokenPoolBank.sol";
import "./interfaces/ITurtleFinanceMainV1.sol";

contract BankDefault is ITurtleFinanceTokenPoolBank {

    using SafeERC20 for IERC20;

    ITurtleFinanceMainV1 public mainContract;

    constructor(address mainAddr_) {
        require(mainAddr_ != address(0), "mainAddr_ address cannot be 0");
        mainContract = ITurtleFinanceMainV1(mainAddr_);
    }

    modifier onlyOwner() {
        bool isOwner = mainContract.owner() == msg.sender;
        require(isOwner, "caller is not the owner");
        _;
    }
    modifier onlyMain() {
        bool isMain = address(mainContract) == msg.sender;
        require(isMain, "caller is not the main");
        _;
    }

    function mainContractAddress() override external view returns (address){
        return address(mainContract);
    }

    function name() override external view returns (string memory){
        return "BankDefault";
    }


    function withdrawToken(address token, address payable to, uint256 quantity) public onlyOwner {
        if (token == address(0))
            to.transfer(quantity);
        else
            IERC20(token).safeTransfer(to, quantity);
    }

    function create(address token) onlyMain override external {

    }

    function balanceOf(address token) onlyMain override external view returns (uint256){
        return IERC20(token).balanceOf(address(this));
    }

    function save(address token, uint256 quantity) onlyMain override external {
    }

    function take(address token, uint256 quantity) onlyMain override external {
        IERC20(token).safeTransfer(address(mainContract), quantity);
    }

    function destroy(address token) onlyMain override external {

    }

}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract ERC20Contract is ERC20 {
    constructor(string memory name, string memory symbol, uint256 initialBalance) ERC20(name, symbol) {
        _mint(msg.sender, initialBalance);
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./extensions/IERC721Metadata.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/Strings.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping (uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping (address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : '';
    }

    /**
     * @dev Base URI for computing {tokenURI}. Empty by default, can be overriden
     * in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        private returns (bool)
    {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    // solhint-disable-next-line no-inline-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual { }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {

    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC721.sol";
import "./IERC721Enumerable.sol";

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC721.sol";

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {

    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ERC1155Contract is ERC1155, Ownable {
    constructor (string memory uri_) ERC1155(uri_)  {
    }
}// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


contract ERC721Contract is ERC721, ERC721Enumerable, Ownable {
    constructor (string memory name, string memory symbol) ERC721(name, symbol)  {
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool){
        return super.supportsInterface(interfaceId);
    }
}