// Dependency file: @openzeppelin/contracts/security/ReentrancyGuard.sol

// SPDX-License-Identifier: MIT

// pragma solidity ^0.8.0;

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


// Dependency file: @openzeppelin/contracts/utils/Address.sol


// pragma solidity ^0.8.0;

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


// Dependency file: @openzeppelin/contracts/utils/Strings.sol


// pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


// Dependency file: @openzeppelin/contracts/token/ERC20/IERC20.sol


// pragma solidity ^0.8.0;

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


// Dependency file: @openzeppelin/contracts/utils/Context.sol


// pragma solidity ^0.8.0;

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


// Dependency file: @openzeppelin/contracts/access/Ownable.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";

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


// Dependency file: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/utils/Address.sol";

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

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
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
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// Dependency file: @openzeppelin/contracts/security/Pausable.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


// Dependency file: contracts/v5/binance-vrf/traits/PausableElement.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/security/Pausable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract PausableElement is Ownable, Pausable {
    /// @notice pause contract
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice unpause contract
    function unpause() external onlyOwner {
        _unpause();
    }
}


// Dependency file: contracts/v5/binance-vrf/traits/WithdrawalElement.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "@openzeppelin/contracts/security/Pausable.sol";
// import "contracts/v5/binance-vrf/traits/PausableElement.sol";

abstract contract WithdrawalElement is PausableElement {
    using SafeERC20 for IERC20;
    using Address for address;

    event WithdrawToken(address token, address recipient, uint256 amount);
    event Withdraw(address recipient, uint256 amount);

    /// @notice management function. Withdraw all tokens in emergency mode only when contract paused
    function withdrawToken(address _token, address _recipient) external virtual onlyOwner whenPaused {
        uint256 amount = IERC20(_token).balanceOf(address(this));

        _withdrawToken(_token, _recipient, amount);
        _afterWithdrawToken(_token, _recipient, amount);
    }

    /// @notice management function. Withdraw  some tokens in emergency mode only when contract paused
    function withdrawSomeToken(
        address _token,
        address _recipient,
        uint256 _amount
    ) public virtual onlyOwner whenPaused {
        _withdrawToken(_token, _recipient, _amount);
        _afterWithdrawToken(_token, _recipient, _amount);
    }

    ///@notice withdraw all BNB. Withdraw in emergency mode only when contract paused
    function withdraw() external virtual onlyOwner whenPaused {
        _withdraw(_msgSender(), address(this).balance);
    }

    ///@notice withdraw some BNB. Withdraw in emergency mode only when contract paused
    function withdrawSome(address _recipient, uint256 _amount) external virtual onlyOwner whenPaused {
        _withdraw(_recipient, _amount);
    }

    function _deliverFunds(
        address _recipient,
        uint256 _value,
        string memory _message
    ) internal {
        (bool sent, ) = payable(_recipient).call{value: _value}("");

        require(sent, _message);
    }

    function _deliverTokens(
        address _token,
        address _recipient,
        uint256 _value
    ) internal {
        IERC20(_token).safeTransfer(_recipient, _value);
    }

    function _withdraw(address _recipient, uint256 _amount) internal virtual {
        require(_recipient != address(0x0), "CryptoDrop Loto: address is zero");
        require(_amount <= address(this).balance, "CryptoDrop Loto: not enought BNB balance");

        _afterWithdraw(_recipient, _amount);

        _deliverFunds(_recipient, _amount, "CryptoDrop Loto: Can't send BNB");
        emit Withdraw(_recipient, _amount);
    }

    function _afterWithdraw(address _recipient, uint256 _amount) internal virtual {}

    function _withdrawToken(
        address _token,
        address _recipient,
        uint256 _amount
    ) internal virtual {
        require(_recipient != address(0x0), "CryptoDrop Loto: address is zero");
        require(_amount <= IERC20(_token).balanceOf(address(this)), "CryptoDrop Loto: not enought token balance");

        IERC20(_token).safeTransfer(_recipient, _amount);

        _afterWithdrawToken(_token, _recipient, _amount);
    }

    function _afterWithdrawToken(
        address _token,
        address _recipient,
        uint256 _amount
    ) internal virtual {}
}


// Dependency file: contracts/v5/binance-vrf/traits/JackpotElement.sol


// pragma solidity ^0.8.0;

// import "contracts/v5/binance-vrf/traits/WithdrawalElement.sol";

