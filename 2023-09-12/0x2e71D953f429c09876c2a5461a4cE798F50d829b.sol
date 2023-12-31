// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./libs/Pausable.sol";
import "./libs/ReentrancyGuard.sol";
import "./libs/TransferHelper.sol";
import "./libs/RevertReasonParser.sol";
import "./libs/SafeMath.sol";
import "./libs/Ownable.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV2.sol";
import "./interfaces/IUniswapV3Pool.sol";

contract BaseCore is Ownable, Pausable, ReentrancyGuard {
    using SafeMath for uint;
    struct ExactInputV2SwapParams {
        address dstReceiver; //to
        address wrappedToken; //gasToken
        address router; //router
        uint amount; //amountIn
        uint minReturnAmount; //minAmountOut
        uint deadline; //deadline
        address[] path;
        address[] pool;
    }

    struct ExactInputV3SwapParams {
        address srcToken; //fromToken
        address dstToken; //toToken
        address dstReceiver; //to
        address wrappedToken; //gasToken
        uint amount; //amountIn
        uint minReturnAmount; //minAmountOut
        uint deadline; //deadline
        address[] pools;
    }

    struct UniswapV3Pool {
        bool status;
        address factory;
        bytes initCodeHash;
    }

    uint public _aggregate_fee = 30;
    mapping(address => bool) public _wrapped_allowed;
    mapping(address => UniswapV3Pool) public allowedFactoryInitCodeHashList;
    mapping(address => bool) public WList;
    mapping(address => bool) public BList;
    mapping(address => bool) public WPoolList;

    event Receipt(uint time, address from, uint amount);
    event Withdraw(address indexed token, address indexed executor, address indexed recipient, uint amount);
    event setV3FactoryListEvent(uint[] poolIndex, address[] factories, bytes[] initCodeHash);
    event SwapEvent(address srcToken, address dstToken, address dstReceiver, uint amount, uint returnAmount, uint _timestamp, uint _blockNumber);
    event _verifyCallbackEvent(address _pool, bytes32 _poolSalt, address _caller, address _calcPool, address _factory);

    constructor() Ownable(msg.sender) {}

    function calculateTradeFee(uint tradeAmount, uint fee, address _fromToken, address _toToken, address _to) internal view returns (uint) {
        require(!BList[_fromToken] && !BList[_toToken] && !BList[_to] && !BList[msg.sender], "Unacceptable address");
        return (WList[_fromToken] || WList[_toToken] || WList[_to]) ? tradeAmount : tradeAmount.sub(fee);
    }

    function _emitSwapEvent(address _srcToken, address _dstToken, address _dstReceiver, uint _amount, uint _returnAmount, uint _timestamp, uint _blockNumber) internal {
        emit SwapEvent(
            _srcToken,
            _dstToken,
            _dstReceiver,
            _amount,
            _returnAmount,
            _timestamp,
            _blockNumber
        );
    }

    function setAggregateFee(uint newRate) external onlyExecutor {
        require(newRate >= 0 && newRate <= 1000, "fee rate is:0-1000");
        _aggregate_fee = newRate;
    }

    //whitelist
    function setWList(address[] memory _addressList, bool _status) external onlyExecutor {
        uint _num = _addressList.length;
        for (uint i = 0; i < _num; i++) {
            WList[_addressList[i]] = _status;
        }
    }

    //blacklist
    function setBList(address[] memory _addressList, bool _status) external onlyExecutor {
        uint _num = _addressList.length;
        for (uint i = 0; i < _num; i++) {
            BList[_addressList[i]] = _status;
        }
    }

    function setWPoolList(address[] memory _addressList, bool _status) external onlyExecutor {
        uint _num = _addressList.length;
        for (uint i = 0; i < _num; i++) {
            WPoolList[_addressList[i]] = _status;
        }
    }

    function setWrappedTokensList(address[] calldata wrappedTokens, bool _status) public onlyExecutor {
        uint _num = wrappedTokens.length;
        for (uint i = 0; i < _num; i++) {
            _wrapped_allowed[wrappedTokens[i]] = _status;
        }
    }

    function setV3FactoryList(address[] calldata factories, bytes[] calldata initCodeHash, bool _status) public onlyExecutor {
        require(factories.length == initCodeHash.length, "invalid data");
        uint len = factories.length;
        for (uint i; i < len; i++) {
            allowedFactoryInitCodeHashList[factories[i]] = UniswapV3Pool({
                status: _status,
                factory: factories[i],
                initCodeHash: initCodeHash[i]
            });
        }
    }

    function setPause(bool paused) external onlyExecutor {
        if (paused) {
            _pause();
        } else {
            _unpause();
        }
    }

    receive() external payable {
        emit Receipt(block.timestamp, msg.sender, msg.value);
    }
}// SPDX-License-Identifier: MIT
pragma solidity >=0.6.9;

