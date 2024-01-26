// SPDX-License-Identifier: TINY TITANS ©

pragma solidity ^0.8.3;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
    function refillJackpot() external;
    function mintRewards(address _challenger, address _enemy) external;
}

interface IERC20Burnable is IERC20 {
    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
}

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

abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

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
    constructor () {
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

        require(_msgSender() == owner || ERC721.isApprovedForAll(owner, _msgSender()),
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
        return (spender == owner || getApproved(tokenId) == spender || ERC721.isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     d*
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

contract Constants {
    uint tokenAmountForMint = 250000000000000000;
    uint tokenForInstantRest = 10000000000000000;
    uint resCost = 100000000000000000;
    
    uint priceForHundretPowerUp = 1000000000000000;
    uint priceForTwoHundredPowerUp = 2000000000000000;
    uint priceForThreeHundretPowerUp = 3000000000000000;
    
    uint priceForFight = 10000000000000000;
    uint winnerXp = 21;
    uint loserXp = 7;
    
    address payable owner;
    address rev = payable(0xcD2B3C517D3De4F962dc01700dc57960CDbeB5E9);
}

contract Rand is Constants {
    
    uint internal nonce = 1;
    
    function setNonce(uint _nonce) internal {
        nonce = _nonce;
    }
    
    function _randModulus(uint _mod) internal returns(uint){
        uint rand = SafeMath.mod(uint(keccak256(abi.encodePacked(msg.sender, nonce))), _mod);
        nonce++;
        return rand;
    }

}

contract Statistics is Rand{
    
    ContractStatistics contractStatistics;
    
    struct ContractStatistics{
        uint totalFights;
        uint totalTitansStat;
        uint totalTitansSales;
        uint totalPowerupsBought;
    }
    
    function getContractStatistics() public view returns(ContractStatistics memory _stats){
        return contractStatistics;
    }
}

contract TinyTitans is ERC721, Statistics {
    
    event NewTitanMinted(uint indexed _id);
    event Rested();
    event InstantExhaustionResetBought();
    
    using Address for address;

    uint id;
    uint totalTitans;
    address titisAddress;

    mapping(address => bool) addressHasTitan;
    mapping(uint => address) titanToAddress;
    mapping(address => uint) addressToTitan;
    mapping(uint => Titan) indexToTitan;
    mapping(string => bool) nameTaken;
    mapping(address => uint) ttShare;

    uint[] public picArray;

    struct Titan{
        uint level;
        uint currentExperience;
        uint experienceForNextLevel;
        string name;
        uint hitPoints;
        uint basicDmg;
        uint stamina;
        uint attackPower;
        uint defense;
        uint initiative;
        uint agility;
        uint luck;
        uint image;
        address payable owner;
        uint fightsWon;
        uint fightsLost;
        uint exhaustion;
        uint lastTimeRested;
        uint hunger;
        uint lastTimeFed;
        bool alive;
        uint price;
        uint16[5] powerUps;
        bool hasPowerUps;
        uint restPoints;
        uint resCounter;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function ownerPayout() public onlyOwner {
        payable(owner).transfer(ttShare[owner]);
        ttShare[owner] = 0;
    }
    
    function getOwnerRewards() public view returns (uint){
        return ttShare[owner];
    }
    
    function adjustPrices(uint _tokenAmountForMint, uint _tokenForInstantRest, uint _resCost, uint _priceForHundretPowerUp, uint _priceForTwoHundredPowerUp,
    uint _priceForThreeHundretPowerUp, uint _priceForFight) public onlyOwner {
        tokenAmountForMint = _tokenAmountForMint;
        tokenForInstantRest = _tokenForInstantRest;
        resCost = _resCost;
        priceForHundretPowerUp = _priceForHundretPowerUp;
        priceForTwoHundredPowerUp = _priceForTwoHundredPowerUp;
        priceForThreeHundretPowerUp = _priceForThreeHundretPowerUp;
        priceForFight = _priceForFight;
    }

    constructor () {
        owner = payable(msg.sender);
        fillPicArray(300,0);
    }

    function revShareExec() internal {
        uint revShareWei = SafeMath.div(SafeMath.mul(msg.value,30), 100);
        payable(rev).transfer(revShareWei);
        ttShare[owner] = SafeMath.add(ttShare[owner], SafeMath.sub(msg.value, revShareWei));
    }
    
    function fillPicArray(uint _startValue, uint _endValue) public onlyOwner{
        for(uint i = _startValue; i > _endValue; i--){
            picArray.push(i);
        }
    }

    function setTitisAddress(address _address) public onlyOwner{
        titisAddress = _address;
    }
    
    function limitNameLength(string memory source) public pure returns (string memory) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
        return "";
    }
    bytes32 result;
    assembly {
        result := mload(add(source, 32))
    }
    
        uint8 i = 0;
        bytes32 _bytes32 = result;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    /**
     * @dev
     * user needs to call the approve directly on the ERC20 contract before creating the Titan
    */
    function createNewTitan(string memory _name) public payable{
        require(msg.value >= tokenAmountForMint);
        require(picArray.length > 0);
        require(!nameTaken[_name]);
        require(!addressHasTitan[msg.sender]);
        
        id = SafeMath.add(id, 1);
        
        Titan memory titan;
        titan.level = 1;
        titan.currentExperience = 0;
        titan.experienceForNextLevel = 100;
        titan.name = limitNameLength(_name);
        titan.hitPoints = SafeMath.add(10, Rand._randModulus(10));
        titan.basicDmg = SafeMath.add(3, Rand._randModulus(3));
        titan.stamina = SafeMath.add(1, Rand._randModulus(3));
        titan.attackPower = SafeMath.add(1, Rand._randModulus(3));
        titan.defense = SafeMath.add(1, _randModulus(1));
        titan.initiative = SafeMath.add(1, Rand._randModulus(3));
        titan.agility = SafeMath.add(1, Rand._randModulus(3));
        titan.luck = 1;
        titan.image = picArray[SafeMath.sub(picArray.length,1)];
        titan.owner = payable(msg.sender);
        titan.fightsWon = 0;
        titan.fightsLost = 0;
        titan.exhaustion = 0;
        titan.lastTimeRested = block.number;
        titan.hunger = 0;
        titan.lastTimeFed = block.number;
        titan.alive = true;
        titan.price = 0;
        titan.powerUps = [uint16(0),uint16(0),uint16(0),uint16(0),uint16(0)];
        titan.hasPowerUps = false;
        titan.restPoints = 0;
        titan.resCounter = 0;

        delete picArray[SafeMath.sub(picArray.length,1)];
        picArray.pop();
        
        addressHasTitan[msg.sender] = true;
        titanToAddress[id] = msg.sender;
        addressToTitan[msg.sender] = id;
        indexToTitan[id] = titan;
        nameTaken[_name] = true;

        _mint(msg.sender, id);
        totalTitans = SafeMath.add(totalTitans,1);
        contractStatistics.totalTitansStat = SafeMath.add(contractStatistics.totalTitansStat,1);
        revShareExec();
        emit NewTitanMinted(id);
    }

    function getOwnerOfTitan(uint _id) public view returns (address _owner){
        return titanToAddress[_id];
    }

    function checkAddressHasTitan(address _address) public view returns (bool _truefalse){
        return addressHasTitan[_address];
    }

    function getTitanIdByAddress(address _address) public view returns (uint _id){
        return addressToTitan[_address];
    }

    function getTotalTitans() public view returns(uint _amount){
        return totalTitans;
    }
    
    function _baseURI() internal pure override returns (string memory) {
        return "https://tinytitans.fi/titanMetadata/";
    }
    
}

contract RestHandler is TinyTitans {
      
      function getRestPoints(uint _id) public view returns (uint){
        uint lastTimeRested = indexToTitan[_id].lastTimeRested;
        uint rested = SafeMath.div(SafeMath.sub(block.number, lastTimeRested), 288);
        if (rested > 100){
            rested = 100;
        }
        return rested;
    }

    function rest() public {
        uint titanId = getTitanIdByAddress(msg.sender);
        uint rested = getRestPoints(titanId);
        if(rested > indexToTitan[titanId].exhaustion){
            indexToTitan[titanId].exhaustion = 0;
            indexToTitan[titanId].lastTimeRested = block.number;
        } else {
            indexToTitan[titanId].exhaustion = SafeMath.sub(indexToTitan[titanId].exhaustion, rested);
            indexToTitan[titanId].lastTimeRested = block.number;
        }
        emit Rested();
    }
    
    function buyInstantExhaustionReset() public payable{
        require(msg.value >= tokenForInstantRest);
        uint titanId = getTitanIdByAddress(msg.sender);
        indexToTitan[titanId].exhaustion = 0;
        indexToTitan[titanId].lastTimeRested = block.number;
        revShareExec();
        emit InstantExhaustionResetBought();
    }
}

contract Tamagotchi is RestHandler{
    
    event Fed();
    event Resurrected();
    
    modifier checkIfAlive() {
        uint hungerLevel = getHunger(addressToTitan[msg.sender]);
        if (hungerLevel < 100){
         _;   
        } else {
            indexToTitan[addressToTitan[msg.sender]].alive = false;
        }
    }
    
    modifier titanAlive() {
        if(indexToTitan[addressToTitan[msg.sender]].alive = true){
            _;
        }
    }
    
    function getHunger(uint _id) public view returns (uint _hungerLevel){
        uint lastTimeFed = indexToTitan[_id].lastTimeFed;
        uint hungerLevel = SafeMath.div(SafeMath.sub(block.number, lastTimeFed), 8640);
        if (hungerLevel > 100){
            hungerLevel = 100;
        }
        return hungerLevel;
    }
    
    function feed() public titanAlive {
        indexToTitan[addressToTitan[msg.sender]].hunger = 0;
        indexToTitan[addressToTitan[msg.sender]].lastTimeFed = block.number;
        emit Fed();
    }
    
    function resurrect() public payable{
        require(msg.value >= resCost);
        indexToTitan[addressToTitan[msg.sender]].hunger = 0;
        indexToTitan[addressToTitan[msg.sender]].lastTimeFed = block.number;
        indexToTitan[addressToTitan[msg.sender]].alive = true;
        indexToTitan[addressToTitan[msg.sender]].resCounter = SafeMath.add(indexToTitan[addressToTitan[msg.sender]].resCounter, 1);
        revShareExec();
        emit Resurrected();
    }
    
    function getTitanByIndex(uint _id) public view returns (Titan memory _titan){
        Titan memory titan = indexToTitan[_id];
        titan.restPoints = getRestPoints(_id);
        titan.hunger = getHunger(_id);
        if(getHunger(_id)==100){
            titan.alive = false;
        }
        return titan;
    }

}

contract LevelHandler is Tamagotchi {
    
    function checkLevelUp(uint _id) internal{
        Titan memory titan = getTitanByIndex(_id);
        if (titan.currentExperience >= titan.experienceForNextLevel){
            levelUp(_id);
        }
    }

    function levelUp(uint _id) internal{
        indexToTitan[_id].level = SafeMath.add(indexToTitan[_id].level, 1);
        indexToTitan[_id].currentExperience = SafeMath.sub(indexToTitan[_id].currentExperience, indexToTitan[_id].experienceForNextLevel);
        indexToTitan[_id].experienceForNextLevel = SafeMath.div(SafeMath.mul(indexToTitan[_id].experienceForNextLevel,11),10);
        indexToTitan[_id].hitPoints = SafeMath.add(indexToTitan[_id].hitPoints, Rand._randModulus(10));
        indexToTitan[_id].basicDmg = SafeMath.add(indexToTitan[_id].basicDmg, Rand._randModulus(3));
        indexToTitan[_id].stamina = SafeMath.add(indexToTitan[_id].stamina, Rand._randModulus(3));
        indexToTitan[_id].attackPower = SafeMath.add(indexToTitan[_id].attackPower, Rand._randModulus(3));
        indexToTitan[_id].defense = SafeMath.add(indexToTitan[_id].defense, _randModulus(3));
        indexToTitan[_id].initiative = SafeMath.add(indexToTitan[_id].initiative, Rand._randModulus(3));
        indexToTitan[_id].agility = SafeMath.add(indexToTitan[_id].agility, Rand._randModulus(3));
        if (indexToTitan[_id].level % 10 == 0 && indexToTitan[_id].luck < 5){
            indexToTitan[_id].luck = SafeMath.add(indexToTitan[_id].luck,1);
        }
    }
    
    
}

contract SellTinyTitan is LevelHandler {
    
    event ToMarketPlaceAdded(uint indexed _id);
    event FromMarketPlaceRemoved(uint indexed _id);
    event TitanSaleCanceled(uint indexed _id);
    
    constructor () {
    }
    
    function calcSellFee(uint _price) private pure returns(uint _fee){
        uint _reward=SafeMath.div(SafeMath.mul(_price, 5),100);
        return _reward;
    }

    function calcTitanOwnerReward(uint _price) public pure returns (uint){
        uint _reward=SafeMath.sub(_price, calcSellFee(_price));
        return _reward;
    }

    function putTitanForSale(uint _price) public {
        require(_price > 100);
        require(indexToTitan[getTitanIdByAddress(msg.sender)].price == 0);
        approve(address(this), getTitanIdByAddress(msg.sender));
        indexToTitan[getTitanIdByAddress(msg.sender)].price = _price;
        emit ToMarketPlaceAdded(getTitanIdByAddress(msg.sender));
    }

    function buyTitan(uint _id) public payable {
        require(!addressHasTitan[msg.sender]);
        require(msg.value >= indexToTitan[_id].price);
        address oldOwner = getOwnerOfTitan(_id);
        uint ownerReward = calcTitanOwnerReward(indexToTitan[_id].price);
        payable(oldOwner).transfer(ownerReward);
        uint fee = SafeMath.sub(msg.value, ownerReward);
        uint revSh= SafeMath.div(SafeMath.mul(fee,30), 100);
        payable(rev).transfer(revSh);
        ttShare[owner] = SafeMath.add(ttShare[owner], SafeMath.sub(fee, revSh));
        transferFrom(ownerOf(_id), msg.sender, _id);
        indexToTitan[_id].price = 0;
        indexToTitan[_id].owner = payable(msg.sender);
        contractStatistics.totalTitansSales = SafeMath.add(contractStatistics.totalTitansSales,1);
        emit FromMarketPlaceRemoved(_id);
    }
    
    function cancelTitanSale() public {
        indexToTitan[getTitanIdByAddress(msg.sender)].price = 0;
        emit TitanSaleCanceled(addressToTitan[msg.sender]);
    }
    
    function transferFrom(address from, address to, uint256 tokenId) public override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId) || _isApprovedOrOwner(address(this), tokenId), "ERC721: transfer caller is not owner nor approved");
        addressHasTitan[from] = false;
        addressHasTitan[to] = true;
        delete addressToTitan[from];
        titanToAddress[tokenId] = to;
        addressToTitan[to] = tokenId;
        indexToTitan[tokenId].owner = payable(to);
        _transfer(from, to, tokenId);
    }

}

