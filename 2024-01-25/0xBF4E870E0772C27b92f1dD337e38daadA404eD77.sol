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
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPriceOracle {
    function setPriceManager(address manager, bool enabled) external;

    function setChainPrice(uint16 _chainId, uint256 _price) external;

    function setAssetPrice(address _asset, uint256 _price) external;

    function setChainPrices(uint16[] calldata _chainIds, uint256[] calldata _prices) external;

    function setAssetPrices(address[] calldata _assets, uint256[] calldata _prices) external;

    function getChainPrice(uint16 _chainId) external view returns (uint256);

    function getChainPrices(uint16[] memory _chainIds) external view returns (uint256[] memory);

    function getAssetPrice(address _asset) external view returns (uint256);

    function getAssetPrices(address[] memory _assets) external view returns (uint256[] memory);

}
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Ownable} from"@openzeppelin/contracts/access/Ownable.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";

contract PriceOracle is Ownable, IPriceOracle {
    struct PriceData {
        uint256 price;
        uint256 timestamp;
    }

    mapping(address => bool) public priceManager;
    mapping(uint16 => PriceData) public chainData;
    mapping(address => PriceData) public assetData;

    event SetPriceManager(address manager, bool enabled);
    event SetChainPrice(uint16 chainId, uint256 price);
    event SetAssetPrice(address assetId, uint256 price);

    constructor(address manager) {
        priceManager[manager] = true;
    }

    modifier checkPrice(uint256 _price, uint256 timestamp) {
        require(_price > 0, "Oracle: price can not be 0");
        require(block.timestamp > timestamp, "Oracle: At least one block must pass before calling again");
        _;
    }

    modifier onlyPriceManager() {
        require(priceManager[msg.sender] == true, "Oracle: caller is not a priceManager");
        _;
    }

    function setPriceManager(address _manager, bool _enabled) external onlyOwner {
        require(priceManager[_manager] != _enabled, "Oracle: manager already enabled/disabled");
        priceManager[_manager] = _enabled;
        emit SetPriceManager(_manager, _enabled);
    }

    function setChainPrice(uint16 _chainId, uint256 _price) public onlyPriceManager checkPrice(_price, chainData[_chainId].timestamp) {
        chainData[_chainId].price = _price;
        chainData[_chainId].timestamp = block.timestamp;
        emit SetChainPrice(_chainId, _price);
    }

    function setAssetPrice(address _asset, uint256 _price) public onlyPriceManager checkPrice(_price, assetData[_asset].timestamp) {
        assetData[_asset].price = _price;
        assetData[_asset].timestamp = block.timestamp;
        emit SetAssetPrice(_asset, _price);
    }

    function setChainPrices(uint16[] calldata _chainIds, uint256[] calldata _prices) public onlyPriceManager {
        require(_chainIds.length == _prices.length, "Oracle: invalid chainId length");
        for (uint256 i = 0; i < _chainIds.length; i++) {
            setChainPrice(_chainIds[i], _prices[i]);
        }
    }

    function setAssetPrices(address[] calldata _assets, uint256[] calldata _prices) public onlyPriceManager {
        require(_assets.length == _prices.length, "Oracle: invalid assetId length");
        for (uint256 i = 0; i < _assets.length; i++) {
            setAssetPrice(_assets[i], _prices[i]);
        }
    }

    function getChainPrice(uint16 _chainId) public view returns (uint256){
        return chainData[_chainId].price;
    }

    function getChainPrices(uint16[] memory _chainIds) public view returns (uint256[] memory){
        uint256[] memory prices = new uint256[](_chainIds.length);
        for (uint256 i = 0; i < _chainIds.length; i++) {
            prices[i] = getChainPrice(_chainIds[i]);
        }
        return prices;
    }

    function getAssetPrice(address _asset) public view returns (uint256)    {
        return assetData[_asset].price;
    }

    function getAssetPrices(address[] memory _assets) public view returns (uint256[] memory){
        uint256[] memory prices = new uint256[](_assets.length);
        for (uint256 i = 0; i < _assets.length; i++) {
            prices[i] = getAssetPrice(_assets[i]);
        }
        return prices;
    }
}