abstract contract JackpotElement is WithdrawalElement {
    using SafeERC20 for IERC20;
    using Address for address;

    uint256 public jackpotAmount;

    event Received(address sender, uint256 value);

    receive() external payable {}

    /// Receive BNB
    function addJackpot() external payable virtual onlyOwner {
        jackpotAmount += msg.value;
        emit Received(_msgSender(), msg.value);
    }

    function _afterWithdraw(address _recipient, uint256 _amount) internal override {
        if (_amount > jackpotAmount) {
            jackpotAmount = 0;
        } else {
            jackpotAmount -= _amount;
        }
    }
}


// Dependency file: contracts/v5/binance-vrf/traits/MiningElement.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract MiningElement is Ownable {
    using SafeERC20 for IERC20;

    address public baseToken;

    bool public isMiningAvailable;

    uint256 public miningAmount;

    mapping(address => uint256) public totalMined;

    mapping(address => mapping(address => uint256)) public miningBalances;

    event TokenMined(address indexed token, address indexed gamer, uint256 miningAmount);
    event UpdateMiningAmount(uint256 miningAmount);
    event UpdateBaseToken(address _baseToken);
    event SetIsMiningAvailable(bool _isMiningAvailable);

    function updateMiningAmount(uint256 _miningAmount) external onlyOwner {
        miningAmount = _miningAmount;
        emit UpdateMiningAmount(_miningAmount);
    }

    function updateBaseToken(address _baseToken) external onlyOwner {
        baseToken = _baseToken;
        isMiningAvailable = false;
        emit UpdateBaseToken(_baseToken);
    }

    function setIsMiningAvailable(bool _isMiningAvailable) external onlyOwner {
        require(baseToken != address(0x0), "base token is zero");

        isMiningAvailable = _isMiningAvailable;
        emit SetIsMiningAvailable(_isMiningAvailable);
    }

    function _initMiningElement(
        address _baseToken,
        uint256 _miningAmount,
        bool _isMiningAvailable
    ) internal virtual {
        baseToken = _baseToken;
        miningAmount = _miningAmount;
        isMiningAvailable = _isMiningAvailable;

        emit UpdateBaseToken(_baseToken);
        emit UpdateMiningAmount(_miningAmount);
        emit SetIsMiningAvailable(_isMiningAvailable);
    }

    function _mining(address _gamer) internal virtual {
        if (isMiningAvailable && IERC20(baseToken).balanceOf(address(this)) >= miningAmount) {
            IERC20(baseToken).safeTransfer(_gamer, miningAmount);

            totalMined[baseToken] += miningAmount;

            miningBalances[baseToken][_gamer] += miningAmount;

            emit TokenMined(baseToken, _gamer, miningAmount);
        }
    }

    function checkMiningAvailability() external view virtual returns (bool) {
        return (isMiningAvailable && IERC20(baseToken).balanceOf(address(this)) >= miningAmount);
    }
}


// Dependency file: contracts/v5/binance-vrf/binance-oracle/VRFConsumerBase.sol

// pragma solidity ^0.8.0;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBase {
    address private immutable vrfCoordinator;

    /**
     * @param _vrfCoordinator address of VRFCoordinator contract
     */
    constructor(address _vrfCoordinator) {
        vrfCoordinator = _vrfCoordinator;
    }

    /**
     * @notice fulfillRandomness handles the VRF response. Your contract must
     * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
     * @notice principles to keep in mind when implementing your fulfillRandomness
     * @notice method.
     *
     * @dev VRFConsumerBase expects its subcontracts to have a method with this
     * @dev signature, and will call it once it has verified the proof
     * @dev associated with the randomness. (It is triggered via a call to
     * @dev rawFulfillRandomness, below.)
     *
     * @param requestId The Id initially returned by requestRandomness
     * @param randomWords the VRF output expanded to the requested number of words
     */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

    // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
    // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
    // the origin of the call
    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
        if (msg.sender != vrfCoordinator) {
            revert("OnlyCoordinatorCanFulfill");
        }
        fulfillRandomWords(requestId, randomWords);
    }
}


// Dependency file: contracts/v5/binance-vrf/binance-oracle/VRFCoordinatorInterface.sol

// pragma solidity ^0.8.0;

