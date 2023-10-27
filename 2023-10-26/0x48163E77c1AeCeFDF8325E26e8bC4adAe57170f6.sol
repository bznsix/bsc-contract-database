// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PriceProvider.sol";
import "../interfaces/ICoinFiatBoard.sol";
import "../interfaces/IPancakeGetter.sol";
import "../interfaces/IERC20.sol";

contract PancakePriceProvider is PriceProvider {
    ///https://docs.pancakeswap.finance/developers/smart-contracts/pancakeswap-exchange/v2-contracts
    address public immutable PANCAKE_V2FACTORY;
    uint256 public immutable DEFAULT_DECIMALS;
    address private immutable ZERO_VALUE =
        0x0000000000000000000000000000000000000000;
    uint256 private immutable k = 10 ** 18;

    mapping(address coinAddress => address routerTokenAddress) coinRouterToken;
    mapping(address coinAddress => address pancakePair) pancakePair;

    error RouterTokenDoesNotExistInOracle(address token);
    error CantFindPancakePair(address tokenA, address tokenB);

    event CoinPairSet(address coin, address pair, address caller);
    event CoinPairRevoked(address coin, address caller);
    event CoinPancakePairUpdated(
        address coinAddress,
        address oldPair,
        address updPair
    );

    constructor(
        address priceOracle,
        uint256 providerNativeFiat,
        address pancakeFactory
    ) PriceProvider(priceOracle, providerNativeFiat) {
        PANCAKE_V2FACTORY = pancakeFactory;
        DEFAULT_DECIMALS = ICoinFiatBoard(ORACLE).defaultDecimals();
    }

    function setCoinRouterToken(
        address coinAddress,
        address routerToken
    ) external onlyTechnicalRole {
        _registerCoinPair(coinAddress, routerToken);
    }

    function revokeCoinRouterToken(
        address coinAddress
    ) external onlyTechnicalRole {
        _revokeCoinPair(coinAddress);
    }

    function updatePancakePair(
        address coinAddress
    ) external onlyTechnicalRole returns (address) {
        return _updatePancakePair(coinAddress);
    }

    function getCoinRouterToken(
        address coinAddress
    ) public view returns (address) {
        return coinRouterToken[coinAddress];
    }

    function getPancakePair(address coinAddress) public view returns (address) {
        return pancakePair[coinAddress];
    }

    function providerIncludesCoin(
        address coinToCheck
    ) public view override returns (bool isIncluded) {
        isIncluded =
            (coinRouterToken[coinToCheck] != address(0)) &&
            (pancakePair[coinToCheck] != address(0));
    }

    function targetCoinPancakePrice(
        address targetCoin
    ) public view returns (uint256 pancakeCoinPrice) {
        address pPair = pancakePair[targetCoin];
        uint112 targetReserves;
        uint112 routerReserves;

        IPancakeGetter(pPair).token0() == targetCoin
            ? (targetReserves, routerReserves, ) = IPancakeGetter(pPair)
                .getReserves()
            : (routerReserves, targetReserves, ) = IPancakeGetter(pPair)
            .getReserves();

        pancakeCoinPrice = uint256(
            (routerReserves * k) /
                _scaleAmount(
                    targetReserves,
                    IERC20(targetCoin).decimals(),
                    IERC20(coinRouterToken[targetCoin]).decimals()
                )
        );
    }

    function routerTokenPriceInFiat(
        address routerToken
    ) public view returns (uint256 routerPriceInFiat) {
        (, routerPriceInFiat) = IPriceOracle(ORACLE).getCoinPrice(
            PROVIDER_FIAT,
            routerToken,
            ZERO_VALUE
        );
    }

    function _getCoinPriceInProviderFiat(
        address targetCoin
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
        providerNativeFiat = PROVIDER_FIAT;
        priceDecimals = DEFAULT_DECIMALS;
        priceProvided = true;

        priceInProviderFiat =
            (targetCoinPancakePrice(targetCoin) *
                routerTokenPriceInFiat(coinRouterToken[targetCoin])) /
            k;
    }

    function _registerCoinPair(
        address coinAddress,
        address routerToken
    ) internal override {
        if (!IPriceOracle(ORACLE).coinExistsInOracle(routerToken))
            revert RouterTokenDoesNotExistInOracle(routerToken);

        coinRouterToken[coinAddress] = routerToken;
        emit CoinPairSet(coinAddress, routerToken, _msgSender());

        _updatePancakePair(coinAddress);
        if (pancakePair[coinAddress] == address(0))
            revert CantFindPancakePair(coinAddress, routerToken);
    }

    function _revokeCoinPair(address coinAddress) internal override {
        emit CoinPancakePairUpdated(
            coinAddress,
            pancakePair[coinAddress],
            address(0)
        );
        emit CoinPairRevoked(coinAddress, _msgSender());

        delete pancakePair[coinAddress];
        delete coinRouterToken[coinAddress];
    }

    function _updatePancakePair(
        address coinAddress
    ) internal returns (address updPancakePair) {
        address oldPair = pancakePair[coinAddress];
        updPancakePair = IPancakeGetter(PANCAKE_V2FACTORY).getPair(
            coinAddress,
            coinRouterToken[coinAddress]
        );
        if (oldPair != updPancakePair) {
            pancakePair[coinAddress] = updPancakePair;
            emit CoinPancakePairUpdated(coinAddress, oldPair, updPancakePair);
        }
    }

    function _scaleAmount(
        uint256 _amount,
        uint256 _amountDecimals,
        uint256 _decimalsToUse
    ) internal pure returns (uint256) {
        if (_amountDecimals < _decimalsToUse) {
            return _amount * (10 ** (_decimalsToUse - _amountDecimals));
        } else if (_amountDecimals > _decimalsToUse) {
            return _amount / (10 ** (_amountDecimals - _decimalsToUse));
        }
        return _amount;
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

interface IPancakeGetter {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function decimals() external pure returns (uint8);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICoinFiatBoard {
    struct Coin {
        string ticker;
        address coinAddress;
        address priceProvider;
        uint256 staticPrice;
        uint256 nativeFiat;
    }

    struct Fiat {
        string currency;
        uint256 numericCode;
        string alphabeticCode;
        Coin fiatCoinData;
        /**
        struct Coin for Fiat has such values :
        {
        string ticker //smart contract creates itself. by concatenation of "fiatCoin" & alphabeticCode (ex. 
                        USD will have ticker "fiatCoinUSD")
        address coinAddress //zero address wich last three symbols are - numeric code of Fiat (ex.
                        USD has numeric code 840, so the address has to 
                        be: 0x0000000000000000000000000000000000000840)
        address priceProvider //ONLY Chainlink!!!
        uint256 staticPrice //zero
        uint256 nativeFiat //ONLY USD!!!
        }
         */
    }

    function getCoinConfig(
        address coinAddress
    ) external view returns (Coin memory);

    function fiatDetails(
        uint256 iso4217NumericCode
    ) external view returns (Fiat memory);

    function zeroValue() external view returns (address);

    function defaultDecimals() external view returns (uint256);
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
