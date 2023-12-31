// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title LemonoPresale
 * @dev A contract for token presale where users can buy tokens using USDC.
 */
contract LemonoPresale is Ownable {
    IERC20 public usdcToken; // The USDC token contract
    uint256 public tokenPrice; // Price per token in Wei
    uint256 public minPurchase; // Minimum purchase amount in Wei
    uint8 public usdcDecimals; // Number of decimals for the USDC token
    address public devAddress; // The address where 5% of USDC withdrawals will be sent
    bool public saleIsActive = true; // Indicates whether the sale is active
    bool public saleIsPermanent = false; // Indicates whether the sale is permanent

    // Mapping to track the total tokens purchased by each buyer
    mapping(address => uint256) public totalPurchased;

    // Array to store the addresses of all buyers
    address[] public buyers;

    event SaleStateToggled(bool saleIsActive);
    event EndPermanentSale();
    event TokensPurchased(address indexed buyer, uint256 quantity);
    event USDCWithdrawn(address indexed recipient, uint256 amount);
    event NATIVEWithdrawn(address indexed recipient, uint256 amount);

    /**
     * @dev Constructor to initialize the contract with the USDC token address and developer address.
     * @param _usdcToken The address of the USDC token contract.
     * @param _devAddress The address where 5% of USDC withdrawals will be sent.
     * @param _decimals USDC decimals differs on different chains.
     */
    constructor(address _usdcToken, address _devAddress, uint8 _decimals) {
        usdcToken = IERC20(_usdcToken);
        usdcDecimals = _decimals;
        tokenPrice = 7 * 10**(_decimals - 3);
        minPurchase = 25 * 10**_decimals;
        devAddress = _devAddress;
    }

    /**
     * @dev Modifier to ensure that the sale is active.
     */
    modifier isActive() {
        require(saleIsPermanent || saleIsActive, "Sale is not active");
        _;
    }

    /**
     * @dev Toggle the state of the sale (active/inactive). Only the owner can call this function.
     */
    function toggleSaleState() external onlyOwner {
        require(!saleIsPermanent, "Sale has ended permanently");
        saleIsActive = !saleIsActive;
        emit SaleStateToggled(saleIsActive);
    }

    /**
     * @dev End the sale permanently. Only the owner can call this function.
     */
    function endPermanentSale() external onlyOwner {
        require(saleIsActive, "Sale is already inactive");
        saleIsActive = false;
        saleIsPermanent = true;
        emit EndPermanentSale();
    }

    /**
     * @dev Buy tokens using a specified amount of USDC. The purchase amount is in whole USDC units.
     * @param usdcAmount The amount of USDC to spend on tokens.
     */
    function buyTokens(uint256 usdcAmount) external isActive {
        require(usdcAmount >= minPurchase, "Purchase amount is below the minimum");

        // Calculate the quantity of tokens based on the purchase amount and the number of decimals
        uint256 qty = usdcAmount / tokenPrice;

        // Transfer USDC from the sender to this contract
        usdcToken.transferFrom(msg.sender, address(this), usdcAmount);
        emit TokensPurchased(msg.sender, qty);

        // Update the total tokens purchased by the sender and add them to the buyers list if necessary
        totalPurchased[msg.sender] += qty;
        if (totalPurchased[msg.sender] == qty) {
            buyers.push(msg.sender);
        }
    }

    /**
     * @dev Get the total number of buyers.
     * @return The total number of buyers.
     */
    function getBuyersCount() external view returns (uint256) {
        return buyers.length;
    }

    /**
     * @dev Get information about a specific buyer's total purchases.
     * @param index The index of the buyer in the buyers array.
     * @return The buyer's address and total tokens purchased.
     */
    function getBuyerInfo(uint256 index) external view returns (address, uint256) {
        require(index < buyers.length, "Index out of range");
        address buyer = buyers[index];
        uint256 amountPurchased = totalPurchased[buyer];
        return (buyer, amountPurchased);
    }

    /**
     * @dev Get information about all buyers and their total purchases.
     * @return An array of buyer addresses and their respective total tokens purchased.
     */
    function getAllBuyersInfo() external view returns (address[] memory, uint256[] memory) {
        address[] memory allBuyers = new address[](buyers.length);
        uint256[] memory totalPurchases = new uint256[](buyers.length);

        for (uint256 i = 0; i < buyers.length; i++) {
            address buyer = buyers[i];
            uint256 amountPurchased = totalPurchased[buyer];
            allBuyers[i] = buyer;
            totalPurchases[i] = amountPurchased;
        }

        return (allBuyers, totalPurchases);
    }

    /**
     * @dev Withdraw all available USDC tokens from the contract. Only the owner can call this function.
     */
    function withdrawAllUSDC() external onlyOwner {
        uint256 contractBalance = usdcToken.balanceOf(address(this));
        require(contractBalance > 0, "No USDC balance to withdraw");

        // Calculate 5% of the contract balance
        uint256 devAmount = (contractBalance * 5) / 100;
        uint256 ownerAmount = contractBalance - devAmount;

        // Transfer 95% to the owner
        usdcToken.transfer(owner(), ownerAmount);
        emit USDCWithdrawn(owner(), ownerAmount);

        // Transfer 5% to the developer address
        usdcToken.transfer(devAddress, devAmount);
        emit USDCWithdrawn(devAddress, devAmount);
    }

    /**
     * @dev Withdraw all available native tokens sent by accident to contract. Only the owner can call this function.
     */
    function withdrawNative() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No NATIVE balance to withdraw");
        payable(owner()).transfer(contractBalance);
        emit NATIVEWithdrawn(owner(), contractBalance);
    }
}
