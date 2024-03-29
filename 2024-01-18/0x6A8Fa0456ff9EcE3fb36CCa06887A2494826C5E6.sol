// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
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
pragma solidity 0.8.19;

import "./ERC20Modified.sol";

contract ERC20Freezable is ERC20Modified {

    mapping(bytes32 => uint64) internal chains;
    mapping(bytes32 => uint) internal freezings;
    mapping(address => uint) internal freezingBalance;

    event Freezed(address indexed to, uint64 release, uint amount);
    event Released(address indexed account, uint amount);

    constructor(string memory name, string memory ticker) ERC20Modified(name, ticker) {}

    /**
     * @notice function to release all available tokens 
     * @return amount released tokens amount
     */
    function releaseAll() external returns(uint amount) {
        (uint _release, uint _balance) = getFreezing(msg.sender, 0);

        while(_release != 0 && block.timestamp > _release){
            releaseOnce();
            amount += _balance;
            (_release, _balance) = getFreezing(msg.sender, 0);
        }
    }

    /**
     * @notice function to transfer tokens with freeze period 
     * @param to tokens receiver
     * @param amount transfer amount
     * @param until freeze until timestamp
     */
    function freezeTo(address to, uint amount, uint64 until) public virtual {
        require(to != address(0), "ERC20Freezable: to zero address");
        require(_balances[msg.sender] >= amount, "ERC20Freezable: invalid balance");

        _balances[msg.sender] = _balances[msg.sender] - amount;

        bytes32 _currentKey = toKey(to, until);
        freezings[_currentKey] = freezings[_currentKey] + amount;
        freezingBalance[to] = freezingBalance[to] + amount;

        freeze(to, until);

        emit Transfer(msg.sender, to, amount);
        emit Freezed(to, until, amount);
    }

    /**
     * @notice function to release one timestamp available tokens 
     */
    function releaseOnce() public {
        bytes32 _headKey = toKey(msg.sender, 0);
        uint64 _head = chains[_headKey];

        require(_head != 0, "ERC20Freezable: frozen tokens absent");
        require(uint64(block.timestamp) > _head, "ERC20Freezable: too soon to unfreeze");

        bytes32 _currentKey = toKey(msg.sender, _head);
        (uint64 _next, uint _amount) = (chains[_currentKey], freezings[_currentKey]);

        delete freezings[_currentKey];

        _balances[msg.sender] = _balances[msg.sender] + _amount;
        freezingBalance[msg.sender] = freezingBalance[msg.sender] - _amount;

        if(_next == 0){
            delete chains[_headKey];
        } else {
            chains[_headKey] = _next;
            delete chains[_currentKey];
        }

        emit Released(msg.sender, _amount);
    }

    /**
     * @notice view function to get actual account's balance + freezingBalance  
     */
    function balanceOf(address account) public view override returns(uint256 balance) {
        return super.balanceOf(account) + freezingBalance[account];
    }

    /**
     * @notice view function to get actual account's balance  
     */
    function actualBalanceOf(address account) public view returns(uint256 balance) {
        return super.balanceOf(account);
    }

    /**
     * @notice view function to get actual account's freezingBalance  
     */
    function freezingBalanceOf(address account) public view returns(uint256 balance) {
        return freezingBalance[account];
    }

    /**
     * @notice view function to get number of timestamps with frozen tokens  
     */
    function freezingCount(address account) public view returns(uint count) {
        uint64 _release = chains[toKey(account, 0)];
        while(_release != 0){
            count++;
            _release = chains[toKey(account, _release)];
        }
    }

    /**
     * @notice view function to get data of frozen tokens by index  
     */
    function getFreezing(address account, uint index) public view returns(uint64 release, uint balance) {
        for(uint i; index + 1 > i; i++){
            release = chains[toKey(account, release)];
            if(release == 0) return (release, balance);
        }
        balance = freezings[toKey(account, release)];
    }

    function toKey(address account, uint release) internal pure returns(bytes32 result) {
        result = 0x5749534800000000000000000000000000000000000000000000000000000000;
        assembly {
            result := or(result, mul(account, 0x10000000000000000))
            result := or(result, and(release, 0xffffffffffffffff))
        }
    }

    function freeze(address to, uint64 until) internal {
        require(until > block.timestamp, "ERC20Freezable: invalid timestamp");

        (bytes32 _key, bytes32 _parentKey) = (toKey(to, until), toKey(to, uint64(0)));
        uint64 _next = chains[_parentKey];

        if(_next == 0){
            chains[_parentKey] = until;
            return;
        }

        bytes32 _nextKey = toKey(to, _next);

        while(_next != 0 && until > _next){
            _parentKey = _nextKey;
            _next = chains[_nextKey];
            _nextKey = toKey(to, _next);
        }

        if(until == _next) return;

        if(_next != 0) chains[_key] = _next;

        chains[_parentKey] = until;
    }
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)
// Modified

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
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
contract ERC20Modified is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
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
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./libraries/ERC20Freezable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MoonSeenRoseToken is ERC20Freezable, Ownable {

    uint public constant MINT_UNLOCKED_TIMESTAMP = 1709251200;

    uint public swapBlockDuration;

    address public farmingAddress;

    mapping(address => bool) public blacklisted;
    mapping(address => uint) public swapBlockTimestamp;

    event Blacklisted(address account, uint amount, uint time);
    event Unblacklisted(address account, uint amount, uint time);

    constructor(
        address owner, 
        address recevier, 
        uint amountToMint,
        uint newSwapBlockDuration
    ) ERC20Freezable("Moonseenrose Token", "MSRT") {
        transferOwnership(owner);
        _mint(recevier, amountToMint);
        swapBlockDuration = newSwapBlockDuration;
    }

    /**
     * @notice function to set {farmingAddress}
     * @param newFarmingAddress new {farmingAddress} address
     * @notice only {owner} available
     */
    function setFarmingAddress(address newFarmingAddress) external onlyOwner() {
        require(block.timestamp >= MINT_UNLOCKED_TIMESTAMP, "MoonSeenRoseToken: too soon");
        farmingAddress = newFarmingAddress;
    }

    /**
     * @notice function to blacklist {account}
     * @param account user address
     * @notice only {owner} available
     */
    function blacklist(address account) external onlyOwner() {
        require(!blacklisted[account], "MoonSeenRoseToken: target blacklisted");
        blacklisted[account] = true; 

        emit Blacklisted(account, balanceOf(account), block.timestamp);
    }

    /**
     * @notice function to unblacklist {account}
     * @param account user address
     * @notice only {owner} available
     */
    function unblacklist(address account) external onlyOwner() {
        require(blacklisted[account], "MoonSeenRoseToken: target is not blacklisted");
        delete blacklisted[account];

        emit Unblacklisted(account, balanceOf(account), block.timestamp);
    }

    /**
     * @notice function to set {swapBlockDuration}
     * @param newSwapBlockDuration new {swapBlockDuration} value
     * @notice only {owner} available
     */
    function setSwapBlockDuration(uint newSwapBlockDuration) external onlyOwner() {
        swapBlockDuration = newSwapBlockDuration;
    }

    /**
     * @notice function to set {swapBlockTimestamp} to exact {target} address
     * @param target address
     * @param swapUnlockTimestamp new {swapBlockTimestamp} value for {target}
     * @notice only {owner} available
     */
    function setSwapUnlockTimestamp(address target, uint swapUnlockTimestamp) external onlyOwner() {
        swapBlockTimestamp[target] = swapUnlockTimestamp;
    }

    /**
     * @notice function to mint {MSRT} tokens 
     * @param amount {MSRT} tokens amount to mint
     * @notice only {farmingAddress} available
     */
    function mint(uint amount) external {
        require(msg.sender == farmingAddress, "MoonSeenRoseToken: forbidden");
        _mint(farmingAddress, amount);
    }

    /**
     * @notice function to transfer tokens with freeze period 
     * @param to tokens receiver
     * @param amount transfer amount
     * @param until freeze until timestamp
     */
    function freezeTo(address to, uint amount, uint64 until) public override {
        _beforeTokenTransfer(msg.sender, to, amount);
        super.freezeTo(to, amount, until);
    }

    function _beforeTokenTransfer(address from, address to, uint /*amount*/) internal override {
        require(!blacklisted[msg.sender] && !blacklisted[from] && !blacklisted[to], "MoonSeenRoseToken: blacklisted");
        require(block.timestamp >= swapBlockTimestamp[to] && block.timestamp >= swapBlockTimestamp[from], "MoonSeenRoseToken: temporally blocked");

        bool success; 
        bytes memory response;
        
        if(swapBlockTimestamp[to] == 0){
            (success, response) = to.staticcall(abi.encodeWithSignature("token0()"));
            if(success && response.length > 0) if(abi.decode(response, (address)) == address(this)) swapBlockTimestamp[to] = block.timestamp + swapBlockDuration;
            (success, response) = to.staticcall(abi.encodeWithSignature("token1()"));
            if(success && response.length > 0) if(abi.decode(response, (address)) == address(this)) swapBlockTimestamp[to] = block.timestamp + swapBlockDuration;
        }

        if(swapBlockTimestamp[from] == 0){
            (success, response) = from.staticcall(abi.encodeWithSignature("token0()"));
            if(success && response.length > 0) if(abi.decode(response, (address)) == address(this)) swapBlockTimestamp[from] = block.timestamp + swapBlockDuration;
            (success, response) = from.staticcall(abi.encodeWithSignature("token1()"));
            if(success && response.length > 0) if(abi.decode(response, (address)) == address(this)) swapBlockTimestamp[from] = block.timestamp + swapBlockDuration;
        }
    }
}