contract Powerup is SellTinyTitan {

    event PowerupBought();

    modifier hasTitan{
         require(checkAddressHasTitan(msg.sender));
         _;
    }

    constructor(){
    }

    function buyPowerUps(uint _percStam, uint _percAp, uint _percDef, uint _percInit, uint _percAgi) public payable hasTitan checkIfAlive{
        uint titanId = getTitanIdByAddress(msg.sender);
        uint16[5] memory powerUpsPerc;
        uint totalPrice = 0;
        if(indexToTitan[titanId].hasPowerUps){
            (powerUpsPerc, totalPrice) = upgradePowerups(_percStam, _percAp, _percDef, _percInit, _percAgi);
        } else {
            (powerUpsPerc,totalPrice) = buyInitialPowerups(_percStam, _percAp, _percDef, _percInit, _percAgi);
        }
        require(msg.value >= totalPrice);
        indexToTitan[titanId].powerUps = powerUpsPerc;
        indexToTitan[titanId].hasPowerUps = true;
        emit PowerupBought();
    }
    
    function buyInitialPowerups(uint _percStam, uint _percAp, uint _percDef, uint _percInit, uint _percAgi) internal returns (uint16[5] memory array, uint _price){
        uint16[5] memory powerUpsPerc = [uint16(_percStam), uint16(_percAp), uint16(_percDef), uint16(_percInit), uint16(_percAgi)];
        uint totalPrice = 0;
        for (uint i=0; i<powerUpsPerc.length; i++) {
            if (powerUpsPerc[i] == 100){
              totalPrice = SafeMath.add(totalPrice,priceForHundretPowerUp);
              contractStatistics.totalPowerupsBought = SafeMath.add(contractStatistics.totalPowerupsBought,1);
            }
            if (powerUpsPerc[i] == 200){
              totalPrice = SafeMath.add(totalPrice,priceForTwoHundredPowerUp);
              contractStatistics.totalPowerupsBought = SafeMath.add(contractStatistics.totalPowerupsBought,1);
            }
            if (powerUpsPerc[i] == 300){
              totalPrice = SafeMath.add(totalPrice,priceForThreeHundretPowerUp);
              contractStatistics.totalPowerupsBought = SafeMath.add(contractStatistics.totalPowerupsBought,1);
            }
        }
        return (powerUpsPerc,totalPrice);
    }
    
    function upgradePowerups(uint _percStam, uint _percAp, uint _percDef, uint _percInit, uint _percAgi) internal returns (uint16[5] memory array, uint _price){
        uint titanId = getTitanIdByAddress(msg.sender);
        uint16[5] memory currentPowerups = indexToTitan[titanId].powerUps;
        uint16[5] memory updatePowerups = [uint16(_percStam), uint16(_percAp), uint16(_percDef), uint16(_percInit), uint16(_percAgi)];
        uint totalPrice = 0;
        for(uint i=0; i < currentPowerups.length; i++){
            if(updatePowerups[i] != 0){
                if(currentPowerups[i] == 0){
                    if(updatePowerups[i] == 100){
                        totalPrice = SafeMath.add(totalPrice, priceForHundretPowerUp);
                        contractStatistics.totalPowerupsBought = SafeMath.add(contractStatistics.totalPowerupsBought,1);
                    }
                    if(updatePowerups[i] == 200){
                        totalPrice = SafeMath.add(totalPrice, priceForTwoHundredPowerUp);
                        contractStatistics.totalPowerupsBought = SafeMath.add(contractStatistics.totalPowerupsBought,1);
                    }
                    if(updatePowerups[i] == 300){
                        totalPrice = SafeMath.add(totalPrice, priceForThreeHundretPowerUp);
                        contractStatistics.totalPowerupsBought = SafeMath.add(contractStatistics.totalPowerupsBought,1);
                    }
                }
                if(currentPowerups[i] == 100){
                    if(updatePowerups[i] == 200){
                        totalPrice = SafeMath.add(totalPrice, SafeMath.sub(priceForTwoHundredPowerUp,priceForHundretPowerUp));
                        contractStatistics.totalPowerupsBought = SafeMath.add(contractStatistics.totalPowerupsBought,1);
                    }
                    if(updatePowerups[i] == 300){
                        totalPrice = SafeMath.add(totalPrice, SafeMath.sub(priceForThreeHundretPowerUp,priceForHundretPowerUp));
                        contractStatistics.totalPowerupsBought = SafeMath.add(contractStatistics.totalPowerupsBought,1);
                    }
                }
                if(currentPowerups[i] == 200){
                    if(updatePowerups[i] == 300){
                        totalPrice = SafeMath.add(totalPrice, SafeMath.sub(priceForThreeHundretPowerUp,priceForTwoHundredPowerUp));
                        contractStatistics.totalPowerupsBought = SafeMath.add(contractStatistics.totalPowerupsBought,1);
                    }
                }
                if(currentPowerups[i]<updatePowerups[i]){
                    currentPowerups[i] = updatePowerups[i];
                }
            }
        }
        return(currentPowerups,totalPrice);
    }
    
    function removePowerups(uint _id) internal{
        indexToTitan[_id].powerUps = [0,0,0,0,0];
        indexToTitan[_id].hasPowerUps = false;
    }
    
    function createStatsArray(uint _id) internal view returns (uint[11] memory _statsarray){
        uint[11] memory _statsChallenger =  [_id, indexToTitan[_id].currentExperience, indexToTitan[_id].experienceForNextLevel,
        indexToTitan[_id].hitPoints, indexToTitan[_id].basicDmg, indexToTitan[_id].stamina,
        indexToTitan[_id].attackPower, indexToTitan[_id].defense, indexToTitan[_id].initiative,
        indexToTitan[_id].agility, indexToTitan[_id].luck];

        _statsChallenger[5] = SafeMath.add(_statsChallenger[6], SafeMath.div(_statsChallenger[6], 3));

        if(indexToTitan[_id].hasPowerUps){
            uint j = 5;
            uint16[5] memory _powerups = indexToTitan[_id].powerUps;
            for (uint i=0; i<_powerups.length; i++) {
                if (_powerups[i] > 0){
                    _statsChallenger[j] = SafeMath.add(_statsChallenger[j], SafeMath.div(SafeMath.mul(_statsChallenger[j],_powerups[i]),100));
                }
                j = SafeMath.add(j,1);
            }
        }

        return _statsChallenger;
    }

}

