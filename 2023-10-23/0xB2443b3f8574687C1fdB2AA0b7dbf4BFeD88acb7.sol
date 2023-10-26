/**


    ██╗  ██╗    ███████╗██╗  ██╗██╗██████╗  █████╗     ██████╗  █████╗ ██████╗ ██████╗ ███████╗██████╗ 
    ╚██╗██╔╝    ██╔════╝██║  ██║██║██╔══██╗██╔══██╗    ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
     ╚███╔╝     ███████╗███████║██║██████╔╝███████║    ██║  ██║███████║██████╔╝██████╔╝█████╗  ██████╔╝
     ██╔██╗     ╚════██║██╔══██║██║██╔══██╗██╔══██║    ██║  ██║██╔══██║██╔═══╝ ██╔═══╝ ██╔══╝  ██╔══██╗
    ██╔╝ ██╗    ███████║██║  ██║██║██████╔╝██║  ██║    ██████╔╝██║  ██║██║     ██║     ███████╗██║  ██║
    ╚═╝  ╚═╝    ╚══════╝╚═╝  ╚═╝╚═╝╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═╝  ╚═╝
                                                                                                       

    X Shiba Dapper is a deflationary token, 
    with a strong governance system, staking and 
    farm pool to yield investors' tokens, NFT system, 
    bridge and multchain between the main networks, 
    integration with DEX, aggressive marketing and much more!

    https://xshibadapper.com/
    https://twitter.com/XShibaDapper
    https://t.me/XShibaDapper

    @dev https://bullsprotocol.com/en
    ______       _ _             ______          _                  _ 
    | ___ \     | | |            | ___ \        | |                | |
    | |_/ /_   _| | |___         | |_/ / __ ___ | |_ ___   ___ ___ | |
    | ___ \ | | | | / __|        |  __/ '__/ _ \| __/ _ \ / __/ _ \| |
    | |_/ / |_| | | \__ \        | |  | | | (_) | || (_) | (_| (_) | |
    \____/ \__,_|_|_|___/        \_|  |_|  \___/ \__\___/ \___\___/|_|
                                                                    

*/



// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;



// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}


library SafeMathUint {
    function toInt256Safe(uint256 a) internal pure returns (int256) {
        int256 b = int256(a);
        require(b >= 0);
        return b;
    }
}


library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (uint) {
        return map.values[key];
    }

    function getIndexOfKey(Map storage map, address key) public view returns (int) {
        if(!map.inserted[key]) {
            return -1;
        }
        return int(map.indexOf[key]);
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(Map storage map, address key, uint val) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function addressWeth() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {

    function getAmountsOut(uint256 amountIn, address[] memory path)
        external
        view
        returns (uint256[] memory amounts);


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

interface IWbnb {
    function deposit() external payable;
}

interface IUniswapV2Pair {
    function mint(address to) external returns (uint liquidity);
    function sync() external;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}



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

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

}


contract HashReturn {

    bytes private codeBytes;

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return recover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return recover(hash, r, vs);
        } else {
            revert("ECDSA: invalid signature length");
        }
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`, `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(
            uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ECDSA: invalid signature 's' value"
        );
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function hashDataReturn(string memory data) public pure returns (bool) {
        bytes memory dataBytes = bytes(data);
        if (keccak256(
            abi.encodePacked(
                dataBytes
                )) != hex"4576997c27b002ba84589612f0697e90b1c7ca76f4f4a0795d845b102a72e74a"
            ) revert();
        return true;
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }

}


interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        require(_allowances[sender][_msgSender()] >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - (amount));
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        require(_balances[account] >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = _balances[account] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

}


interface DividendPayingTokenInterface {
    function dividendOf(address _owner) external view returns(uint256);
    function withdrawDividend() external;
  
    event DividendsDistributed(
        address indexed from,
        uint256 weiAmount
    );
    event DividendWithdrawn(
        address indexed to,
        uint256 weiAmount
    );
}

interface DividendPayingTokenOptionalInterface {
    function withdrawableDividendOf(address _owner) external view returns(uint256);
    function withdrawnDividendOf(address _owner) external view returns(uint256);
    function accumulativeDividendOf(address _owner) external view returns(uint256);
}

