// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Access.sol";
import "./CoinFiatBoard.sol";
import "./ProvidersBoard.sol";
import "./interfaces/IPriceAdapter.sol";

contract PriceOracle is Access, CoinFiatBoard, ProvidersBoard {
    address priceAdapter;

    event PriceAdapterSet(address oldAdapter, address newAdapter);

    function addNewCoin(
        address coinAddress,
        address priceProvider,
        uint256 priceForConfig,
        uint256 nativeFiat
    )
        external
        fiatExists(nativeFiat)
        onlyTechnicalRole
        properProvider(priceProvider)
    {
        if (coinAddress == address(0)) revert ZeroValueNotAllowed();

        _addNewCoin(
            IERC20(coinAddress).symbol(),
            coinAddress,
            priceProvider,
            priceForConfig,
            nativeFiat
        );
        allCoinsList.push(coinAddress);
    }

    function revokeCoin(
        address coinAddress
    ) external onlyTechnicalRole coinExists(coinAddress) {
        _revokeCoin(coinAddress);
    }

    function setCoinConfigPrice(
        address coinAddress,
        uint256 newPriceForConfig
    ) external onlyTechnicalRole coinExists(coinAddress) {
        _updateCoin(coinConfig[coinAddress], newPriceForConfig);
    }

    function setCoinPriceProvider(
        address coinAddress,
        address newPriceProvider
    )
        external
        onlyTechnicalRole
        coinExists(coinAddress)
        properProvider(newPriceProvider)
    {
        _updateCoin(coinConfig[coinAddress], newPriceProvider);
    }

    function updateCoinConfig(
        address coinAddress,
        address newPriceProvider,
        uint256 newPriceForConfig,
        uint256 newNativeFiat
    )
        external
        onlyTechnicalRole
        coinExists(coinAddress)
        fiatExists(newNativeFiat)
        properProvider(newPriceProvider)
    {
        _updateCoin(
            coinAddress,
            newPriceProvider,
            newPriceForConfig,
            newNativeFiat
        );
    }

    function addPriceProvider(
        address priceProvider
    ) external onlyTechnicalRole {
        _addPriceProvider(priceProvider);
    }

    function revokePriceProvider(
        address priceProvider
    ) external onlyTechnicalRole {
        if (hasCoinsAssociatedWithProvider(priceProvider))
            revert RemoveProviderFromAllCoins(priceProvider);
        _revokePriceProvider(priceProvider);
    }

    function setPriceAdapter(address newAdapter) external onlyTechnicalRole {
        address oldAdapter = priceAdapter;
        priceAdapter = newAdapter;

        emit PriceAdapterSet(oldAdapter, newAdapter);
    }

    function addFiatCurrency(
        string calldata currency,
        uint256 numericCode,
        string calldata alphabeticCode,
        address fiatCoinAddress,
        address fiatPriceProvider,
        uint256 fiatPriceForConfig,
        uint256 fiatNativeFiat
    ) external onlyTechnicalRole {
        if (numericCode == 0) revert ZeroValueNotAllowed();
        _addFiat(
            currency,
            numericCode,
            alphabeticCode,
            fiatCoinAddress,
            fiatPriceProvider,
            fiatPriceForConfig,
            fiatNativeFiat
        );
    }

    function revokeFiatCurrency(
        uint256 numericCode
    ) external fiatExists(numericCode) onlyTechnicalRole {
        _revokeFiat(numericCode);
    }

    function getCoinPrice(
        uint256 fiatForPrice,
        address targetCoin,
        address relatedCoin
    )
        external
        view
        fiatExists(fiatForPrice)
        coinExists(targetCoin)
        returns (bool priceProvided, uint256 price)
    {
        if (!(relatedCoin == ZERO_VALUE || coinExistsInOracle(relatedCoin)))
            revert CoinDoesNotExistInPriceOracle(relatedCoin);

        (priceProvided, price) = IPriceAdapter(priceAdapter).calculatePrice(
            fiatForPrice,
            targetCoin,
            relatedCoin
        );
    }

    function hasCoinsAssociatedWithProvider(
        address provider
    ) public view returns (bool hasCoins) {
        if (allCoinsList.length > 0) {
            for (uint256 i = 0; i < allCoinsList.length; i++) {
                if (provider == coinConfig[allCoinsList[i]].priceProvider) {
                    hasCoins = true;
                    break;
                }
            }
        }

        if (!hasCoins && possibleFiat.length > 0) {
            for (uint256 i = 0; i < possibleFiat.length; i++) {
                if (
                    provider ==
                    fiatData[possibleFiat[i]].fiatCoinData.priceProvider
                ) {
                    hasCoins = true;
                    break;
                }
            }
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPriceProvider {
    function getCoinPriceInProviderFiat(
        address targetCoin
    )
        external
        view
        returns (
            bool priceProvided,
            uint256 priceInProviderFiat,
            uint256 priceDecimals,
            uint256 providerFiat
        );

    function providerIncludesCoin(
        address coinToCheck
    ) external view returns (bool isIncluded);

    function providerFiat() external view returns (uint256);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPriceAdapter {
    function calculatePrice(
        uint256 fiatToUseForPrice,
        address targetCoin,
        address relatedCoin
    ) external view returns (bool priceProvided, uint256 calculatedPrice);
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
pragma solidity ^0.8.0;

import "./interfaces/IPriceProvider.sol";

contract ProvidersBoard {
    address[] internal providersList;
    mapping(uint256 iso4217NumericCode => address[] providersWithDefiniteFiat) providersListByFiat;

    error ZeroValueNotAllowed();
    error ImpossiblePriceProvider(address provider);
    error PriceProviderAlreadyExists(address provider);
    error RemoveProviderFromAllCoins(address provider);

    event PriceProviderAdded(address provider);
    event PriceProviderRevoked(address provider);

    modifier properProvider(address priceProvider) {
        if (!(priceProvider == address(0) || _validProvider(priceProvider)))
            revert ImpossiblePriceProvider(priceProvider);
        _;
    }

    function _addPriceProvider(address priceProvider) internal {
        if (priceProvider == address(0)) revert ZeroValueNotAllowed();

        if (_validProvider(priceProvider))
            revert PriceProviderAlreadyExists(priceProvider);

        providersList.push(priceProvider);
        providersListByFiat[IPriceProvider(priceProvider).providerFiat()].push(
            priceProvider
        );
        emit PriceProviderAdded(priceProvider);
    }

    function _revokePriceProvider(address priceProvider) internal {
        if (!_validProvider(priceProvider))
            revert ImpossiblePriceProvider(priceProvider);

        address[] storage listByFiat = providersListByFiat[
            IPriceProvider(priceProvider).providerFiat()
        ];

        for (uint256 j = 0; j < listByFiat.length; j++) {
            if (priceProvider == listByFiat[j]) {
                listByFiat[j] = listByFiat[listByFiat.length - 1];
                listByFiat.pop();
            }
        }

        for (uint256 i = 0; i < providersList.length; i++) {
            if (priceProvider == providersList[i]) {
                providersList[i] = providersList[providersList.length - 1];
                providersList.pop();

                emit PriceProviderRevoked(priceProvider);
                break;
            }
        }
    }

    function getPriceProvidersList() external view returns (address[] memory) {
        return providersList;
    }

    function numberOfProviders() external view returns (uint256) {
        return providersList.length;
    }

    function getPriceProvidersListByFiat(
        uint256 iso4217NumericCode
    ) external view returns (address[] memory) {
        return providersListByFiat[iso4217NumericCode];
    }

    function numberOfProvidersByFiat(
        uint256 iso4217NumericCode
    ) external view returns (uint256) {
        return providersListByFiat[iso4217NumericCode].length;
    }

    function _validProvider(
        address provider
    ) internal view returns (bool isValid) {
        if (providersList.length > 0) {
            uint256 counter;
            for (uint256 i = 0; i < providersList.length; i++) {
                if (provider == providersList[i]) {
                    counter++;
                    break;
                }
            }
            isValid = counter > 0;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/ICoinFiatBoard.sol";
import "./interfaces/IPriceProvider.sol";
import "./interfaces/IERC20.sol";

contract CoinFiatBoard is ICoinFiatBoard {
    address internal immutable ZERO_VALUE =
        0x0000000000000000000000000000000000000000;
    uint256 internal immutable DEFAULT_DECIMALS;

    address[] internal allCoinsList;
    uint256[] public possibleFiat;

    mapping(address coinAddress => Coin) coinConfig;
    mapping(uint256 iso4217NumericCode => Fiat) fiatData;

    error CoinDoesNotExistInPriceOracle(address coin);
    error CoinAlreadyExistsInPriceOracle(address coin);
    error CoinDoesNotExistInProvider(address priceProvider);

    error FiatDoesNotExistInPriceOracle(uint256 iso4217NumericCode);
    error FiatAlreadyExistsInPriceOracle(uint256 iso4217NumericCode);
    error FiatDoesNotMatch();

    event DecimalsSet(uint256 oldDecimals, uint256 newDecimals);
    event CoinAdded(
        string coinTicker,
        address coinAddress,
        address priceProvider,
        uint256 priceForConfig,
        uint256 nativeFiat
    );
    event CoinRevoked(address coinAddress);
    event CoinConfigPriceUpdated(
        uint256 oldPrice,
        uint256 newPrice,
        uint256 newNativeFiat
    );
    event CoinProviderUpdated(address oldProvider, address newProvider);
    event CoinNativeFiatUpdated(uint256 oldNativeFiat, uint256 newNativeFiat);

    event FiatAdded(Fiat);
    event FiatRevoked(Fiat);

    modifier coinExists(address coin) {
        if (!coinExistsInOracle(coin))
            revert CoinDoesNotExistInPriceOracle(coin);
        _;
    }

    modifier fiatExists(uint256 fiatNumericCode) {
        if (!_fiatExists(fiatNumericCode))
            revert FiatDoesNotExistInPriceOracle(fiatNumericCode);
        _;
    }

    constructor() {
        DEFAULT_DECIMALS = 18;
        emit DecimalsSet(0, DEFAULT_DECIMALS);
    }

    function getCoinConfig(
        address coinAddress
    ) external view returns (Coin memory) {
        return coinConfig[coinAddress];
    }

    function zeroValue() external view returns (address) {
        return ZERO_VALUE;
    }

    function defaultDecimals() external view returns (uint256) {
        return DEFAULT_DECIMALS;
    }

    function getAllCoinsList() external view returns (address[] memory) {
        return allCoinsList;
    }

    function fiatExistsInOracle(
        uint256 iso4217NumericCode
    ) external view returns (bool) {
        return _fiatExists(iso4217NumericCode);
    }

    function fiatDetails(
        uint256 iso4217NumericCode
    ) external view returns (Fiat memory) {
        return fiatData[iso4217NumericCode];
    }

    function coinExistsInOracle(
        address coin
    ) public view returns (bool isCoinExists) {
        isCoinExists = coinConfig[coin].coinAddress != address(0);
    }

    function getAllPossibleFiat() public view returns (uint256[] memory) {
        return possibleFiat;
    }

    function _addNewCoin(
        string memory coinTicker,
        address coinAddress,
        address priceProvider,
        uint256 priceForConfig,
        uint256 nativeFiat
    ) internal {
        if (coinExistsInOracle(coinAddress))
            revert CoinAlreadyExistsInPriceOracle(coinAddress);
        _coinProviderMatch(coinAddress, nativeFiat, priceProvider);

        coinConfig[coinAddress] = Coin(
            coinTicker,
            coinAddress,
            priceProvider,
            priceForConfig,
            nativeFiat
        );

        emit CoinAdded(
            coinTicker,
            coinAddress,
            priceProvider,
            priceForConfig,
            nativeFiat
        );
    }

    function _revokeCoin(address coinAddress) internal {
        for (uint256 i = 0; i < allCoinsList.length; i++) {
            if (coinAddress == allCoinsList[i]) {
                allCoinsList[i] = allCoinsList[allCoinsList.length - 1];
                allCoinsList.pop();

                emit CoinRevoked(coinAddress);

                delete coinConfig[coinAddress];
                break;
            }
        }
    }

    function _updateCoin(Coin memory coin, uint256 priceForConfig) internal {
        uint256 oldPrice = coin.staticPrice;
        coinConfig[coin.coinAddress].staticPrice = priceForConfig;

        emit CoinConfigPriceUpdated(oldPrice, priceForConfig, coin.nativeFiat);
    }

    function _updateCoin(Coin memory coin, address priceProvider) internal {
        _coinProviderMatch(coin.coinAddress, coin.nativeFiat, priceProvider);

        address oldProvider = coin.priceProvider;
        coinConfig[coin.coinAddress].priceProvider = priceProvider;

        emit CoinProviderUpdated(oldProvider, priceProvider);
    }

    function _updateCoin(
        address coinAddress,
        address newPriceProvider,
        uint256 newPriceForConfig,
        uint256 newNativeFiat
    ) internal {
        uint256 oldFiat = coinConfig[coinAddress].nativeFiat;
        coinConfig[coinAddress].nativeFiat = newNativeFiat;
        emit CoinNativeFiatUpdated(oldFiat, newNativeFiat);

        _updateCoin(coinConfig[coinAddress], newPriceForConfig);
        _updateCoin(coinConfig[coinAddress], newPriceProvider);
    }

    function _addFiat(
        string memory currency,
        uint256 numericCode,
        string memory alphabeticCode,
        address fiatCoinAddress,
        address fiatPriceProvider,
        uint256 fiatPriceForConfig,
        uint256 fiatNativeFiat
    ) internal {
        if (_fiatExists(numericCode))
            revert FiatAlreadyExistsInPriceOracle(numericCode);

        _addNewCoin(
            string.concat("fiatCoin", alphabeticCode),
            fiatCoinAddress,
            fiatPriceProvider,
            fiatPriceForConfig,
            fiatNativeFiat
        );

        fiatData[numericCode] = Fiat(
            currency,
            numericCode,
            alphabeticCode,
            coinConfig[fiatCoinAddress]
        );

        possibleFiat.push(numericCode);

        emit FiatAdded(fiatData[numericCode]);
    }

    function _revokeFiat(uint256 _numericCode) internal {
        if (possibleFiat.length > 0) {
            for (uint256 i = 0; i < possibleFiat.length; i++) {
                if (_numericCode == possibleFiat[i]) {
                    possibleFiat[i] = possibleFiat[possibleFiat.length - 1];
                    possibleFiat.pop();

                    emit FiatRevoked(fiatData[_numericCode]);

                    delete coinConfig[
                        fiatData[_numericCode].fiatCoinData.coinAddress
                    ];
                    delete fiatData[_numericCode];
                    break;
                }
            }
        }
    }

    function _fiatExists(
        uint256 numericCode
    ) internal view returns (bool isFiatExists) {
        isFiatExists = fiatData[numericCode].numericCode != 0;
    }

    function _coinProviderMatch(
        address coinAddress,
        uint256 coinFiat,
        address priceProvider
    ) internal view {
        if (priceProvider != ZERO_VALUE) {
            if (coinFiat != IPriceProvider(priceProvider).providerFiat())
                revert FiatDoesNotMatch();
            if (
                !IPriceProvider(priceProvider).providerIncludesCoin(coinAddress)
            ) revert CoinDoesNotExistInProvider(priceProvider);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Access is Ownable {
    mapping(address => bool) technicalRole;

    error AccessDenied(address deniedAccount);

    event TechnicalRoleGranted(address account, address caller);
    event TechnicalaRoleRevoked(address account, address caller);

    modifier ownerOrTechnicalRole() {
        if (!(_msgSender() == owner() || hasTechnicalRole(_msgSender())))
            revert AccessDenied(_msgSender());
        _;
    }

    modifier onlyTechnicalRole() {
        if (!hasTechnicalRole(_msgSender())) revert AccessDenied(_msgSender());
        _;
    }

    function addTechnicalRole(address account) external ownerOrTechnicalRole {
        if (!hasTechnicalRole(account)) {
            technicalRole[account] = true;
            emit TechnicalRoleGranted(account, _msgSender());
        }
    }

    function revokeTechnicalRole(
        address account
    ) external ownerOrTechnicalRole {
        if (hasTechnicalRole(account)) {
            technicalRole[account] = false;
            emit TechnicalaRoleRevoked(account, _msgSender());
        }
    }

    function hasTechnicalRole(address account) public view returns (bool) {
        return technicalRole[account];
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
