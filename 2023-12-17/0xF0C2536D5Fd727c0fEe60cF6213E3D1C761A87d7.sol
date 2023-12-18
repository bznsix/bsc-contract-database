// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;

import {IERC20} from "./IERC20.sol";
import {IERC20Metadata} from "./extensions/IERC20Metadata.sol";
import {Context} from "../../utils/Context.sol";
import {IERC20Errors} from "../../interfaces/draft-IERC6093.sol";

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
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

import {IERC20} from "../IERC20.sol";

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.20;

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
//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;
import "@openzeppelin/contracts/utils/Address.sol";

library SafeMath {
  
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

   
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

  
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
     *
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
     *
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


interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
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
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

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
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
// SPDX-License-Identifier: UNLICENSED

// website: https://vaultlegends.com/

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces.sol";

contract VaultLegends is ERC20, Ownable {
    using SafeMath for uint256;

    address constant routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;//0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

    address payable marketingWallet;
    address payable devWallet;

    // Distribution percentages
    uint256 public poolPercentage = 50;
    uint256 public marketingPercentage = 10;
    uint256 public devPercentage = 10;
    uint256 public affiliatePercentage = 5;
    uint256 public liquidityPercentage = 25;

    // Lottery
    uint256 public ticketPrice = 0.0001 ether;
    uint256 public numberOfWinners = 10;
    uint256 public currentLotteryRound; // Track the current lottery round
    uint256 public lotteryDeadline;
    uint256 public lotteryDuration = 60; // 604800 = one week
    uint256 public poolBalance; // Prize pool
    bool public active = false;
    mapping(address=>uint256) public userEarnings;
    mapping(address => uint256) public userBalances;
    mapping(uint256 => mapping(uint256=>address)) public lotteryWinners;
    mapping(uint256 => uint256) public lotteryWinnersCnt;
    // Maintain user ticket counts and participants for each lottery round
    mapping(address => mapping(uint256 => uint256)) public userTicketCountsByLottery; // Tickets per user per lottery
    mapping(uint256 => address[]) public participantsByLottery; // Participants list for each lottery
    mapping(uint256 => mapping (uint256 =>address)) public allTickets;
    mapping(uint256=>uint256) public  ticketCount;

    // Affiliate Program
    mapping(address=>address) public affiliates;
    mapping(address=>uint256) public affiliatesCount;
    mapping(address=>uint256) public affiliateEarnings;
    mapping(address=>bool) public userHasAffiliate;

    // Presale
    uint256 public tokensForPresale = 0;  
    uint256 public tokensForLiquidity = 0;   
    uint256 public tokensSold = 0; 
    uint256 public presaleBalance = 0;
    uint256 public presaleFee = 20;
    uint256 public presalePrice = 0.001 ether;
    uint256 public maxPresaleAmount = 1 ether;
    bool public presaleEnded = false;

    bool internal lpInitialized = false;

    // Gems
    uint256 public roiPercentage1 =  100;
    uint256 public roiPercentage2 = 50; 
    uint256 public roiPercentage3 = 33;  
    uint256 public roiPercentage4 = 25; 
    uint256 public claimDelay1 = 60*60*24; 
    uint256 public claimDelay2 = 60*60*24; 
    uint256 public claimDelay3 = 60*60*24; 
    uint256 public claimDelay4 = 60*60*24; 

    mapping(address => mapping(uint8=>uint256)) public gemBalance; 
    mapping(address => mapping(uint8=>uint256)) public lastClaimedTime; 
    mapping(address => mapping(uint8=>uint256)) public totalClaimed;

    uint256 public _lotteryPercentage = 20;
    constructor(address initialOwner, uint256 initialSupply, uint256 decimals, uint256 presalePercentage) ERC20("Vault Legends Token", "VAULT") Ownable(initialOwner) {
        marketingWallet = payable(initialOwner);
        devWallet = payable(initialOwner);
        uint256 _initialSupply = initialSupply * 10 ** decimals; 
        tokensForPresale = (_initialSupply * presalePercentage / 100)/2;
        tokensForLiquidity = tokensForPresale;
        _mint(address(this), _initialSupply);
    }


    function setPresalePrice(uint256 _price) external onlyOwner {
        presalePrice = _price;
    }
    function setPresaleMax(uint256 _max) external onlyOwner {
        maxPresaleAmount = _max;
    }

    function endPresale() external onlyOwner {
        _endPresale();
    }

    function _endPresale() internal{
        uint256 balanceToAdd = presaleBalance;
        if(balanceToAdd > (address(this).balance - poolBalance))
        {
            balanceToAdd =  (address(this).balance - poolBalance);
        }
        require(balanceToAdd > 0, "Not enough BNB balance");
        
        addLiquidity(tokensSold, balanceToAdd);
        if(tokensForPresale > 0) _burn(address(this), tokensForPresale);
        tokensForPresale = 0;
        presaleEnded = true;
    }

    function presale(address affiliate) external payable {
        if(!userHasAffiliate[msg.sender]){
            affiliates[msg.sender] = affiliate;
            affiliatesCount[affiliate]++;
            userHasAffiliate[msg.sender] = true;
        }
        require(!presaleEnded && tokensForPresale > 0, "Presale has ended.");
        uint256 tokensToSell = (msg.value / presalePrice)*10**18;
        require(msg.value <= maxPresaleAmount && tokensToSell <= tokensForPresale, "Max exceeded.");
        tokensForPresale -= (tokensToSell);
        presaleBalance += (msg.value * (100-presaleFee) / 100);
        tokensSold += (tokensToSell);
        ERC20(this).transfer(msg.sender, tokensToSell);
        payable(marketingWallet).transfer(msg.value * presaleFee / 100);
    }
    /*function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }*/
    function setLotteryDeadline(uint256 _lotteryDeadline) external onlyOwner {
        lotteryDeadline = _lotteryDeadline;
    }

    function setLotteryDuration(uint256 durationInSeconds) external onlyOwner {
        lotteryDuration = durationInSeconds;
    }

    function setNumberOfWinners(uint256 _numberOfWinners) external onlyOwner {
        numberOfWinners = _numberOfWinners;
    }

    function setTicketPrice(uint256 newPrice) external onlyOwner {
        ticketPrice = newPrice;
    }       
    
    function setMarketingWallet(address newAddress) external onlyOwner {
        marketingWallet = payable(newAddress);
    }
    function setDevWallet(address newAddress) external onlyOwner {
        devWallet = payable(newAddress);
    }

    function rescueBNB() external {
        require(address(this).balance > 0 && address(this).balance != poolBalance, "No BNB to rescue");
        poolBalance = address(this).balance;
    }

    function setShares(uint256 _poolPercentage, uint256 _marketingPercentage, uint256 _devPercentage, uint256 _affiliatePercentage, uint256 _liquidityPercentage) external onlyOwner {
        require(_poolPercentage + _marketingPercentage + _affiliatePercentage + _liquidityPercentage + _devPercentage <= 100, "Shares must add up to 100%");
        poolPercentage = _poolPercentage;
        marketingPercentage = _marketingPercentage;
        affiliatePercentage = _affiliatePercentage;
        liquidityPercentage = _liquidityPercentage;
        devPercentage = _devPercentage;
    }

    function vaultLevel(address user) external view returns(uint256){
        return getVaultLevel(user);
    }

    function getVaultLevel(address user) internal view returns(uint256){
        uint256 totalGems = gemBalance[user][1]+gemBalance[user][2]+gemBalance[user][3]+gemBalance[user][4];
         uint256 decimals = 10**18;
         uint256 level = (totalGems/decimals)+1;
         if(level > 10 ) level = 10;
         return level;
    }

    function buyTickets(address affiliate) external payable {

        if(!userHasAffiliate[msg.sender]){
            affiliates[msg.sender] = affiliate;
            affiliatesCount[affiliate]++;
            userHasAffiliate[msg.sender] = true;
        }

        if(block.timestamp < lotteryDeadline || lotteryDeadline == 0){
            
            // Calculate the number of tickets based on the paid amount
            uint256 numberOfTickets = msg.value / ticketPrice; 
            require(numberOfTickets > 0, "Number of tickets must be greater than 0");
            // Use modulo operation to remove decimal part
            numberOfTickets = numberOfTickets - (numberOfTickets % 1);
            uint256 ticketMultiplier = getVaultLevel(msg.sender);

            numberOfTickets = numberOfTickets * ticketMultiplier;
            uint256 liquidityShare = msg.value * liquidityPercentage / 100;
            // Calculate shares
            uint256 poolShare = msg.value * poolPercentage / 100;
            uint256 marketingShare = msg.value * marketingPercentage / 100;
            uint256 devShare = msg.value * devPercentage / 100;
            uint256 affiliateShare = msg.value * affiliatePercentage / 100;
            if(!lpInitialized){
                addLiquidity(liquidityShare * 1000, msg.value);
                lpInitialized = true;
            }  
            else { 
                // Start the lottery
                if(!active) {
                    startLottery();
                }
                        
                // Add balance to the prize pool
                poolBalance = poolBalance+=(poolShare);
                // Transfer to marketing wallet
                payable(marketingWallet).transfer(marketingShare);
                // Transfer to dev wallet
                payable(devWallet).transfer(devShare);
                // Transfer to affiliate
                payable(affiliates[msg.sender]).transfer(affiliateShare);
                affiliateEarnings[affiliates[msg.sender]] += (affiliateShare);
                // Register the user as a participant in the current lottery round
                if(userTicketCountsByLottery[msg.sender][currentLotteryRound] <= 0) {
                    participantsByLottery[currentLotteryRound].push(msg.sender);
                }
                // Add tickets to the user for the current lottery round
                userTicketCountsByLottery[msg.sender][currentLotteryRound] = userTicketCountsByLottery[msg.sender][currentLotteryRound]+=(numberOfTickets);
                // Add the new tickets to the end of the array
                for (uint i = 0; i < numberOfTickets; i++) {
                        allTickets[currentLotteryRound][ticketCount[currentLotteryRound]] = msg.sender;
                        ticketCount[currentLotteryRound]++;
                }
                buyGemsWithEth(liquidityShare, 0);
                // Emit event
            }
        }
        else {
            require(block.timestamp > (lotteryDeadline + (60*60*24)), "is owner alive ?");
            if(active) {
                _conductLottery();
            }
        }
    }
 
    
    function startLottery() internal {
        active = true;
        lotteryDeadline = block.timestamp + lotteryDuration;
        currentLotteryRound++;
         ticketCount[currentLotteryRound] = 0;
    }

    function endLottery() internal {
        lotteryDeadline = 0;
        poolBalance = 0;
        active = false;
    }

    function conductLottery() external onlyOwner {
        _conductLottery();
    }

    function _conductLottery() internal {
        uint256 N = numberOfWinners;
        
        if(N > ticketCount[currentLotteryRound]){
            N = ticketCount[currentLotteryRound];
        }

        if( N > 0){
            address[] memory winners = new address[](N);
            uint256 _i = 0;
            for (uint256 i = 0; i < N; i++) {
                uint256 randomIndex = generateRandomIndex();
                winners[i] = allTickets[currentLotteryRound][randomIndex];
                lotteryWinners[currentLotteryRound][i] = allTickets[currentLotteryRound][randomIndex];
                delete allTickets[currentLotteryRound][randomIndex];
                _i++;
            }
            lotteryWinnersCnt[currentLotteryRound] = _i;
            distributePrizes(winners);
        }
        endLottery();
    }

    function generateRandomIndex() internal view returns (uint256) {
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1))));
        uint256 maxIndex = ticketCount[currentLotteryRound];

        while (true) {
            uint256 randomIndex = seed % maxIndex;
            if (allTickets[currentLotteryRound][randomIndex] != address(0)) {
                return randomIndex;
            }
            // Try another if address(0)
            seed = uint256(keccak256(abi.encodePacked(seed)));
        }
    }

    function contains(uint[] memory arr, uint val) private pure returns (bool) {
        for (uint i = 0; i < arr.length; i++) {
            if (arr[i] == val) {
                return true;
            }
        }
        return false;
    }

    function distributePrizes(address[] memory winners) internal {
        uint256 prizeAmount = poolBalance / winners.length;
        for (uint256 i = 0; i < winners.length; i++) {
            address payable winner = payable(winners[i]);
            winner.transfer(prizeAmount);
            userEarnings[address(winners[i])]+=(prizeAmount);
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 value) internal {
        if(!lpInitialized){
            lpInitialized = true;
        }  
        IUniswapV2Router02 pancakeRouter = IUniswapV2Router02(routerAddress);
        _approve(address(this), address(routerAddress), tokenAmount);
        pancakeRouter.addLiquidityETH{value: value}(
            address(this),
            tokenAmount,
            0,
            0,
            address(this), // msg.sender for testing or address(0) so this liquidity can't be removed
            block.timestamp
        );
    }   
    event GemsPurchased(address indexed buyer, uint256 amount);
    event ROIClaimed(address indexed user, uint256 amount);
    
    // Function to purchase Gems using ETH
    function _buyGemsWithEth(address affiliate) external payable {
        if(!userHasAffiliate[msg.sender]){
            affiliates[msg.sender] = affiliate;
            affiliatesCount[affiliate]++;
            userHasAffiliate[msg.sender] = true;
        }
        buyGemsWithEth(msg.value, _lotteryPercentage);
    }

    function buyGemsWithEth(uint256 _ethAmount, uint256 lotteryPercentage) internal {
        require(_ethAmount > 0, "Sent ETH amount should be greater than zero");
        // Calculate the percentage reserved for lottery
        uint256 ethAmount = (_ethAmount*(100-lotteryPercentage))/100;

        // Add balance to the prize pool
        poolBalance = poolBalance+=(_ethAmount-ethAmount);

        // Create an array to define the token swap path
        address[] memory path = new address[](2);
        IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);

        // Define the path for token swapping between ETH and the token address
        path[0] = router.WETH();
        path[1] = address(this);

        uint8 level = determineLevel(_ethAmount);
        uint256 numberOfGems = estimateGemsAmount(ethAmount, router, path);
        uint256 tokenBalance = balanceOf(address(this));
        uint256 tokensToLiquidify = 0;
        if(tokenBalance > 0){
            if(tokenBalance >= numberOfGems){
                tokensToLiquidify = numberOfGems;
            }
            else {
                tokensToLiquidify = tokenBalance;
            }
        }
        if (tokensToLiquidify > 0) {
            uint256 fees = tokensToLiquidify * 30 / 100;
            IERC20(address(this)).transfer(address(marketingWallet), fees*80/100);
            IERC20(address(this)).transfer(affiliates[msg.sender], fees*20/100);
            tokensToLiquidify = tokensToLiquidify * 70 / 100;
            addLiquidity(tokensToLiquidify * 10 ** 18, ethAmount);
        }
        else {
            router.removeLiquidityETH(
                address(this),
                numberOfGems,
                0,
                0,
                address(this),
                block.timestamp
            );
        }
        // Update user's gem balance
        gemBalance[msg.sender][level]+=(numberOfGems);
        
        if (lastClaimedTime[msg.sender][level] <=0) {
            lastClaimedTime[msg.sender][level] = block.timestamp;
        }
        else {
            lastClaimedTime[msg.sender][level] -= 60;
        }
        // Emit event for Gems purchased
        emit GemsPurchased(msg.sender, numberOfGems);
    }

    function estimateGemsAmount(uint256 ethAmount, bool fromTickets) external view returns(uint8, uint256) {
        // Create an array to define the token swap path
        address[] memory path = new address[](2);
        IUniswapV2Router02 router = IUniswapV2Router02(routerAddress);

        // Define the path for token swapping between ETH and the token address
        path[0] = router.WETH();
        path[1] = address(this);
        if (!fromTickets) return (determineLevel(ethAmount), estimateGemsAmount(ethAmount*(100-_lotteryPercentage)/100, router, path));
        else return (determineLevel(ethAmount*liquidityPercentage/100), estimateGemsAmount(ethAmount*liquidityPercentage/100, router, path));
    }

    function estimateGemsAmount(uint256 ethAmount, IUniswapV2Router02 router,  address[] memory path) internal view returns(uint256) {
        uint256[] memory amounts = router.getAmountsOut(ethAmount, path);
        uint256 numberOfGems = amounts[1];
        return numberOfGems;
    }

    function determineLevel(uint256 ethAmount) internal view returns (uint8) {
        uint256 gemPrice = ticketPrice * liquidityPercentage / 100;
        uint256 LEVEL_1_REQUIREMENT = gemPrice; 
        uint256 LEVEL_2_REQUIREMENT = gemPrice*4; 
        uint256 LEVEL_3_REQUIREMENT = gemPrice*7; 
        uint256 LEVEL_4_REQUIREMENT = gemPrice*10; 

        if (ethAmount >= LEVEL_4_REQUIREMENT) {
            return 4;
        } else if (ethAmount >= LEVEL_3_REQUIREMENT) {
            return 3;
        } else if (ethAmount >= LEVEL_2_REQUIREMENT) {
            return 2;
        } else if (ethAmount >= LEVEL_1_REQUIREMENT) {
            return 1;
        } else {
            revert("Insufficient eth amount for gem purchase");
        }
    }
    function claimROI(uint8 gemId, bool compound) external {
        require(gemId < 5 && gemId > 0, "Invalid GemID");
        uint256 claimDelay = 0;
        if(gemId == 1) {
            claimDelay = claimDelay1;
        }
        if(gemId == 2) {
            claimDelay = claimDelay2;
        }
        if(gemId == 3) {
            claimDelay = claimDelay3;
        }
        if(gemId == 4) {
            claimDelay = claimDelay4;
        }
        require(claimDelay != 0, "Invalid GemID");

        uint256 lastClaimed = lastClaimedTime[msg.sender][gemId];
        require(block.timestamp >= lastClaimed + claimDelay, "Wait until deadline");

        uint256 gemsOwned = gemBalance[msg.sender][gemId];
        require(gemsOwned > 0, "You don't own any gems of this kind");

        (uint256 roiToAdd, uint256 lastTimeRewarded) = calculatePendingROI(msg.sender, gemId);
        lastClaimedTime[msg.sender][gemId] = block.timestamp;
    
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance>=roiToAdd){
            _approve(address(this),address(this), tokenBalance);
            if(!compound) ERC20(this).transfer(msg.sender, roiToAdd);
            else gemBalance[msg.sender][gemId]+=(roiToAdd);
        }
        else {
            if(!compound) _mint(msg.sender, roiToAdd);
            else gemBalance[msg.sender][gemId]+=(roiToAdd);
        }

        totalClaimed[msg.sender][gemId]+=(roiToAdd);

        emit ROIClaimed(msg.sender, roiToAdd);
    }

    function _calculatePendingROI(address user) external view returns (uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256, uint256) {
        uint256 timestamp = block.timestamp;
        (uint256 r1, uint256 l1) = calculatePendingROI(user, 1);
        (uint256 r2, uint256 l2) = calculatePendingROI(user, 2);
        (uint256 r3, uint256 l3) = calculatePendingROI(user, 3);
        (uint256 r4, uint256 l4) = calculatePendingROI(user, 4);
        return (r1,r2,r3,r4,l1,l2,l3,l4,timestamp);
    }
    
    function calculatePendingROI(address user, uint8 gemId) internal view returns (uint256, uint256) {
        uint256 lastClaimed = lastClaimedTime[user][gemId];
        uint256 timeSinceLastClaim = block.timestamp - lastClaimed;
        require(gemId < 5 && gemId > 0, "Invalid GemID");
        uint256 claimDelay = 0;
        uint256 roiPercentage = 0;
        if(gemId == 1) {
            claimDelay = claimDelay1;
            roiPercentage = roiPercentage1;
        }
        if(gemId == 2) {
            claimDelay = claimDelay2;
            roiPercentage = roiPercentage2;
        }
        if(gemId == 3) {
            claimDelay = claimDelay3;
            roiPercentage = roiPercentage3;
        }
        if(gemId == 4) {
            claimDelay = claimDelay4;
            roiPercentage = roiPercentage4;
        }
        require(claimDelay != 0 && roiPercentage != 0, "Invalid GemID");
        uint256 gemsOwned = gemBalance[user][gemId];

        uint256 roiToAdd = 0;
        if (timeSinceLastClaim <= claimDelay){
            roiToAdd = gemsOwned/roiPercentage*timeSinceLastClaim/3600;
        }
        else if (gemsOwned > 0){
            roiToAdd = gemsOwned/roiPercentage*claimDelay/3600;
        }
        uint256 lastingTime = 0;
        if(lastClaimed > 0) lastingTime = lastClaimed + claimDelay;
        return (roiToAdd, lastingTime);
    }

    function setROIPercentage(uint256 newROIPercentage, uint8 gemId) external onlyOwner {
        require(gemId < 5 && gemId > 0, "Invalid GemID");
        if(gemId == 1) {
            roiPercentage1 = newROIPercentage;
        }
        if(gemId == 2) {
            roiPercentage2 = newROIPercentage;
        }
        if(gemId == 3) {
            roiPercentage3 = newROIPercentage;
        }
        if(gemId == 4) {
            roiPercentage4 = newROIPercentage;
        }
    }

    function setClaimDelay(uint256 newClaimDelay, uint8 gemId) external onlyOwner {
        require(gemId < 5 && gemId > 0, "Invalid GemID");
        if(gemId == 1) {
            claimDelay1 = newClaimDelay;
        }
        if(gemId == 2) {
            claimDelay2 = newClaimDelay;
        }
        if(gemId == 3) {
            claimDelay3 = newClaimDelay;
        }
        if(gemId == 4) {
            claimDelay4 = newClaimDelay;
        }
    } 
}