interface IERC20 {

    function totalSupply() external view returns (uint);
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

}// SPDX-License-Identifier: MIT
pragma solidity >=0.6.9;

interface IUniswapV2 {
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IUniswapV3Pool {
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function fee() external view returns (uint24);

    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)
// Add executor extension

pragma solidity ^0.8.0;

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
abstract contract Ownable {

    address private _executor;
    address private _pendingExecutor;
    bool internal _initialized;

    event ExecutorshipTransferStarted(address indexed previousExecutor, address indexed newExecutor);
    event ExecutorshipTransferred(address indexed previousExecutor, address indexed newExecutor);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor(address newExecutor) {
        require(!_initialized, "Ownable: initialized");
        _transferExecutorship(newExecutor);
        _initialized = true;
    }

    /**
     * @dev Throws if called by any account other than the executor.
     */
    modifier onlyExecutor() {
        _checkExecutor();
        _;
    }

    /**
     * @dev Returns the address of the current executor.
     */
    function executor() public view virtual returns (address) {
        return _executor;
    }

    /**
     * @dev Returns the address of the pending executor.
     */
    function pendingExecutor() public view virtual returns (address) {
        return _pendingExecutor;
    }

    /**
     * @dev Throws if the sender is not the executor.
     */
    function _checkExecutor() internal view virtual {
        require(executor() == msg.sender, "Ownable: caller is not the executor");
    }

    /**
     * @dev Transfers executorship of the contract to a new account (`newExecutor`).
     * Can only be called by the current executor.
     */
    function transferExecutorship(address newExecutor) public virtual onlyExecutor {
        _pendingExecutor = newExecutor;
        emit ExecutorshipTransferStarted(executor(), newExecutor);
    }

    function _transferExecutorship(address newExecutor) internal virtual {
        delete _pendingExecutor;
        address oldExecutor = _executor;
        _executor = newExecutor;
        emit ExecutorshipTransferred(oldExecutor, newExecutor);
    }

    function acceptExecutorship() external {
        address sender = msg.sender;
        require(pendingExecutor() == sender, "Ownable: caller is not the new executor");
        _transferExecutorship(sender);
    }
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable {
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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
        emit Paused(msg.sender);
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
        emit Unpaused(msg.sender);
    }
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
    // Booleans are more expensive than uint or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint private constant _NOT_ENTERED = 1;
    uint private constant _ENTERED = 2;

    uint private _status;

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
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        assembly {
            sstore(_status.slot, _ENTERED)
        }
        _;
        assembly {
            sstore(_status.slot, _NOT_ENTERED)
        }
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
}// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

library RevertReasonParser {
    function parse(bytes memory data, string memory prefix) internal pure returns (string memory) {
        // https://solidity.readthedocs.io/en/latest/control-structures.html#revert
        // We assume that revert reason is abi-encoded as Error(string)

        // 68 = 4-byte selector 0x08c379a0 + 32 bytes offset + 32 bytes length
        if (data.length >= 68 && data[0] == "\x08" && data[1] == "\xc3" && data[2] == "\x79" && data[3] == "\xa0") {
            string memory reason;
            // solhint-disable no-inline-assembly
            assembly {
            // 68 = 32 bytes data length + 4-byte selector + 32 bytes offset
                reason := add(data, 68)
            }
            /*
                revert reason is padded up to 32 bytes with ABI encoder: Error(string)
                also sometimes there is extra 32 bytes of zeros padded in the end:
                https://github.com/ethereum/solidity/issues/10170
                because of that we can't check for equality and instead check
                that string length + extra 68 bytes is less than overall data length
            */
            require(data.length >= 68 + bytes(reason).length, "Invalid revert reason");
            return string(abi.encodePacked(prefix, "Error(", reason, ")"));
        }
        // 36 = 4-byte selector 0x4e487b71 + 32 bytes integer
        else if (data.length == 36 && data[0] == "\x4e" && data[1] == "\x48" && data[2] == "\x7b" && data[3] == "\x71") {
            uint code;
            // solhint-disable no-inline-assembly
            assembly {
            // 36 = 32 bytes data length + 4-byte selector
                code := mload(add(data, 36))
            }
            return string(abi.encodePacked(prefix, "Panic(", _toHex(code), ")"));
        }

        return string(abi.encodePacked(prefix, "Unknown(", _toHex(data), ")"));
    }

    function _toHex(uint value) private pure returns (string memory) {
        return _toHex(abi.encodePacked(value));
    }

    function _toHex(bytes memory data) private pure returns (string memory) {
        bytes16 alphabet = 0x30313233343536373839616263646566;
        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < data.length; i++) {
            str[2 * i + 2] = alphabet[uint8(data[i] >> 4)];
            str[2 * i + 3] = alphabet[uint8(data[i] & 0x0f)];
        }
        return string(str);
    }
}// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }

    function div(uint x, uint y) internal pure returns (uint z) {
        require(y != 0 , 'ds-math-div-zero');
        z = x / y;
    }

    function toInt256(uint256 value) internal pure returns (int256) {
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }
}// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