contract TinyTitanBrawl is Powerup{

    event BattleResult(uint indexed _winner, uint indexed _loser);
    
    constructor(){
    }

    function fightIndividual(uint _idEnemy) public payable hasTitan checkIfAlive{
        require(msg.value >= priceForFight);
        require(_idEnemy != addressToTitan[msg.sender]);
        require(_idEnemy <= totalTitans);
        uint idChallenger = getTitanIdByAddress(msg.sender);
        fight(idChallenger, _idEnemy);
        IERC20(titisAddress).mintRewards(msg.sender, getOwnerOfTitan(_idEnemy));
    }

    function fightRandom() public hasTitan checkIfAlive{
        require(indexToTitan[getTitanIdByAddress(msg.sender)].exhaustion < 100);
        uint idChallenger = getTitanIdByAddress(msg.sender);
        uint randomIndex = Rand._randModulus(totalTitans);

        if(randomIndex == idChallenger){
            randomIndex = SafeMath.add(randomIndex, 1);
            if(randomIndex > totalTitans){
                randomIndex = SafeMath.sub(randomIndex, 2);
            }
        }

        if(randomIndex == 0){
            if(idChallenger == totalTitans){
                randomIndex = SafeMath.sub(idChallenger,1);
            } else {
                randomIndex = SafeMath.add(idChallenger,1);
            }
        }
        fight(idChallenger, randomIndex);
        IERC20(titisAddress).mintRewards(msg.sender, getOwnerOfTitan(randomIndex));
    }

    function fight(uint _idChallenger, uint _idEnemy) internal returns(uint _winner){
        /**
         * 0 uint id;
         * 1 uint currentExperience;
         * 2 uint experienceForNextLevel;
         * 3 uint hitpoints;
         * 4 uint basic_dmg;
         * 5 uint stamina;
         * 6 uint attack_power;
         * 7 uint defense;
         * 8 uint initiative;
         * 9 uint agility;
         * 10 uint luck;
         */
        uint[11] memory statsChallenger = createStatsArray(_idChallenger);
        uint[11] memory statsEnemy = createStatsArray(_idEnemy);
        uint[11] memory attacker;
        uint[11] memory defender;
        uint[11] memory dummy;
        uint256 winnerTitan = 0;
        uint256 loserTitan = 0;
        
        if(statsChallenger[8] >= statsEnemy[8]){
            attacker = statsChallenger;
            defender = statsEnemy;
        }
        else{
            attacker = statsEnemy;
            defender = statsChallenger;
        }

        uint breaker = 1;

        do{
            if(attacker[9] >= _randModulus(SafeMath.add(attacker[9], defender[9]))){
                uint attack = SafeMath.add(attacker[4], SafeMath.div(attacker[6],3));
                uint damage = 1;
                if (attack > defender[7]){
                    damage = SafeMath.sub(attack, defender[7]);
                }
                if (damage < defender[3]){
                    defender[3] = SafeMath.sub(defender[3], damage);
                } else {
                    defender[3] = 0;
                }
            }

            if(defender[3] > 0){
                dummy = attacker;
                attacker = defender;
                defender = dummy;
            }
            else{
                winnerTitan = attacker[0];
                loserTitan = defender[0];
            }

            breaker = SafeMath.add(breaker,1);

            if(SafeMath.mod(breaker, 3)==0){
                if(attacker[3]<3){
                    attacker[3] = 0;
                } else {
                    attacker[3] = SafeMath.div(attacker[3],3);
                }
                
                if(defender[3]<3){
                    defender[3] = 0;
                } else {
                    defender[3] = SafeMath.div(defender[3],3);
                }
            }
        } while (winnerTitan == 0 && loserTitan == 0);

        removePowerups(_idChallenger);
        removePowerups(_idChallenger);
        
        if(indexToTitan[winnerTitan].alive){
        indexToTitan[winnerTitan].currentExperience = SafeMath.add(indexToTitan[winnerTitan].currentExperience, winnerXp);
        checkLevelUp(winnerTitan);
        }
        if(indexToTitan[loserTitan].alive){
        indexToTitan[loserTitan].currentExperience = SafeMath.add(indexToTitan[loserTitan].currentExperience, loserXp);
        checkLevelUp(loserTitan);
        }
        if(indexToTitan[statsChallenger[0]].alive){
            indexToTitan[statsChallenger[0]].exhaustion = SafeMath.add(indexToTitan[statsChallenger[0]].exhaustion, 20);
            if(indexToTitan[statsChallenger[0]].exhaustion > 100){
                indexToTitan[statsChallenger[0]].exhaustion = 100;
            }
        }
        if(indexToTitan[statsEnemy[0]].alive){
            indexToTitan[statsEnemy[0]].exhaustion = SafeMath.add(indexToTitan[statsEnemy[0]].exhaustion, 5);
            if(indexToTitan[statsEnemy[0]].exhaustion > 100){
                indexToTitan[statsEnemy[0]].exhaustion = 100;
            }
        }
        
        emit BattleResult(winnerTitan, loserTitan);
        
        setNonce(SafeMath.add(SafeMath.mul(winnerTitan, attacker[3]),defender[9]));
        contractStatistics.totalFights = SafeMath.add(contractStatistics.totalFights,1);
        indexToTitan[winnerTitan].fightsWon = SafeMath.add(indexToTitan[winnerTitan].fightsWon, 1);
        indexToTitan[loserTitan].fightsLost = SafeMath.add(indexToTitan[loserTitan].fightsLost, 1);
        return winnerTitan;

    }
}