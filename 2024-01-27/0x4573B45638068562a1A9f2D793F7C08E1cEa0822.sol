// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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
// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPancakeSwapRouter {
    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}

contract GAIN_BNB is Ownable, ReentrancyGuard {

    IPancakeSwapRouter private pancakeSwapRouter;
    address public immutable BNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public immutable USDT_ADDRESS = 0x55d398326f99059fF775485246999027B3197955;

    enum PackageTier { None, Fifty, Hundred, TwoFifty, FiveHundred, Thousand, TwoThousandFiveHundred, FiveThousand }
    
    mapping(address => address) private referee_referrer;
    mapping(address => uint256) private withdrawable_balance;
    mapping(address => PackageTier) public userPurchases;
    mapping(PackageTier => uint256) public packagePrices;

    event Register(address indexed buyer, address indexed referrer, uint8 packageTier, uint256 amount);
    event Activation(address indexed buyer, uint8 packageTier, uint256 amount);
    event FundDistribution(address indexed user, uint256 amount);
    event ClaimBonus(address indexed user, uint256 amount);

    constructor(address initialOwner, address router) Ownable(initialOwner) {
        pancakeSwapRouter = IPancakeSwapRouter(router);
        packagePrices[PackageTier.Fifty] = 50 * 1e18;
        packagePrices[PackageTier.Hundred] = 100 * 1e18;
        packagePrices[PackageTier.TwoFifty] = 250 * 1e18;
        packagePrices[PackageTier.FiveHundred] = 500 * 1e18;
        packagePrices[PackageTier.Thousand] = 1000 * 1e18;
        packagePrices[PackageTier.TwoThousandFiveHundred] = 2500 * 1e18;
        packagePrices[PackageTier.FiveThousand] = 5000 * 1e18;
    }


    function register(address referrer, PackageTier packageTier) external payable nonReentrant {
        uint256 packageTierAmount = getBNBAmountForUSD(packagePrices[packageTier]);
        require(msg.value >= packageTierAmount, "GB: insufficient amount");
        // Revert if the user has already been registered
        require(referee_referrer[msg.sender] == address(0), "GB: user already registered");
        // Set the referee_referrer for that user
        referee_referrer[msg.sender] = referrer;
        // Set the package amount as well, which is the highest he has purchased till now ($50)
        userPurchases[msg.sender] = packageTier;
        emit Register(msg.sender, referrer, uint8(packageTier), packageTierAmount);
    }

    function activation(PackageTier packageTier) external payable nonReentrant {
        uint256 packageTierAmount = getBNBAmountForUSD(packagePrices[packageTier]);
        require(isEligible(msg.sender, packageTier), "GB: Not eligible for this package");
        // Put conditions here
        require(msg.value >= packageTierAmount, "GB: insufficient amount");
        // Update user's highest package tier
        userPurchases[msg.sender] = packageTier;
        emit Activation(msg.sender, uint8(packageTier), packageTierAmount);
    }

    function getBNBAmountForUSD(uint usdAmount) public view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = USDT_ADDRESS;
        path[1] = BNB_ADDRESS;

        uint[] memory amounts = pancakeSwapRouter.getAmountsOut(usdAmount, path);
        return amounts[1];
    }

    function isEligible(address user, PackageTier packageTier) public view returns (bool) {
        if (packageTier == PackageTier.Fifty) {
            // $50 package can be bought multiple times
            return true;
        } else {
            // For other packages, ensure the user has bought the previous package
            return packageTier == PackageTier(uint(userPurchases[user]) + 1);
        }
    }

    function fundDistribution(address payable[] calldata recipients, uint[] calldata amounts) external onlyOwner nonReentrant {
       require(recipients.length == amounts.length, "GB: Lengths mismatch");

        uint totalAmount = 0;
        for (uint i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        require(address(this).balance >= totalAmount, "GB: Insufficient balance");

        uint length = recipients.length;
        for (uint i = 0; i < length; i++) {
            // Safe transfer of ETH to each recipient
            address recipient = recipients[i];
            uint256 amount = amounts[i];
            (bool success, ) = recipients[i].call{value: amounts[i]}("");
            require(success, "GB: bnb transfer failed");
            emit FundDistribution(recipient, amount);
        }
    }

    function claimBonus(uint amount) external nonReentrant {
        // Check if the user has withdrawable_balance
        require(withdrawable_balance[msg.sender] >= amount, "GB: insufficient withdrawable balance");
        // Make it to 0 first before withdrawal
        withdrawable_balance[msg.sender] -= amount;
        // Withdraw and check for success
        // Safe transfer of ETH to each recipient
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        emit ClaimBonus(msg.sender, amount);
        require(success, "GB: bnb transfer failed");
    }

    function rebirthActivation(address[] calldata recipients, uint[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "GB: lengths mismatch");
        uint length = amounts.length;
        for (uint i=0; i<length; i++) {
            withdrawable_balance[recipients[i]] = amounts[i];
        }
    }

    function getReferrer(address referee) external view returns (address) {
        return referee_referrer[referee];
    }

    function getWithdrawableBalance(address user) external view returns (uint) {
        return withdrawable_balance[user];
    }

    function renounceOwnership() public override onlyOwner {
        // _transferOwnership(address(0));
    }
 
}