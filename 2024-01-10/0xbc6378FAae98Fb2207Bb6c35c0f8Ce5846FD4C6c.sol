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
// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract _8BitToken is Ownable, ERC20 {
    struct Locked {
        uint256 rAmount;
        uint256 rate;
        uint256 time;
    }

    struct Fee {
        uint256 refFee;
        uint256 buybackFee;
        uint256 devFee;
        uint256 marketingFee;
    }

    struct valuesFromGetValues {
        uint256 rAmount;
        uint256 rTransferAmount;
        uint256 tTransferAmount;
        uint256 rRfi;
        uint256 tRfi;
        uint256 tFee;
        uint256 rFee;
    }

    //Token configuration
    string private constant _name = "8Bit Chain";
    string private constant _symbol = "w8Bit";
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public immutable pair;
    IRouter public immutable swapRouter;
    uint8 private constant _decimals = 18;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal = 140_000_000 * 10 ** _decimals;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    address public immutable underlying = address(0);
    address public bridge;

    //Limits
    uint256 public cooldown = 3600; //1 minute sell cooldown
    bool public transferCooldown;
    uint256 public maxWallet = _tTotal; //2% max wallet
    mapping(address => Locked[]) public lockedTokens;
    mapping(address => uint256) public lastUnlock;
    bool public tradingEnabled;

    //Exclude
    mapping(address => bool) public _isExcludedFromBuyFee;
    mapping(address => bool) public _isExcludedFromSellFee;
    mapping(address => bool) public _isExcludedFromFee;
    mapping(address => bool) public _isExcluded;
    mapping(address => bool) public _isExcludedFromCooldown;
    mapping(address => bool) public _isExcludedFromMaxWallet;
    address[] private _excluded;

    //NFTs, NFT holders can be excluded form buy fees
    mapping(address => bool) public isSupportedNFT;
    mapping(address => bool) public disallowedNFTHolder;

    //Fees
    Fee public buyFee = Fee(2, 2, 2, 2);
    Fee public sellFee = Fee(2, 2, 2, 2);
    Fee public transferFee = Fee(0, 0, 0, 0);
    uint256 public totalBuyFees = 8;
    uint256 public totalSellFees = 8;
    uint256 public totalTransferFees = 0;
    address public marketingWallet;
    address public devWallet;
    address public buybackWallet;
    uint256 public totalRewardsReflected;
    bool public swapping = false;
    uint256 public swapThreshold = _tTotal / 10000;

    modifier inSwapFlag() {
        swapping = true;
        _;
        swapping = false;
    }

    modifier onlyBridge() {
        require(msg.sender == bridge, "Only bridge");
        _;
        swapping = false;
    }

    event FeesChanged();
    event Reflected(uint256 amount);

    constructor() ERC20(_name, _symbol) {
        swapRouter = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        pair = IFactory(swapRouter.factory()).createPair(
            address(this),
            swapRouter.WETH()
        );

        excludeFromReward(address(this));
        excludeFromReward(address(pair));

        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[owner()] = true;

        _isExcludedFromMaxWallet[address(this)] = true;
        _isExcludedFromMaxWallet[owner()] = true;

        _isExcludedFromCooldown[address(this)] = true;
        _isExcludedFromCooldown[owner()] = true;
        _isExcludedFromCooldown[pair] = true;

        _rOwned[msg.sender] = _rTotal;
        _tOwned[msg.sender] = _tTotal;
        emit Transfer(address(0), owner(), _tTotal);
    }

    receive() external payable {}

    fallback() external payable {}

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function isContract(address _addr) public view returns (bool isContract) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function updateMarketingWallet(address marketing) public onlyOwner {
        marketingWallet = marketing;
    }

    function updateDevWallet(address developer) public onlyOwner {
        devWallet = developer;
    }

    function updateBuyBackWallet(address buyBack) public onlyOwner {
        buybackWallet = buyBack;
    }

    function reflectionFromToken(
        uint256 tAmount,
        bool deductTransferRfi
    ) public view returns (uint256) {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferRfi) {
            valuesFromGetValues memory s = _getValues(
                tAmount,
                true,
                address(0),
                address(0)
            );
            return s.rAmount;
        } else {
            valuesFromGetValues memory s = _getValues(
                tAmount,
                true,
                address(0),
                address(0)
            );
            return s.rTransferAmount;
        }
    }

    function tokenFromReflection(
        uint256 rAmount
    ) public view returns (uint256) {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    //costumized to be compatible with locking system
    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
            _resetAccountLocked(account, false);
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
        //rate would be significantly different after including an account into rewards, hence we have to reset the locked amounts
        _resetAccountLocked(account, false);
    }

    function resetAccountLocked(address account, bool locked) public onlyOwner {
        _resetAccountLocked(account, locked);
    }

    function _resetAccountLocked(address account, bool locked) internal {
        delete lockedTokens[account];
        lastUnlock[account] = 0;
        lockedTokens[account].push(
            Locked({
                time: locked ? block.timestamp : 0,
                rAmount: _rOwned[account],
                rate: _getRate()
            })
        );
    }

    function updateSwapThreshold(uint256 newAmount) public onlyOwner {
        require(
            newAmount <= _tTotal / 100,
            "swap threshold not in range [0 - suppy / 100]"
        );
        swapThreshold = newAmount;
    }

    function setExcludedFromMaxWallet(
        address target,
        bool status
    ) public onlyOwner {
        _isExcludedFromMaxWallet[target] = status;
    }

    function setExcludedFromCooldown(
        address target,
        bool status
    ) public onlyOwner {
        if (!status) {
            require(target != pair, "can't include pair in coodown");
        }
        _isExcludedFromCooldown[target] = status;
        delete lockedTokens[target];
        lastUnlock[target] = 0;
        if (!status) {
            lockedTokens[target].push(
                Locked({
                    time: block.timestamp,
                    rAmount: _rOwned[target],
                    rate: _getRate()
                })
            );
        }
    }

    function setExcludedFromAllFees(
        address target,
        bool status
    ) public onlyOwner {
        _isExcludedFromFee[target] = status;
    }

    function setExcludedFromBuyFees(
        address target,
        bool status
    ) public onlyOwner {
        _isExcludedFromBuyFee[target] = status;
    }

    function setExcludedFromSelFees(
        address target,
        bool status
    ) public onlyOwner {
        _isExcludedFromSellFee[target] = status;
    }

    function setIsSupportedNFT(
        address nftContract,
        bool status
    ) public onlyOwner {
        isSupportedNFT[nftContract] = status;
    }

    function excludeNFTHolderFromBuyFees(address nftContract) public {
        require(isSupportedNFT[nftContract], "NFT contract not supported");
        require(
            IERC721(nftContract).balanceOf(msg.sender) != 0,
            "You are not holding any NFT of this type"
        );
        require(
            !disallowedNFTHolder[msg.sender],
            "your privilege has been taken away by owner"
        );
        _isExcludedFromBuyFee[msg.sender] = true;
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Cannot re-enable trading");
        tradingEnabled = true;
    }

    function toggleCooldownOnTransfers(bool status) external onlyOwner {
        transferCooldown = status;
    }

    function updateBuyFee(
        uint256 devFee,
        uint256 marketingFee,
        uint256 refFee,
        uint256 buyBackFee
    ) public onlyOwner {
        totalBuyFees = devFee + marketingFee + refFee + buyBackFee;
        require(totalBuyFees <= 8, "can't set fees over 8%");
        buyFee = Fee(refFee, buyBackFee, devFee, marketingFee);
    }

    function updateSellFee(
        uint256 devFee,
        uint256 marketingFee,
        uint256 refFee,
        uint256 buyBackFee
    ) public onlyOwner {
        totalSellFees = devFee + marketingFee + refFee + buyBackFee;
        require(totalSellFees <= 8, "can't set fees over 8%");
        sellFee = Fee(refFee, buyBackFee, devFee, marketingFee);
    }

    function updateTransferFee(
        uint256 devFee,
        uint256 marketingFee,
        uint256 refFee,
        uint256 buyBackFee
    ) public onlyOwner {
        totalTransferFees = devFee + marketingFee + refFee + buyBackFee;
        require(totalTransferFees <= 8, "can't set fees over 8%");
        transferFee = Fee(refFee, buyBackFee, devFee, marketingFee);
    }

    function updateCooldown(uint256 newCooldown) public onlyOwner {
        require(newCooldown <= 12 hours, "Can not set cooldown over 12 hours");
        cooldown = newCooldown;
    }

    function updateMaxWallet(uint256 newMaxWallet) public onlyOwner {
        require(
            newMaxWallet >= totalSupply() / 1000,
            "Can not max wallet lower than 0.1% of supply"
        );
        maxWallet = newMaxWallet;
    }

    function setBridge(address _bridge) public onlyOwner {
        require(bridge == address(0));
        require(isContract(_bridge), "Bridge can only be a contract");
        bridge = _bridge;
    }

    function unprivilegeNFTHolder(
        address nftHolder,
        bool yesno
    ) public onlyOwner {
        disallowedNFTHolder[nftHolder] = yesno;
        if (yesno) {
            _isExcludedFromBuyFee[nftHolder] = false;
        }
    }

    function _reflectRfi(uint256 rRfi, uint256 tRfi) internal {
        _rTotal -= rRfi;
        totalRewardsReflected += tRfi;
        emit Reflected(tRfi);
    }

    function _takeFee(address sender, uint256 rFee, uint256 tFee) internal {
        if (_isExcluded[address(this)]) {
            _tOwned[address(this)] += tFee;
        }
        _rOwned[address(this)] += rFee;
        emit Transfer(sender, address(this), tFee);
    }

    function _getValues(
        uint256 tAmount,
        bool takeFee,
        address from,
        address to
    ) private view returns (valuesFromGetValues memory to_return) {
        to_return = _getTValues(tAmount, takeFee, from, to);
        (
            to_return.rAmount,
            to_return.rTransferAmount,
            to_return.rRfi,
            to_return.rFee
        ) = _getRValues1(to_return, tAmount, takeFee, _getRate());

        return to_return;
    }

    function _getTValues(
        uint256 tAmount,
        bool takeFee,
        address from,
        address to
    ) private view returns (valuesFromGetValues memory s) {
        if (!takeFee) {
            s.tTransferAmount = tAmount;
            return s;
        }

        uint256 temp = totalTransferFees;
        Fee memory feeStruct = transferFee;
        if (from == pair) {
            if (_isExcludedFromBuyFee[to]) {
                temp = 0;
            } else {
                temp = totalBuyFees;
                feeStruct = buyFee;
            }
        } else if (to == pair) {
            if (_isExcludedFromSellFee[from]) {
                temp = 0;
            } else {
                temp = totalSellFees;
                feeStruct = sellFee;
            }
        }

        if (temp > 0) {
            s.tRfi = (tAmount * feeStruct.refFee) / 100;
            s.tFee = (tAmount * (temp - feeStruct.refFee)) / 100;
        }
        s.tTransferAmount = tAmount - s.tRfi - s.tFee;
        return s;
    }

    function _getRValues1(
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
            uint256 rFee
        )
    {
        rAmount = tAmount * currentRate;

        if (!takeFee) {
            return (rAmount, rAmount, 0, 0);
        }

        rRfi = s.tRfi * currentRate;
        rFee = s.tFee * currentRate;

        rTransferAmount = rAmount - rRfi - rFee;

        return (rAmount, rTransferAmount, rRfi, rFee);
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
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        bool takeFee = false;
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
            require(tradingEnabled, "Trading not active");
            takeFee = true;
        }
        _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        valuesFromGetValues memory s = _getValues(
            tAmount,
            takeFee,
            sender,
            recipient
        );

        if (recipient != pair) {
            if (
                !_isExcludedFromMaxWallet[sender] &&
                !_isExcludedFromMaxWallet[recipient]
            ) {
                require(
                    balanceOf(recipient) + s.tTransferAmount <= maxWallet,
                    "Maximum wallet has been reached for this account."
                );
            }
        }

        bool allowed = true; //this is true by defualt, if user has locked tokens
        //this value will be challenged and will be updated to false if there are not enough tokens
        uint256 lockTime = block.timestamp;

        if (recipient == pair) {
            if (!_isExcludedFromCooldown[sender]) {
                allowed = _unlockedTokens(sender, true, tAmount);
            }
            if (balanceOf(address(this)) > swapThreshold && !swapping) {
                internalSwap(swapThreshold);
            }
        }
        if (recipient != pair && sender != pair) {
            if (!_isExcludedFromCooldown[sender]) {
                allowed = _unlockedTokens(sender, false, tAmount);
            }
            if (!_isExcludedFromCooldown[recipient]) {
                if (!transferCooldown) {
                    lockTime = 0;
                }
                lockedTokens[recipient].push(
                    Locked({
                        rAmount: s.rTransferAmount,
                        time: lockTime,
                        rate: _getRate()
                    })
                );
            }
        }
        if (sender == pair) {
            if (!_isExcludedFromCooldown[recipient]) {
                lockedTokens[recipient].push(
                    Locked({
                        rAmount: s.rTransferAmount,
                        time: lockTime,
                        rate: _getRate()
                    })
                );
            }
        }

        require(allowed == true, "Not enough unlocked tokens");

        if (_isExcluded[sender]) {
            _tOwned[sender] = _tOwned[sender] - tAmount;
        }

        if (_isExcluded[recipient]) {
            _tOwned[recipient] = _tOwned[recipient] + s.tTransferAmount;
        }

        _rOwned[sender] = _rOwned[sender] - s.rAmount;
        _rOwned[recipient] = _rOwned[recipient] + s.rTransferAmount;

        if (s.rRfi > 0 || s.tRfi > 0) _reflectRfi(s.rRfi, s.tRfi);
        if (s.rFee > 0 || s.tFee > 0) _takeFee(sender, s.rFee, s.tFee);

        emit Transfer(sender, recipient, s.tTransferAmount);
    }

    //if holder is excluded => calculate lock amount using the rate in which the tokens were locked
    //if holder is not excluded from rewards => calculate the lock amount based on latest rate, which means user
    //can enjoy reflectinos even on locked amounts.
    function _unlockedTokens(
        address holder,
        bool isSell,
        uint256 tAmount
    ) internal returns (bool) {
        bool excludedFromReward = _isExcluded[holder];
        uint256 lockedAmount;
        uint256 rate;
        uint256 rAmount;
        for (
            uint256 i = lastUnlock[holder];
            i < lockedTokens[holder].length;
            i++
        ) {
            if (
                block.timestamp >= lockedTokens[holder][i].time + cooldown ||
                !isSell
            ) {
                rate = excludedFromReward
                    ? lockedTokens[holder][i].rate
                    : _getRate();
                rAmount = lockedTokens[holder][i].rAmount;
                lockedAmount = rAmount / rate;
                if (tAmount > lockedAmount) {
                    tAmount -= lockedAmount;
                    lockedTokens[holder][i].rAmount = 0;
                    lastUnlock[holder] += 1;
                } else {
                    lockedTokens[holder][i].rAmount -= tAmount * rate;
                    tAmount = 0;
                }
                if (tAmount == 0) {
                    return true;
                }
            }
        }
        //allow one more token, to fix rounding issues
        //balanceOf might be lower or higher than total tAmount if we try to transfer all of the tokens
        //this is because, balanceOf function is dividing whole rAmount by current ratio, wherease we are
        //dividing rAmount of each Lock object by this ratio in each step, this high likely causes rounding errors depending on length
        //of locked objects, e.g. if we have 100 lock objects, we might miss 100 tokens (1 token each step) due to rounding errors
        //using 10 ** _decimals mitigates this issue
        if (tAmount <= 10 ** _decimals) {
            return true;
        }
        return false;
    }

    function internalSwap(uint256 input) internal inSwapFlag {
        if (input == 0) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = swapRouter.WETH();

        _approve(address(this), address(swapRouter), ~uint256(0));

        try
            swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
                input,
                0,
                path,
                address(this),
                block.timestamp
            )
        {} catch {}

        if (address(this).balance > 0) {
            uint256 balance = address(this).balance;
            uint256 marketingETHShare;
            uint256 buyBackETHShare;
            uint256 devETHShare;
            {
                Fee memory buyFees = buyFee;
                Fee memory sellFees = sellFee;
                Fee memory transferFees = transferFee;
                uint256 totalFees = totalBuyFees +
                    totalSellFees +
                    totalTransferFees;
                marketingETHShare =
                    ((transferFees.marketingFee +
                        sellFees.marketingFee +
                        buyFees.marketingFee) * balance) /
                    totalFees;
                devETHShare =
                    ((buyFees.devFee + transferFees.devFee + sellFees.devFee) *
                        balance) /
                    totalFees;
                buyBackETHShare =
                    ((buyFees.buybackFee +
                        sellFees.buybackFee +
                        transferFees.buybackFee) * balance) /
                    totalFees;
            }
            (bool success, ) = marketingWallet.call{value: marketingETHShare}(
                ""
            );
            (success, ) = buybackWallet.call{value: buyBackETHShare}("");
            (success, ) = devWallet.call{value: devETHShare}("");
        }
    }

    function getUnlockedTokens(
        address holder,
        bool isSell
    ) public view returns (uint256) {
        uint256 tAmount = 0;
        bool excludedFromReward = _isExcluded[holder];
        uint256 rate;
        uint256 rAmount;
        uint256 lockedAmount;
        for (
            uint256 i = lastUnlock[holder];
            i < lockedTokens[holder].length;
            i++
        ) {
            if (
                block.timestamp >= lockedTokens[holder][i].time + cooldown ||
                !isSell
            ) {
                rate = excludedFromReward
                    ? lockedTokens[holder][i].rate
                    : _getRate();
                rAmount = lockedTokens[holder][i].rAmount;
                lockedAmount = rAmount / rate;
                tAmount += lockedAmount;
            }
        }
        return tAmount;
    }

    function withdrawETH(uint256 weiAmount) external onlyOwner {
        payable(msg.sender).transfer(weiAmount);
    }

    function withdrawERC20Tokens(
        address _tokenAddr,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        require(_tokenAddr != address(this));
        IERC20(_tokenAddr).transfer(_to, _amount);
    }
}