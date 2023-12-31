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

pragma solidity 0.8.19;

interface IPositionRouter {
    function increasePositionRequestKeysStart() external returns (uint256);

    function decreasePositionRequestKeysStart() external returns (uint256);

    function executeIncreasePositions(uint256 _count, address payable _executionFeeReceiver) external;

    function executeDecreasePositions(uint256 _count, address payable _executionFeeReceiver) external;

    function executeIncreasePosition(bytes32 _key, address payable _executionFeeReceiver) external returns (bool);

    function cancelIncreasePosition(bytes32 _key, address payable _executionFeeReceiver) external returns (bool);

    function executeDecreasePosition(bytes32 _key, address payable _executionFeeReceiver) external returns (bool);

    function cancelDecreasePosition(bytes32 _key, address payable _executionFeeReceiver) external returns (bool);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IVaultPriceFeed {
    function adjustmentBasisPoints(address _token)
        external
        view
        returns (uint256);

    function isAdjustmentAdditive(address _token) external view returns (bool);

    function setAdjustment(
        address _token,
        bool _isAdditive,
        uint256 _adjustmentBps
    ) external;

    function setUseV2Pricing(bool _useV2Pricing) external;

    function setIsAmmEnabled(bool _isEnabled) external;

    function setIsSecondaryPriceEnabled(bool _isEnabled) external;

    function setSpreadBasisPoints(address _token, uint256 _spreadBasisPoints)
        external;

    function setSpreadThresholdBasisPoints(uint256 _spreadThresholdBasisPoints)
        external;

    function setFavorPrimaryPrice(bool _favorPrimaryPrice) external;

    function setPriceSampleSpace(uint256 _priceSampleSpace) external;

    function setMaxStrictPriceDeviation(uint256 _maxStrictPriceDeviation)
        external;

    function getPrice(
        address _token,
        bool _maximise,
        bool _includeAmmPrice,
        bool _useSwapPricing
    ) external view returns (uint256);

    function getAmmPrice(address _token) external view returns (uint256);

    function getLatestPrimaryPrice(address _token)
        external
        view
        returns (uint256);

    function getPrimaryPrice(address _token, bool _maximise)
        external
        view
        returns (uint256);

    function setTokenConfig(
        address _token,
        address _priceFeed,
        uint256 _priceDecimals,
        bool _isStrictStable,
        uint256 _stalePriceThreshold
    ) external;
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ISecondaryPriceFeed.sol";
import "./interfaces/IFastPriceFeed.sol";
import "./interfaces/IFastPriceEvents.sol";
import "../core/interfaces/IVaultPriceFeed.sol";
import "../core/interfaces/IPositionRouter.sol";

contract FastPriceFeed is ISecondaryPriceFeed, IFastPriceFeed, Ownable {
    // fit data in a uint256 slot to save gas costs
    struct PriceDataItem {
        uint160 refPrice; // Chainlink price
        uint32 refTime; // last updated at time
        uint32 cumulativeRefDelta; // cumulative Chainlink price delta
        uint32 cumulativeFastDelta; // cumulative fast price delta
    }

    uint256 public constant PRICE_PRECISION = 10**30;

    uint256 public constant CUMULATIVE_DELTA_PRECISION = 10 * 1000 * 1000;

    uint256 public constant MAX_REF_PRICE = type(uint160).max;
    uint256 public constant MAX_CUMULATIVE_REF_DELTA = type(uint32).max;
    uint256 public constant MAX_CUMULATIVE_FAST_DELTA = type(uint32).max;

    // uint256(~0) is 256 bits of 1s
    // shift the 1s by (256 - 32) to get (256 - 32) 0s followed by 32 1s
    uint256 public constant BITMASK_32 = type(uint256).max >> (256 - 32);

    uint256 public constant BASIS_POINTS_DIVISOR = 10000;

    uint256 public constant MAX_PRICE_DURATION = 30 minutes;

    bool public isInitialized;
    bool public isSpreadEnabled = false;

    address public vaultPriceFeed;
    address public fastPriceEvents;

    address public tokenManager;

    address public positionRouter;

    uint256 public override lastUpdatedAt;
    uint256 public override lastUpdatedBlock;

    uint256 public priceDuration;
    uint256 public maxPriceUpdateDelay;
    uint256 public spreadBasisPointsIfInactive;
    uint256 public spreadBasisPointsIfChainError;
    uint256 public minBlockInterval;
    uint256 public maxTimeDeviation;

    uint256 public priceDataInterval;

    // allowed deviation from primary price
    uint256 public maxDeviationBasisPoints;

    uint256 public minAuthorizations;
    uint256 public disableFastPriceVoteCount = 0;

    mapping(address => bool) public isUpdater;

    mapping(address => uint256) public prices;
    mapping(address => PriceDataItem) public priceData;
    mapping(address => uint256) public maxCumulativeDeltaDiffs;

    mapping(address => bool) public isSigner;
    mapping(address => bool) public disableFastPriceVotes;

    // array of tokens used in setCompactedPrices, saves L1 calldata gas costs
    address[] public tokens;
    // array of tokenPrecisions used in setCompactedPrices, saves L1 calldata gas costs
    // if the token price will be sent with 3 decimals, then tokenPrecision for that token
    // should be 10 ** 3
    uint256[] public tokenPrecisions;

    event DisableFastPrice(address signer);
    event EnableFastPrice(address signer);
    event PriceData(
        address token,
        uint256 refPrice,
        uint256 fastPrice,
        uint256 cumulativeRefDelta,
        uint256 cumulativeFastDelta
    );
    event MaxCumulativeDeltaDiffExceeded(
        address token,
        uint256 refPrice,
        uint256 fastPrice,
        uint256 cumulativeRefDelta,
        uint256 cumulativeFastDelta
    );

    modifier onlySigner() {
        require(isSigner[msg.sender], "FastPriceFeed: forbidden");
        _;
    }

    modifier onlyUpdater() {
        require(isUpdater[msg.sender], "FastPriceFeed: forbidden");
        _;
    }

    modifier onlyTokenManager() {
        require(msg.sender == tokenManager, "FastPriceFeed: forbidden");
        _;
    }

    constructor(
        uint256 _priceDuration,
        uint256 _maxPriceUpdateDelay,
        uint256 _minBlockInterval,
        uint256 _maxDeviationBasisPoints,
        address _fastPriceEvents,
        address _tokenManager,
        address _positionRouter
    ) {
        require(
            _priceDuration <= MAX_PRICE_DURATION,
            "FastPriceFeed: invalid _priceDuration"
        );
        priceDuration = _priceDuration;
        maxPriceUpdateDelay = _maxPriceUpdateDelay;
        minBlockInterval = _minBlockInterval;
        maxDeviationBasisPoints = _maxDeviationBasisPoints;
        fastPriceEvents = _fastPriceEvents;
        tokenManager = _tokenManager;
        positionRouter = _positionRouter;
    }

    function initialize(
        uint256 _minAuthorizations,
        address[] memory _signers,
        address[] memory _updaters
    ) public onlyOwner {
        require(!isInitialized, "FastPriceFeed: already initialized");
        isInitialized = true;

        minAuthorizations = _minAuthorizations;

        for (uint256 i = 0; i < _signers.length; i++) {
            address signer = _signers[i];
            isSigner[signer] = true;
        }

        for (uint256 i = 0; i < _updaters.length; i++) {
            address updater = _updaters[i];
            isUpdater[updater] = true;
        }
    }

    function setSigner(address _account, bool _isActive)
        external
        override
        onlyOwner
    {
        isSigner[_account] = _isActive;
    }

    function setUpdater(address _account, bool _isActive)
        external
        override
        onlyOwner
    {
        isUpdater[_account] = _isActive;
    }

    function setFastPriceEvents(address _fastPriceEvents) external onlyOwner {
        fastPriceEvents = _fastPriceEvents;
    }

    function setVaultPriceFeed(address _vaultPriceFeed)
        external
        override
        onlyOwner
    {
        vaultPriceFeed = _vaultPriceFeed;
    }

    function setMaxTimeDeviation(uint256 _maxTimeDeviation) external onlyOwner {
        maxTimeDeviation = _maxTimeDeviation;
    }

    function setPriceDuration(uint256 _priceDuration)
        external
        override
        onlyOwner
    {
        require(
            _priceDuration <= MAX_PRICE_DURATION,
            "FastPriceFeed: invalid _priceDuration"
        );
        priceDuration = _priceDuration;
    }

    function setMaxPriceUpdateDelay(uint256 _maxPriceUpdateDelay)
        external
        override
        onlyOwner
    {
        maxPriceUpdateDelay = _maxPriceUpdateDelay;
    }

    function setSpreadBasisPointsIfInactive(
        uint256 _spreadBasisPointsIfInactive
    ) external override onlyOwner {
        spreadBasisPointsIfInactive = _spreadBasisPointsIfInactive;
    }

    function setSpreadBasisPointsIfChainError(
        uint256 _spreadBasisPointsIfChainError
    ) external override onlyOwner {
        spreadBasisPointsIfChainError = _spreadBasisPointsIfChainError;
    }

    function setMinBlockInterval(uint256 _minBlockInterval)
        external
        override
        onlyOwner
    {
        minBlockInterval = _minBlockInterval;
    }

    function setIsSpreadEnabled(bool _isSpreadEnabled)
        external
        override
        onlyOwner
    {
        isSpreadEnabled = _isSpreadEnabled;
    }

    function setLastUpdatedAt(uint256 _lastUpdatedAt) external onlyOwner {
        lastUpdatedAt = _lastUpdatedAt;
    }

    function setTokenManager(address _tokenManager) external onlyTokenManager {
        tokenManager = _tokenManager;
    }

    function setMaxDeviationBasisPoints(uint256 _maxDeviationBasisPoints)
        external
        override
        onlyTokenManager
    {
        maxDeviationBasisPoints = _maxDeviationBasisPoints;
    }

    function setMaxCumulativeDeltaDiffs(
        address[] memory _tokens,
        uint256[] memory _maxCumulativeDeltaDiffs
    ) external override onlyTokenManager {
        for (uint256 i = 0; i < _tokens.length; i++) {
            address token = _tokens[i];
            maxCumulativeDeltaDiffs[token] = _maxCumulativeDeltaDiffs[i];
        }
    }

    function setPriceDataInterval(uint256 _priceDataInterval)
        external
        override
        onlyTokenManager
    {
        priceDataInterval = _priceDataInterval;
    }

    function setMinAuthorizations(uint256 _minAuthorizations)
        external
        onlyTokenManager
    {
        minAuthorizations = _minAuthorizations;
    }

    function setTokens(
        address[] memory _tokens,
        uint256[] memory _tokenPrecisions
    ) external onlyOwner {
        require(
            _tokens.length == _tokenPrecisions.length,
            "FastPriceFeed: invalid lengths"
        );
        tokens = _tokens;
        tokenPrecisions = _tokenPrecisions;
    }

    function setPrices(
        address[] memory _tokens,
        uint256[] memory _prices,
        uint256 _timestamp
    ) external onlyUpdater {
        bool shouldUpdate = _setLastUpdatedValues(_timestamp);

        if (shouldUpdate) {
            address _fastPriceEvents = fastPriceEvents;
            address _vaultPriceFeed = vaultPriceFeed;

            for (uint256 i = 0; i < _tokens.length; i++) {
                address token = _tokens[i];
                _setPrice(token, _prices[i], _vaultPriceFeed, _fastPriceEvents);
            }
        }
    }

    function setCompactedPrices(
        uint256[] memory _priceBitArray,
        uint256 _timestamp
    ) external onlyUpdater {
        bool shouldUpdate = _setLastUpdatedValues(_timestamp);

        if (shouldUpdate) {
            address _fastPriceEvents = fastPriceEvents;
            address _vaultPriceFeed = vaultPriceFeed;

            for (uint256 i = 0; i < _priceBitArray.length; i++) {
                uint256 priceBits = _priceBitArray[i];

                for (uint256 j = 0; j < 8; j++) {
                    uint256 index = i * 8 + j;
                    if (index >= tokens.length) {
                        return;
                    }

                    uint256 startBit = 32 * j;
                    uint256 price = (priceBits >> startBit) & BITMASK_32;

                    address token = tokens[i * 8 + j];
                    uint256 tokenPrecision = tokenPrecisions[i * 8 + j];
                    uint256 adjustedPrice = (price * PRICE_PRECISION) /
                        tokenPrecision;

                    _setPrice(
                        token,
                        adjustedPrice,
                        _vaultPriceFeed,
                        _fastPriceEvents
                    );
                }
            }
        }
    }

    function setPricesWithBits(uint256 _priceBits, uint256 _timestamp)
        external
        override
        onlyUpdater
    {
        _setPricesWithBits(_priceBits, _timestamp);
    }

    function setPricesWithBitsAndExecute(
        uint256 _priceBits,
        uint256 _timestamp,
        uint256 _endIndexForIncreasePositions,
        uint256 _endIndexForDecreasePositions,
        uint256 _maxIncreasePositions,
        uint256 _maxDecreasePositions
    ) external onlyUpdater {
        _setPricesWithBits(_priceBits, _timestamp);

        IPositionRouter _positionRouter = IPositionRouter(positionRouter);
        uint256 maxEndIndexForIncrease = _positionRouter
            .increasePositionRequestKeysStart() + _maxIncreasePositions;
        uint256 maxEndIndexForDecrease = _positionRouter
            .decreasePositionRequestKeysStart() + _maxDecreasePositions;

        if (_endIndexForIncreasePositions > maxEndIndexForIncrease) {
            _endIndexForIncreasePositions = maxEndIndexForIncrease;
        }

        if (_endIndexForDecreasePositions > maxEndIndexForDecrease) {
            _endIndexForDecreasePositions = maxEndIndexForDecrease;
        }

        _positionRouter.executeIncreasePositions(
            _endIndexForIncreasePositions,
            payable(msg.sender)
        );
        _positionRouter.executeDecreasePositions(
            _endIndexForDecreasePositions,
            payable(msg.sender)
        );
    }

    function disableFastPrice() external onlySigner {
        require(
            !disableFastPriceVotes[msg.sender],
            "FastPriceFeed: already voted"
        );
        disableFastPriceVotes[msg.sender] = true;
        disableFastPriceVoteCount += 1;

        emit DisableFastPrice(msg.sender);
    }

    function enableFastPrice() external onlySigner {
        require(
            disableFastPriceVotes[msg.sender],
            "FastPriceFeed: already enabled"
        );
        disableFastPriceVotes[msg.sender] = false;
        disableFastPriceVoteCount -= 1;

        emit EnableFastPrice(msg.sender);
    }

    // under regular operation, the fastPrice (prices[token]) is returned and there is no spread returned from this function,
    // though VaultPriceFeed might apply its own spread
    //
    // if the fastPrice has not been updated within priceDuration then it is ignored and only _refPrice with a spread is used (spread: spreadBasisPointsIfInactive)
    // in case the fastPrice has not been updated for maxPriceUpdateDelay then the _refPrice with a larger spread is used (spread: spreadBasisPointsIfChainError)
    //
    // there will be a spread from the _refPrice to the fastPrice in the following cases:
    // - in case isSpreadEnabled is set to true
    // - in case the maxDeviationBasisPoints between _refPrice and fastPrice is exceeded
    // - in case watchers flag an issue
    // - in case the cumulativeFastDelta exceeds the cumulativeRefDelta by the maxCumulativeDeltaDiff
    function getPrice(
        address _token,
        uint256 _refPrice,
        bool _maximise
    ) external view override returns (uint256) {
        if (block.timestamp > lastUpdatedAt + maxPriceUpdateDelay) {
            if (_maximise) {
                return
                    (_refPrice *
                        (BASIS_POINTS_DIVISOR +
                            spreadBasisPointsIfChainError)) /
                    BASIS_POINTS_DIVISOR;
            }

            return
                (_refPrice *
                    (BASIS_POINTS_DIVISOR - spreadBasisPointsIfChainError)) /
                BASIS_POINTS_DIVISOR;
        }

        if (block.timestamp > lastUpdatedAt + priceDuration) {
            if (_maximise) {
                return
                    (_refPrice *
                        (BASIS_POINTS_DIVISOR + spreadBasisPointsIfInactive)) /
                    BASIS_POINTS_DIVISOR;
            }

            return
                (_refPrice *
                    (BASIS_POINTS_DIVISOR - spreadBasisPointsIfInactive)) /
                BASIS_POINTS_DIVISOR;
        }

        uint256 fastPrice = prices[_token];
        if (fastPrice == 0) {
            return _refPrice;
        }

        uint256 diffBasisPoints = _refPrice > fastPrice
            ? _refPrice - fastPrice
            : fastPrice - _refPrice;
        diffBasisPoints = (diffBasisPoints * BASIS_POINTS_DIVISOR) / _refPrice;

        // create a spread between the _refPrice and the fastPrice if the maxDeviationBasisPoints is exceeded
        // or if watchers have flagged an issue with the fast price
        bool hasSpread = !favorFastPrice(_token) ||
            diffBasisPoints > maxDeviationBasisPoints;

        if (hasSpread) {
            // return the higher of the two prices
            if (_maximise) {
                return _refPrice > fastPrice ? _refPrice : fastPrice;
            }

            // return the lower of the two prices
            return _refPrice < fastPrice ? _refPrice : fastPrice;
        }

        return fastPrice;
    }

    function favorFastPrice(address _token) public view returns (bool) {
        if (isSpreadEnabled) {
            return false;
        }

        if (disableFastPriceVoteCount >= minAuthorizations) {
            // force a spread if watchers have flagged an issue with the fast price
            return false;
        }

        (
            ,
            ,
            /* uint256 prevRefPrice */
            /* uint256 refTime */
            uint256 cumulativeRefDelta,
            uint256 cumulativeFastDelta
        ) = getPriceData(_token);
        if (
            cumulativeFastDelta > cumulativeRefDelta &&
            cumulativeFastDelta - cumulativeRefDelta >
            maxCumulativeDeltaDiffs[_token]
        ) {
            // force a spread if the cumulative delta for the fast price feed exceeds the cumulative delta
            // for the Chainlink price feed by the maxCumulativeDeltaDiff allowed
            return false;
        }

        return true;
    }

    function getPriceData(address _token)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        PriceDataItem memory data = priceData[_token];
        return (
            uint256(data.refPrice),
            uint256(data.refTime),
            uint256(data.cumulativeRefDelta),
            uint256(data.cumulativeFastDelta)
        );
    }

    function _setPricesWithBits(uint256 _priceBits, uint256 _timestamp)
        private
    {
        bool shouldUpdate = _setLastUpdatedValues(_timestamp);

        if (shouldUpdate) {
            address _fastPriceEvents = fastPriceEvents;
            address _vaultPriceFeed = vaultPriceFeed;

            for (uint256 j = 0; j < 8; j++) {
                uint256 index = j;
                if (index >= tokens.length) {
                    return;
                }

                uint256 startBit = 32 * j;
                uint256 price = (_priceBits >> startBit) & BITMASK_32;

                address token = tokens[j];
                uint256 tokenPrecision = tokenPrecisions[j];
                uint256 adjustedPrice = (price * PRICE_PRECISION) /
                    tokenPrecision;

                _setPrice(
                    token,
                    adjustedPrice,
                    _vaultPriceFeed,
                    _fastPriceEvents
                );
            }
        }
    }

    function _setPrice(
        address _token,
        uint256 _price,
        address _vaultPriceFeed,
        address _fastPriceEvents
    ) private {
        if (_vaultPriceFeed != address(0)) {
            uint256 refPrice = IVaultPriceFeed(_vaultPriceFeed)
                .getLatestPrimaryPrice(_token);
            uint256 fastPrice = prices[_token];

            (
                uint256 prevRefPrice,
                uint256 refTime,
                uint256 cumulativeRefDelta,
                uint256 cumulativeFastDelta
            ) = getPriceData(_token);

            if (prevRefPrice > 0) {
                uint256 refDeltaAmount = refPrice > prevRefPrice
                    ? refPrice - prevRefPrice
                    : prevRefPrice - refPrice;
                uint256 fastDeltaAmount = fastPrice > _price
                    ? fastPrice - _price
                    : _price - fastPrice;

                // reset cumulative delta values if it is a new time window
                if (
                    refTime / priceDataInterval !=
                    block.timestamp / priceDataInterval
                ) {
                    cumulativeRefDelta = 0;
                    cumulativeFastDelta = 0;
                }

                cumulativeRefDelta =
                    cumulativeRefDelta +
                    ((refDeltaAmount * CUMULATIVE_DELTA_PRECISION) /
                        prevRefPrice);
                cumulativeFastDelta =
                    cumulativeFastDelta +
                    ((fastDeltaAmount * CUMULATIVE_DELTA_PRECISION) /
                        fastPrice);
            }

            if (
                cumulativeFastDelta > cumulativeRefDelta &&
                cumulativeFastDelta - cumulativeRefDelta >
                maxCumulativeDeltaDiffs[_token]
            ) {
                emit MaxCumulativeDeltaDiffExceeded(
                    _token,
                    refPrice,
                    fastPrice,
                    cumulativeRefDelta,
                    cumulativeFastDelta
                );
            }

            _setPriceData(
                _token,
                refPrice,
                cumulativeRefDelta,
                cumulativeFastDelta
            );
            emit PriceData(
                _token,
                refPrice,
                fastPrice,
                cumulativeRefDelta,
                cumulativeFastDelta
            );
        }

        prices[_token] = _price;
        _emitPriceEvent(_fastPriceEvents, _token, _price);
    }

    function _setPriceData(
        address _token,
        uint256 _refPrice,
        uint256 _cumulativeRefDelta,
        uint256 _cumulativeFastDelta
    ) private {
        require(_refPrice < MAX_REF_PRICE, "FastPriceFeed: invalid refPrice");
        // skip validation of block.timestamp, it should only be out of range after the year 2100
        require(
            _cumulativeRefDelta < MAX_CUMULATIVE_REF_DELTA,
            "FastPriceFeed: invalid cumulativeRefDelta"
        );
        require(
            _cumulativeFastDelta < MAX_CUMULATIVE_FAST_DELTA,
            "FastPriceFeed: invalid cumulativeFastDelta"
        );

        priceData[_token] = PriceDataItem(
            uint160(_refPrice),
            uint32(block.timestamp),
            uint32(_cumulativeRefDelta),
            uint32(_cumulativeFastDelta)
        );
    }

    function _emitPriceEvent(
        address _fastPriceEvents,
        address _token,
        uint256 _price
    ) private {
        if (_fastPriceEvents == address(0)) {
            return;
        }

        IFastPriceEvents(_fastPriceEvents).emitPriceEvent(_token, _price);
    }

    function _setLastUpdatedValues(uint256 _timestamp) private returns (bool) {
        if (minBlockInterval > 0) {
            require(
                block.number - lastUpdatedBlock >= minBlockInterval,
                "FastPriceFeed: minBlockInterval not yet passed"
            );
        }

        uint256 _maxTimeDeviation = maxTimeDeviation;
        require(
            _timestamp > block.timestamp - _maxTimeDeviation,
            "FastPriceFeed: _timestamp below allowed range"
        );
        require(
            _timestamp < block.timestamp + _maxTimeDeviation,
            "FastPriceFeed: _timestamp exceeds allowed range"
        );

        // do not update prices if _timestamp is before the current lastUpdatedAt value
        if (_timestamp < lastUpdatedAt) {
            return false;
        }

        lastUpdatedAt = _timestamp;
        lastUpdatedBlock = block.number;

        return true;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IFastPriceEvents {
    function emitPriceEvent(address _token, uint256 _price) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface IFastPriceFeed {
    function lastUpdatedAt() external view returns (uint256);

    function lastUpdatedBlock() external view returns (uint256);

    function setSigner(address _account, bool _isActive) external;

    function setUpdater(address _account, bool _isActive) external;

    function setPriceDuration(uint256 _priceDuration) external;

    function setMaxPriceUpdateDelay(uint256 _maxPriceUpdateDelay) external;

    function setSpreadBasisPointsIfInactive(
        uint256 _spreadBasisPointsIfInactive
    ) external;

    function setSpreadBasisPointsIfChainError(
        uint256 _spreadBasisPointsIfChainError
    ) external;

    function setMinBlockInterval(uint256 _minBlockInterval) external;

    function setIsSpreadEnabled(bool _isSpreadEnabled) external;

    function setMaxDeviationBasisPoints(uint256 _maxDeviationBasisPoints)
        external;

    function setMaxCumulativeDeltaDiffs(
        address[] memory _tokens,
        uint256[] memory _maxCumulativeDeltaDiffs
    ) external;

    function setPriceDataInterval(uint256 _priceDataInterval) external;

    function setVaultPriceFeed(address _vaultPriceFeed) external;

    function setPricesWithBits(uint256 _priceBits, uint256 _timestamp) external;
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

interface ISecondaryPriceFeed {
    function getPrice(
        address _token,
        uint256 _referencePrice,
        bool _maximise
    ) external view returns (uint256);
}
