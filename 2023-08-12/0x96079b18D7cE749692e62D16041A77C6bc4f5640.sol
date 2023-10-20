// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC1155/IERC1155.sol)

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
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

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
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

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
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
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
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
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
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IStaking {

    struct Pool {
        address token;
        address rewardToken;
        uint minimumDeposit;
        uint roi;
        uint bonusRoi;
        uint roiStep;
        uint rquirePool;
        uint requireAmount;
        uint blockDuration;
        uint nftId;
    }

    // Info of each user.
    struct UserInfo {
        address user;
        address referrer;
        uint investment;
        uint stakingValue;
        uint rewardLockedUp;
        uint totalDeposit;
        uint totalWithdrawn;
        uint nextWithdraw;
        uint unlockDate;
        uint depositCheckpoint;
        uint busdTotalDeposit;
        uint nftBalance;
    }

    struct RefData {
        address referrer;
        uint amount;
        bool exists;
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVault {

    function safeTransfer(IERC20 from, address to, uint amount) external;

    function safeTransfer(address _to, uint _value) external;

    function getTokenAddressBalance(address token) external view returns (uint);

    function getTokenBalance(IERC20 token) external view returns (uint);

    function getBalance() external view returns (uint);

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./IUniswapV2Router01.sol";

abstract contract IContractsLibrary {
    function BUSD() external view virtual returns (address);

    function WBNB() external view virtual returns (address);

    function ROUTER() external view virtual returns (IUniswapV2Router01);

    function getBusdToBNBToToken(
        address token,
        uint _amount
    ) external view virtual returns (uint256);

    function getTokensToBNBtoBusd(
        address token,
        uint _amount
    ) external view virtual returns (uint256);

    function getTokensToBnb(
        address token,
        uint _amount
    ) external view virtual returns (uint256);

    function getBnbToTokens(
        address token,
        uint _amount
    ) public view virtual returns (uint256);

    function getTokenToBnbToAltToken(
        address token,
        address altToken,
        uint _amount
    ) public view virtual returns (uint256);

    function getLpPrice(
        address token,
        uint _amount
    ) public view virtual returns (uint256);

    function getUsdToBnB(uint amount) external view virtual returns (uint256);

    function getBnbToUsd(uint amount) external view virtual returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./StakingStateV2.sol";
import "./IVault.sol";
import "./resources/IContractsLibrary.sol";
import "./IStaking.sol";

contract tokenStakingV2 is StakingStateV2, ReentrancyGuard, ERC1155Holder, IStaking {
    using SafeMath for uint;
    // uint internal constant PERCENT_DIVIDER = 1000; // 1000 = 100%, 100 = 10%, 10 = 1%, 1 = 0.1%
    IVault public vault;
    IContractsLibrary public contractsLibrary;
    IERC1155 public nft;

    mapping(address => RefData) public referrers;

    uint public constant minPool = 1;
    uint public poolsLength = 0;
    mapping(uint => mapping(address => UserInfo)) public users;

    mapping(address => uint) public lastBlock;
    mapping(uint => Pool) public pools;

    bool public forceAllowed;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(
        address indexed referrer,
        address indexed referral,
        uint256 indexed level,
        uint256 amount
    );
    event FeePayed(address indexed user, uint256 totalAmount);
    event Reinvestment(address indexed user, uint256 amount);
    event ForceWithdraw(address indexed user, uint256 amount);

    constructor(
        address _vault,
        address _library,
        address _token,
        address _nft
    ) {
        devAddress = msg.sender;
        vault = IVault(_vault);
        contractsLibrary = IContractsLibrary(_library);
        nft = IERC1155(_nft);

        pools[1] = Pool({
            token: _token,
            rewardToken: address(0),
            minimumDeposit: 0,
            roi: 30,
            bonusRoi: 30,
            roiStep: MONTH_STEP,
            rquirePool: 0,
            requireAmount: 0,
            blockDuration: MONTH_STEP,
            nftId: 0
        });

        pools[2] = Pool({
            token: _token,
            rewardToken: address(0),
            minimumDeposit: 0,
            roi: 50,
            bonusRoi: 50,
            roiStep: MONTH_STEP,
            rquirePool: 0,
            requireAmount: 0,
            blockDuration: MONTH_STEP * 2,
            nftId: 0
        });

        pools[3] = Pool({
            token: _token,
            rewardToken: address(0),
            minimumDeposit: 0,
            roi: 80,
            bonusRoi: 70,
            roiStep: MONTH_STEP,
            rquirePool: 0,
            requireAmount: 0,
            blockDuration: MONTH_STEP * 3,
            nftId: 0
        });

        poolsLength = 3;
    }

    modifier tenBlocks() {
        require(block.number.sub(lastBlock[msg.sender]) > 10, "wait 10 blocks");
        _;
        lastBlock[msg.sender] = block.number;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    modifier isNotContract() {
        require(!isContract(msg.sender), "contract not allowed");
        _;
    }

    function invest(
        uint _pool,
        uint amount
    )
        external
        nonReentrant
        whenNotPaused
        tenBlocks
        isNotContract
        hasNotStoppedProduction
    {
        require(amount > 0, "Amount must be greater than 0");
        require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
        UserInfo storage user = users[_pool][msg.sender];
        Pool memory pool = pools[_pool];
        require(user.stakingValue == 0, "User already invested");

        if (pool.rquirePool > 0) {
            require(
                users[pool.rquirePool][msg.sender].totalDeposit >=
                    pool.requireAmount,
                "Require amount"
            );
        }
        if (pool.minimumDeposit > 0) {
            require(amount >= pool.minimumDeposit, "Minimum deposit");
        }

        IERC20(pool.token).transferFrom(msg.sender, address(vault), amount);

        RefData storage refData = referrers[msg.sender];
        if (!refData.exists) {
            refData.exists = true;
            totalUsers++;
            emit Newbie(msg.sender);
        }

        if (user.user == address(0)) {
            user.user = msg.sender;
            investors[_pool][totalUsers] = msg.sender;
        }
        updateDeposit(msg.sender, _pool);
        users[_pool][msg.sender].investment += amount;

        if (pool.token == pool.rewardToken) {
            users[_pool][msg.sender].stakingValue += amount;
        } else if (pool.rewardToken == address(0)) {
            users[_pool][msg.sender].stakingValue += contractsLibrary
                .getTokensToBnb(pool.token, amount);
        } else {
            users[_pool][msg.sender].stakingValue += contractsLibrary
                .getTokenToBnbToAltToken(pool.token, pool.rewardToken, amount);
        }
        users[_pool][msg.sender].totalDeposit += amount;

        totalInvested[_pool] += amount;
        totalDeposits[_pool]++;

        if (user.nextWithdraw == 0) {
            user.nextWithdraw = block.timestamp + HARVEST_DELAY;
        }

        user.unlockDate = block.timestamp + pool.blockDuration;

        emit NewDeposit(msg.sender, amount);
    }

    function payBonus(uint _pool) external nonReentrant
        whenNotPaused
        tenBlocks
        isNotContract
        hasNotStoppedProduction {
            require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
            UserInfo storage user = users[_pool][msg.sender];
            require(user.stakingValue > 0, "User not invested");
            require(user.nftBalance == 0, "User already has bonus");
            require(user.unlockDate > block.timestamp, "Token is unlocked");
            Pool memory pool = pools[_pool];
            uint nftBalance = nft.balanceOf(msg.sender, pool.nftId);
            require(nftBalance > 0, "User has no NFT");
            updateDeposit(msg.sender, _pool);
            user.nftBalance = 1;
            nft.safeTransferFrom(msg.sender, address(this), pool.nftId, 1, "");
        }

    function payToUser(uint _pool, bool _withdraw) internal {
        require(userCanwithdraw(msg.sender, _pool), "User cannot withdraw");
        require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
        updateDeposit(msg.sender, _pool);
        uint fromVault;
        uint nftBalance;
        if (_withdraw) {
            require(
                block.timestamp >= users[_pool][msg.sender].unlockDate,
                "Token is locked"
            );
            fromVault = users[_pool][msg.sender].investment;
            nftBalance = users[_pool][msg.sender].nftBalance;
            delete users[_pool][msg.sender].investment;
            delete users[_pool][msg.sender].stakingValue;
            delete users[_pool][msg.sender].nextWithdraw;
            delete users[_pool][msg.sender].nftBalance;
            delete users[_pool][msg.sender].unlockDate;
        } else {
            users[_pool][msg.sender].nextWithdraw =
                block.timestamp +
                HARVEST_DELAY;
        }
        uint formThis = users[_pool][msg.sender].rewardLockedUp;
        delete users[_pool][msg.sender].rewardLockedUp;
        uint _toWithdraw = formThis;
        totalWithdrawn[_pool] += _toWithdraw;
        users[_pool][msg.sender].totalWithdrawn += _toWithdraw;
        if (fromVault > 0) {
            vault.safeTransfer(
                IERC20(pools[_pool].token),
                msg.sender,
                fromVault
            );
        }
        if(nftBalance > 0) {
            nft.safeTransferFrom(address(this), msg.sender, pools[_pool].nftId, nftBalance, "");
        }
        address tokenReward = pools[_pool].rewardToken;
        if (tokenReward == address(0)) {
            payable(msg.sender).transfer(formThis);
        } else {
            IERC20(tokenReward).transfer(msg.sender, formThis);
        }
        emit Withdrawn(msg.sender, _toWithdraw);
    }

    function harvest(
        uint _pool
    )
        external
        nonReentrant
        whenNotPaused
        tenBlocks
        isNotContract
        hasNotStoppedProduction
    {
        payToUser(_pool, false);
    }

    function withdraw(
        uint _pool
    )
        external
        nonReentrant
        whenNotPaused
        tenBlocks
        isNotContract
        hasNotStoppedProduction
    {
        payToUser(_pool, true);
    }

    function forceWithdraw(
        uint _pool
    ) external nonReentrant whenNotPaused tenBlocks isNotContract {
        require(userCanwithdraw(msg.sender, _pool), "User cannot withdraw");
        require(forceAllowed, "Force withdraw is not allowed");
        require(_pool >= minPool && _pool <= poolsLength, "Invalid pool");
        uint toTransfer = users[_pool][msg.sender].investment;
        delete users[_pool][msg.sender].rewardLockedUp;
        delete users[_pool][msg.sender].investment;
        delete users[_pool][msg.sender].stakingValue;
        delete users[_pool][msg.sender].nextWithdraw;
        delete users[_pool][msg.sender].unlockDate;
        // users[_pool][msg.sender].totalWithdrawn += toTransfer;
        delete users[_pool][msg.sender].depositCheckpoint;
        uint nftBalance = users[_pool][msg.sender].nftBalance;
        delete users[_pool][msg.sender].nftBalance;
        // totalWithdrawn[_pool] += toTransfer;
        require(toTransfer > 0, "Nothing to withdraw");
        vault.safeTransfer(IERC20(pools[_pool].token), msg.sender, toTransfer);
        if(nftBalance > 0) {
            nft.safeTransferFrom(address(this), msg.sender, pools[_pool].nftId, nftBalance, "");
        }

        emit ForceWithdraw(msg.sender, toTransfer);
    }

    function getReward(
        uint _weis,
        uint _seconds,
        uint _pool,
        address _user
    ) public view returns (uint) {
        Pool memory pool = pools[_pool];
        uint roi = pool.roi;
        if(users[_pool][_user].nftBalance > 0) {
            roi += pool.bonusRoi;
        }
        return
            (_weis * _seconds * roi) /
            (pool.roiStep * PERCENT_DIVIDER);
    }

    function userCanwithdraw(
        address user,
        uint _pool
    ) public view returns (bool) {
        if (block.timestamp > users[_pool][user].nextWithdraw) {
            if (users[_pool][user].stakingValue > 0) {
                return true;
            }
        }
        return false;
    }

    function getDeltaPendingRewards(
        address _user,
        uint _pool
    ) public view returns (uint) {
        if (users[_pool][_user].depositCheckpoint == 0) {
            return 0;
        }
        uint time = block.timestamp;
        if (stopProductionDate > 0 && time > stopProductionDate) {
            time = stopProductionDate;
        }
        if(time > users[_pool][_user].unlockDate) {
            time = users[_pool][_user].unlockDate;
        }

        if(time <= users[_pool][_user].depositCheckpoint) {
            return 0;
        }
        return
            getReward(
                users[_pool][_user].stakingValue,
                time.sub(users[_pool][_user].depositCheckpoint),
                _pool,
                _user
            );
    }

    function getUserTotalPendingRewards(
        address _user,
        uint _pool
    ) public view returns (uint) {
        return
            users[_pool][_user].rewardLockedUp +
            getDeltaPendingRewards(_user, _pool);
    }

    function updateDeposit(address _user, uint _pool) internal {
        users[_pool][_user].rewardLockedUp = getUserTotalPendingRewards(
            _user,
            _pool
        );
        users[_pool][_user].depositCheckpoint = block.timestamp;
    }

    function getUser(
        address _user,
        uint _pool
    ) external view returns (UserInfo memory userInfo_, uint pendingRewards) {
        userInfo_ = users[_pool][_user];
        pendingRewards = getUserTotalPendingRewards(_user, _pool);
    }

    function getAllUsers(uint _pool) external view returns (UserInfo[] memory) {
        UserInfo[] memory result = new UserInfo[](totalUsers);
        for (uint i = 0; i < totalUsers; i++) {
            result[i] = users[_pool][investors[_pool][i]];
        }
        return result;
    }

    function getUsersRange(uint _pool, uint _from, uint _to)
        external
        view
        returns (UserInfo[] memory)
    {
        require(_from < _to, "Invalid range");
        require(_to <= totalUsers, "Invalid range");
        UserInfo[] memory result = new UserInfo[](_to - _from);
        for (uint i = _from; i < _to; i++) {
            result[i - _from] = users[_pool][investors[_pool][i]];
        }
        return result;
    }

    function getUserByIndex(
        uint _pool,
        uint _index
    ) external view returns (UserInfo memory) {
        require(_index < totalUsers, "Index out of bounds");
        return users[_pool][investors[_pool][_index]];
    }

    function addPool(
        address _token,
        address _rewardToken,
        uint _minimumDeposit,
        uint roi,
        uint _bonusRoi,
        uint roiStep,
        uint _requirePool,
        uint _requireAmount,
        uint _blockDuration,
        uint _nftId
    ) external onlyOwner {
        poolsLength++;
        pools[poolsLength] = Pool({
            token: _token,
            rewardToken: _rewardToken,
            minimumDeposit: _minimumDeposit,
            roi: roi,
            bonusRoi: _bonusRoi,
            roiStep: roiStep,
            rquirePool: _requirePool,
            requireAmount: _requireAmount,
            blockDuration: _blockDuration,
            nftId: _nftId
        });
    }

    fallback() external payable {}

    receive() external payable {}

    function takeBNB() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    
    function takeTokens(address _token, uint _bal) external onlyOwner {
        IERC20(_token).transfer(msg.sender, _bal);
    }

    function setAllowForceWithdraw(bool _forceAllowed) external onlyOwner {
        forceAllowed = _forceAllowed;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StakingStateV2 {
    address public devAddress;
    mapping(uint => mapping(uint => address)) public investors;
    uint internal constant TIME_STEP = 1 days;
    uint internal constant MONTH_STEP = 30 * TIME_STEP;
    uint internal constant HARVEST_DELAY = TIME_STEP;
    // uint internal constant BLOCK_TIME_STEP = 30 * TIME_STEP;
    uint internal constant PERCENT_DIVIDER = 1000;
    uint internal constant REFERRER_PERCENTS = 50;

    uint public initDate;

    uint internal totalUsers;
    mapping(uint => uint) internal totalInvested;
    mapping(uint => uint) internal totalWithdrawn;
    mapping(uint => uint) internal totalReinvested;
    mapping(uint => uint) internal totalDeposits;
    mapping(uint => uint) internal totalReinvestCount;
    uint public stopProductionDate;
    bool public stopProductionVar;
    bool public referrer_is_allowed = true;

    event Paused(address account);
    event Unpaused(address account);

    modifier hasStoppedProduction() {
        require(hasStoppedProductionView(), "Production is not stopped");
        _;
    }

    modifier hasNotStoppedProduction() {
        require(!hasStoppedProductionView(), "Production is stopped");
        _;
    }

    function hasStoppedProductionView() public view returns (bool) {
        return stopProductionVar;
    }

    modifier onlyOwner() {
        require(devAddress == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(initDate > 0, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(initDate == 0, "Pausable: not paused");
        _;
    }

    function stopProduction() external onlyOwner {
        stopProductionVar = true;
        stopProductionDate = block.timestamp;
    }

    function unpause() external whenPaused onlyOwner {
        initDate = block.timestamp;
        emit Unpaused(msg.sender);
    }

    function isPaused() public view returns (bool) {
        return initDate == 0;
    }

    function getDAte() external view returns (uint) {
        return block.timestamp;
    }

    function getPublicData(uint _pool)
        external
        view
        returns (
            uint totalUsers_,
            uint totalInvested_,
            uint totalDeposits_,
            uint totalReinvested_,
            uint totalReinvestCount_,
            uint totalWithdrawn_,
            bool isPaused_
        )
    {
        totalUsers_ = totalUsers;
        totalInvested_ = totalInvested[_pool];
        totalDeposits_ = totalDeposits[_pool];
        totalReinvested_ = totalReinvested[_pool];
        totalReinvestCount_ = totalReinvestCount[_pool];
        totalWithdrawn_ = totalWithdrawn[_pool];
        isPaused_ = isPaused();
    }

    function getAllInvestors(
        uint _pool
    ) external view returns (address[] memory) {
        address[] memory investorsList = new address[](totalUsers);
        for (uint i = 0; i < totalUsers; i++) {
            investorsList[i] = investors[_pool][i];
        }
        return investorsList;
    }

    function getInvestorByIndex(
        uint _pool,
        uint index
    ) external view returns (address) {
        require(index < totalUsers, "Index out of range");
        return investors[_pool][index];
    }

    function setReferrerIsAllowed(
        bool _referrer_is_allowed
    ) external onlyOwner {
        referrer_is_allowed = _referrer_is_allowed;
    }
}