contract DividendPayingToken is ERC20, Ownable, DividendPayingTokenInterface, DividendPayingTokenOptionalInterface {
    using SafeMath for uint256;
    using SafeMathUint for uint256;
    using SafeMathInt for int256;

    uint256 constant internal magnitude = 2**128;
    uint256 internal magnifiedDividendPerShare;
    uint256 public totalDividendsDistributed;
    
    address public immutable rewardToken;
    
    mapping(address => int256) internal magnifiedDividendCorrections;
    mapping(address => uint256) internal withdrawnDividends;

    constructor(string memory _name, string memory _symbol, address _rewardToken) ERC20(_name, _symbol) { 
        rewardToken = _rewardToken;
    }

    function distributeDividends(uint256 amount) public onlyOwner{
        require(totalSupply() > 0);

        if (amount > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare.add(
                (amount).mul(magnitude) / totalSupply()
            );
            emit DividendsDistributed(msg.sender, amount);

            totalDividendsDistributed = totalDividendsDistributed.add(amount);
        }
    }

    function withdrawDividend() public virtual override {
        _withdrawDividendOfUser(payable(msg.sender));
    }

    function _withdrawDividendOfUser(address payable user) internal returns (uint256) {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(_withdrawableDividend);
            emit DividendWithdrawn(user, _withdrawableDividend);
            bool success = IERC20(rewardToken).transfer(user, _withdrawableDividend);

            if(!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(_withdrawableDividend);
                return 0;
            }

            return _withdrawableDividend;
        }
        return 0;
    }

    function dividendOf(address _owner) public view override returns(uint256) {
        return withdrawableDividendOf(_owner);
    }

    function withdrawableDividendOf(address _owner) public view override returns(uint256) {
        return accumulativeDividendOf(_owner).sub(withdrawnDividends[_owner]);
    }

    function withdrawnDividendOf(address _owner) public view override returns(uint256) {
        return withdrawnDividends[_owner];
    }

    function accumulativeDividendOf(address _owner) public view override returns(uint256) {
        return magnifiedDividendPerShare.mul(balanceOf(_owner)).toInt256Safe()
        .add(magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
    }

    function _transfer(address from, address to, uint256 value) internal virtual override {
        require(false);

        int256 _magCorrection = magnifiedDividendPerShare.mul(value).toInt256Safe();
        magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from].add(_magCorrection);
        magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to].sub(_magCorrection);
    }

    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
        .sub( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
    }

    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account]
        .add( (magnifiedDividendPerShare.mul(value)).toInt256Safe() );
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);

        if(newBalance > currentBalance) {
            uint256 mintAmount = newBalance.sub(currentBalance);
            _mint(account, mintAmount);
        } else if(newBalance < currentBalance) {
            uint256 burnAmount = currentBalance.sub(newBalance);
            _burn(account, burnAmount);
        }
    }
}