library TransferHelper {

    address private constant _ETH_ADDRESS = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    address private constant _ZERO_ADDRESS = address(0);

    function getEthAddress() external view returns (address) {
        uint chainId = block.chainid;
        if (chainId == 1) {
            return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        } else if (chainId == 5) {
            return 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
        } else if (chainId == 42161) {
            return 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
        } else if (chainId == 421613) {
            return 0xe39Ab88f8A4777030A534146A9Ca3B52bd5D43A3;
        } else if (chainId == 137) {
            return 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
        } else if (chainId == 80001) {
            return 0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889;
        } else if (chainId == 56) {
            return 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        } else if (chainId == 97) {
            return 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
        } else if (chainId == 204) {
            return 0x4200000000000000000000000000000000000006;
        } else if (chainId == 5611) {
            return 0x617d91847b74B70a3D3e3745445cb0d1b3c8560E;
        } else if (chainId == 324) {
            return 0x5AEa5775959fBC2557Cc8789bC1bf90A239D9a91;
        } else if (chainId == 8453) {
            return 0x4200000000000000000000000000000000000006;
        } else if (chainId == 369) {
            return 0xA1077a294dDE1B09bB078844df40758a5D0f9a27;
        } else {
            return 0x4200000000000000000000000000000000000006;
        }
    }

    function isETH(address token) internal pure returns (bool) {
        return (token == _ZERO_ADDRESS || token == _ETH_ADDRESS);
    }

    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_TOKEN_FAILED');
    }

    function safeTransferWithoutRequire(address token, address to, uint value) internal returns (bool) {
        // bytes4(keccak256(bytes('transfer(address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        // solium-disable-next-line
        (bool success,) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: TRANSFER_FAILED');
    }

    function safeDeposit(address wrapped, uint value) internal {
        // bytes4(keccak256(bytes('deposit()')));
        (bool success, bytes memory data) = wrapped.call{value: value}(abi.encodeWithSelector(0xd0e30db0));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: DEPOSIT_FAILED');
    }

    function safeWithdraw(address wrapped, uint value) internal {
        // bytes4(keccak256(bytes('withdraw(uint wad)')));
        (bool success, bytes memory data) = wrapped.call{value: 0}(abi.encodeWithSelector(0x2e1a7d4d, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: WITHDRAW_FAILED');
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./UniswapV2Router.sol";
import "./UniswapV3Router.sol";

contract SmartRouter is UniswapV2Router, UniswapV3Router {
    function withdrawTokens(address[] memory tokens, address recipient) external onlyExecutor {
        for (uint index; index < tokens.length; index++) {
            uint amount;
            if (TransferHelper.isETH(tokens[index])) {
                amount = address(this).balance;
                TransferHelper.safeTransferETH(recipient, amount);
            } else {
                amount = IERC20(tokens[index]).balanceOf(address(this));
                TransferHelper.safeTransferWithoutRequire(tokens[index], recipient, amount);
            }
            emit Withdraw(tokens[index], msg.sender, recipient, amount);
        }
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseCore.sol";

contract UniswapV2Router is BaseCore {
    using SafeMath for uint;

    struct BeforeSwapItem {
        uint fee;
        address[] path;
        address srcToken;
        address dstToken;
    }

    function _beforeSwap(ExactInputV2SwapParams calldata exactInput) internal returns (bool isFromETH, bool isToETH, uint actualAmountIn, address[] memory paths, uint thisAddressBeforeBalance, uint toBeforeBalance) {
        BeforeSwapItem memory kk;
        kk.fee = exactInput.amount.mul(_aggregate_fee).div(10000);
        require(exactInput.path.length == exactInput.pool.length + 1, "Invalid path");
        require(_wrapped_allowed[exactInput.wrappedToken], "Invalid wrapped address");
        kk.path = exactInput.path;
        kk.srcToken = exactInput.path[0];
        kk.dstToken = kk.path[exactInput.path.length - 1];
        actualAmountIn = calculateTradeFee(exactInput.amount, kk.fee, kk.srcToken, kk.dstToken, exactInput.dstReceiver);
        if (TransferHelper.isETH(kk.srcToken)) {
            isFromETH = true;
            require(msg.value == exactInput.amount, "Invalid msg.value");
            kk.path[0] = exactInput.wrappedToken;
            TransferHelper.safeDeposit(exactInput.wrappedToken, actualAmountIn);
        } else {
            isFromETH = false;
            if (kk.fee > 0) {
                TransferHelper.safeTransferFrom(kk.srcToken, msg.sender, address(this), kk.fee);
            }
        }
        if (TransferHelper.isETH(kk.dstToken)) {
            kk.path[kk.path.length - 1] = exactInput.wrappedToken;
            isToETH = true;
            thisAddressBeforeBalance = IERC20(exactInput.wrappedToken).balanceOf(address(this));
        } else {
            isToETH = false;
            toBeforeBalance = IERC20(kk.dstToken).balanceOf(exactInput.dstReceiver);
        }
        paths = kk.path;
    }

    function exactInputV2SwapAndGasUsed(ExactInputV2SwapParams calldata exactInput) external payable returns (uint returnAmount, uint gasUsed) {
        uint gasLeftBefore = gasleft();
        returnAmount = _executeV2Swap(exactInput);
        gasUsed = gasLeftBefore - gasleft();
    }

    function exactInputV2Swap(ExactInputV2SwapParams calldata exactInput) external payable returns (uint returnAmount) {
        returnAmount = _executeV2Swap(exactInput);
    }

    function _executeV2Swap(ExactInputV2SwapParams calldata exactInput) internal nonReentrant whenNotPaused returns (uint returnAmount) {
        require(exactInput.deadline >= block.timestamp, "Expired");
        address _router = exactInput.router;
        {
            (bool isFromETH, bool isToETH, uint actualAmountIn, address[] memory paths, uint thisAddressBeforeBalance, uint toBeforeBalance) = _beforeSwap(exactInput);
            if (isFromETH) {
                TransferHelper.safeTransfer(paths[0], exactInput.pool[0], actualAmountIn);
            } else {
                TransferHelper.safeTransferFrom(paths[0], msg.sender, exactInput.pool[0], actualAmountIn);
            }
            if (isToETH) {
                _swapSupportingFeeOnTransferTokens(_router, paths, exactInput.pool, address(this));
                returnAmount = IERC20(exactInput.wrappedToken).balanceOf(address(this)).sub(thisAddressBeforeBalance);
            } else {
                _swapSupportingFeeOnTransferTokens(_router, paths, exactInput.pool, exactInput.dstReceiver);
                returnAmount = IERC20(paths[paths.length - 1]).balanceOf(exactInput.dstReceiver).sub(toBeforeBalance);
            }
            require(returnAmount >= exactInput.minReturnAmount, "Too little received");
            if (isToETH) {
                TransferHelper.safeWithdraw(exactInput.wrappedToken, returnAmount);
                TransferHelper.safeTransferETH(exactInput.dstReceiver, returnAmount);
            }
        }
        _emitSwapEvent(exactInput.path[0], exactInput.path[exactInput.path.length - 1], exactInput.dstReceiver, exactInput.amount, returnAmount, block.timestamp, block.number);
    }

    function _swap(uint[] memory amounts, address[] memory path, address[] memory pool, address _to) internal {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = input < output ? (input, output) : (output, input);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            address to = i < path.length - 2 ? pool[i + 1] : _to;
            IUniswapV2(pool[i]).swap(
                amount0Out, amount1Out, to, new bytes(0)
            );
        }
    }

    function _swapSupportingFeeOnTransferTokens(address router, address[] memory path, address[] memory pool, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            address[] memory _path = new  address[](2);
            _path[0] = input;
            _path[1] = output;
            (address token0,) = input < output ? (input, output) : (output, input);
            IUniswapV2 pair = IUniswapV2(pool[i]);
            uint amountInput;
            uint amountOutput;
            {
                (uint reserve0, uint reserve1,) = pair.getReserves();
                //(uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                (uint reserveInput,) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
                //amountOutput = IUniswapV2(router).getAmountOut(amountInput, reserveInput, reserveOutput);
                amountOutput = (IUniswapV2(router).getAmountsOut(amountInput, _path))[1];
            }
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? pool[i + 1] : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseCore.sol";

contract UniswapV3Router is BaseCore {

    using SafeMath for uint;
    uint160 private constant MIN_SQRT_RATIO = 4295128739;
    uint160 private constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    fallback() external {
        (int256 amount0Delta, int256 amount1Delta, bytes memory _data) = abi.decode(msg.data[4 :], (int256, int256, bytes));
        _executeCallback(amount0Delta, amount1Delta, _data);
    }

    function pancakeV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata _data
    ) external {
        _executeCallback(amount0Delta, amount1Delta, _data);
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata _data
    ) external {
        _executeCallback(amount0Delta, amount1Delta, _data);
    }

    function _executeCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes memory _data
    ) internal {
        require(amount0Delta > 0 || amount1Delta > 0, "M0 or M1"); // swaps entirely within 0-liquidity regions are not supported
        (address pool, bytes memory tokenInAndPoolSalt) = abi.decode(_data, (address, bytes));
        (address tokenIn, bytes32 poolSalt,address factory) = abi.decode(tokenInAndPoolSalt, (address, bytes32, address));
        _verifyCallback(pool, poolSalt, msg.sender, factory);
        uint amountToPay = uint(amount1Delta);
        if (amount0Delta > 0) {
            amountToPay = uint(amount0Delta);
        }
        TransferHelper.safeTransfer(tokenIn, msg.sender, amountToPay);
    }

    function exactInputV3SwapAndGasUsed(ExactInputV3SwapParams calldata params) external payable returns (uint returnAmount, uint gasUsed) {
        uint gasLeftBefore = gasleft();
        returnAmount = _executeV3Swap(params);
        gasUsed = gasLeftBefore - gasleft();

    }

    function exactInputV3Swap(ExactInputV3SwapParams calldata params) external payable returns (uint returnAmount) {
        returnAmount = _executeV3Swap(params);
    }

    function _executeV3Swap(ExactInputV3SwapParams calldata params) internal nonReentrant whenNotPaused returns (uint returnAmount) {
        uint fee = params.amount.mul(_aggregate_fee).div(10000);
        require(params.pools.length > 0, "Empty pools");
        require(params.deadline >= block.timestamp, "Expired");
        require(_wrapped_allowed[params.wrappedToken], "Invalid wrapped address");
        address tokenIn = params.srcToken;
        address tokenOut = params.dstToken;
        uint actualAmountIn = calculateTradeFee(params.amount, fee, tokenIn, tokenOut, params.dstReceiver);
        uint toBeforeBalance;
        bool isToETH;
        if (TransferHelper.isETH(params.srcToken)) {
            tokenIn = params.wrappedToken;
            require(msg.value == params.amount, "Invalid msg.value");
            TransferHelper.safeDeposit(params.wrappedToken, actualAmountIn);
        } else {
            TransferHelper.safeTransferFrom(params.srcToken, msg.sender, address(this), params.amount);
        }
        if (TransferHelper.isETH(params.dstToken)) {
            tokenOut = params.wrappedToken;
            toBeforeBalance = IERC20(params.wrappedToken).balanceOf(address(this));
            isToETH = true;
        } else {
            toBeforeBalance = IERC20(params.dstToken).balanceOf(params.dstReceiver);
        }
        {
            uint len = params.pools.length;
            address recipient = address(this);
            bytes memory tokenInAndPoolSalt;
            bool _zeroForOne;
            if (len > 1) {
                address thisTokenIn = tokenIn;
                address thisTokenOut = address(0);
                for (uint i; i < len; i++) {
                    address thisPool = params.pools[i];
                    (thisTokenIn, tokenInAndPoolSalt, _zeroForOne) = _verifyPool(thisTokenIn, thisTokenOut, thisPool);
                    if (i == len - 1 && !isToETH) {
                        recipient = params.dstReceiver;
                        thisTokenOut = tokenOut;
                    }
                    actualAmountIn = _swap(recipient, thisPool, tokenInAndPoolSalt, actualAmountIn, _zeroForOne);
                }
                returnAmount = actualAmountIn;
            } else {
                (, tokenInAndPoolSalt, _zeroForOne) = _verifyPool(tokenIn, tokenOut, params.pools[0]);
                if (!isToETH) {
                    recipient = params.dstReceiver;
                }
                returnAmount = _swap(recipient, params.pools[0], tokenInAndPoolSalt, actualAmountIn, _zeroForOne);
            }
        }
        if (isToETH) {
            returnAmount = IERC20(params.wrappedToken).balanceOf(address(this)).sub(toBeforeBalance);
            require(returnAmount >= params.minReturnAmount, "Too little received");
            TransferHelper.safeWithdraw(params.wrappedToken, returnAmount);
            TransferHelper.safeTransferETH(params.dstReceiver, returnAmount);
        } else {
            returnAmount = IERC20(params.dstToken).balanceOf(params.dstReceiver).sub(toBeforeBalance);
            require(returnAmount >= params.minReturnAmount, "Too little received");
        }
        _emitSwapEvent(params.srcToken, params.dstToken, params.dstReceiver, params.amount, returnAmount, block.timestamp, block.number);
    }

    function _swap(address recipient, address pool, bytes memory tokenInAndPoolSalt, uint amount, bool _zeroForOne) internal returns (uint amountOut) {
        bool zeroForOne = _zeroForOne;
        address _pool = pool;
        if (zeroForOne) {
            (, int256 amount1) =
            IUniswapV3Pool(_pool).swap(
                recipient,
                zeroForOne,
                amount.toInt256(),
                MIN_SQRT_RATIO + 1,
                abi.encode(_pool, tokenInAndPoolSalt)
            );
            amountOut = SafeMath.toUint256(- amount1);
        } else {
            (int256 amount0,) =
            IUniswapV3Pool(_pool).swap(
                recipient,
                zeroForOne,
                amount.toInt256(),
                MAX_SQRT_RATIO - 1,
                abi.encode(_pool, tokenInAndPoolSalt)
            );
            amountOut = SafeMath.toUint256(- amount0);
        }
    }

    function _verifyPool(address tokenIn, address tokenOut, address pool) internal view returns (address nextTokenIn, bytes memory tokenInAndPoolSalt, bool zeroForOne) {
        IUniswapV3Pool iPool = IUniswapV3Pool(pool);
        address token0 = iPool.token0();
        address token1 = iPool.token1();
        uint24 fee = iPool.fee();
        address factory = iPool.factory();
        bytes32 poolSalt = keccak256(abi.encode(token0, token1, fee));
        if (tokenIn == token0) {
            if (tokenOut != address(0)) {
                require(tokenOut == token1, "Bad pool");
            }
            nextTokenIn = token1;
            tokenInAndPoolSalt = abi.encode(token0, poolSalt, factory);
            zeroForOne = true;
        } else {
            if (tokenOut != address(0)) {
                require(tokenOut == token0, "Bad pool");
            }
            nextTokenIn = token0;
            tokenInAndPoolSalt = abi.encode(token1, poolSalt, factory);
            zeroForOne = false;
        }
    }

    function _verifyCallback(address pool, bytes32 poolSalt, address caller, address factory) internal {
        UniswapV3Pool memory v3Pool = allowedFactoryInitCodeHashList[factory];
        require(v3Pool.status, "Callback bad pool 0");
        require(v3Pool.factory != address(0), "Callback bad pool 1");
        address calcPool = address(
            uint160(
                uint(
                    keccak256(
                        abi.encodePacked(
                            hex'ff',
                            v3Pool.factory,
                            poolSalt,
                            v3Pool.initCodeHash
                        )
                    )
                )
            )
        );
        if (!WPoolList[caller]) {
            require(calcPool == caller, "Callback bad pool 2");
        }
        emit _verifyCallbackEvent(pool, poolSalt, caller, calcPool, factory);
        require(pool == caller, "Callback bad pool 3");
    }

    function calculateInitCodeHash(bytes memory contractCode) public pure returns (bytes32) {
        bytes32 initCodeHash = keccak256(contractCode);
        return initCodeHash;
    }
}