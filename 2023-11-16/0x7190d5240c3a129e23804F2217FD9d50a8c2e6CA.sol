// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
}
// SPDX-License-Identifier: MIT
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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

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
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.19 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract GreenlersAdmin is ReentrancyGuard, Ownable {
  uint256 public saleId;
  uint256 public BASE_MULTIPLIER;

  struct Sale {
    address saleToken;
    uint256 buyPrice;
    uint256 sellPrice;
    uint256 tokensToSell;
    uint256 baseDecimals;
    uint256 inSale;
    uint256 enableBuyWithEth;
    uint256 enableBuyWithUsdt;
    address payout;
  }

  IERC20 public USDTInterface;
  AggregatorV3Interface internal aggregatorInterface; // https://docs.chain.link/docs/ethereum-addresses/ => (BNB / USD)

  mapping(uint256 => bool) public paused;
  mapping(uint256 => Sale) public sale;

  event SaleCreated(uint256 indexed _id, uint256 _totalTokens, uint256 enableBuyWithEth, uint256 enableBuyWithUsdt, address _payout);

  event SaleUpdated(bytes32 indexed key, uint256 prevValue, uint256 newValue, uint256 timestamp);

  event TokensTransacted(
    bytes32 key,
    address indexed user,
    uint256 indexed id,
    address indexed purchaseToken,
    uint256 tokensBought,
    uint256 amountPaid,
    uint256 timestamp
  );

  event SaleTokenAddressUpdated(address indexed prevValue, address indexed newValue, uint256 timestamp);

  event SalePayoutAddressUpdated(address indexed prevValue, address indexed newValue, uint256 timestamp);

  event SalePaused(uint256 indexed id, uint256 timestamp);
  event SaleUnpaused(uint256 indexed id, uint256 timestamp);

  /**
   * @dev Initializes the contract and sets key parameters
   * @param _oracle Oracle contract to fetch ETH/USDT price
   * @param _usdt USDT token contract address
   */
  constructor(address _oracle, address _usdt) {
    require(_oracle != address(0), "Zero aggregator address");
    require(_usdt != address(0), "Zero USDT address");

    aggregatorInterface = AggregatorV3Interface(_oracle);
    USDTInterface = IERC20(_usdt);
    BASE_MULTIPLIER = (10**18);
  }

  /**
   * @dev Creates a new sale
   * @param _saleTokenAddress Sale token address
   * @param _buyPrice Per token price multiplied by (10**18)
   * @param _sellPrice Per token price multiplied by (10**18)
   * @param _tokensToSell No of tokens to sell without denomination. If 1 million tokens to be sold then - 1_000_000 has to be passed
   * @param _baseDecimals No of decimals for the token. (10**18), for 18 decimal token
   * @param _enableBuyWithEth Enable/Disable buy of tokens with ETH
   * @param _enableBuyWithUsdt Enable/Disable buy of tokens with USDT
   * @param _payout Ethereum address where sale contributions will be moved
   */
  function createSale(
    address _saleTokenAddress,
    uint256 _buyPrice,
    uint256 _sellPrice,
    uint256 _tokensToSell,
    uint256 _baseDecimals,
    uint256 _enableBuyWithEth,
    uint256 _enableBuyWithUsdt,
    address _payout
  ) external onlyOwner {
    require(_buyPrice > 0, "Zero price");
    require(_sellPrice > 0, "Zero price");
    require(_tokensToSell > 0, "Zero tokens to sell");
    require(_baseDecimals > 0, "Zero decimals for the token");

    saleId++;

    sale[saleId] = Sale(_saleTokenAddress, _buyPrice, _sellPrice, _tokensToSell, _baseDecimals, _tokensToSell, _enableBuyWithEth, _enableBuyWithUsdt, _payout);

    emit SaleCreated(saleId, _tokensToSell, _enableBuyWithEth, _enableBuyWithUsdt, _payout);
  }

  /**
   * @dev To update the oracle address address
   * @param _newAddress oracle address
   */

  function changeOracleAddress(address _newAddress) external onlyOwner {
    require(_newAddress != address(0), "Zero token address");
    aggregatorInterface = AggregatorV3Interface(_newAddress);
  }

  /**
   * @dev To update the usdt token address
   * @param _newAddress Sale token address
   */
  function changeUsdtAddress(address _newAddress) external onlyOwner {
    require(_newAddress != address(0), "Zero token address");
    USDTInterface = IERC20(_newAddress);
  }

  /**
   * @dev To update the sale token address
   * @param _id Sale id to update
   * @param _newAddress Sale token address
   */
  function changeSaleTokenAddress(uint256 _id, address _newAddress) external checkSaleId(_id) onlyOwner {
    require(_newAddress != address(0), "Zero token address");
    address prevValue = sale[_id].saleToken;
    sale[_id].saleToken = _newAddress;
    emit SaleTokenAddressUpdated(prevValue, _newAddress, block.timestamp);
  }

  /**
   * @dev To update the payout address
   * @param _id Sale id to update
   * @param _newAddress payout address
   */
  function changePayoutAddress(uint256 _id, address _newAddress) external checkSaleId(_id) onlyOwner {
    require(_newAddress != address(0), "Zero token address");
    address prevValue = sale[_id].payout;
    sale[_id].payout = _newAddress;
    emit SalePayoutAddressUpdated(prevValue, _newAddress, block.timestamp);
  }

  /**
   * @dev To update the buy price
   * @param _id Sale id to update
   * @param _newPrice New buy price of the token
   */
  function changeBuyPrice(uint256 _id, uint256 _newPrice) external checkSaleId(_id) onlyOwner {
    require(_newPrice > 0, "Zero price");
    uint256 prevValue = sale[_id].buyPrice;
    sale[_id].buyPrice = _newPrice;
    emit SaleUpdated(bytes32("BUY"), prevValue, _newPrice, block.timestamp);
  }

  /**
   * @dev To update the sell price
   * @param _id Sale id to update
   * @param _newPrice New sell price of the token
   */
  function changeSellPrice(uint256 _id, uint256 _newPrice) external checkSaleId(_id) onlyOwner {
    require(_newPrice > 0, "Zero price");
    uint256 prevValue = sale[_id].sellPrice;
    sale[_id].sellPrice = _newPrice;
    emit SaleUpdated(bytes32("SELL"), prevValue, _newPrice, block.timestamp);
  }

  /**
   * @dev To update possibility to buy with ETH
   * @param _id Sale id to update
   * @param _enableToBuyWithEth New value of enable to buy with ETH
   */
  function changeEnableBuyWithEth(uint256 _id, uint256 _enableToBuyWithEth) external checkSaleId(_id) onlyOwner {
    uint256 prevValue = sale[_id].enableBuyWithEth;
    sale[_id].enableBuyWithEth = _enableToBuyWithEth;
    emit SaleUpdated(bytes32("ENABLE_BUY_WITH_ETH"), prevValue, _enableToBuyWithEth, block.timestamp);
  }

  /**
   * @dev To update possibility to buy with Usdt
   * @param _id Sale id to update
   * @param _enableToBuyWithUsdt New value of enable to buy with Usdt
   */
  function changeEnableBuyWithUsdt(uint256 _id, uint256 _enableToBuyWithUsdt) external checkSaleId(_id) onlyOwner {
    uint256 prevValue = sale[_id].enableBuyWithUsdt;
    sale[_id].enableBuyWithUsdt = _enableToBuyWithUsdt;
    emit SaleUpdated(bytes32("ENABLE_BUY_WITH_USDT"), prevValue, _enableToBuyWithUsdt, block.timestamp);
  }

  /**
   * @dev To pause the sale
   * @param _id Sale id to update
   */
  function pauseSale(uint256 _id) external checkSaleId(_id) onlyOwner {
    require(!paused[_id], "Already paused");
    paused[_id] = true;
    emit SalePaused(_id, block.timestamp);
  }

  /**
   * @dev To unpause the sale
   * @param _id Sale id to update
   */
  function unPauseSale(uint256 _id) external checkSaleId(_id) onlyOwner {
    require(paused[_id], "Not paused");
    paused[_id] = false;
    emit SaleUnpaused(_id, block.timestamp);
  }

  /**
   * @dev To get latest ethereum price in 10**18 format
   */
  function getLatestPrice() public view returns (uint256) {
    (, int256 price, , , ) = aggregatorInterface.latestRoundData();
    price = (price * (10**10));
    return uint256(price);
  }

  modifier checkSaleId(uint256 _id) {
    require(_id > 0 && _id <= saleId, "Invalid sale id");
    _;
  }

  /**
   * @dev To buy into a sale using USDT
   * @param _id Sale id
   * @param amount No of tokens to buy
   */
  function buyWithUSDT(uint256 _id, uint256 amount) external checkSaleId(_id) returns (bool) {
    require(amount > 0, "Zero claim amount");
    require(sale[_id].saleToken != address(0), "Sale token address not set");
    require(!paused[_id], "Sale paused");
    require(sale[_id].enableBuyWithUsdt > 0, "Not allowed to buy with USDT");
    uint256 usdPrice = amount * sale[_id].buyPrice;
    sale[_id].inSale -= amount;

    Sale memory _sale = sale[_id];

    uint256 ourAllowance = USDTInterface.allowance(_msgSender(), address(this));
    require(usdPrice <= ourAllowance, "Make sure to add enough allowance");
    (bool success, ) = address(USDTInterface).call(
      abi.encodeWithSignature("transferFrom(address,address,uint256)", _msgSender(), _sale.payout, usdPrice)
    );
    require(success, "Token payment failed");

    //send token to user wallet
    uint256 amountToClaim = amount * (10**sale[_id].baseDecimals);

    bool status = IERC20(sale[_id].saleToken).transfer(_msgSender(), amountToClaim);

    require(status, "Token transfer failed");

    emit TokensTransacted(bytes32("BOUGHT"), _msgSender(), _id, address(USDTInterface), amount, usdPrice, block.timestamp);

    return true;
  }

  /**
   * @dev To buy into a sale using ETH
   * @param _id Sale id
   * @param amount No of tokens to buy
   */
  function buyWithEth(uint256 _id, uint256 amount) external payable checkSaleId(_id) nonReentrant returns (bool) {
    require(amount > 0, "Zero claim amount");
    require(sale[_id].saleToken != address(0), "Sale token address not set");
    require(!paused[_id], "Sale paused");
    require(sale[_id].enableBuyWithEth > 0, "Not allowed to buy with ETH");
    uint256 usdPrice = amount * sale[_id].buyPrice;
    uint256 ethAmount = (usdPrice * BASE_MULTIPLIER) / getLatestPrice();
    require(msg.value >= ethAmount, "Less payment");
    uint256 excess = msg.value - ethAmount;
    sale[_id].inSale -= amount;
    Sale memory _sale = sale[_id];

    //send token price to admin wallet
    sendValue(payable(_sale.payout), ethAmount);

    //send token to user wallet
    uint256 amountToClaim = amount * (10**sale[_id].baseDecimals);

    require(amountToClaim <= IERC20(sale[_id].saleToken).balanceOf(address(this)), "Not enough tokens in the contract");

    bool status = IERC20(sale[_id].saleToken).transfer(_msgSender(), amountToClaim);

    require(status, "Token transfer failed");

    if (excess > 0) sendValue(payable(_msgSender()), excess);

    emit TokensTransacted(bytes32("BOUGHT"), _msgSender(), _id, address(0), amount, ethAmount, block.timestamp);

    return true;
  }

  /**
   * @dev To swap Greenlers token for equivalent Eth
   * @param _id Sale id
   * @param amount No of tokens to sell
   */
  function sellGreenForEth(uint256 _id, uint256 amount) external checkSaleId(_id) nonReentrant returns (bool) {
    require(amount > 0, "Zero claim amount");
    require(sale[_id].saleToken != address(0), "Sale token address not set");
    require(!paused[_id], "Sale paused");
    // require(sale[_id].enableBuyWithEth > 0, "Not allowed to buy with ETH");
    uint256 usdPrice = amount * sale[_id].sellPrice;
    uint256 ethAmount = (usdPrice * BASE_MULTIPLIER) / getLatestPrice();

    //send greenlers to admin wallet
    sendValue(payable(_msgSender()), ethAmount);

    //send token to user wallet
    uint256 amountToSell = amount * (10**sale[_id].baseDecimals);

    require(amountToSell <= IERC20(sale[_id].saleToken).allowance(_msgSender(), address(this)), "Make sure to add enough allowance");

    bool status = IERC20(sale[_id].saleToken).transferFrom(_msgSender(), address(this), amountToSell);

    require(status, "Token transfer failed");

    emit TokensTransacted(bytes32("SOLD"), _msgSender(), _id, address(0), amount, ethAmount, block.timestamp);

    return true;
  }

  /**
   * @dev To swap Greenlers token for equivalent Eth
   * @param _id Sale id
   * @param amount No of tokens to sell
   */
  function sellGreenForUSD(uint256 _id, uint256 amount) external checkSaleId(_id) nonReentrant returns (bool) {
    require(amount > 0, "Zero claim amount");
    require(sale[_id].saleToken != address(0), "Sale token address not set");
    require(!paused[_id], "Sale paused");
    // require(sale[_id].enableBuyWithUsdt > 0, "Not allowed to buy with USDT");
    uint256 usdPrice = amount * sale[_id].sellPrice;
    sale[_id].inSale += amount;

    //send greenlers to admin wallet
    uint256 amountToSell = amount * (10**sale[_id].baseDecimals);

    require(amountToSell <= IERC20(sale[_id].saleToken).allowance(_msgSender(), address(this)), "Make sure to add enough allowance");

    bool status = IERC20(sale[_id].saleToken).transferFrom(_msgSender(), address(this), amountToSell);
    
    require(status, "Token payment failed");
    
    require(usdPrice <= USDTInterface.balanceOf(address(this)), "Not usdt enough tokens in the contract");

    (bool success, ) = address(USDTInterface).call(
      abi.encodeWithSignature("transfer(address,uint256)", _msgSender(), usdPrice)
    );

    require(success, "Token transfer failed");

    emit TokensTransacted(bytes32("SOLD"), _msgSender(), _id, address(USDTInterface), amount, usdPrice, block.timestamp);

    return true;
  }

  /**
   * @dev Helper funtion to get ETH price for given amount
   * @param _id Sale id
   * @param amount No of tokens to buy
   */
  function ethBuyHelper(uint256 _id, uint256 amount) external view checkSaleId(_id) returns (uint256 ethAmount) {
    uint256 usdPrice = amount * sale[_id].buyPrice;
    ethAmount = (usdPrice * BASE_MULTIPLIER) / getLatestPrice();
  }

  /**
   * @dev Helper funtion to get ETH price for given amount
   * @param _id Sale id
   * @param amount No of tokens to sell
   */
  function ethSellHelper(uint256 _id, uint256 amount) external view checkSaleId(_id) returns (uint256 ethAmount) {
    uint256 usdPrice = amount * sale[_id].sellPrice;
    ethAmount = (usdPrice * BASE_MULTIPLIER) / getLatestPrice();
  }

  /**
   * @dev Helper funtion to get USDT price for given amount
   * @param _id Sale id
   * @param amount No of tokens to buy
   */
  function usdtBuyHelper(uint256 _id, uint256 amount) external view checkSaleId(_id) returns (uint256 usdPrice) {
    usdPrice = amount * sale[_id].buyPrice;
    return usdPrice;
  }

  /**
   * @dev Helper funtion to get USDT price for given amount
   * @param _id Sale id
   * @param amount No of tokens to sell
   */
  function usdtSellHelper(uint256 _id, uint256 amount) external view checkSaleId(_id) returns (uint256 usdPrice) {
    usdPrice = amount * sale[_id].sellPrice;
    return usdPrice;
  }

  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Low balance");
    (bool success, ) = recipient.call{value: amount}("");
    require(success, "ETH Payment failed");
  }

  /**
   * @dev To get total tokens user has for a given sale round.
   * @param userAddress User address
   * @param _id Sale id
   */

  function userBalance(uint8 _id, address userAddress) public view returns (uint256) {
    uint256 balance = IERC20(sale[_id].saleToken).balanceOf(address(userAddress));

    return balance;
  }

  //Use this in case Coins are sent to the contract by mistake
  function rescueETH(uint256 weiAmount) external onlyOwner {
    require(address(this).balance >= weiAmount, "insufficient Token balance");
    payable(msg.sender).transfer(weiAmount);
  }

  function rescueAnyERC20Tokens(
    address _tokenAddr,
    address _to,
    uint256 _amount
  ) public onlyOwner {
    IERC20(_tokenAddr).transfer(_to, _amount);
  }

  receive() external payable {}

  //override ownership renounce function from ownable contract
  function renounceOwnership() public pure override(Ownable) {
    revert("Unfortunately you cannot renounce Ownership of this contract!");
  }
}
