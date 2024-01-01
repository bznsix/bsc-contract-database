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
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)

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
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

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
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/IERC721.sol)

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

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
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
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

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
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC721/utils/ERC721Holder.sol)

pragma solidity ^0.8.0;

import "../IERC721Receiver.sol";

/**
 * @dev Implementation of the {IERC721Receiver} interface.
 *
 * Accepts all token transfers.
 * Make sure the contract is able to use its token with {IERC721-safeTransferFrom}, {IERC721-approve} or {IERC721-setApprovalForAll}.
 */
contract ERC721Holder is IERC721Receiver {
    /**
     * @dev See {IERC721Receiver-onERC721Received}.
     *
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

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
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ISwapPair {
    function mint(address to) external returns (uint256 liquidity);
}

interface ISwapRouter {
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface INonfungiblePositionManager is IERC721 {
    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function collect(CollectParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );
}

interface IV3CALC {
    function principal(
        address pool,
        int24 _tickLower,
        int24 _tickUpper,
        uint128 liquidity
    ) external view returns (uint256 amount0, uint256 amount1);
}

contract SwapIntermediateWallet {
    address owner;
    constructor(address _owner) {
        owner = _owner;
    }

    function withdraw(IERC20 token, address to, uint256 amount) external {
        require(msg.sender == owner, "Only owner can withdraw tokens");
        token.transfer(to, amount);
    }
}

interface IWBNB is IERC20 {
}

interface IANTNFT is IERC721Enumerable {
    function receiveBuildingTax() external payable;
    function receiveNodeReward() external payable;
}

interface IANTREWARD {
    function receiveVanguardReward() external payable;
    function receiveHolderReward(uint256 amount) external;
}

contract ANTT is ERC20, ERC721Holder, Ownable {

    struct UserData {
        address referrer;
        uint256 investAmount;
        uint256 marketReserve;
        uint256 remainingEarningsCap;
        uint256 totalInvestAmount;
        uint256 teamInvestAmount;
        uint256 activeReferralsCount;
        uint256 referralNodeHighestInvestAmount;
        uint256 nftDeduction;
        uint256 acceleration;
        uint256 lastActionBlock;
    }

    struct ExchangeRateRecord {
        uint256 exchangeRate;
        uint256 timestamp;
    }

    uint256 public constant BLOCKS_PER_DAY = 28800;
    uint256 public constant MAX_TIER = 50;
    uint256 public constant MIN_REFERRAL_REWARD = 5 ether / 1000;
    uint256 public constant MIN_ACCELERATION = 5 ether / 1000;

    address public nftContract = 0x4DEb791f39a8c98bD6A166A7CB6842FE7b74A300;
    address public rewardContract = 0x2D5Df9dD81dF801Bcd57769cf5512a3F6BEb702f;
    address public deflationOverflowWallet = 0x362F218eE7B404c2EB4ff588d21741bBe2C4c8e8;
    address public contractMaintenanceWallet = 0xA1f1bD33Cf15871cA6FB469f59Ce34e42aE5e8A9;
    address public genesisAnt = 0xeDD355e55E065e42d68Ba541Ed4D8c7acd34F86c;
    address public pairCreator = 0xf668D1B03474dD6c0eE3aE9803Dd001292B59FB4;

    uint256 public priceSupport;
    uint256 public priceSupportMin = 1 ether;
    uint256 public priceSupportMax = 20 ether;

    address public v3PositionCalc = 0x4e2dD79517f62A2a1d2ac046e6b6EB0129655e53;
    address public v3Manage = 0x46A15B0b27311cedF172AB29E4f4766fbE7F4364;
    address public factory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public wbnbusdt = 0x36696169C63e42cd08ce11f5deeBbCeBae652050;
    address public wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public wbnbPair;
    address public usdtPair;
    uint256 public positionTokenId = 364324;

    SwapIntermediateWallet public swapIntermediateWallet;
    SwapIntermediateWallet public swapIntermediateFund;
    address public deadAddr = 0x000000000000000000000000000000000000dEaD;

    mapping(address=>bool) public automatedMarketMakerPairs;
    mapping(address=>mapping(address=>bool)) public invitationSentStatus;
    mapping(address => UserData) public userData;
    mapping(uint256 => ExchangeRateRecord) public exchangeRateRecord;

    uint256 public constant NFT_BATCH_SIZE = 10;
    uint256 public nftAllocatedCount;

    bool public isStarted;

    bool inSwap;
    modifier swapping() {
        inSwap=true;
        _;
        inSwap=false;
    }

    event Started();
    event ReferrerAssigned(address indexed referral, address indexed referrer);
    event NFTClaimed(address indexed addr, uint256 batch, uint256 tokenId);
    event InvestmentStarted(address indexed addr, uint256 value);
    event InvestmentFinalized(address indexed addr);
    event ReferralRewarded(address indexed from, address indexed to, uint256 amount);
    event Accelerated(address indexed from, address indexed to, uint256 amount);
    event EarningsClaimed(address indexed addr, uint256 earnings, uint256 transferTokenAmount);

    constructor() ERC20("AntDAO Token", "ANTT") {
        _mint(address(this), 1889999990 * 10**18);
        _mint(pairCreator, 210000000 * 10**18);
        _mint(0x41061b8bCa768972C83ACbc1c1b2cCEf4D77D7d7, 10 * 10**18);

        (address token0, address token1) = sortTokens(usdt, address(this));
        usdtPair = address(uint160(uint(keccak256(abi.encodePacked(
            hex'ff',
            factory,
            keccak256(abi.encodePacked(token0, token1)),
            hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'
        )))));
        (address token3, address token4) = sortTokens(wbnb, address(this));
        wbnbPair = address(uint160(uint(keccak256(abi.encodePacked(
            hex'ff',
            factory,
            keccak256(abi.encodePacked(token3, token4)),
            hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'
        )))));
        automatedMarketMakerPairs[usdtPair]=true;
        automatedMarketMakerPairs[wbnbPair]=true;

        swapIntermediateWallet = new SwapIntermediateWallet(address(this));
        swapIntermediateFund = new SwapIntermediateWallet(address(this));

        userData[0x41061b8bCa768972C83ACbc1c1b2cCEf4D77D7d7].referrer = genesisAnt;
    }

    receive() external payable {
        address sender = msg.sender;
        uint256 receivedBNB = msg.value;
        processInvestment(sender, receivedBNB);
    }

    function processInvestment(address sender, uint256 receivedBNB) private {
        if (isContract(sender) || (tx.origin != sender)) {
            return;
        }
        require(isStarted, "Contract not yet started");
        require(receivedBNB >= 1 ether, "Minimum investment is 1 BNB");
        UserData storage senderData = userData[sender];
        require(senderData.investAmount == 0, "You have already invested");

        uint256 marketReserve = receivedBNB * 60 / 100;
        uint256 releaseNow = receivedBNB * 12 / 1000;
        senderData.investAmount = receivedBNB;
        senderData.totalInvestAmount += receivedBNB;
        senderData.remainingEarningsCap = receivedBNB * 2;
        senderData.marketReserve = marketReserve - releaseNow;
        senderData.lastActionBlock = block.number;
        
        emit InvestmentStarted(sender, receivedBNB);

        purchaseTokens(releaseNow);

        uint256 totalReferralReward = receivedBNB * 20 / 100;
        uint256 transferredReferralReward = 0;
        address referrer = senderData.referrer;
        if (referrer != address(0)) {
            userData[referrer].activeReferralsCount += 1;

            uint256 referralNodeInvestAmount = senderData.teamInvestAmount + senderData.totalInvestAmount;
            uint256 referralReward = receivedBNB * 10 / 100;
            for (uint256 i = 0; i < MAX_TIER && referrer != address(0); i++) {
                UserData storage referrerData = userData[referrer];
                referrerData.teamInvestAmount += receivedBNB;

                if(referralNodeInvestAmount > referrerData.referralNodeHighestInvestAmount) {
                    referrerData.referralNodeHighestInvestAmount = referralNodeInvestAmount;
                }

                uint256 requiredActiveReferrals = i + 1;
                if(requiredActiveReferrals > 10) {
                    requiredActiveReferrals = 10;
                }
                if(referralReward >= MIN_REFERRAL_REWARD && referrerData.remainingEarningsCap != 0 && requiredActiveReferrals <= referrerData.activeReferralsCount) {
                    if(referralReward >= referrerData.remainingEarningsCap) {
                        uint256 actualTransfer = referrerData.remainingEarningsCap;
                        payable(referrer).transfer(actualTransfer);
                        transferredReferralReward += actualTransfer;
                        emit ReferralRewarded(sender, referrer, actualTransfer);
                        finalizeInvestment(referrer);
                    } else {
                        payable(referrer).transfer(referralReward);
                        referrerData.remainingEarningsCap -= referralReward;
                        transferredReferralReward += referralReward;
                        emit ReferralRewarded(sender, referrer, referralReward);
                    }
                }

                referrer = referrerData.referrer;
                referralNodeInvestAmount = referrerData.teamInvestAmount + referrerData.totalInvestAmount;
                referralReward /= 2;
            }
        }
        uint256 remainingReferralReward = totalReferralReward - transferredReferralReward;
        if(remainingReferralReward != 0) {
            if(contractMaintenanceWallet.balance < 1 ether) {
                uint256 shortfall = 1 ether - contractMaintenanceWallet.balance;
                uint256 amountToSend = shortfall > remainingReferralReward ? remainingReferralReward : shortfall;
                payable(contractMaintenanceWallet).transfer(amountToSend);
                remainingReferralReward -= amountToSend;
            }
            priceSupport += remainingReferralReward;
        }

        IANTNFT(nftContract).receiveBuildingTax{value:receivedBNB * 10 / 100}();
        IANTNFT(nftContract).receiveNodeReward{value:receivedBNB * 8 / 100}();
        IANTREWARD(rewardContract).receiveVanguardReward{value:receivedBNB * 2 / 100}();

        increaseMarketReserve();

        if(balanceOf(address(this)) >= 1e13) {
            super._transfer(address(this), sender, 1e13);
        }
    }

    function finalizeInvestment(address addr) private {
        UserData storage addrData = userData[addr];
        uint256 marketReserve = addrData.marketReserve;
        addrData.marketReserve = 0;
        addrData.investAmount = 0;
        addrData.remainingEarningsCap = 0;
        addrData.acceleration = 0;

        address referrer = addrData.referrer;
        if (referrer != address(0)) {
            UserData storage referrerData = userData[referrer];
            if(referrerData.activeReferralsCount > 0) {
                referrerData.activeReferralsCount -= 1;
            }
        }

        if(marketReserve != 0) {
            purchaseTokensFromReserve(marketReserve);
        }

        emit InvestmentFinalized(addr);
    }

    function receivePriceSupport() external payable {
        priceSupport += msg.value;
        increaseMarketReserve();
    }

    function currentNFTBatch() public view returns(uint256) {
        return nftAllocatedCount / NFT_BATCH_SIZE + 1;
    }

    function currentNFTPerformanceThreshold() public view returns(uint256) { 
        return currentNFTPerformanceThreshold(nftAllocatedCount);
    }

    function currentNFTPerformanceThreshold(uint256 _nftAllocatedCount) private pure returns (uint256){
        uint256 nftPerformanceLevel = _nftAllocatedCount / NFT_BATCH_SIZE;
        if(nftPerformanceLevel > 14) {
            nftPerformanceLevel = 14;
        }
        return 100 ether * (12 ** nftPerformanceLevel) / (10 ** nftPerformanceLevel);
    }

    function checkNftEligibility(address addr) external view returns(bool) {
        UserData memory addrData = userData[addr];
        return addrData.teamInvestAmount - addrData.referralNodeHighestInvestAmount - addrData.nftDeduction >= currentNFTPerformanceThreshold();
    }

    function claimNFT() external returns (bool, uint256){
        address addr = msg.sender;
        UserData storage addrData = userData[addr];
        uint256 performanceThreshold = currentNFTPerformanceThreshold();
        require(addrData.teamInvestAmount - addrData.referralNodeHighestInvestAmount - addrData.nftDeduction >= performanceThreshold, "Rejected");
        
        IANTNFT contractInterface = IANTNFT(nftContract);
        uint256 nftCount = contractInterface.balanceOf(address(this));
        if(nftCount != 0) {
            uint256 batch = currentNFTBatch();
            uint256 nftTokenId = contractInterface.tokenOfOwnerByIndex(address(this), 0);
            contractInterface.safeTransferFrom(address(this), addr, nftTokenId);

            nftAllocatedCount += 1;
            addrData.nftDeduction += performanceThreshold;

            emit NFTClaimed(addr, batch, nftTokenId);

            return (true, nftTokenId);
        } else {
            return (false, 0);
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != to, "Transfer to the same address is not allowed");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (inSwap || ((from == pairCreator || to == pairCreator) && owner() != address(0))) {
            super._transfer(from, to, amount);
            return;
        }

        if(automatedMarketMakerPairs[from]) {
            revert("Buying Not Allowed");
        } else if(automatedMarketMakerPairs[to]) {
            sellTokens(from, to, amount);
            checkPrice();
        } else if (to == address(this)) {
            claimEarnings(from, amount);
        } else {
            super._transfer(from, to, amount);
            if (from != genesisAnt && to != genesisAnt && !isContract(from) && !isContract(to)) {
                transferBetweenUsers(from, to);
            }
        }
    }

    function sellTokens(address from, address to, uint256 amount) private swapping {
        uint256 liquidityCapitalAmount = amount * 20 / 100;
        uint256 holderRewardAmount = amount * 2 / 100;
        uint256 tradingTaxAmount = amount * 3 / 100;
        uint256 tokenBurningAmount = amount * 5 / 100;
        uint256 slippage = liquidityCapitalAmount + holderRewardAmount + tradingTaxAmount + tokenBurningAmount;
        super._transfer(from, address(swapIntermediateFund), slippage);
        super._transfer(address(swapIntermediateFund), address(this), balanceOf(address(swapIntermediateFund)));

        super._transfer(address(this), rewardContract, holderRewardAmount);
        IANTREWARD(rewardContract).receiveHolderReward(holderRewardAmount);

        super._transfer(address(this), nftContract, tradingTaxAmount);

        burnTokens(tokenBurningAmount);

        _approve(address(this), router, liquidityCapitalAmount/2);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = wbnb;
        ISwapRouter(router).swapExactTokensForTokens(liquidityCapitalAmount/2, 0, path, address(swapIntermediateWallet), block.timestamp + 1000);
        uint256 addWBNBLiquidity = IWBNB(wbnb).balanceOf(address(swapIntermediateWallet));
        swapIntermediateWallet.withdraw(IWBNB(wbnb), address(this), addWBNBLiquidity);

        uint256 addTokenLiquidity = liquidityCapitalAmount - liquidityCapitalAmount/2;

        IWBNB(wbnb).transfer(wbnbPair, addWBNBLiquidity);
        super._transfer(address(this), wbnbPair, addTokenLiquidity);
        ISwapPair(wbnbPair).mint(contractMaintenanceWallet);

        super._transfer(from, to, amount - slippage);
    }

    function claimEarnings(address from, uint256 amount) private {
        address sender = msg.sender;
        require(sender == from && sender == tx.origin, "Only direct token owner operations allowed");

        UserData storage fromUser = userData[from];
        uint256 investAmount = fromUser.investAmount;
        uint256 lastActionBlock = fromUser.lastActionBlock;
        require(investAmount > 0, "Investment amount must be greater than zero");
        require(lastActionBlock != 0 && lastActionBlock + BLOCKS_PER_DAY <= block.number, "Cannot claim earnings yet");

        super._transfer(from, address(this), amount);
        burnTokens(amount);

        uint256 daysElapsed = (block.number - lastActionBlock) / BLOCKS_PER_DAY;

        if(fromUser.marketReserve != 0) {
            uint256 releaseNow = investAmount * 12 / 1000 * daysElapsed;
            if(releaseNow > fromUser.marketReserve){
                releaseNow = fromUser.marketReserve;
            }
            purchaseTokensFromReserve(releaseNow);
            fromUser.marketReserve -= releaseNow;
        }

        uint256 earnings = investAmount / 100 * daysElapsed;
        address referrer = fromUser.referrer;
        if (referrer != address(0)) {
            uint256 acceleration = earnings * 20 / 100;
            for (uint256 i = 0; i < MAX_TIER && acceleration >= MIN_ACCELERATION && referrer != address(0); i++) {
                UserData storage referrerData = userData[referrer];
                if(referrerData.investAmount != 0) {
                    referrerData.acceleration += acceleration;
                    emit Accelerated(from, referrer, acceleration);
                }

                referrer = referrerData.referrer;
                acceleration = acceleration*2/3;
            }
        }

        if(fromUser.acceleration != 0) {
            earnings += fromUser.acceleration;
            fromUser.acceleration = 0;
        }
        
        if(earnings > fromUser.remainingEarningsCap) {
            earnings = fromUser.remainingEarningsCap;
        }
        uint256 transferTokenAmount = getAmountsOut(earnings);
        super._transfer(address(this), from, transferTokenAmount);
        emit EarningsClaimed(from, earnings, transferTokenAmount);
        fromUser.lastActionBlock = block.number;
        if(earnings < fromUser.remainingEarningsCap) {
            fromUser.remainingEarningsCap -= earnings;
        } else {
            finalizeInvestment(from);
        }
    }

    function transferBetweenUsers(address from, address to) private {
        UserData memory fromUser = userData[from];
        UserData memory toUser = userData[to];
        if(fromUser.referrer != address(0) && toUser.referrer == address(0)) {
            invitationSentStatus[from][to] = true;
        } else if(fromUser.referrer == address(0) && toUser.referrer != address(0) && invitationSentStatus[to][from]) {
            userData[from].referrer = to;
            if(fromUser.investAmount != 0) {
                userData[to].activeReferralsCount += 1;
            }
            invitationSentStatus[to][from] = false;
            emit ReferrerAssigned(from, to);
        }
    }

    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function burnTokens(uint256 amount) private {
        uint256 _totalSupply = totalSupply();
        uint256 _burned = balanceOf(deadAddr);
        if(_totalSupply - _burned - amount >= _totalSupply / 100) {
            super._transfer(address(this), deadAddr, amount);
        } else if(_totalSupply - _burned <= _totalSupply / 100) {
            super._transfer(address(this), deflationOverflowWallet, amount);
        } else {
            uint256 shortfall = _totalSupply - _burned - _totalSupply / 100;
            super._transfer(address(this), deadAddr, shortfall);
            super._transfer(address(this), deflationOverflowWallet, amount - shortfall);
        }
    }

    function increaseMarketReserve() private {
        uint256 balanceOfContract = address(this).balance;
        if(balanceOfContract > 0) {
            (uint128 lpAmount,,uint256 amount1) = INonfungiblePositionManager(v3Manage).increaseLiquidity{value: balanceOfContract}(INonfungiblePositionManager.IncreaseLiquidityParams({
                tokenId:positionTokenId,
                amount0Desired:0,
                amount1Desired:balanceOfContract,
                amount0Min:0,
                amount1Min:balanceOfContract,
                deadline:block.timestamp+1000
            }));
            require(lpAmount > 0 && amount1 == balanceOfContract, "DepositV3 Error");
        }
    }

    function purchaseTokens(uint256 bnbAmount) private swapping {
        address[] memory path = new address[](2);
        path[0] = wbnb;
        path[1] = address(this);

        ISwapRouter(router).swapExactETHForTokens{value: bnbAmount}(0, path, address(swapIntermediateWallet), block.timestamp + 1000);
        uint256 tokenAmount = balanceOf(address(swapIntermediateWallet));
        super._transfer(address(swapIntermediateWallet), address(this), tokenAmount);
    }

    function purchaseTokensFromReserve(uint256 bnbAmount) private swapping {
        (,,,,,int24 tickLower,int24 tickUpper,uint128 liquidity,,,,) = INonfungiblePositionManager(v3Manage).positions(positionTokenId);
        require(liquidity > 0, "Zero liquidity");

        (,uint256 balanceOfWBNB) = IV3CALC(v3PositionCalc).principal(wbnbusdt, tickLower, tickUpper, liquidity);
        require(balanceOfWBNB >= bnbAmount, "Insufficient BNB balance");

        uint256 calcRes = (bnbAmount * liquidity) / balanceOfWBNB;
        uint128 deLpAmunt = uint128(calcRes) + 1;
        if (deLpAmunt > liquidity) {
            deLpAmunt = liquidity;
        }
        (, uint256 wbnbAmount) = INonfungiblePositionManager(v3Manage)
            .decreaseLiquidity(
                INonfungiblePositionManager.DecreaseLiquidityParams({
                    tokenId: positionTokenId,
                    liquidity: deLpAmunt,
                    amount0Min: 0,
                    amount1Min: 0,
                    deadline: block.timestamp + 1000
                })
            );
        require(wbnbAmount > 0, "No tokens returned from liquidity decrease");
        INonfungiblePositionManager(v3Manage).collect(
            INonfungiblePositionManager.CollectParams({
                tokenId: positionTokenId,
                recipient: address(this),
                amount0Max: 340282366920938463463374607431768211455,
                amount1Max: 340282366920938463463374607431768211455
            })
        );

        IERC20(wbnb).approve(router, wbnbAmount);
        address[] memory path = new address[](2);
        path[0] = wbnb;
        path[1] = address(this);
        ISwapRouter(router).swapExactTokensForTokens(wbnbAmount, 0, path, address(swapIntermediateWallet), block.timestamp + 1000);
        uint256 tokenAmount = balanceOf(address(swapIntermediateWallet));
        super._transfer(address(swapIntermediateWallet), address(this), tokenAmount);
    }

    function checkPrice() private {
        uint256 midnight = block.timestamp / 1 days * 1 days;
        uint256 currentHour = (block.timestamp - midnight) / 1 hours;
        uint256 currentHourStartTimestamp = midnight + currentHour * 1 hours;
        ExchangeRateRecord storage record = exchangeRateRecord[currentHour];
        if(record.timestamp != currentHourStartTimestamp) {
            uint256 historicalExchangeRate = 0;
            if(record.timestamp == currentHourStartTimestamp - 1 days) {
                historicalExchangeRate = record.exchangeRate;
            } else {
                for(uint8 i = 1; i <= 4; ++i) {
                    uint256 h = (currentHour + i) % 24;
                    ExchangeRateRecord memory r = exchangeRateRecord[h];
                    if(r.timestamp == currentHourStartTimestamp - 1 days + (1 hours * i)) {
                        historicalExchangeRate = r.exchangeRate;
                        break;
                    }
                }
            }
            if(historicalExchangeRate != 0) {
                record.exchangeRate = comparePrice(historicalExchangeRate);
            } else {
                record.exchangeRate = getAmountsOut(1 ether);
            }
            record.timestamp = currentHourStartTimestamp;
        }
    }

    function comparePrice(uint256 historicalExchangeRate) private returns(uint256) {
        uint256 currentExchangeRate = getAmountsOut(1 ether);
        if(currentExchangeRate > historicalExchangeRate) {
            if(100 - historicalExchangeRate*100/currentExchangeRate >= 20) {
                if(stabilizePrice()) {
                    currentExchangeRate = getAmountsOut(1 ether);
                }
            }
        }
        return currentExchangeRate;
    }

    function stabilizePrice() private returns(bool) {
        uint256 _priceSupport = priceSupport;
        uint256 _priceSupportMin = priceSupportMin;
        uint256 _priceSupportMax = priceSupportMax;
        if(_priceSupport != 0) {
            uint256 amount = 0;
            if(_priceSupport <= _priceSupportMin) {
                amount = _priceSupport;
            } else {
                amount = _priceSupport / 5;
                if(amount < _priceSupportMin) {
                    amount = _priceSupportMin;
                } else if(amount > _priceSupportMax && _priceSupportMax > _priceSupportMin) {
                    amount = _priceSupportMax;
                }
            }
            purchaseTokensFromReserve(amount);
            priceSupport -= amount;
            return true;
        }
        return false;
    }

    function getAmountsOut(uint256 bnbAmount) private view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = wbnb;
        path[1] = address(this);
        uint256[] memory amounts = ISwapRouter(router).getAmountsOut(bnbAmount, path);
        return amounts[1];
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "PancakeLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "PancakeLibrary: ZERO_ADDRESS");
    }

    function start() external onlyOwner {
        require(!isStarted, "Contract has already been started");
        isStarted = true;
        emit Started();
    }

    function transferPositionToken(address to) external onlyOwner {
        INonfungiblePositionManager(v3Manage).transferFrom(address(this), to, positionTokenId);
    }
}
