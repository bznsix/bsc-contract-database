// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./interfaces/IFee.sol";
import "./interfaces/IHRC20.sol";
import "./interfaces/IPair.sol";
import "./interfaces/IWETH.sol";
import "./utils/Convert.sol";
import "./utils/PancakeLibrary.sol";
import "./utils/EnumStringSet.sol";
import "./utils/TransferHelper.sol";

contract HGSwapBscBridge is Ownable, ReentrancyGuard, Pausable {
    using Convert for bytes;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumStringSet for EnumStringSet.StringSet;
    using SafeMath for uint;

    EnumStringSet.StringSet chains;
    EnumerableSet.AddressSet relayers;

    struct CrossChainRequest {
        uint nonce;

        uint amountIn;
        uint amountOutMin;

        uint timestamp;
        uint deadline;

        address fromAsset;
        address from;

        string toChain;
        string toAsset;
        string to;
    }

    struct CrossChainResponse {
        bool isBreak;
        uint fee;

        uint amountIn;
        uint amountOut;

        uint timestamp;
        uint deadline;

        address toAsset;
        address to;

        string fromChain;
        string from;
    }

    struct LowerLimit {
        uint amount0OutMin;
        uint amount1OutMin;
        uint rewardsMin;
    }

    // HECO to XXX
    CrossChainRequest[] public requests;
    mapping(bytes32 => uint) public requestNonce;

    // Network => RequestHash => Response
    mapping(bytes32 => mapping(bytes32 => CrossChainResponse)) public responses;

    uint public minAmountPerSwap;
    uint public maxAmountPerSwap;

    address public bridgeToken;
    address public feeModel;

    address public custodian;
    address public governor;

    address public WBNB;
    address public pancakeFactory;

    modifier onlyGov() {
        require(msg.sender == governor, 'HGSwapBscBridge: NOT_THE_GOVERNOR');
        _;
    }

    modifier onlyCustodian() {
        require(msg.sender == custodian, 'HGSwapBscBridge: NOT_THE_CUSTODIAN');
        _;
    }

    modifier onlyRelayer() {
        require(relayers.contains(msg.sender), 'HGSwapBscBridge: NOT_THE_RELAYER');
        _;
    }

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'HGSwapBscBridge: EXPIRED');
        _;
    }

    constructor (
        address _wbnb,
        address _factory,
        address _custodian,
        address _token
    ) public {
        governor = msg.sender;
        WBNB = _wbnb;
        pancakeFactory = _factory;
        custodian = _custodian;
        bridgeToken = _token;
    }

    event SwapInPlace (
        uint amountIn,
        uint amountOut,
        uint fee,
        address fromAsset,
        address dex
    );

    event SwapCrossChain (
        bytes32 requestHash,
        uint nonce
    );

    event BridgeBalanceChanged(
        address token_,
        uint before_,
        uint after_
    );

    event TransferFees(
        address token,
        address from,
        address to,
        uint amount
    );

    event TransferRewards(
        address token,
        address from,
        address to,
        uint amount
    );

    /// @dev 链内兑换
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual ensure(deadline) whenNotPaused {
        uint amountOut = _swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, amountOutMin, path);
        uint feeAmount = _getBaseFee(amountOut);

        emit SwapInPlace(amountIn, amountOut, feeAmount, path[0], pancakeFactory);
        uint adjustedAmountOut = amountOut.sub(feeAmount);

        TransferHelper.safeTransfer(path[path.length - 1], to, adjustedAmountOut);
    }

    /// @dev 跨链兑换
    function swapExactTokensForTokensSupportingFeeOnTransferTokensCrossChain(
        uint amount0In,
        LowerLimit calldata limit,
        address[] calldata path,
        string memory to,
        uint deadline,
        string memory toChain,
        string memory toAsset
    ) external virtual payable ensure(deadline) whenNotPaused {
        require(path[path.length - 1] == bridgeToken, 'HGSwapBscBridge: INVALID_PATH');
        require(chains.contains(toChain), 'HGSwapBscBridge: INVALID_TARGET_CHAIN');

        uint balanceBefore = IHRC20(bridgeToken).balanceOf(address(this));
        uint amountOut;

        if (path.length == 1) {
            TransferHelper.safeTransferFrom(bridgeToken, msg.sender, address(this), amount0In);
            amountOut = amount0In;
        } else {
            amountOut = _swapExactTokensForTokensSupportingFeeOnTransferTokens(amount0In, limit.amount0OutMin, path);
        }

        require(amountOut <= maxAmountPerSwap, 'HGSwapBscBridge: EXCEED_UPPER_LIMIT');
        require(amountOut >= minAmountPerSwap, 'HGSwapBscBridge: UNDERS_LOWER_LIMIT');

        uint feeAmount = _getFee(msg.sender, amountOut, balanceBefore, limit.rewardsMin);
        emit SwapInPlace(amount0In, amountOut, feeAmount, path[0], pancakeFactory);
        uint amount1In = amountOut.sub(feeAmount);

        uint nonce = requests.length;
        CrossChainRequest memory request = CrossChainRequest({
            nonce: nonce,

            amountIn: amount1In,
            amountOutMin: limit.amount1OutMin,

            timestamp: block.timestamp,
            deadline: deadline,

            fromAsset: path[0],
            from: msg.sender,

            toChain: toChain,
            toAsset: toAsset,
            to: to
        });

        bytes32 requestHash = calcRequestHash(request);
        requestNonce[requestHash] = nonce;
        requests.push(request);

        emit SwapCrossChain(requestHash, nonce);
        emit BridgeBalanceChanged(bridgeToken, balanceBefore, IHRC20(bridgeToken).balanceOf(address(this)));
    }

    function _swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path
    ) internal virtual returns (uint) {
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, PancakeLibrary.pairFor(pancakeFactory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IHRC20(path[path.length - 1]).balanceOf(address(this));
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IHRC20(path[path.length - 1]).balanceOf(address(this)).sub(balanceBefore);
        require(amountOut >= amountOutMin, 'HGSwapBscBridge: INSUFFICIENT_OUTPUT_AMOUNT');
        return amountOut;
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual payable ensure(deadline) whenNotPaused {
        uint amountOut = _swapExactETHForTokensSupportingFeeOnTransferTokens(amountOutMin, path);
        uint feeAmount = _getBaseFee(amountOut);

        emit SwapInPlace(msg.value, amountOut, feeAmount, path[0], pancakeFactory);
        uint adjustedAmountOut = amountOut.sub(feeAmount);

        TransferHelper.safeTransfer(path[path.length - 1], to, adjustedAmountOut);
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokensCrossChain(
        LowerLimit calldata limit,
        address[] calldata path,
        string memory to,
        uint deadline,
        string memory toChain,
        string memory toAsset
    ) external virtual payable ensure(deadline) whenNotPaused {
        require(path[path.length - 1] == bridgeToken, 'HGSwapBscBridge: INVALID_PATH');
        require(chains.contains(toChain), 'HGSwapBscBridge: INVALID_TARGET_CHAIN');

        uint balanceBefore = IHRC20(bridgeToken).balanceOf(address(this));
        uint amountOut = _swapExactETHForTokensSupportingFeeOnTransferTokens(limit.amount0OutMin, path);

        require(amountOut <= maxAmountPerSwap, 'HGSwapBscBridge: EXCEED_UPPER_LIMIT');
        require(amountOut >= minAmountPerSwap, 'HGSwapBscBridge: UNDERS_LOWER_LIMIT');

        uint feeAmount = _getFee(msg.sender, amountOut, balanceBefore, limit.rewardsMin);
        emit SwapInPlace(msg.value, amountOut, feeAmount, path[0], pancakeFactory);
        uint amount1In = amountOut.sub(feeAmount);

        uint nonce = requests.length;
        CrossChainRequest memory request = CrossChainRequest({
            nonce: nonce,

            amountIn: amount1In,
            amountOutMin: limit.amount1OutMin,

            timestamp: block.timestamp,
            deadline: deadline,

            fromAsset: WBNB,
            from: msg.sender,

            toChain: toChain,
            toAsset: toAsset,
            to: to
        });

        bytes32 requestHash = calcRequestHash(request);
        requestNonce[requestHash] = nonce;
        requests.push(request);

        emit SwapCrossChain(requestHash, nonce);
        emit BridgeBalanceChanged(bridgeToken, balanceBefore, IHRC20(bridgeToken).balanceOf(address(this)));
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual ensure(deadline) whenNotPaused {
        uint amountOut = _swapExactTokensForETHSupportingFeeOnTransferTokens(amountIn, amountOutMin, path);
        uint feeAmount = _getBaseFee(amountOut);

        emit SwapInPlace(amountIn, amountOut, feeAmount, path[0], pancakeFactory);
        IWETH(WBNB).withdraw(amountOut);

        uint adjustedAmountOut = amountOut.sub(feeAmount);
        TransferHelper.safeTransferETH(to, adjustedAmountOut);
    }

    function _swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path
    ) internal virtual returns (uint) {
        require(path[0] == WBNB, 'HGSwapBscBridge: INVALID_PATH');
        uint amountIn = msg.value;
        IWETH(WBNB).deposit{value: amountIn}();
        assert(IWETH(WBNB).transfer(PancakeLibrary.pairFor(pancakeFactory, path[0], path[1]), amountIn));
        uint balanceBefore = IHRC20(path[path.length - 1]).balanceOf(address(this));
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IHRC20(path[path.length - 1]).balanceOf(address(this)).sub(balanceBefore);
        require(amountOut >= amountOutMin, 'HGSwapBscBridge: INSUFFICIENT_OUTPUT_AMOUNT');
        return amountOut;
    }

    function _swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path
    ) internal virtual returns (uint) {
        require(path[path.length - 1] == WBNB, 'HGSwapBscBridge: INVALID_PATH');
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, PancakeLibrary.pairFor(pancakeFactory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IHRC20(WBNB).balanceOf(address(this));
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IHRC20(WBNB).balanceOf(address(this)).sub(balanceBefore);
        require(amountOut >= amountOutMin, 'HGSwapBscBridge: INSUFFICIENT_OUTPUT_AMOUNT');
        return amountOut;
    }

    function _confirmSwapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) internal ensure(deadline) {
        TransferHelper.safeTransfer(
            path[0], PancakeLibrary.pairFor(pancakeFactory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IHRC20(path[path.length - 1]).balanceOf(address(this));
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IHRC20(path[path.length - 1]).balanceOf(address(this)).sub(balanceBefore);
        require(amountOut >= amountOutMin, 'HGSwapBscBridge: INSUFFICIENT_OUTPUT_AMOUNT');
        TransferHelper.safeTransfer(path[path.length - 1], to, amountOut);
    }

    function _confirmSwapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) internal ensure(deadline) {
        require(path[path.length - 1] == WBNB, 'HGSwapBscBridge: INVALID_PATH');
        TransferHelper.safeTransfer(
            path[0], PancakeLibrary.pairFor(pancakeFactory, path[0], path[1]), amountIn
        );
        uint balanceBefore = IHRC20(WBNB).balanceOf(address(this));
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IHRC20(WBNB).balanceOf(address(this)).sub(balanceBefore);
        require(amountOut >= amountOutMin, 'HGSwapBscBridge: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WBNB).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    function _getBaseFee(uint amountOut) internal returns (uint) {
        (uint fee, uint denom) = IFee(feeModel).getBaseFee();
        return amountOut.mul(fee).div(denom);
    }

    function _getFee(address user_, uint amount_, uint balance_, uint rewardsMin) internal returns (uint) {
        (uint feeAmount, uint rewards) = IFee(feeModel).getFee(user_, amount_, balance_);
        require(rewards >= rewardsMin, 'HGSwapBscBridge: REWARDS_TOO_LOWER');

        address treasury = IFee(feeModel).treasury();
        require(treasury != address(0), 'HGSwapBscBridge: TREASURY_ZERO_ADDRESS');

        if (feeAmount > 0) {
            TransferHelper.safeTransfer(bridgeToken, treasury, feeAmount);
            emit TransferFees(bridgeToken, user_, treasury, feeAmount);
        }

        if (rewards > 0) {
            TransferHelper.safeTransferFrom(bridgeToken, treasury, user_, rewards);
            emit TransferRewards(bridgeToken, treasury, user_, rewards);
        }

        return feeAmount;
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = PancakeLibrary.sortTokens(input, output);

            IPair pair = IPair(PancakeLibrary.pairFor(pancakeFactory, input, output));
            uint amountInput;
            uint amountOutput;

            { // scope to avoid stack too deep errors
                (uint reserve0, uint reserve1,) = pair.getReserves();
                (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
                amountInput = IHRC20(input).balanceOf(address(pair)).sub(reserveInput);
                amountOutput = PancakeLibrary.getAmountOut(amountInput, reserveInput, reserveOutput);
            }

            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
            address to = i < path.length - 2 ? PancakeLibrary.pairFor(pancakeFactory, output, path[i + 2]) : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));
        }
    }

    receive() external payable { }

    function requestLength() external view returns(uint) {
        return requests.length;
    }

    function calcRequestHash(CrossChainRequest memory request) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            request.nonce,

            request.amountIn,
            request.amountOutMin,

            request.timestamp,
            request.deadline,

            request.fromAsset,
            request.from,

            request.toChain,
            request.toAsset,
            request.to
        ));
    }

    /**
     * Relay Function
     */

    event ConfirmSwapCrossChain(
        bool isBreak,
        bytes32 requestHash,

        uint fee,
        uint amountIn,
        uint amountOut,

        address toAsset,
        address to,
        string fromChain,
        address dex
    );

    function confirmSwapCrossChain(
        bytes32 requestHash,
        uint fee,

        uint amountIn,
        uint amountOutMin,

        address[] calldata path,
        address to,
        uint deadline,

        string memory fromChain,
        string memory from
    ) external onlyRelayer nonReentrant {
        require(path[0] == bridgeToken, 'HGSwapBscBridge: INVALID_PATH');
        require(chains.contains(fromChain), 'HGSwapBscBridge: INVALID_SOURCE_NETWORK');
        require(amountIn > fee, 'HGSwapBscBridge: AMOUNT_IN_LESS_FEE');

        uint balanceBefore = IHRC20(bridgeToken).balanceOf(address(this));

        // deduct gas for relayer
        _transferGasToRelayer(msg.sender, fee);

        uint adjustedAmountIn = amountIn.sub(fee);
        uint amountOut = adjustedAmountIn;

        if (path.length > 1) {
            uint[] memory amountsOut = PancakeLibrary.getAmountsOut(pancakeFactory, adjustedAmountIn, path);
            amountOut = amountsOut[amountsOut.length - 1];
        }

        address toAsset = path[path.length - 1];

        _setResponse(
            requestHash,
            fee,
            amountIn,
            amountOut,
            amountOutMin,
            deadline,
            toAsset,
            to,
            fromChain,
            from
        );

        if (amountOut < amountOutMin || deadline < block.timestamp || path.length == 1) {
            TransferHelper.safeTransfer(bridgeToken, to, adjustedAmountIn);
        } else {
            if (path[path.length - 1] == WBNB) {
                _confirmSwapExactTokensForETHSupportingFeeOnTransferTokens(
                    adjustedAmountIn,
                    amountOutMin,
                    path,
                    to,
                    deadline
                );
            } else {
                _confirmSwapExactTokensForTokensSupportingFeeOnTransferTokens(
                    adjustedAmountIn,
                    amountOutMin,
                    path,
                    to,
                    deadline
                );
            }
        }

        emit BridgeBalanceChanged(bridgeToken, balanceBefore, IHRC20(bridgeToken).balanceOf(address(this)));
    }

    function _transferGasToRelayer(address relayer, uint fee) internal {
        if (fee > 0) {
            TransferHelper.safeTransfer(bridgeToken, PancakeLibrary.pairFor(pancakeFactory, bridgeToken, WBNB), fee);
            uint balanceBefore = IHRC20(WBNB).balanceOf(address(this));

            address[] memory _path = new address[](2);
            (_path[0], _path[1]) = (bridgeToken, WBNB);
            _swapSupportingFeeOnTransferTokens(_path, address(this));

            uint amountOut = IHRC20(WBNB).balanceOf(address(this)).sub(balanceBefore);
            require(amountOut > 0, 'HGSwapBscBridge: INSUFFICIENT_OUTPUT_FEE');

            IWETH(WBNB).withdraw(amountOut);
            TransferHelper.safeTransferETH(relayer, amountOut);
        }
    }

    function _setResponse(
        bytes32 requestHash,
        uint fee,
        uint amountIn,
        uint amountOut,
        uint amountOutMin,
        uint deadline,
        address toAsset,
        address to,
        string memory fromChain,
        string memory from
    ) internal {
        bytes32 fromChainHash = keccak256(abi.encodePacked(fromChain));
        CrossChainResponse storage response = responses[fromChainHash][requestHash];
        require(response.timestamp == 0, 'HGSwapBscBridge: SWAP_CROSS_CONFIRMED');

        response.fee = fee;
        response.amountIn = amountIn;
        response.amountOut = amountOut;
        response.timestamp = block.timestamp;
        response.deadline = deadline;
        response.toAsset = toAsset;
        response.to = to;
        response.fromChain = fromChain;
        response.from = from;

        if (amountOut < amountOutMin || deadline < block.timestamp) {
            response.isBreak = true;
        }

        emit ConfirmSwapCrossChain(
            response.isBreak,
            requestHash,
            fee,
            amountIn,
            amountOut,
            toAsset,
            to,
            fromChain,
            pancakeFactory
        );
    }

    /**
     * Admin Function
     */

    function withdrawal(address token, uint amount) external onlyCustodian {
        if (amount > 0) {
            uint _before = IHRC20(bridgeToken).balanceOf(address(this));

            if (token == WBNB) {
                uint256 wethBalance = IHRC20(token).balanceOf(address(this));
                if (wethBalance > 0) {
                    IWETH(WBNB).withdraw(wethBalance);
                }
                TransferHelper.safeTransferETH(custodian, amount);
            } else {
                TransferHelper.safeTransfer(token, custodian, amount);
            }

            uint _after = IHRC20(bridgeToken).balanceOf(address(this));
            if (_before != _after) {
                emit BridgeBalanceChanged(bridgeToken, _before, _after);
            }
        }
    }

    function pause() external onlyGov {
        _pause();
    }

    function unpause() external onlyGov {
        _unpause();
    }

    function setWETH(address _wbnb) external onlyGov {
        WBNB = _wbnb;
    }

    event SetBridgeFeeModel(address indexed feeModel);
    function setBridgeFeeModel(address feeModel_) external onlyGov {
        require(feeModel_ != address(0), "HGSwapBscBridge: ZERO_ADDRESS");
        feeModel = feeModel_;
    }

    event SetDexFactory(address indexed factory);
    function setPancakeFactory(address factory_) external onlyGov {
        require(factory_ != address(0), "HGSwapBscBridge: ZERO_ADDRESS");
        pancakeFactory = factory_;
        emit SetDexFactory(factory_);
    }

    event SetMinAmountPerSwap(uint indexed amount);
    function setMinAmountPerSwap(uint amount_) external onlyGov {
        minAmountPerSwap = amount_;
        emit SetMinAmountPerSwap(amount_);
    }

    event SetMaxAmountPerSwap(uint indexed amount);
    function setMaxAmountPerSwap(uint amount_) external onlyGov {
        maxAmountPerSwap = amount_;
        emit SetMaxAmountPerSwap(amount_);
    }

    event SetGov(address indexed governor);
    function setGov(address governor_) external onlyGov {
        require(governor_ != address(0), "HGSwapBscBridge: ZERO_GOVERNOR_ADDRESS");
        governor = governor_;
        emit SetGov(governor_);
    }

    event SetCustodian(address indexed custodian);
    function setCustodian(address custodian_) external onlyGov {
        require(custodian_ != address(0), "HGSwapBscBridge: ZERO_CUSTODIAN_ADDRESS");
        custodian = custodian_;
        emit SetCustodian(custodian_);
    }

    event SetBridgeToken(address indexed token);
    function setBridgeToken(address token_) external onlyGov {
        require(token_ != address(0), "HGSwapBscBridge: ZERO_BRIDGE_TOKEN");
        bridgeToken = token_;
        emit SetBridgeToken(token_);
    }

    function addRelayer(address relayer_) external onlyGov {
        require(relayer_ != address(0), "HGSwapBscBridge: ZERO_ADDRESS");
        bool result = relayers.add(relayer_);
        require(result, "HGSwapBscBridge: RELAYER_EXISTED");
    }

    function removeRelayer(address relayer_) external onlyGov {
        require(relayer_ != address(0), "HGSwapBscBridge: ZERO_ADDRESS");
        relayers.remove(relayer_);
    }

    function addChain(string memory chain_) external onlyGov {
        require(!isEmptyString(chain_), "HGSwapBscBridge: EMPTY_CHAIN_NAME");
        chains.add(chain_);
    }

    function removeChain(string memory chain_) external onlyGov {
        require(!isEmptyString(chain_), "HGSwapBscBridge: EMPTY_CHAIN_NAME");
        chains.remove(chain_);
    }

    function isEmptyString(string memory str) internal pure returns (bool) {
        return bytes(str).length == 0;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }


    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
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
        require(b > 0, "SafeMath: modulo by zero");
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
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
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
        require(b > 0, errorMessage);
        return a / b;
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
        require(b > 0, errorMessage);
        return a % b;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";

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
    constructor () internal {
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
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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

    constructor () internal {
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
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

interface IFee {
    function getBaseFee() external returns (uint, uint);
    function getFee(address user_, uint amount_, uint balance_) external returns (uint, uint);
    function treasury() external returns (address);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IHRC20 is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "./IHRC20.sol";

interface IPair is IHRC20 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

library Convert {
    function bytesToAddress(bytes memory bys) internal pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "../interfaces/IPair.sol";

library PancakeLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5' // init code hash
            ))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        pairFor(factory, tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'PancakeLibrary: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'PancakeLibrary: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'PancakeLibrary: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'PancakeLibrary: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(9975);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'PancakeLibrary: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.StringSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.StringSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`StringSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumStringSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as StringSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;

        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping (bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            // When the value to delete is the last one, the swap operation is unnecessary. However, since this occurs
            // so rarely, we still do the swap anyway to avoid the gas cost of adding an 'if' statement.

            bytes32 lastvalue = set._values[lastIndex];

            // Move the last value to the index where the value to delete is
            set._values[toDeleteIndex] = lastvalue;
            // Update the index for the moved value
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }

    // StringSet

    struct StringSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(StringSet storage set, string memory value) internal returns (bool) {
        return _add(set._inner, keccak256(abi.encodePacked(value)));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(StringSet storage set, string memory value) internal returns (bool) {
        return _remove(set._inner, keccak256(abi.encodePacked(value)));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(StringSet storage set, string memory value) internal view returns (bool) {
        return _contains(set._inner, keccak256(abi.encodePacked(value)));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(StringSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

   /**
    * @dev Returns the value stored at position `index` in the set. O(1).
    *
    * Note that there are no guarantees on the ordering of values inside the
    * array, and it may change when more values are added or removed.
    *
    * Requirements:
    *
    * - `index` must be strictly less than {length}.
    */
    function at(StringSet storage set, uint256 index) internal view returns (bytes32) {
    	return _at(set._inner, index);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