interface VRFCoordinatorInterface {
    /**
     * @notice Get configuration relevant for making requests
     * @return minimumRequestConfirmations global min for request confirmations
     * @return maxGasLimit global max for request gas limit
     * @return s_provingKeyHashes list of registered key hashes
     */
    function getRequestConfig()
        external
        view
        returns (
            uint16,
            uint32,
            bytes32[] memory
        );

    /**
     * @notice Request a set of random words.
     * @param keyHash - Corresponds to a particular oracle job which uses
     * that key for generating the VRF proof. Different keyHash's have different gas price
     * ceilings, so you can select a specific one to bound your maximum per request cost.
     * @param subId  - The ID of the VRF subscription. Must be funded
     * with the minimum subscription balance required for the selected keyHash.
     * @param minimumRequestConfirmations - How many blocks you'd like the
     * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
     * for why you may want to request more. The acceptable range is
     * [minimumRequestBlockConfirmations, 200].
     * @param callbackGasLimit - How much gas you'd like to receive in your
     * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
     * may be slightly less than this amount because of gas used calling the function
     * (argument decoding etc.), so you may need to request slightly more than you expect
     * to have inside fulfillRandomWords. The acceptable range is
     * [0, maxGasLimit]
     * @param numWords - The number of uint256 random values you'd like to receive
     * in your fulfillRandomWords callback. Note these numbers are expanded in a
     * secure way by the VRFCoordinator from a single random value supplied by the oracle.
     * @return requestId - A unique identifier of the request. Can be used to match
     * a request to a response in fulfillRandomWords.
     */
    function requestRandomWords(
        bytes32 keyHash,
        uint64 subId,
        uint16 minimumRequestConfirmations,
        uint32 callbackGasLimit,
        uint32 numWords
    ) external returns (uint256 requestId);

    /**
     * @notice Create a VRF subscription.
     * @return subId - A unique subscription id.
     * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
     * @dev Note to fund the subscription, use transferAndCall. For example
     */
    function createSubscription() external returns (uint64 subId);

    /**
     * @notice Get a VRF subscription.
     * @param subId - ID of the subscription
     * @return balance - BNB balance of the subscription in juels.
     * @return reqCount - number of requests for this subscription, determines fee tier.
     * @return owner - owner of the subscription.
     * @return consumers - list of consumer address which are able to use this subscription.
     */
    function getSubscription(uint64 subId)
        external
        view
        returns (
            uint96 balance,
            uint64 reqCount,
            address owner,
            address[] memory consumers
        );

    /**
     * @notice Request subscription owner transfer.
     * @param subId - ID of the subscription
     * @param newOwner - proposed new owner of the subscription
     */
    function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

    function deposit(uint64 subId) external payable;

    /**
     * @notice Request subscription owner transfer.
     * @param subId - ID of the subscription
     * @dev will revert if original owner of subId has
     * not requested that msg.sender become the new owner.
     */
    function acceptSubscriptionOwnerTransfer(uint64 subId) external;

    /**
     * @notice Add a consumer to a VRF subscription.
     * @param subId - ID of the subscription
     * @param consumer - New consumer which can use the subscription
     */
    function addConsumer(uint64 subId, address consumer) external;

    /**
     * @notice Remove a consumer from a VRF subscription.
     * @param subId - ID of the subscription
     * @param consumer - Consumer to remove from the subscription
     */
    function removeConsumer(uint64 subId, address consumer) external;

    /**
     * @notice Cancel a subscription
     * @param subId - ID of the subscription
     * @param to - Where to send the remaining BNB to
     */
    function cancelSubscription(uint64 subId, address to) external;

    /*
     * @notice Check to see if there exists a request commitment consumers
     * for all consumers and keyhashes for a given sub.
     * @param subId - ID of the subscription
     * @return true if there exists at least one unfulfilled request for the subscription, false
     * otherwise.
     */
    function pendingRequestExists(uint64 subId) external view returns (bool);
}


// Dependency file: contracts/v5/binance-vrf/traits/BinanceVRFElement.sol


// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";
// import "contracts/v5/binance-vrf/traits/JackpotElement.sol";
// import "contracts/v5/binance-vrf/traits/MiningElement.sol";

// import "contracts/v5/binance-vrf/binance-oracle/VRFConsumerBase.sol";
// import "contracts/v5/binance-vrf/binance-oracle/VRFCoordinatorInterface.sol";

