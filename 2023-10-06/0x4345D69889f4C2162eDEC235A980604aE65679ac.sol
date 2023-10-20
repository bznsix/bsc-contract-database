// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title TokenDeposit
 * @dev This contract allows users to deposit a specific token (CERT) and administrators to withdraw any token.
 * Administrators can also set prices for tokens that users can sell in exchange for CERT tokens.
 */
contract TokenDeposit is ReentrancyGuard {
    // Admin address who has the rights to withdraw tokens and update admin
    address public admin;

    // Address of the new admin candidate, needs to accept admin role
    address public newAdminCandidate;

    // The time lock for withdrawals by the admin in seconds
    uint256 public withdrawTimelock;

    // The timestamp of the last withdrawal made by the admin
    uint256 public lastWithdrawTimestamp;

    // Address of the CERT token which users can deposit
    address public certTokenAddress;

    // Boolean flag to toggle the sell functionality on or off
    bool public isBuyActive = true;

    // Address of the wallet from which CERT tokens will be transferred during a sell
    address public certWallet;

    // Native token
    address public constant BNB_ADDRESS =
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // Minimum amount of CERT tokens that can be purchased
    uint256 public minPurchaseAmount = 1;

    /**
     * @dev Structure to hold the details of each transaction.
     */
    struct Transaction {
        address user; // Address of the user who made the transaction
        uint256 amount; // Amount involved in the transaction
        uint256 timestamp; // Timestamp when the transaction was made
        bool isBuy; // True if the transaction is a sell transaction, false if it is a deposit transaction
    }

    // Mapping to store the array of transactions for each user address
    mapping(address => Transaction[]) private userTransactions;

    // Mapping to store the sell prices for tokens that can be sold for CERT
    mapping(address => uint256) public buyPrices;

    // Mapping to keep track of allowed tokens for selling
    mapping(address => bool) public allowedTokens;

    // Event emitted when a user deposits CERT tokens
    event Deposit(address indexed user, uint256 amount, uint256 timestamp);

    // Event emitted when the admin withdraws any token from the contract
    event Withdrawal(
        address indexed admin,
        address indexed token,
        uint256 amount,
        uint256 timestamp
    );

    // Event emitted when the admin role is updated
    event AdminUpdated(address indexed previousAdmin, address indexed newAdmin);

    // Event emitted when the sell price of a token is updated
    event BuyPriceUpdated(address indexed token, uint256 price);

    event Bought(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 certAmount,
        uint256 timestamp
    );

    // Event emitted when the sell functionality is toggled on or off
    event BuyToggled(bool isSellActive);

    // Event emitted when a token is allowed or disallowed for selling
    event AllowToken(address token, bool status);

    /**
     * @dev Constructor to initialize the contract with initial values.
     * @param _withdrawTimelock The time lock for withdrawals by the admin.
     * @param _certTokenAddress The address of the CERT token.
     * @param _certWallet The address of the wallet from which CERT tokens will be transferred during a sell.
     */
    constructor(
        uint256 _withdrawTimelock,
        address _certTokenAddress,
        address _certWallet
    ) {
        admin = msg.sender;
        withdrawTimelock = _withdrawTimelock;
        certTokenAddress = _certTokenAddress;
        certWallet = _certWallet;
    }

    // Modifier to restrict function access to only the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    /**
     * @dev Allows the admin to toggle the sell functionality on or off.
     */
    function toggleBuyActive() external onlyAdmin {
        isBuyActive = !isBuyActive;
        emit BuyToggled(isBuyActive);
    }

    /**
     * @dev Allows the admin to update the address of the certWallet.
     * @param _newCertWallet The new address of the certWallet.
     */
    function updateCertWallet(address _newCertWallet) external onlyAdmin {
        require(_newCertWallet != address(0), "Invalid address");
        certWallet = _newCertWallet;
    }

    // Allows the admin to update the minimum purchase amount
    function updateMinPurchaseAmount(
        uint256 _newMinPurchaseAmount
    ) external onlyAdmin {
        minPurchaseAmount = _newMinPurchaseAmount;
    }

    /**
     * @dev Allows users to deposit CERT tokens.
     * @param amount The amount of CERT tokens to deposit.
     */
    function depositToken(uint256 amount) external nonReentrant {
        IERC20 certToken = IERC20(certTokenAddress);
        require(
            certToken.balanceOf(msg.sender) >= amount,
            "Insufficient balance"
        );
        require(
            certToken.allowance(msg.sender, address(this)) >= amount,
            "Not enough balance approved"
        );

        // Transfer the tokens from user to the contract
        require(
            certToken.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );

        // Store the deposit details
        userTransactions[msg.sender].push(
            Transaction(msg.sender, amount, block.timestamp, false)
        );

        // Emit the event to record the deposit
        emit Deposit(msg.sender, amount, block.timestamp);
    }

    /**
     * @dev Allows the admin to withdraw any token from the contract.
     * @param tokenAddress The address of the token to withdraw.
     * @param user The address to send the withdrawn tokens to.
     * @param amount The amount of tokens to withdraw.
     */
    function withdrawToken(
        address tokenAddress,
        address user,
        uint256 amount
    ) external onlyAdmin {
        require(
            block.timestamp >= lastWithdrawTimestamp + withdrawTimelock,
            "Admin withdraw timelock in progress"
        );
        IERC20 token = IERC20(tokenAddress);
        require(
            token.balanceOf(address(this)) >= amount,
            "Insufficient contract balance"
        );

        // Transfer the tokens from contract to the user
        require(token.transfer(user, amount), "Token transfer failed");

        // Update the last withdrawal timestamp
        lastWithdrawTimestamp = block.timestamp;

        // Emit the event to record the withdrawal
        emit Withdrawal(user, tokenAddress, amount, block.timestamp);
    }

    /**
     * @dev Allows the admin to withdraw BNB from the contract.
     * @param user The address to send the withdrawn BNB to.
     * @param amount The amount of BNB to withdraw in wei.
     */
    function withdrawBNB(
        address payable user,
        uint256 amount
    ) external onlyAdmin {
        require(
            block.timestamp >= lastWithdrawTimestamp + withdrawTimelock,
            "Admin withdraw timelock in progress"
        );
        require(
            address(this).balance >= amount,
            "Insufficient contract balance"
        );

        // Transfer the specified amount of BNB from contract to the user
        user.transfer(amount);

        // Update the last withdrawal timestamp
        lastWithdrawTimestamp = block.timestamp;

        // Emit the event to record the withdrawal
        emit Withdrawal(user, BNB_ADDRESS, amount, block.timestamp);
    }

    /**
     * @dev Allows anyone to check the balance of a token in the contract.
     * @param tokenAddress The address of the token to check the balance of.
     * @return The balance of the specified token in the contract.
     */
    function contractTokensBalance(
        address tokenAddress
    ) external view returns (uint256) {
        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(address(this));
    }

    /**
     * @dev Allows anyone to view the transactions of a user.
     * @param user The address of the user whose transactions to view.
     * @return An array of the user's transactions.
     */
    function getUserTransactions(
        address user
    ) external view returns (Transaction[] memory) {
        return userTransactions[user];
    }

    /**
     * @dev Allows the admin to update the withdraw time lock.
     * @param _newWithdrawTimelock The new withdraw time lock.
     */
    function updateWithdrawTimelock(
        uint256 _newWithdrawTimelock
    ) external onlyAdmin {
        withdrawTimelock = _newWithdrawTimelock;
    }

    /**
     * @dev Allows the admin to nominate a new admin.
     * @param _newAdminCandidate The address of the new admin candidate.
     */
    function updateAdmin(address _newAdminCandidate) external onlyAdmin {
        require(_newAdminCandidate != address(0), "Invalid address");
        newAdminCandidate = _newAdminCandidate;
    }

    /**
     * @dev Allows the new admin candidate to accept the admin role.
     */
    function acceptAdminRole() external {
        require(
            msg.sender == newAdminCandidate,
            "Only new admin candidate can accept admin role"
        );
        emit AdminUpdated(admin, newAdminCandidate);
        admin = newAdminCandidate;
        newAdminCandidate = address(0);
    }

    /**
     * @dev Allows the admin to update the address of the CERT token.
     * @param _newCertTokenAddress The new address of the CERT token.
     */
    function updateCertTokenAddress(
        address _newCertTokenAddress
    ) external onlyAdmin {
        require(_newCertTokenAddress != address(0), "Invalid address");
        certTokenAddress = _newCertTokenAddress;
    }

    /**
     * @dev Allows the admin to update the sell price of a token.
     * @param tokenAddress The address of the token to update the sell price for.
     * @param price The new sell price of the token.
     */
    function updateBuyPrice(
        address tokenAddress,
        uint256 price
    ) external onlyAdmin {
        require(tokenAddress != address(0), "Invalid address");
        require(price > 0, "Price must be greater than 0");

        if (!allowedTokens[tokenAddress]) {
            allowedTokens[tokenAddress] = true;
            emit AllowToken(tokenAddress, true);
        }

        buyPrices[tokenAddress] = price;
        emit BuyPriceUpdated(tokenAddress, price);
    }

    /**
     * @dev Allows the admin to remove a token from the list of allowed tokens.
     * @param tokenAddress The address of the token to disallow.
     */
    function disallowToken(address tokenAddress) external onlyAdmin {
        require(tokenAddress != address(0), "Invalid address");
        allowedTokens[tokenAddress] = false;
        emit AllowToken(tokenAddress, false);
    }

    /**
     * @dev Allows users to purchase CERT in exhange of specified tokens.
     * @param tokenAddress The address of the token to sell.
     * @param certAmount The amount of tokens to sell.
     */
    function buyCERT(
        address tokenAddress,
        uint256 certAmount
    ) external nonReentrant {
        require(
            certAmount >= minPurchaseAmount,
            "Purchase amount below minimum limit"
        );
        require(allowedTokens[tokenAddress], "This token is not allowed");
        require(
            buyPrices[tokenAddress] > 0,
            "Token not available for buying or price not set"
        );
        require(isBuyActive, "Buying is currently disabled");
        uint256 amount = calculateCertPrice(tokenAddress, certAmount);

        IERC20 token = IERC20(tokenAddress);
        require(
            token.balanceOf(msg.sender) >= amount,
            "Insufficient balance of Token A"
        );
        require(
            token.allowance(msg.sender, address(this)) >= amount,
            "Not enough Token A approved"
        );

        IERC20 certToken = IERC20(certTokenAddress);
        require(
            certToken.balanceOf(certWallet) >= certAmount,
            "Insufficient CERT balance in admin wallet"
        );

        // Transfer the calculated amount of Token A from user to the contract
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Token A transfer failed"
        );

        IERC20Metadata cert = IERC20Metadata(certTokenAddress);
        uint256 certAmountInDecimal = certAmount * 10 ** cert.decimals();

        // Transfer the specified certAmount of CERT tokens from certWallet to the user
        require(
            certToken.transferFrom(certWallet, msg.sender, certAmountInDecimal),
            "CERT Token transfer failed"
        );

        // Store the transaction details
        userTransactions[msg.sender].push(
            Transaction(msg.sender, certAmount, block.timestamp, true)
        );

        // Emit the event to record the transaction
        emit Bought(
            msg.sender,
            tokenAddress,
            amount,
            certAmount,
            block.timestamp
        );
    }

    /**
     * @dev Allows users to purchase CERT in exhange of native tokens.
     * @param certAmount The amount of tokens to sell.
     */

    function buyCERTwithBNB(uint256 certAmount) external payable nonReentrant {
        require(
            certAmount >= minPurchaseAmount,
            "Purchase amount below minimum limit"
        );

        require(isBuyActive, "Buying is currently disabled");
        require(buyPrices[BNB_ADDRESS] > 0, "BNB price not set");
        uint256 amount = calculateCertPrice(BNB_ADDRESS, certAmount);

        require(amount <= msg.value, "Insufficient BNB sent");

        IERC20 certToken = IERC20(certTokenAddress);
        require(
            certToken.balanceOf(certWallet) >= certAmount,
            "Insufficient CERT balance in admin wallet"
        );

        // Transfer the excess BNB back to the user if any
        if (msg.value > amount) {
            payable(msg.sender).transfer(msg.value - amount);
        }

        IERC20Metadata cert = IERC20Metadata(certTokenAddress);
        uint256 certAmountInDecimal = certAmount * 10 ** cert.decimals();

        // Transfer the specified certAmount of CERT tokens from certWallet to the user
        require(
            certToken.transferFrom(certWallet, msg.sender, certAmountInDecimal),
            "CERT Token transfer failed"
        );

        // Store the transaction details
        userTransactions[msg.sender].push(
            Transaction(msg.sender, certAmount, block.timestamp, true)
        );

        // Emit the event to record the transaction
        emit Bought(
            msg.sender,
            BNB_ADDRESS,
            amount,
            certAmount,
            block.timestamp
        );
    }

    /**
     * @dev Allows anyone to calculate the equivalent amount of a token for a specified amount of CERT tokens.
     * @param tokenAddress The address of the token to calculate the equivalent amount for.
     * @param certAmount The amount of CERT tokens.
     * @return The equivalent amount of the specified token.
     */
    function calculateCertPrice(
        address tokenAddress,
        uint256 certAmount
    ) public view returns (uint256) {
        require(buyPrices[tokenAddress] > 0, "Price for the token is not set");
        uint256 equivalentAmountForCert;
        if (tokenAddress == BNB_ADDRESS) {
            equivalentAmountForCert =
                (certAmount * 100 * (10 ** 18)) /
                buyPrices[tokenAddress];
        } else {
            // Calculate the equivalent amount of the specified token for the given certAmount
            IERC20Metadata token = IERC20Metadata(tokenAddress);
            equivalentAmountForCert =
                (certAmount * 100 * (10 ** uint256(token.decimals()))) /
                buyPrices[tokenAddress];
        }

        return equivalentAmountForCert;
    }
}