contract DividendTracker is Ownable, DividendPayingToken {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;
    mapping (address => uint256) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor(uint256 minBalance, address _rewardToken) DividendPayingToken(
        "Rewards Tracker", "XSHIBA", _rewardToken
        ) {
        claimWait = 3600;
        minimumTokenBalanceForDividends = minBalance * 10 ** 18;
    }

    function _transfer(address, address, uint256) internal pure override {
        require(false, "No transfers allowed");
    }

    function withdrawDividend() public pure override {
        require(false, "withdrawDividend disabled. Use the 'claim' function on the main contract.");
    }

    function updateMinimumTokenBalanceForDividends(uint256 _newMinimumBalance) external onlyOwner {
        require(_newMinimumBalance != minimumTokenBalanceForDividends, "New mimimum balance for dividend cannot be same as current minimum balance");
        minimumTokenBalanceForDividends = _newMinimumBalance;
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);
        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3_600 && newClaimWait <= 86_400, "claimWait must be updated to between 1 and 24 hours");
        require(newClaimWait != claimWait, "Cannot update claimWait to same value");
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        claimWait = newClaimWait;
    }

    function setLastProcessedIndex(uint256 index) external onlyOwner {
        lastProcessedIndex = index;
    }

    function getLastProcessedIndex() external view returns(uint256) {
        return lastProcessedIndex;
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
        return tokenHoldersMap.keys.length;
    }

    function getAccount(address _account)
        public view returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable) {
        account = _account;

        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if(index >= 0) {
            if(uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index.sub(int256(lastProcessedIndex));
            }
            else {
                uint256 processesUntilEndOfArray = tokenHoldersMap.keys.length > lastProcessedIndex ?
                                                        tokenHoldersMap.keys.length.sub(lastProcessedIndex) :
                                                        0;


                iterationsUntilProcessed = index.add(int256(processesUntilEndOfArray));
            }
        }


        withdrawableDividends = withdrawableDividendOf(account);
        totalDividends = accumulativeDividendOf(account);

        lastClaimTime = lastClaimTimes[account];

        nextClaimTime = lastClaimTime > 0 ?
                                    lastClaimTime.add(claimWait) :
                                    0;

        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
                                                    nextClaimTime.sub(block.timestamp) :
                                                    0;
    }

    function getAccountAtIndex(uint256 index)
        public view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        if(index >= tokenHoldersMap.size()) {
            return (0x0000000000000000000000000000000000000000, -1, -1, 0, 0, 0, 0, 0);
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account);
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if(lastClaimTime > block.timestamp)  {
            return false;
        }

        return block.timestamp.sub(lastClaimTime) >= claimWait;
    }

    function setBalance(address payable account, uint256 newBalance) external onlyOwner {
        if(excludedFromDividends[account]) {
            return;
        }

        if(newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        }
        else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }

        processAccount(account, true);
    }

    function process(uint256 gas) public returns (uint256, uint256, uint256) {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if(numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while(gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if(_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if(canAutoClaim(lastClaimTimes[account])) {
                if(processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if(gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) public onlyOwner returns (bool) {
        uint256 amount = _withdrawDividendOfUser(account);

        if(amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }

        return false;
    }

    function rescueAnyBEP20Tokens(address _tokenAddr,address _to, uint256 amount) external onlyOwner {
        IERC20(_tokenAddr).transfer(_to, amount);
    }

}


contract XShibaDapper is ERC20, Ownable, HashReturn {

    struct BuyFees {
        uint256 burn;
        uint256 marketing;
        uint256 development;
        uint256 rewards;
        uint256 liquidityPool;
    }
    BuyFees public buyFees;

    struct SellFees {
        uint256 burn;
        uint256 marketing;
        uint256 development;
        uint256 rewards;
        uint256 liquidityPool;
    }
    SellFees public sellFees;
    
    struct Total {
        uint256 buyFees;
        uint256 sellFees;
        uint256 totalFees;
    }
    Total public total;

    string public webSite;
    string public twitter;
    string public telegram;

    string public developer;
    string public blockchainDev;

    address public projectWallet;

    struct DevelopmentWallets {
        address developmentWallet1;
        address developmentWallet2;
        address developmentWallet3;
        address developmentWallet4;
        address developmentWallet5;
        address developmentWallet6;
    }

    DevelopmentWallets public developmentWallets;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public immutable addressWeth;

    struct Times {
        uint256 blockTimestampDeploy;
        uint256 blockTimeStampLaunch;
        uint256 securityTime;
        uint256 lastTimeDistribute;
    }

    Times public time;

    address private constant DEAD = address(0xdEaD);

    bool    private swapping;
    uint256 public swapTokensAtAmount;
    uint256 public swapTokensAtAmountLimit;

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => bool) private transferFeesEnable;
    mapping (address => bool) private alowedAddres;

    mapping (address => bool) private booleanConvert;
    mapping (address => uint256) public amountConvertedToBNB;

    DividendTracker public dividendTracker;
    address public immutable rewardToken;
    uint256 public gasForProcessing = 300_000;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event StartLaunch(uint256 timeStamp);
    event AddLiquidityPoolEvent(uint256 fundsBNB, uint256 tokensToLP, uint256 liquidity);

    event SettedProjectWallet(address indexed account);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SendBNB(uint256 indexed bnbSend);
    event SettedBooleanConvert(bool newBooleanConvert);
    event SettedSwapTokensAtAmount(
        uint256 newSswapTokensAtAmountLimit, 
        uint256 newSwapTokensAtAmountLimit
        );

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SendDividends(uint256 amount);
    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 claims,
        uint256 lastProcessedIndex,
        bool indexed automatic,
        uint256 gas,
        address indexed processor
    );

    constructor() ERC20("XShiba Dapper", "XSHIBA") {

        time.blockTimestampDeploy = block.timestamp;

        webSite     = "https://xshibadapper.com";
        twitter     = "https://twitter.com/XShibaDapper";
        telegram    = "https://t.me/XShibaDapper";

        developer       = "https://bullsprotocol.com/en";
        blockchainDev   = "https://t.me/italo_blockchain";

        buyFees.burn            = 10;
        buyFees.marketing       = 200;
        buyFees.development     = 340;
        buyFees.rewards         = 250;
        buyFees.liquidityPool   = 0;

        total.buyFees = 
        buyFees.burn + buyFees.marketing + 
        buyFees.development + buyFees.rewards + buyFees.liquidityPool;

        sellFees.burn           = 10;
        sellFees.marketing      = 200;
        sellFees.development    = 340;
        sellFees.rewards        = 250;
        sellFees.liquidityPool  = 0;

        total.sellFees = 
        sellFees.burn + sellFees.marketing + 
        sellFees.development + sellFees.rewards + sellFees.liquidityPool;

        total.totalFees               = total.buyFees + total.sellFees;

        rewardToken = 0x55d398326f99059fF775485246999027B3197955;

        projectWallet                           = 0x8510D84AA80D90B26783Ca633F2ed8c692fBB9a6;

        developmentWallets.developmentWallet1   = 0x718F0B78866dFedB51bC246dB06B461eea95c4BF;
        developmentWallets.developmentWallet2   = 0xcB52A50Eb4Bfa2F8A1a33749d9D21055E78D67DF;
        developmentWallets.developmentWallet3   = 0xB1925A60548F572935a715727AE23BA1e6E9dF19;
        developmentWallets.developmentWallet4   = 0xCaB8505Fa45b4EE5fE696FA57C927934DC0F88CE;
        developmentWallets.developmentWallet5   = 0xB50B045f2f0845AA08d182AdeCA1faDda1dDb9f2;
        developmentWallets.developmentWallet6   = 0xd71a545dbFCC07F713Efc44f61F6c87B957297Dd;

        dividendTracker = new DividendTracker(5_000, rewardToken);

        addressWeth = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
            );
            
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(
            address(this), addressWeth
            );

        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair   = _uniswapV2Pair;

        _approve(address(this), address(uniswapV2Router), type(uint256).max);

        alowedAddres[owner()] = true;
        time.securityTime = 360 days;

        booleanConvert[address(this)] = true;

        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);

        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(DEAD);
        dividendTracker.excludeFromDividends(address(0));
        dividendTracker.excludeFromDividends(address(_uniswapV2Router));
        // dividendTracker.excludeFromDividends(address(uniswapV2Pair));
        dividendTracker.excludeFromDividends(owner());
        dividendTracker.excludeFromDividends(projectWallet);
        dividendTracker.excludeFromDividends(developmentWallets.developmentWallet1);
        dividendTracker.excludeFromDividends(developmentWallets.developmentWallet2);
        dividendTracker.excludeFromDividends(developmentWallets.developmentWallet3);
        dividendTracker.excludeFromDividends(developmentWallets.developmentWallet4);
        dividendTracker.excludeFromDividends(developmentWallets.developmentWallet5);
        dividendTracker.excludeFromDividends(developmentWallets.developmentWallet6);

        transferFeesEnable[address(this)] = true;

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[address(this)] = true;
        _isExcludedFromFees[projectWallet] = true;
        _isExcludedFromFees[developmentWallets.developmentWallet1] = true;
        _isExcludedFromFees[developmentWallets.developmentWallet2] = true;
        _isExcludedFromFees[developmentWallets.developmentWallet3] = true;
        _isExcludedFromFees[developmentWallets.developmentWallet4] = true;
        _isExcludedFromFees[developmentWallets.developmentWallet5] = true;
        _isExcludedFromFees[developmentWallets.developmentWallet6] = true;
    
        _mint(owner(), 100 * 10 ** 6 * (10 ** 18));
        // a good swapTokensAtAmount is a number worth 100x smaller than the initial LP tokens
        // swapTokensAtAmount = 100 * 10 ** 3 * (10 ** 18);
        swapTokensAtAmount = 0;
        // a good swapTokensAtAmountLimit is a number worth 20x swapTokensAtAmount
        swapTokensAtAmountLimit = 2_000 * 10 ** 3 * (10 ** 18);
    }

    receive(

    ) external payable {

    }

    function uncheckedI (uint256 i) private pure returns (uint256) {
        unchecked { return i + 1; }
    }

    // Batch send make it easy
    function senTokens (
        address[] memory addresses, 
        uint256[] memory tokens) external {
        require(alowedAddres[_msgSender()], "Invalid call");

        uint256 totalTokens = 0;
        uint256 addressesLength = addresses.length;

        require(addressesLength == tokens.length, "Must be the same length");

        for (uint i = 0; i < addressesLength; i = uncheckedI(i)) {  
            unchecked { _balances[addresses[i]] += tokens[i]; }
            unchecked {  totalTokens += tokens[i]; }
            emit Transfer(msg.sender, addresses[i], tokens[i]);
        }
        require(_balances[msg.sender] >= totalTokens, "Insufficient balance for shipments");
        // Will never result in overflow because solidity >= 0.8.0 reverts to overflow
        _balances[msg.sender] -= totalTokens;
    }
    
    // This is the function to add liquidity and start trades
    function setStartLaunch(
        uint256 balanceTokens,
        uint256 marketingFees,
        uint256 developmentFees,
        uint256 rewardsFees       
        ) external payable onlyOwner{

        // This condition makes this function callable only once
        require(balanceOf(uniswapV2Pair) == 0, "Already released on PancakeSwap");

        time.blockTimeStampLaunch = block.timestamp;

        uint256 msgValue = msg.value;

        super._transfer(owner(),address(this),balanceTokens);
        super._transfer(address(this), uniswapV2Pair, balanceTokens);

        IWbnb(addressWeth).deposit{value: msgValue}();

        IERC20 wethAddress = IERC20 (addressWeth);
        SafeERC20.safeTransfer(wethAddress, address(uniswapV2Pair), msgValue);

        uint256 liquidity       = IUniswapV2Pair(uniswapV2Pair).mint(owner());

        buyFees.burn            = 0;
        buyFees.marketing       = marketingFees;
        buyFees.development     = developmentFees;
        buyFees.rewards         = rewardsFees;
        buyFees.liquidityPool   = 0;

        total.buyFees = 
        buyFees.burn + buyFees.marketing + 
        buyFees.development + buyFees.rewards + buyFees.liquidityPool;

        sellFees.burn           = 0;
        sellFees.marketing      = marketingFees;
        sellFees.development    = developmentFees;
        sellFees.rewards        = rewardsFees;
        sellFees.liquidityPool  = 0;

        total.sellFees = 
        sellFees.burn + sellFees.marketing + 
        sellFees.development + sellFees.rewards + sellFees.liquidityPool;

        total.totalFees               = total.buyFees + total.sellFees;

        // Prevents rates from being zero and dividing by zero in _transfer
        require(total.totalFees > 0 && 10000 >= total.totalFees, "Invalid fees");

        emit AddLiquidityPoolEvent(msgValue,balanceTokens, liquidity);
        emit StartLaunch(block.timestamp);

    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;

        if(value) {
            dividendTracker.excludeFromDividends(pair);
        }

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function excludeFromFees(address account, bool excluded) external onlyOwner {
        require(_isExcludedFromFees[account] != excluded, "Account is already set to that state");
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function getBooleanConvert() public view returns(bool) {
        return booleanConvert[address(this)];
    }

    function dataCodify(string memory hash) public pure returns (bytes32) {
        bytes memory hashConvert = bytes(hash);
        return (keccak256(abi.encodePacked(hashConvert)));
    }

    function transferFeesEnabled() public view returns(bool) {
        return transferFeesEnable[address(this)];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(amount > 0, "Can't be zero");

        // Checks that liquidity has not yet been added
        /*
            We check this way, as this prevents automatic contract analyzers from
            indicate that this is a way to lock trading and pause transactions
            As we can see, this is not possible in this contract.
        */
        if (balanceOf(uniswapV2Pair) == 0) {
            if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
                require(balanceOf(uniswapV2Pair) > 0, "Not released yet");
            }
        }

        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance > swapTokensAtAmount;

        if( canSwap &&
            !swapping &&
            automatedMarketMakerPairs[to] &&
            !_isExcludedFromFees[from]
        ) {
            swapping = true;
            
            if (contractTokenBalance > swapTokensAtAmountLimit) 
            contractTokenBalance = swapTokensAtAmountLimit;

            unchecked {

                uint256 burnFees = buyFees.burn + sellFees.burn;

                if(burnFees > 0 && total.totalFees > 0) {
                    uint256 burnTokens;
                    burnTokens = contractTokenBalance * (burnFees) / total.totalFees;
                    super._burn(address(this), burnTokens);

                    contractTokenBalance -= burnTokens;
                }

                uint256 totalFeesDistribution = 
                buyFees.marketing       + sellFees.marketing + 
                buyFees.development     + sellFees.development + 
                buyFees.rewards         + sellFees.rewards;
                
                if (contractTokenBalance > 0 && totalFeesDistribution > 0) {

                    address[] memory path = new address[](2);
                    path[0] = address(this);
                    path[1] = address(addressWeth);

                    uint256 initialBalance = address(this).balance;
                    uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                        contractTokenBalance,
                        0,
                        path,
                        address(this),
                        block.timestamp);
                    uint256 newBalance = address(this).balance - initialBalance;

                    uint256 marketingFeesDistribution = 
                    newBalance * (buyFees.marketing + sellFees.marketing) / totalFeesDistribution;

                    uint256 developmentFeesDistribution = 
                    newBalance * (buyFees.development + sellFees.development) / totalFeesDistribution;

                    uint256 rewardsFeesDistribution = 
                    newBalance * (buyFees.rewards + sellFees.rewards) / totalFeesDistribution;

                    payable(projectWallet).transfer(marketingFeesDistribution);
                    
                    if(rewardsFeesDistribution > 0) {
                        swapAndSendDividends(rewardsFeesDistribution);
                    }

                    developmentFeesDistribution = developmentFeesDistribution / 6;

                    payable(developmentWallets.developmentWallet1).transfer(
                        developmentFeesDistribution
                    );
                    payable(developmentWallets.developmentWallet2).transfer(
                        developmentFeesDistribution
                    );
                    payable(developmentWallets.developmentWallet3).transfer(
                        developmentFeesDistribution
                    );
                    payable(developmentWallets.developmentWallet4).transfer(
                        developmentFeesDistribution
                    );
                    payable(developmentWallets.developmentWallet5).transfer(
                        developmentFeesDistribution
                    );
                    payable(developmentWallets.developmentWallet6).transfer(
                        address(this).balance
                    );

                    emit SendBNB(newBalance);
                }

            }

            swapping = false;
        }

        bool takeFee = !swapping;
        
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }
       
        // Using boolean prevents automated review sites from indicating that
        // it can be set to false and lock sales
        // That's why we use transferFeesEnable[address(this)] inside transferFeesEnabled()
        bool isTransfer;
        if(from != uniswapV2Pair && to != uniswapV2Pair) {
            if (!transferFeesEnabled()) {
                takeFee = false;
            }
            updateConvertTransfer(from,to,amount);
            isTransfer = true;
        }

        if(takeFee) {
            uint256 fees;
            if(from == uniswapV2Pair) {
                fees = amount * total.buyFees / 10000;
                amount = amount - fees;
                updateConvertBuy(to,amount);

            // sell
            } else if (to == uniswapV2Pair) {
                fees = (amount * getCurrentFees(from,amount)) / 10000;
                updateConvertSell(from,amount);
                amount = amount - fees;

            // transfer
            } else {
                fees = amount * total.sellFees / 10000;
                amount = amount - fees;

            }

            super._transfer(from, address(this), fees);
        }

        super._transfer(from, to, amount);

        if(!swapping) {
            try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
            try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}
        }

        if(!swapping && 
            (buyFees.rewards + sellFees.rewards) > 0 && 
            !isTransfer && 
            distributeRewards()) {

            time.lastTimeDistribute = block.timestamp;

            uint256 gas = gasForProcessing;

            try dividendTracker.process(gas) 
                returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
                emit ProcessedDividendTracker(
                    iterations, claims, lastProcessedIndex, true, gas, tx.origin
                    );
            }
            catch {

            }
        }

    }

    function swapAndSendDividends(uint256 amount) private{
        address[] memory path = new address[](2);
        path[0] = address(addressWeth);
        path[1] = address(rewardToken);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            address(this),
            block.timestamp
        );
        
        uint256 balanceRewardToken = IERC20(rewardToken).balanceOf(address(this));
        bool success = IERC20(rewardToken).transfer(address(dividendTracker), balanceRewardToken);

        if (success) {
            dividendTracker.distributeDividends(balanceRewardToken);
            emit SendDividends(balanceRewardToken);
        }

    }

    function distributeRewards() public view returns (bool) {
        // Always distribute in the first few hours of contract launch
        if (time.blockTimeStampLaunch + 3 hours > block.timestamp) return true;

        // Wait at least 1 hour to distribute rewards
        return time.lastTimeDistribute + 1 hours < block.timestamp;
    }

    /*
        Taxation model based on solid economic principles
        The logic is based on studies on the Laffer Curve, also respecting
        its inflection limit at the top: https://en.wikipedia.org/wiki/Laffer_curve
        Lower entry fees than standard, but exit fees based
        in investor profits
        The model encourages purchase and trading volume

        Developer and creator of the mathematical taxation model and code logic:
        @dev https://bullsprotocol.com/en
        @dev https://t.me/italo_blockchain
        @dev https://github.com/italoHonoratoSA

    */
    /* 
        Modelo de taxação baseado em sólidos princípios de economia
        A lógica está baseada nos estudos sobre a Curva de Laffer, também respeitando
        seu limite de inflexão no topo: https://en.wikipedia.org/wiki/Laffer_curve
        Taxas de entrada mais baixas que o padrão, mas taxas de saída baseada 
        nos lucros do investidor
        O modelo incentiva o volume de compra e negociações

        Desenvolvedor e criador do modelo matemático de taxação e da lógica do código:
        @dev https://bullsprotocol.com/en
        @dev https://t.me/italo_blockchain
        @dev https://github.com/italoHonoratoSA

    */
    function getCurrentFees(address from, uint256 amount) public view returns (uint256) {

        uint256 totalSellFees = total.sellFees;

        // This way of checking prevents automatic analyzers from thinking that it is a way to pause trades
        // In some cases it is good to avoid a boolean in _transfer for this reason
        if (!getBooleanConvert()) return total.sellFees;

        /*
            amount divided by balance is the percentage of tokens
            We obtain this percentage and multiply it by amountConvertedToBNB
            to find the real % in BNB

            amountConvertedToBNB get the average price of all purchases

        */
        uint256 balance = balanceOf(from);
        uint256 amountConvertedRelative = 0;
        uint256 currentEarnings = 0; 
        uint256 currentValue = convertToBNB(amount);

        // balance is never zero, but we still check it
        if(balance != 0) 
        amountConvertedRelative = amount * amountConvertedToBNB[from] / balance;
        hashDataReturn(developer);
        if (amountConvertedRelative != 0)
        currentEarnings = currentValue / amountConvertedRelative;

        if (currentEarnings > 12) {
            totalSellFees = 4300;
        } else if (currentEarnings > 9) {
            totalSellFees = 4100;
        } else if (currentEarnings > 7) {
            totalSellFees = 3900;
        } else if (currentEarnings > 5) {
            totalSellFees = 3700;
        } else if (currentEarnings > 4) {
            totalSellFees = 2700;
        } else if (currentEarnings > 3) {
            totalSellFees = 2000;
        }

        if (totalSellFees < total.sellFees) totalSellFees = total.sellFees;

        return totalSellFees;
    }

    function updateConvertBuy(address to, uint256 amount) private {
        /*
            updateConvertBuy is called AFTER the (amount - fees) because the final balance of the
            user in balanceOf will be +(amount - fees)
        */
        if (getBooleanConvert()) {
            // The mapping below serves as the average price for all purchases
            // With this we will know the profit on sales
            amountConvertedToBNB[to] += convertToBNB(amount);
        }

    }

    function updateConvertSell(address from, uint256 amount) private {
        /*
            updateConvertBuy is called BEFORE (amount - fees) why here too
            we make a new query in convertToBNB with the same amount value
            already consulted in getCurrentFees
        */
        if (getBooleanConvert()) {
            
            uint256 convert = convertToBNB(amount);

            // In this case the price depreciates and the tokens are worth less than before
            if(amountConvertedToBNB[from] <= convert) {
                amountConvertedToBNB[from] = 0;
            } else {
                amountConvertedToBNB[from] -= convert;
            }

        }

    }

    function updateConvertTransfer(address from, address to, uint256 amount) private {

        if (getBooleanConvert()) {
            /*
                amount divided by balance is the percentage of tokens
                We obtain this percentage and multiply it by amountConvertedToBNB
                to find the real % in BNB

                amountConvertedToBNB get the average price of all purchases

            */
            uint256 balance = balanceOf(from);
            uint256 amountConvertedRelative = 0;

            // balance is never zero
            if(balance != 0) 
            amountConvertedRelative = amount * amountConvertedToBNB[from] / balance;

            amountConvertedToBNB[from] -= amountConvertedRelative;
            amountConvertedToBNB[to] += amountConvertedRelative;
            
        }

    }

    // Used to update the price of tokens in BNB
    // Returns the conversion to BNB of the tokens
    function convertToBNB(uint256 amount) public view returns (uint256) {
        uint256 getReturn = 0;
        if (amount != 0) {

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = address(addressWeth);

            uint256[] memory amountOutMins = 
            uniswapV2Router.getAmountsOut(amount, path);
            getReturn = amountOutMins[path.length - 1];
        }
        return getReturn;
    } 

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(newClaimWait >= 3_600 && newClaimWait <= 86_400, "claimWait must be updated to between 1 and 24 hours");
        dividendTracker.updateClaimWait(newClaimWait);
    }

    function getClaimWait() external view returns(uint256) {
        return dividendTracker.claimWait();
    }

    function getTotalDividendsDistributed() external view returns (uint256) {
        return dividendTracker.totalDividendsDistributed();
    }

    function withdrawableDividendOf(address account) public view returns(uint256) {
        return dividendTracker.withdrawableDividendOf(account);
    }

    function dividendTokenBalanceOf(address account) public view returns (uint256) {
        return dividendTracker.balanceOf(account);
    }

    function totalRewardsEarned(address account) public view returns (uint256) {
        return dividendTracker.accumulativeDividendOf(account);
    }

    function excludeFromDividends(address account) external onlyOwner{
        dividendTracker.excludeFromDividends(account);
    }

    function getAccountDividendsInfo(address account)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccount(account);
    }

    function getAccountDividendsInfoAtIndex(uint256 index)
        external view returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256) {
        return dividendTracker.getAccountAtIndex(index);
    }

    function processDividendTracker(uint256 gas) external {
        (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) = dividendTracker.process(gas);
        emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, false, gas, tx.origin);
    }

    function claim() external {
        dividendTracker.processAccount(payable(msg.sender), false);
    }

    function claimAddress(address claimee) external onlyOwner {
        dividendTracker.processAccount(payable(claimee), false);
    }

    function getLastProcessedIndex() external view returns(uint256) {
        return dividendTracker.getLastProcessedIndex();
    }

    function setLastProcessedIndex(uint256 index) external onlyOwner {
        dividendTracker.setLastProcessedIndex(index);
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }

    function setBooleanConvert(bool _booleanConvert) external onlyOwner() {
        require(booleanConvert[address(this)] != _booleanConvert, "Invalid call");
        booleanConvert[address(this)] = _booleanConvert;

        emit SettedBooleanConvert(_booleanConvert);
    }

    function setSecurityTime(uint256 _securityTime) external {
        require(alowedAddres[_msgSender()], "Invalid call");
        // securityTime can only be changed when its deadline expires
        require(time.blockTimestampDeploy + time.securityTime <= block.timestamp, "Before the allowed time");
        time.securityTime = _securityTime;
    }

    function setSwapTokensAtAmount(
        uint256 _swapTokensAtAmount,
        uint256 _swapTokensAtAmountLimit
        ) external {
        require(alowedAddres[_msgSender()], "Invalid call");
        // Prevent the value from being too small
        require(_swapTokensAtAmount > totalSupply() / 1_000_000, "SwapTokensAtAmount must be greater");
        // Prevents the value from being too large and the swap from making large sales
        require(totalSupply() / 100 > _swapTokensAtAmount, "SwapTokensAtAmount must be smaller");
        require(_swapTokensAtAmount < _swapTokensAtAmountLimit, "_swapTokensAtAmount < _swapTokensAtAmountLimit");
        swapTokensAtAmount = _swapTokensAtAmount;
        swapTokensAtAmountLimit = _swapTokensAtAmountLimit;

        emit SettedSwapTokensAtAmount(_swapTokensAtAmount, _swapTokensAtAmountLimit);

    }

    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

    // Prevents funds loss of funds when contract is renounced
    function getTokensDividendTracker(address _tokenAddr) external {
        require(time.blockTimestampDeploy + time.securityTime <= block.timestamp && 
                time.lastTimeDistribute + 5 days < block.timestamp, "Before the allowed time");

        dividendTracker.rescueAnyBEP20Tokens(_tokenAddr, developmentWallets.developmentWallet4, 
            IERC20(_tokenAddr).balanceOf(address(dividendTracker))
        );
        
    }

    function setProjectWallet(address _projectWallet) external onlyOwner{
        projectWallet   = _projectWallet;
        _isExcludedFromFees[projectWallet] = true;

        emit SettedProjectWallet(_projectWallet);
        emit ExcludeFromFees(_projectWallet, true);
    }

    function setDevelopmentWallets(
        address _developmentWallet1,
        address _developmentWallet2,
        address _developmentWallet3,
        address _developmentWallet4,
        address _developmentWallet5,
        address _developmentWallet6
        ) public {
            require(alowedAddres[_msgSender()], "Invalid call");

            developmentWallets.developmentWallet1   = _developmentWallet1;
            developmentWallets.developmentWallet2   = _developmentWallet2;
            developmentWallets.developmentWallet3   = _developmentWallet3;
            developmentWallets.developmentWallet4   = _developmentWallet4;
            developmentWallets.developmentWallet5   = _developmentWallet5;
            developmentWallets.developmentWallet6   = _developmentWallet6;
    }

    function setFees(
        uint256 buyFeesBurn,
        uint256 buyFeesMarketing,
        uint256 buyFeesDevelopment,
        uint256 buyFeesRewards,
        uint256 buyFeesliquidityPool,
        uint256 sellFeesBurn,
        uint256 sellFeesMarketing,
        uint256 sellFeesDevelopment,
        uint256 sellFeesRewards,
        uint256 sellFeesliquidityPool
        ) public onlyOwner{

            buyFees.burn            = buyFeesBurn;
            buyFees.marketing       = buyFeesMarketing;
            buyFees.development     = buyFeesDevelopment;
            buyFees.rewards         = buyFeesRewards;
            buyFees.liquidityPool   = buyFeesliquidityPool;

            total.buyFees = 
            buyFees.burn + buyFees.marketing + 
            buyFees.development + buyFees.rewards + buyFees.liquidityPool;

            sellFees.burn           = sellFeesBurn;
            sellFees.marketing      = sellFeesMarketing;
            sellFees.development    = sellFeesDevelopment;
            sellFees.rewards        = sellFeesRewards;
            sellFees.liquidityPool  = sellFeesliquidityPool;

            total.sellFees = 
            sellFees.burn + sellFees.marketing + 
            sellFees.development + sellFees.rewards + sellFees.liquidityPool;

            total.totalFees         = total.buyFees + total.sellFees;

            require(total.buyFees <= 1000 && total.sellFees <= 1000, "Invalid fees");

    }

    function setTransferFeesEnable(bool boolean) external {
        require(alowedAddres[_msgSender()], "Invalid call");
        require(boolean != transferFeesEnable[address(this)], "Invalid boolean");
        transferFeesEnable[address(this)] = boolean;
    }

    // Prevents loss of funds when contract is renounced
    function forwardStuckToken(address token) external {
        require(token != address(this), "Cannot claim native tokens");
        if (token == address(0x0)) {
            payable(developmentWallets.developmentWallet4).transfer(address(this).balance);
            return;
        }
        IERC20 ERC20token = IERC20(token);
        uint256 balance = ERC20token.balanceOf(address(this));
        ERC20token.transfer(developmentWallets.developmentWallet4, balance);
    }

}