abstract contract BinanceVRFElement is JackpotElement, MiningElement, ReentrancyGuard, VRFConsumerBase {
    using SafeERC20 for IERC20;
    using Address for address;

    address public storageAddress;
    address public teamAddress;
    address public committeeAddress;
    address public leaderboardAddress;

    uint256 public bnbOracleFee = 0.005 ether;

    uint16 public constant REQUEST_CONFIRMATION = 3;
    uint32 public constant NUM_WORDS = 1;
    uint32 private callbackGasLimit;

    VRFCoordinatorInterface public COORDINATOR;
    bytes32 private keyHash;
    uint64 private subId;

    uint32 private numWords;

    bool initializedVRFElement;
    bool initializedMiningElement;

    event UpdateStorageAddress(address storageAddress);
    event UpdateTeamAddress(address teamAddress);
    event UpdateCommitteeAddress(address committeeAddress);
    event UpdateLeaderboardAddress(address leaderboardAddress);
    event UpdateKeyHash(bytes32 keyHash);
    event UpdateSubId(uint64 _subId);
    event UpdateBNBOracleFee(uint256 _newFee);

    function initMiningElement(
        address _baseToken,
        uint256 _miningAmount,
        bool _isMiningAvalable
    ) external onlyOwner {
        require(!initializedMiningElement, "Mining Element initialized");

        _initMiningElement(_baseToken, _miningAmount, _isMiningAvalable);

        initializedMiningElement = true;
    }

    function initVRFElement(
        uint64 _subId,
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        address _storageAddress,
        address _teamAddress,
        address _committeeAddress,
        address _leaderboardAddress
    ) external onlyOwner {
        require(!initializedVRFElement, "VRF Element initialized");

        _initVRFElement(_subId, _keyHash, _callbackGasLimit, _storageAddress, _teamAddress, _committeeAddress, _leaderboardAddress);

        initializedVRFElement = true;
    }

    function _initVRFElement(
        uint64 _subId,
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        address _storageAddress,
        address _teamAddress,
        address _committeeAddress,
        address _leaderboardAddress
    ) internal virtual {
        subId = _subId;
        keyHash = _keyHash;
        callbackGasLimit = _callbackGasLimit;

        storageAddress = _storageAddress;
        teamAddress = _teamAddress;
        leaderboardAddress = _leaderboardAddress;
        committeeAddress = _committeeAddress;
    }

    ///@notice update address of storage contract
    ///@param _storageAddress storage contract address
    function updateStorageAddress(address _storageAddress) external onlyOwner {
        storageAddress = _storageAddress;

        emit UpdateStorageAddress(storageAddress);
    }

    ///@notice update team address
    ///@param _teamAddress team address
    function updateTeamAddress(address _teamAddress) external onlyOwner {
        teamAddress = _teamAddress;

        emit UpdateTeamAddress(teamAddress);
    }

    function updateCommitteeAddress(address _committeeAddress) external onlyOwner {
        committeeAddress = _committeeAddress;

        emit UpdateCommitteeAddress(committeeAddress);
    }

    function updateLeaderboardAddress(address _leaderboardAddress) external onlyOwner {
        leaderboardAddress = _leaderboardAddress;

        emit UpdateLeaderboardAddress(leaderboardAddress);
    }

    function updateSubId(uint64 _subId) external onlyOwner {
        subId = _subId;
        emit UpdateSubId(_subId);
    }

    function updateBNBOracleFee(uint256 _newFee) external onlyOwner {
        bnbOracleFee = _newFee;
        emit UpdateBNBOracleFee(_newFee);
    }

    function _getBlockHash(uint256 _randomness) internal view virtual returns (bytes32 _hash) {
        return keccak256(abi.encode(_randomness));
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual override {}

    function _requestRandomWords() internal returns (uint256 requestId) {
        address(COORDINATOR).call{value: bnbOracleFee}(abi.encodeWithSignature("deposit(uint64)", subId));

        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(keyHash, subId, REQUEST_CONFIRMATION, callbackGasLimit, NUM_WORDS);
    }
}


// Dependency file: contracts/v5/binance-vrf/traits/BinanceVRFElementIdUint256.sol


// pragma solidity ^0.8.0;

// import "contracts/v5/binance-vrf/traits/BinanceVRFElement.sol";

abstract contract BinanceVRFElementIdUint256 is BinanceVRFElement {
    struct RandomnessRequestData {
        uint256 betId;
        address gamer;
        uint256 number;
        bool fullfilled;
    }

    mapping(uint256 => RandomnessRequestData) public randomnessRequests;

    function _requestRandomness(uint256 _id, address _gamer) internal returns (uint256 requestId) {
        requestId = _requestRandomWords();

        RandomnessRequestData memory data = RandomnessRequestData({betId: _id, gamer: _gamer, number: 0, fullfilled: false});

        randomnessRequests[requestId] = data;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        RandomnessRequestData storage data = randomnessRequests[requestId];
        require(!data.fullfilled, "VRF: request already processed");

        data.fullfilled = true;
        data.number = randomWords[0];

        _processBetWithRandomness(data, data.number);
        _mining(data.gamer);
    }

    function _processBetWithRandomness(RandomnessRequestData storage _data, uint256 _randomness) internal virtual {}
}


// Root file: contracts/v5/games/CryptoDropSelectV5.sol


pragma solidity ^0.8.0;

// import "contracts/v5/binance-vrf/traits/BinanceVRFElementIdUint256.sol";

/// @notice CryptoDrop Shell Game (CryptoDrop Envelopes) V4
contract CryptoDropSelectV5 is BinanceVRFElementIdUint256 {
    using SafeERC20 for IERC20;
    using Address for address;

    enum Select {
        A,
        B,
        C,
        D
    }

    uint256 internal constant MIN_BET = 0.01 ether;
    uint256 internal constant MAX_BET = 0.025 ether;

    uint256 internal constant MIN_WIN = 0.004 ether; //0.4%
    uint256 internal constant MAX_WIN = 0.01 ether; //1%

    uint256 internal constant PRECISION = 1 ether;

    uint256 internal constant JACKPOT_PERCENT = 90;
    uint256 internal constant STORAGE_PERCENT = 3;
    uint256 internal constant COMMITTEE_PERCENT = 3;
    uint256 internal constant LEADERBOARD_PERCENT = 2;
    uint256 internal constant TEAM_PERCENT = 2;

    bytes1[4] public selectA;
    bytes1[4] public selectB;
    bytes1[4] public selectC;
    bytes1[4] public selectD;

    struct Limits {
        uint256 min;
        uint256 max;
    }

    Limits public betLimits;
    Limits public winLimits;

    struct Bet {
        uint256 requestId;
        uint256 blockNumber;
        uint256 amount;
        uint256 vrfFee;
        uint256 reward;
        bytes hash;
        Select select;
    }

    event PayoutBet(uint256 id, uint256 amount, address gamer);
    event ProcessBet(uint256 id, address gamer, uint256 amount, uint256 reward, bytes hash, uint8 envelope);
    event SetBetLimits(uint256 _min, uint256 _max);
    event SetWinLimits(uint256 _min, uint256 _max);

    mapping(address => Bet[]) public bets;

    constructor(address vrfCoordinator) VRFConsumerBase(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorInterface(vrfCoordinator);

        betLimits.min = MIN_BET;
        betLimits.max = MAX_BET;

        winLimits.min = MIN_WIN;
        winLimits.max = MAX_WIN;

        selectA = [bytes1(0x00), bytes1(0x01), bytes1(0x02), bytes1(0x03)];

        selectB = [bytes1(0x04), bytes1(0x05), bytes1(0x06), bytes1(0x07)];

        selectC = [bytes1(0x08), bytes1(0x09), bytes1(0x0a), bytes1(0x0b)];

        selectD = [bytes1(0x0c), bytes1(0x0d), bytes1(0x0e), bytes1(0x0f)];
    }

    function placeBet(Select _select) external payable virtual nonReentrant whenNotPaused {
        require(uint8(_select) < 4, "CryptoDrop V5: invalid envelope");
        require(!msg.sender.isContract(), "CryptoDrop V5: sender cannot be a contract");
        require(tx.origin == msg.sender, "CryptoDrop V5: msg sender is not original user");

        uint256 betAmount = msg.value;

        uint256 minSize = betLimits.min + bnbOracleFee;
        uint256 maxSize = betLimits.max + bnbOracleFee;

        require(
            betAmount >= minSize && betAmount <= maxSize,
            string(
                abi.encodePacked(
                    "CryptoDrop V5: Bet amount should be greater or equal than ",
                    Strings.toString(minSize),
                    " and less or equal than ",
                    Strings.toString(maxSize),
                    " WEI"
                )
            )
        );

        Bet memory bet = Bet(0, block.number - 1, betAmount, bnbOracleFee, 0, "", _select);

        bets[msg.sender].push(bet);

        uint256 id = bets[msg.sender].length - 1;

        _beforeProcessBet(betAmount - bnbOracleFee);

        _processBet(msg.sender, id);
    }

    function setBetLimits(uint256 _min, uint256 _max) external onlyOwner {
        require(_min > bnbOracleFee, "Cryptodrop V5: invalid min");
        require(_max > _min + bnbOracleFee, "Cryptodrop V5: invalid max");

        betLimits.min = _min;
        betLimits.max = _max;

        emit SetBetLimits(_min, _max);
    }

    function setWinLimits(uint256 _min, uint256 _max) external onlyOwner {
        winLimits.min = _min;
        winLimits.max = _max;

        emit SetWinLimits(_min, _max);
    }

    function getBetsLength(address _account) external view returns (uint256) {
        return bets[_account].length;
    }

    function _beforeProcessBet(uint256 _amount) internal virtual {
        //
        uint256 jackpotFee = (_amount * JACKPOT_PERCENT * PRECISION) / 100 / PRECISION;

        uint256 storageFee = (_amount * STORAGE_PERCENT * PRECISION) / 100 / PRECISION;
        uint256 teamFee = (_amount * TEAM_PERCENT * PRECISION) / 100 / PRECISION;
        uint256 leaderboardFee = (_amount * LEADERBOARD_PERCENT * PRECISION) / 100 / PRECISION;
        uint256 committeeFee = (_amount * COMMITTEE_PERCENT * PRECISION) / 100 / PRECISION;

        // increase jackpot
        jackpotAmount += jackpotFee;

        _deliverFunds(storageAddress, storageFee, "CryptoDrop V5: failed transfer BNB to Staking Storage");

        _deliverFunds(teamAddress, teamFee, "CryptoDrop V5: failed transfer BNB to Team");

        _deliverFunds(leaderboardAddress, leaderboardFee, "CryptoDrop V5: failed transfer BNB to Leaderboard");

        _deliverFunds(committeeAddress, committeeFee, "CryptoDrop V5: failed transfer BNB to Committee");
    }

    function _processBet(address _gamer, uint256 _id) internal virtual {
        uint256 requestId = _requestRandomness(_id, _gamer);

        RandomnessRequestData memory data = RandomnessRequestData({betId: _id, gamer: _gamer, number: 0, fullfilled: false});

        randomnessRequests[requestId] = data;

        Bet storage bet = bets[_gamer][_id];

        bet.requestId = requestId;
    }

    function _processBetWithRandomness(RandomnessRequestData storage _data, uint256 _randomness) internal virtual override {
        uint256 betId = _data.betId;

        address gamer = _data.gamer;

        bytes32 blockHash = _getBlockHash(_randomness);

        Bet storage bet = bets[gamer][betId];

        bytes1 field;

        bool isWin = false;

        bytes memory b = new bytes(6);

        for (uint8 j = 0; j < 6; j++) {
            field = blockHash[26 + j] >> 4;
            b[j] = field;
        }

        bet.hash = b;

        if (bet.select == Select.A) {
            for (uint8 i = 0; i < 4; i++) {
                if (bet.hash[5] == selectA[i]) {
                    isWin = true;
                    break;
                }
            }
        }

        if (bet.select == Select.B) {
            for (uint8 i = 0; i < 4; i++) {
                if (bet.hash[5] == selectB[i]) {
                    isWin = true;
                    break;
                }
            }
        }

        if (bet.select == Select.C) {
            for (uint8 i = 0; i < 4; i++) {
                if (bet.hash[5] == selectC[i]) {
                    isWin = true;
                    break;
                }
            }
        }

        if (bet.select == Select.D) {
            for (uint8 i = 0; i < 4; i++) {
                if (bet.hash[5] == selectD[i]) {
                    isWin = true;
                    break;
                }
            }
        }

        if (isWin) {
            uint256 winSize = (bet.amount * winLimits.max) / betLimits.max;

            uint256 prize = (jackpotAmount * winSize) / PRECISION;

            if (prize > address(this).balance) {
                prize = address(this).balance;
            }

            jackpotAmount -= prize;

            bet.reward = prize;

            //sent to gamer prize
            _deliverFunds(gamer, prize, "CryptoDrop V5: failed transfer BNB to Gamer");

            emit PayoutBet(betId, prize, gamer);
        }

        emit ProcessBet(betId, gamer, bet.amount, bet.reward, bet.hash, uint8(bet.select));
    }
}