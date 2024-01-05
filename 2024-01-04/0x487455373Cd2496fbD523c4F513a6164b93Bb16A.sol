// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.18;

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

// File: @openzeppelin/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.18;

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

// File: swap.sol

pragma solidity ^0.8.0;

/// @title TokenSwap: A contract for swapping tokens using two Uniswap routers
/// @notice This contract allows users to deposit tokens, swap them using two Uniswap routers, and withdraw tokens.
contract TokenSwap is Ownable {
    constructor(address initialOwner) Ownable(initialOwner) {}

    // Mapping to store user deposits
    mapping(address => mapping(address => uint256)) public deposits; // Mapping user -> token -> amount

    // Mapping to track deposited tokens for each user
    mapping(address => address[]) public userDepositedTokens; // Mapping user -> tokens

    mapping(address => uint256) public accumulatedFees; // Mapping token -> accumulated fee

    // Vriable to store the fee percentage
    uint256 public feePercentageNumerator = 25; // Numerator for the fee percentage
    uint256 public feePercentageDenominator = 1000; // Denominator for the fee percentage

    /// @dev Event emitted when the fee percentage is changed
    event FeePercentageChanged(
        uint256 newFeePercentageNumerator,
        uint256 newFeePercentageDenominator
    );

    /// @dev Event emitted when tokens are swapped
    event TokensSwapped(
        address indexed user,
        address router1Address,
        address router2Address,
        address tokenIn,
        address tokenOut,
        uint256 swapAmount,
        uint256 amountOutFinal,
        address[] pathsIn,
        address[] pathsOut
    );

    // Event emitted when tokens are deposited
    event TokensDeposited(address indexed user, address token, uint256 amount);

    // Event emitted when tokens are withdrawn
    event TokensWithdrawn(address indexed user, address token, uint256 amount);

    /// @dev Modifier to prevent reentrancy
    bool private locked;

    /// @dev Prevents reentrancy by ensuring that the function is not called recursively
    modifier noReentrancy() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    /// @dev Mapping to store the expected code hash of trusted routers
    mapping(address => bytes32) public expectedCodeHash;

    /// @dev Modifier to ensure that the provided router is trusted
    modifier onlyTrustedRouter(address routerAddress) {
        require(isTrustedRouter(routerAddress), "Untrusted router");
        _;
    }

    /// @notice Checks if a router is trusted based on its code hash
    /// @param routerAddress The address of the router contract
    /// @return true if the router is trusted, false otherwise
    function isTrustedRouter(address routerAddress) public view returns (bool) {
        return
            expectedCodeHash[routerAddress] != bytes32(0) &&
            getCodeHash(routerAddress) == expectedCodeHash[routerAddress];
    }

    /// @notice Sets or removes routers as trusted by updating their expected code hashes
    /// @param routerAddresses An array of addresses of the router contracts to be updated
    /// @param add Boolean flag indicating whether to add (true) or remove (false) the routers
    function setTrustedRouters(
        address[] calldata routerAddresses,
        bool add
    ) external onlyOwner {
        for (uint256 i = 0; i < routerAddresses.length; i++) {
            if (add) {
                // Add router by setting its expected code hash
                expectedCodeHash[routerAddresses[i]] = getCodeHash(
                    routerAddresses[i]
                );
            } else {
                // Remove router by setting its expected code hash to zero
                expectedCodeHash[routerAddresses[i]] = bytes32(0);
            }
        }
    }

    function getCodeHash(address target) internal view returns (bytes32) {
        bytes32 codeHash;
        assembly {
            codeHash := extcodehash(target)
        }
        return codeHash;
    }

    /// @param router1Address The address of the first Uniswap router
    /// @param router2Address The address of the second Uniswap router
    /// @param tokenIn The address of the input token
    /// @param tokenOut The address of the output token
    /// @param swapAmount The amount of input tokens to be swapped
    /// @param amountOutMin The minimum amount of output tokens expected from the first swap
    /// @param amountOutFinal The minimum amount of output tokens expected from the second swap
    /// @param pathsIn An array of addresses representing the swap path for the first swap
    /// @param pathsOut An array of addresses representing the swap path for the second swap
    struct SwapInfo {
        address router1Address;
        address router2Address;
        address tokenIn;
        address tokenOut;
        uint256 swapAmount;
        uint256 amountOutMin;
        uint256 amountOutFinal;
        address[] pathsIn;
        address[] pathsOut;
    }

    /// @notice Swap tokens using two Uniswap routers
    /// @param swapInfo Struct containing swap-related information
    function swapTokens(
        SwapInfo memory swapInfo
    )
        external
        noReentrancy
        onlyTrustedRouter(swapInfo.router1Address)
        onlyTrustedRouter(swapInfo.router2Address)
    {
        // Checks if user has enough tokens to swap
        require(
            deposits[msg.sender][swapInfo.tokenIn] >= swapInfo.swapAmount,
            "Swap amount exceeds deposited amount"
        );

        require(
            swapInfo.tokenIn != swapInfo.tokenOut,
            "TokenIn and TokenOut must be different"
        );
        require(swapInfo.swapAmount > 0, "Invalid swap amount");
        require(
            swapInfo.pathsIn.length > 0 && swapInfo.pathsOut.length > 0,
            "Swap paths must not be empty"
        );
        require(
            swapInfo.pathsIn[0] == swapInfo.tokenIn &&
                swapInfo.pathsIn[swapInfo.pathsIn.length - 1] ==
                swapInfo.tokenOut,
            "Invalid pathsIn"
        );
        require(
            swapInfo.pathsOut[0] == swapInfo.tokenOut &&
                swapInfo.pathsOut[swapInfo.pathsOut.length - 1] ==
                swapInfo.tokenIn,
            "Invalid pathsOut"
        );
        require(swapInfo.amountOutMin > 0, "Invalid amountOutMin");
        require(swapInfo.amountOutFinal > 0, "Invalid amountOutFinal");

        // Effects: Update the user's deposit
        deposits[msg.sender][swapInfo.tokenIn] -= swapInfo.swapAmount;

        // Check if router1 has allowance, if not, approve it
        uint256 allowance = IERC20(swapInfo.tokenOut).allowance(
            address(this),
            swapInfo.router1Address
        );
        if (allowance < swapInfo.swapAmount) {
            IERC20(swapInfo.tokenIn).approve(
                swapInfo.router1Address,
                type(uint256).max
            );
        }

        // Interactions: Perform the first token swap
        uint256[] memory amounts = IUniswapV2Router(swapInfo.router1Address)
            .swapExactTokensForTokens(
                swapInfo.swapAmount,
                swapInfo.amountOutMin,
                swapInfo.pathsIn,
                address(this),
                block.timestamp + 300
            );

        uint256 amountOut = amounts[amounts.length - 1];

        // Check if router2 has allowance, if not, approve it
        allowance = IERC20(swapInfo.tokenOut).allowance(
            address(this),
            swapInfo.router2Address
        );
        if (allowance < amountOut) {
            IERC20(swapInfo.tokenOut).approve(
                swapInfo.router2Address,
                type(uint256).max
            );
        }

        // Interactions: Perform the second token swap
        uint256[] memory amounts2 = IUniswapV2Router(swapInfo.router2Address)
            .swapExactTokensForTokens(
                amountOut,
                swapInfo.amountOutFinal,
                swapInfo.pathsOut,
                address(this),
                block.timestamp + 300
            );

        // Emit an event indicating the tokens were swapped
        emit TokensSwapped(
            msg.sender,
            swapInfo.router1Address,
            swapInfo.router2Address,
            swapInfo.tokenIn,
            swapInfo.tokenOut,
            swapInfo.swapAmount,
            swapInfo.amountOutFinal,
            swapInfo.pathsIn,
            swapInfo.pathsOut
        );

        // Update the user's deposit after the second swap
        deposits[msg.sender][swapInfo.tokenIn] += amounts2[amounts2.length - 1];
    }

    /// @notice Deposit tokens into the contract
    /// @param tokenAddress The address of the token to be deposited
    /// @param amount The amount of tokens to be deposited
    function deposit(address tokenAddress, uint256 amount) external {
        // Ensure that the contract is approved to spend the specified amount of tokens
        require(
            IERC20(tokenAddress).allowance(msg.sender, address(this)) >= amount,
            "Token allowance too low"
        );
        // Calculate the fee
        uint256 fee = (amount * feePercentageNumerator) /
            feePercentageDenominator; // Use the dynamically changeable fee

        // Update the accumulated fee for the token
        accumulatedFees[tokenAddress] += fee;

        // Calculate the actual amount to be deposited after deducting the fee
        uint256 depositAmount = amount - fee;

        // Transfer the amount to the contract
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);

        // Update the user's deposit with the amount minus fee
        deposits[msg.sender][tokenAddress] += depositAmount;

        if (!contains(userDepositedTokens[msg.sender], tokenAddress)) {
            userDepositedTokens[msg.sender].push(tokenAddress);
        }

        // Emit the TokensDeposited event
        emit TokensDeposited(msg.sender, tokenAddress, depositAmount);
    }

    /// @notice Get the deposit balance for a user and a specific token
    /// @param user The user's address
    /// @param token The address of the token
    /// @return The amount of the specified token deposited by the user
    function getDepositBalance(
        address user,
        address token
    ) external view returns (uint256) {
        return deposits[user][token];
    }

    /// @notice Get the list of deposited tokens for a user
    /// @param user The user's address
    /// @return An array of addresses representing the tokens deposited by the user
    function getDepositedTokens(
        address user
    ) external view returns (address[] memory) {
        return userDepositedTokens[user];
    }

    /// @notice Withdraw tokens from the contract
    /// @param tokenAddress The address of the token to be withdrawn
    /// @param amount The amount of tokens to be withdrawn
    function withdraw(
        address tokenAddress,
        uint256 amount
    ) external noReentrancy {
        // Checks if the withdrawal amount is valid
        require(amount > 0, "Withdraw amount must be greater than zero");
        require(
            deposits[msg.sender][tokenAddress] >= amount,
            "Insufficient deposited amount"
        );

        // Effects: Update the user's deposit
        deposits[msg.sender][tokenAddress] -= amount;

        // Interactions: Transfer the tokens to the user
        IERC20(tokenAddress).transfer(msg.sender, amount);

        // Emit the TokensWithdrawn event
        emit TokensWithdrawn(msg.sender, tokenAddress, amount);
    }

    /// @dev Internal function to check if an element is in an array
    /// @param array The array to search
    /// @param element The element to search for
    /// @return true if the element is in the array, false otherwise
    function contains(
        address[] memory array,
        address element
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == element) {
                return true;
            }
        }
        return false;
    }

    /// @notice Sets the fee percentage for deposits with fractional precision.
    /// @dev Only the owner of the contract can call this function.
    /// @param newFeePercentageNumerator The new numerator for the fee percentage.
    /// @param newFeePercentageDenominator The new denominator for the fee percentage.
    /// @dev Emits a `FeePercentageChanged` event upon successful update.
    function setFeePercentage(
        uint256 newFeePercentageNumerator,
        uint256 newFeePercentageDenominator
    ) external onlyOwner {
        require(
            newFeePercentageNumerator <= 1000,
            "Fee percentage numerator must be <= 1000"
        );
        require(
            newFeePercentageDenominator != 0,
            "Denominator must not be zero"
        );
        require(
            newFeePercentageNumerator <= newFeePercentageDenominator,
            "Numerator must be less than or equal to the denominator"
        );

        feePercentageNumerator = newFeePercentageNumerator;
        feePercentageDenominator = newFeePercentageDenominator;

        emit FeePercentageChanged(
            newFeePercentageNumerator,
            newFeePercentageDenominator
        );
    }

    /// @notice Allows the owner to withdraw accumulated fees from the contract.
    /// @dev Only the owner of the contract can call this function.
    /// @param tokenAddress The address of the token to be withdrawn.
    /// @param amount The amount of tokens to be withdrawn.
    /// @dev Requires that the contract has enough balance of the specified token.
    function withdrawFees(
        address tokenAddress,
        uint256 amount
    ) external onlyOwner {
        require(amount > 0, "Withdraw amount must be greater than zero");
        require(
            IERC20(tokenAddress).balanceOf(address(this)) >= amount,
            "Insufficient contract balance"
        );
        require(
            accumulatedFees[tokenAddress] >= amount,
            "Insufficient accumulated fees"
        );

        // Update the accumulated fee for the token
        accumulatedFees[tokenAddress] -= amount;

        // Transfer the tokens to the owner
        IERC20(tokenAddress).transfer(msg.sender, amount);

        // Emit the TokensWithdrawn event
        emit TokensWithdrawn(msg.sender, tokenAddress, amount);
    }

    function getAccumulatedFee(address token) external view returns (uint256) {
        return accumulatedFees[token];
    }
}

// Interface for the Uniswap V2 Router
interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

// Interface for the ERC-20 Token Standard
interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
}