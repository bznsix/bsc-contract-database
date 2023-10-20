// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "Ownable.sol";
import "IAlgoVault.sol";
import "AggregatorV3Interface.sol";


contract AlgoVaultOracle is Ownable {

    //btc price oracle
    AggregatorV3Interface public btcPriceFeed = AggregatorV3Interface(0x264990fbd0A4796A3E3d8E37C4d5F87a3aCa5Ebf);

    address public vault;
    address public share;

    mapping(address => uint256) private _shareTokenPrice;
    mapping (address => bool) public isOperator;

    event VaultUpdated(address indexed _vault);
    event ShareUpdated(address indexed _share);
    event SharePriceUpdated(address indexed token, uint256 newPrice, uint256 btcPrice, uint256 time);
    event OperatorUpdated(address indexed _operator, bool indexed _isActive);

    modifier onlyOperator() {
        require(isOperator[msg.sender] == true, "caller is not the operator");
        _;
    }

    constructor(address _vault, address _share) {
        require(_vault != address(0), "vault address can not be zero address");
        require(_share != address(0), "share token address can not be zero address");
        vault = _vault;
        share = _share;
    }

    function setVault(address _vault) external onlyOperator {
        require(_vault != address(0), "vault address can not be zero address");
        vault = _vault;
        emit VaultUpdated(_vault);
    }

    function setShareToken(address _share) external onlyOperator {
        require(_share != address(0), "share token address can not be zero address");
        share = _share;
        emit ShareUpdated(_share);
    }

    function setOperator(address _operator, bool _isActive) external onlyOwner {
        require(_operator != address(0), "operator address can not be zero address");
        isOperator[_operator] = _isActive;
        emit OperatorUpdated(_operator, _isActive);
    }

    function shareTokenPrice(address token) public view returns (uint256) {
        return _shareTokenPrice[token];
    }

    // The token must be a token within the token list of the vault.
    function checkBaseTokenList(address token) public view returns (bool) {
        return IAlgoVault(vault).checkBaseTokenList(token);
    }

    /**
     * Returns the latest btc price,decimals: 8
     */
    function getLatestBTCPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = btcPriceFeed.latestRoundData();
        return price;
    }

    function setChainlinkBTCOracle(address _address) external onlyOperator {
        require(_address != address(0), "zero address");
        btcPriceFeed = AggregatorV3Interface(_address);
    }

    function updateSharePrice(address[] memory _baseTokenList, uint256[] memory _price) external onlyOperator {
        require(_baseTokenList.length == _price.length, "array length mismatch");
        uint256 btcPrice = uint256(getLatestBTCPrice());
        for(uint i = 0; i <_baseTokenList.length; i++) {
            address token = _baseTokenList[i];
            require(checkBaseTokenList(token) == true, "token is not in the baseTokenList");
            uint256 price = _price[i];
            require(price != 0, "share price can not be zero");
            _shareTokenPrice[token] = price;
            emit SharePriceUpdated(token, price, btcPrice, block.timestamp);
        }
    }
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "Context.sol";
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
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

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
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IAlgoVault {

    struct TokenInfo {
        address token;
        uint256 amount;
    }

    function DIVISION_PRECISION() external view returns (uint256);

    function PRICE_PRECISION() external view returns (uint256);

    function stakeInfo(address user, address token) external view returns (uint256);

    function withdrawInfo(address user, address token) external view returns (uint256);

    function checkBaseTokenList(address token) external view returns (bool);

    function checkPortfolioTokenList(address token) external view returns (bool);

    function getCurrentMinute() external view returns (uint256);

    function lockupStartTime() external view returns (uint256);

    function lockupEndTime() external view returns (uint256);

    function feeIn() external view returns (uint256);

    function feeOut() external view returns (uint256);

    function dailyFee() external view returns (uint256);

    function instantWithdrawFee() external view returns (uint256);

    function instantWithdrawFeeRatio() external view returns (uint256);

    function totalStakeRequest(address token) external view returns (uint256);

    function totalWithdrawRequest(address token) external view returns (uint256);

    function minimumRequest(address token) external view returns (uint256);

    function portfolioTokenList(uint256 index) external view returns (address);

    function baseTokenList(uint256 index) external view returns (address);

    function getPortfolio() external view returns (TokenInfo[] memory);

    function lastWithdrawTime() external view returns (uint256);

    function getTokenBalance(address token) external view returns (uint256);

    function getAllPortfolioTokenList() external view returns (address[] memory);

    function getAllBaseTokenList() external view returns (address[] memory);

}// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}