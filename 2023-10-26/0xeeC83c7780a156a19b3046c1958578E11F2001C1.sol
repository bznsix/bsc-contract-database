// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceProvider.sol";
import "../interfaces/IAggregatorV3Interface.sol";

contract ChainlinkPriceProvider is PriceProvider {
    address immutable USD = 0x0000000000000000000000000000000000000840;
    event CoinPairSet(address coin, address pair, address caller);
    event CoinPairRevoked(address coin, address caller);

    constructor(
        address priceOracle,
        uint256 providerNativeFiat //iso4217NumericCode
    ) PriceProvider(priceOracle, providerNativeFiat) {
        // set up at once the pair of fiatUSDCoin
        // (address of Coin 0x0000000000000000000000000000000000000840)
        // it has to have the address of Pair:0x0000000000000000000000000000000000000840
        // to return the price = 1 for USD fiat
        _registerCoinPair(USD, USD);
    }

    mapping(address coinAddress => address usdPriceFeedAddress) coinPair;

    function setCoinPair(
        address coinAddress,
        address pairToUSD
    ) external onlyTechnicalRole {
        _registerCoinPair(coinAddress, pairToUSD);
    }

    function revokeCoinPair(address coinAddress) external onlyTechnicalRole {
        _revokeCoinPair(coinAddress);
    }

    function getCoinPair(address coinAddress) public view returns (address) {
        return coinPair[coinAddress];
    }

    function providerIncludesCoin(
        address coinToCheck
    ) public view override returns (bool isIncluded) {
        isIncluded = coinPair[coinToCheck] != address(0);
    }

    function _registerCoinPair(
        address coinAddress,
        address pairToUSD
    ) internal override {
        coinPair[coinAddress] = pairToUSD;
        emit CoinPairSet(coinAddress, pairToUSD, _msgSender());
    }

    function _revokeCoinPair(address coinAddress) internal override {
        delete coinPair[coinAddress];
        emit CoinPairRevoked(coinAddress, _msgSender());
    }

    function _getCoinPriceInProviderFiat(
        address coin
    )
        internal
        view
        override
        returns (
            bool priceProvided,
            uint256 priceInProviderFiat,
            uint256 priceDecimals,
            uint256 providerNativeFiat
        )
    {
        if (coin == USD) {
            priceInProviderFiat = 1000000;
            priceDecimals = 6;
        } else {
            IAggregatorV3Interface pF = IAggregatorV3Interface(
                getCoinPair(coin)
            );
            (, int price, , , ) = pF.latestRoundData();
            priceInProviderFiat = uint256(price);
            priceDecimals = uint256(pF.decimals());
        }

        priceProvided = true;
        providerNativeFiat = PROVIDER_FIAT;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IPriceOracle.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract PriceProvider is Context {
    uint256 immutable PROVIDER_FIAT;
    address ORACLE;

    error AccessDenied(address deniedAccount);

    event PriceOracleSet(address oracle, address caller);

    modifier onlyTechnicalRole() {
        if (!IPriceOracle(ORACLE).hasTechnicalRole(_msgSender()))
            revert AccessDenied(_msgSender());
        _;
    }

    constructor(address priceOracle, uint256 providerNativeFiat) {
        _setOracle(priceOracle);
        PROVIDER_FIAT = providerNativeFiat;
    }

    function setOracle(address newPriceOracle) external onlyTechnicalRole {
        _setOracle(newPriceOracle);
    }

    function providerFiat() external view returns (uint256) {
        return PROVIDER_FIAT;
    }

    function getCoinPriceInProviderFiat(
        address targetCoin
    )
        external
        view
        returns (
            bool priceProvided,
            uint256 priceInProviderFiat,
            uint256 priceDecimals,
            uint256 providerNativeFiat
        )
    {
        if (providerIncludesCoin(targetCoin))
            (
                priceProvided,
                priceInProviderFiat,
                priceDecimals,
                providerNativeFiat
            ) = _getCoinPriceInProviderFiat(targetCoin);
    }

    function providerIncludesCoin(
        address coinToCheck
    ) public view virtual returns (bool isIncluded) {}

    function _getCoinPriceInProviderFiat(
        address targetCoin
    )
        internal
        view
        virtual
        returns (
            bool priceProvided,
            uint256 priceInProviderFiat,
            uint256 priceDecimals,
            uint256 providerNativeFiat
        )
    {}

    function _registerCoinPair(
        address coinAddress,
        address pair
    ) internal virtual {}

    function _registerCoinPair(
        address coinAddress,
        string memory pair
    ) internal virtual {}

    function _registerCoinPair(
        address coinAddress,
        uint256 pair
    ) internal virtual {}

    function _revokeCoinPair(address coinAddress) internal virtual {}

    function _setOracle(address newOracle) internal {
        ORACLE = newOracle;
        emit PriceOracleSet(newOracle, _msgSender());
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPriceOracle {
    function hasTechnicalRole(address account) external view returns (bool);

    function getPriceProvidersList() external view returns (address[] memory);

    function numberOfProviders() external view returns (uint256);

    function numberOfProvidersByFiat(
        uint256 iso4217NumericCode
    ) external view returns (uint256);

    function getPriceProvidersListByFiat(
        uint256 iso4217NumericCode
    ) external view returns (address[] memory);

    function coinExistsInOracle(
        address coin
    ) external view returns (bool isCoinExists);

    function getCoinPrice(
        uint256 fiatForPrice,
        address targetCoin,
        address relatedCoin
    ) external view returns (bool priceProvided, uint256 price);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAggregatorV3Interface {
  function decimals() external view returns (uint8);
  
  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}// SPDX-License-Identifier: MIT
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
