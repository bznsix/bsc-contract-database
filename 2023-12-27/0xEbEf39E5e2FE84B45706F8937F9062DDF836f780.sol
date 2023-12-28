// Sources flattened with hardhat v2.11.2 https://hardhat.org

// File contracts/interfaces/IEmergencyGuard.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IEmergencyGuard {
    /**
     * Emitted on BNB withdrawal
     *
     * @param receiver address - Receiver of BNB
     * @param amount uint256 - BNB amount
     */
    event EmergencyWithdraw(address receiver, uint256 amount);

    /**
     * Emitted on token withdrawal
     *
     * @param receiver address - Receiver of token
     * @param token address - Token address
     * @param amount uint256 - token amount
     */
    event EmergencyWithdrawToken(
        address receiver,
        address token,
        uint256 amount
    );

    /**
     * Withdraws BNB stores at the contract
     *
     * @param amount uint256 - Amount of BNB to withdraw
     */
    function emergencyWithdraw(uint256 amount) external;

    /**
     * Withdraws token stores at the contract
     *
     * @param token address - Token to withdraw
     * @param amount uint256 - Amount of token to withdraw
     */
    function emergencyWithdrawToken(address token, uint256 amount) external;
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.8.0


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


// File contracts/EmergencyGuard.sol


pragma solidity 0.8.17;

abstract contract EmergencyGuard is IEmergencyGuard {
    function _emergencyWithdraw(uint256 amount) internal virtual {
        address payable sender = payable(msg.sender);
        (bool sent, ) = sender.call{value: amount}("");
        require(sent, "WeSendit: Failed to send BNB");

        emit EmergencyWithdraw(msg.sender, amount);
    }

    function _emergencyWithdrawToken(address token, uint256 amount)
        internal
        virtual
    {
        IERC20(token).transfer(msg.sender, amount);
        emit EmergencyWithdrawToken(msg.sender, token, amount);
    }
}


// File contracts/interfaces/IPancakeRouter.sol


pragma solidity 0.8.17;

interface IPancakeRouter01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}


// File contracts/interfaces/IDynamicFeeManager.sol


pragma solidity 0.8.17;

/**
 * Fee entry structure
 */
struct FeeEntry {
    // Unique identifier for the fee entry
    // Generated out of (destination, doLiquify, doSwapForBusd, swapOrLiquifyAmount) to
    // always use the same feeEntryAmounts entry.
    bytes32 id;
    // Sender address OR wildcard address
    address from;
    // Receiver address OR wildcard address
    address to;
    // Fee percentage multiplied by 100000
    uint256 percentage;
    // Fee destination address
    address destination;
    // Indicator, if contracts should be excluded from this fee
    bool excludeContracts;
    // Indicator, if the fee amount should be used to add liquidation on DEX
    bool doLiquify;
    // Indicator, if the fee amount should be swapped to BUSD
    bool doSwapForBusd;
    // Amount used to add liquidation OR swap to BUSD
    uint256 swapOrLiquifyAmount;
    // Timestamp after which the fee won't be applied anymore
    uint256 expiresAt;
}

interface IDynamicFeeManager {
    /**
     * Emitted on fee addition
     *
     * @param id bytes32 - "Unique" identifier for fee entry
     * @param from address - Sender address OR address(0) for wildcard
     * @param to address - Receiver address OR address(0) for wildcard
     * @param percentage uint256 - Fee percentage to take multiplied by 100000
     * @param destination address - Destination address for the fee
     * @param excludeContracts bool - Indicates, if contracts should be excluded from this fee
     * @param doLiquify bool - Indicates, if the fee amount should be used to add liquidy on DEX
     * @param doSwapForBusd bool - Indicates, if the fee amount should be swapped to BUSD
     * @param swapOrLiquifyAmount uint256 - Amount for liquidify or swap
     * @param expiresAt uint256 - Timestamp after which the fee won't be applied anymore
     */
    event FeeAdded(
        bytes32 indexed id,
        address indexed from,
        address to,
        uint256 percentage,
        address indexed destination,
        bool excludeContracts,
        bool doLiquify,
        bool doSwapForBusd,
        uint256 swapOrLiquifyAmount,
        uint256 expiresAt
    );

    /**
     * Emitted on fee removal
     *
     * @param id bytes32 - "Unique" identifier for fee entry
     * @param index uint256 - Index of removed the fee
     */
    event FeeRemoved(bytes32 indexed id, uint256 index);

    /**
     * Emitted on fee reflection / distribution
     *
     * @param id bytes32 - "Unique" identifier for fee entry
     * @param token address - Token used for fee
     * @param from address - Sender address OR address(0) for wildcard
     * @param to address - Receiver address OR address(0) for wildcard
     * @param destination address - Destination address for the fee
     * @param excludeContracts bool - Indicates, if contracts should be excluded from this fee
     * @param doLiquify bool - Indicates, if the fee amount should be used to add liquidy on DEX
     * @param doSwapForBusd bool - Indicates, if the fee amount should be swapped to BUSD
     * @param swapOrLiquifyAmount uint256 - Amount for liquidify or swap
     * @param expiresAt uint256 - Timestamp after which the fee won't be applied anymore
     */
    event FeeReflected(
        bytes32 indexed id,
        address token,
        address indexed from,
        address to,
        uint256 tFee,
        address indexed destination,
        bool excludeContracts,
        bool doLiquify,
        bool doSwapForBusd,
        uint256 swapOrLiquifyAmount,
        uint256 expiresAt
    );

    /**
     * Emitted on fee state update
     *
     * @param enabled bool - Indicates if fees are enabled now
     */
    event FeeEnabledUpdated(bool enabled);

    /**
     * Emitted on pancake router address update
     *
     * @param newAddress address - New pancake router address
     */
    event PancakeRouterUpdated(address newAddress);

    /**
     * Emitted on BUSD address update
     *
     * @param newAddress address - New BUSD address
     */
    event BusdAddressUpdated(address newAddress);

    /**
     * Emitted on fee limits (fee percentage and transsaction limit) decrease
     */
    event FeeLimitsDecreased();

    /**
     * Emitted on volume percentage for swap events updated
     *
     * @param newPercentage uint256 - New volume percentage for swap events
     */
    event PercentageVolumeSwapUpdated(uint256 newPercentage);

    /**
     * Emitted on volume percentage for liquify events updated
     *
     * @param newPercentage uint256 - New volume percentage for liquify events
     */
    event PercentageVolumeLiquifyUpdated(uint256 newPercentage);

    /**
     * Emitted on Pancakeswap pair (WSI <-> BUSD) address updated
     *
     * @param newAddress address - New pair address
     */
    event PancakePairBusdUpdated(address newAddress);

    /**
     * Emitted on Pancakeswap pair (WSI <-> BNB) address updated
     *
     * @param newAddress address - New pair address
     */
    event PancakePairBnbUpdated(address newAddress);

    /**
     * Emitted on swap and liquify event
     *
     * @param firstHalf uint256 - Half of tokens
     * @param newBalance uint256 - Amount of BNB
     * @param secondHalf uint256 - Half of tokens for BNB swap
     */
    event SwapAndLiquify(
        uint256 firstHalf,
        uint256 newBalance,
        uint256 secondHalf
    );

    /**
     * Emitted on token swap to BUSD
     *
     * @param token address - Token used for swap
     * @param inputAmount uint256 - Amount used as input for swap
     * @param newBalance uint256 - Amount of received BUSD
     * @param destination address - Destination address for BUSD
     */
    event SwapTokenForBusd(
        address token,
        uint256 inputAmount,
        uint256 newBalance,
        address indexed destination
    );

    /**
     * Return the fee entry at the given index
     *
     * @param index uint256 - Index of the fee entry
     *
     * @return fee FeeEntry - Fee entry
     */
    function getFee(uint256 index) external view returns (FeeEntry memory fee);

    /**
     * Adds a fee entry to the list of fees
     *
     * @param from address - Sender address OR wildcard address
     * @param to address - Receiver address OR wildcard address
     * @param percentage uint256 - Fee percentage to take multiplied by 100000
     * @param destination address - Destination address for the fee
     * @param excludeContracts bool - Indicates, if contracts should be excluded from this fee
     * @param doLiquify bool - Indicates, if the fee amount should be used to add liquidy on DEX
     * @param doSwapForBusd bool - Indicates, if the fee amount should be swapped to BUSD
     * @param swapOrLiquifyAmount uint256 - Amount for liquidify or swap
     * @param expiresAt uint256 - Timestamp after which the fee won't be applied anymore
     *
     * @return index uint256 - Index of the newly added fee entry
     */
    function addFee(
        address from,
        address to,
        uint256 percentage,
        address destination,
        bool excludeContracts,
        bool doLiquify,
        bool doSwapForBusd,
        uint256 swapOrLiquifyAmount,
        uint256 expiresAt
    ) external returns (uint256 index);

    /**
     * Removes the fee entry at the given index
     *
     * @param index uint256 - Index to remove
     */
    function removeFee(uint256 index) external;

    /**
     * Reflects the fee for a transaction
     *
     * @param from address - Sender address
     * @param to address - Receiver address
     * @param amount uint256 - Transaction amount
     *
     * @return tTotal uint256 - Total transaction amount after fees
     * @return tFees uint256 - Total fee amount
     */
    function reflectFees(
        address from,
        address to,
        uint256 amount
    ) external returns (uint256 tTotal, uint256 tFees);

    /**
     * Returns the collected amount for swap / liquify fees
     *
     * @param id bytes32 - Fee entry id
     *
     * @return amount uint256 - Collected amount
     */
    function getFeeAmount(bytes32 id) external view returns (uint256 amount);

    /**
     * Returns true if fees are enabled, false when disabled
     *
     * @param value bool - Indicates if fees are enabled
     */
    function feesEnabled() external view returns (bool value);

    /**
     * Sets the transaction fee state
     *
     * @param value bool - true to enable fees, false to disable
     */
    function setFeesEnabled(bool value) external;

    /**
     * Returns the pancake router
     *
     * @return value IPancakeRouter02 - Pancake router
     */
    function pancakeRouter() external view returns (IPancakeRouter02 value);

    /**
     * Sets the pancake router
     *
     * @param value address - New pancake router address
     */
    function setPancakeRouter(address value) external;

    /**
     * Returns the BUSD address
     *
     * @return value address - BUSD address
     */
    function busdAddress() external view returns (address value);

    /**
     * Sets the BUSD address
     *
     * @param value address - BUSD address
     */
    function setBusdAddress(address value) external;

    /**
     * Returns the fee decrease status
     *
     * @return value bool - True if fees are already decreased, false if not
     */
    function feeDecreased() external view returns (bool value);

    /**
     * Returns the fee entry percentage limit
     *
     * @return value uint256 - Fee entry percentage limit
     */
    function feePercentageLimit() external view returns (uint256 value);

    /**
     * Returns the overall transaction fee limit
     *
     * @return value uint256 - Transaction fee limit in percent
     */
    function transactionFeeLimit() external view returns (uint256 value);

    /**
     * Decreases the fee limits from initial values (used for bot protection), to normal values
     */
    function decreaseFeeLimits() external;

    /**
     * Returns the current volume percentage for swap events
     *
     * @return value uint256 - Volume percentage for swap events
     */
    function percentageVolumeSwap() external view returns (uint256 value);

    /**
     * Sets the volume percentage for swap events
     * If set to zero, swapping based on volume will be disabled and fee.swapOrLiquifyAmount is used.
     *
     * @param value uint256 - New volume percentage for swapping
     */
    function setPercentageVolumeSwap(uint256 value) external;

    /**
     * Returns the current volume percentage for liquify events
     *
     * @return value uint256 - Volume percentage for liquify events
     */
    function percentageVolumeLiquify() external view returns (uint256 value);

    /**
     * Sets the volume percentage for liquify events
     * If set to zero, adding liquidity based on volume will be disabled and fee.swapOrLiquifyAmount is used.
     *
     * @param value uint256 - New volume percentage for adding liquidity
     */
    function setPercentageVolumeLiquify(uint256 value) external;

    /**
     * Returns the Pancakeswap pair address (WSI <-> BUSD)
     *
     * @return value address - Pair address
     */
    function pancakePairBusdAddress() external view returns (address value);

    /**
     * Sets the Pancakeswap pair address (WSI <-> BUSD)
     *
     * @param value address - New pair address
     */
    function setPancakePairBusdAddress(address value) external;

    /**
     * Returns the Pancakeswap pair address (WSI <-> BNB)
     *
     * @return value address - Pair address
     */
    function pancakePairBnbAddress() external view returns (address value);

    /**
     * Sets the Pancakeswap pair address (WSI <-> BNB)
     *
     * @param value address - New pair address
     */
    function setPancakePairBnbAddress(address value) external;

    /**
     * Returns the WeSendit token instance
     *
     * @return value IERC20 - WeSendit Token instance
     */
    function token() external view returns (IERC20 value);
}


// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v4.8.0


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC721/IERC721.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


// File contracts/interfaces/IWeStakeitToken.sol


pragma solidity 0.8.17;

interface IWeStakeitToken is IERC721 {
    enum StakingTier {
        BLUE_WHALE,
        SHARK,
        SQUID,
        SHRIMP
    }

    /**
     * Mint a NFT as staking entry
     *
     * @param receiver address - Receiver address
     *
     * @return tokenId uint256 - Minted token id
     */
    function mint(address receiver) external returns (uint256 tokenId);
}


// File contracts/interfaces/IStakingPool.sol


pragma solidity 0.8.17;


/**
 * Pool staking entry object structure
 */
struct PoolEntry {
    // Initial amount of staked token
    uint256 amount;
    // Stake lock duration (in days)
    uint256 duration;
    // Amount of pool shares
    uint256 shares;
    // Reward debt used for calculation
    uint256 rewardDebt;
    // Amount of claimed rewards (only if no auto compounding enabled)
    uint256 claimedRewards;
    // Amount of fees collected from rewards
    uint256 collectedFees;
    // Timestamp of last rewards claim (only if no auto compounding enabled)
    uint256 lastClaimedAt;
    // Block timestamp of staking start
    uint256 startedAt;
    // Indicator, if entry was already unstaked
    bool isUnstaked;
    // Indicator, if auto compounding should be used
    bool isAutoCompoundingEnabled;
}

interface IStakingPool {
    /**
     * Emitted when entering the staking pool
     *
     * @param tokenId uint256 - Proof token ID
     * @param amount uint256 - Initial amount of staked token
     * @param duration uint256 - Stake lock duration (in days)
     * @param shares uint256 - Amount of pool shares
     * @param isAutoCompoundingEnabled bool - Indicator, if auto compounding should be used
     *
     */
    event Staked(
        uint256 indexed tokenId,
        uint256 indexed amount,
        uint256 indexed duration,
        uint256 shares,
        bool isAutoCompoundingEnabled
    );

    /**
     * Emitted when leaving the staking pool
     *
     * @param tokenId uint256 - Proof token ID
     * @param amount uint256 - Initial amount of staked token
     * @param duration uint256 - Stake lock duration (in days)
     * @param shares uint256 - Amount of pool shares
     * @param isAutoCompoundingEnabled bool - Indicator, if auto compounding should be used
     *
     */
    event Unstaked(
        uint256 indexed tokenId,
        uint256 indexed amount,
        uint256 indexed duration,
        uint256 shares,
        bool isAutoCompoundingEnabled
    );

    /**
     * Emitted when entering the staking pool
     *
     * @param tokenId uint256 - Proof token ID
     * @param claimedRewards uint256 - Amount of rewards claimed
     *
     */
    event RewardsClaimed(
        uint256 indexed tokenId,
        uint256 indexed claimedRewards
    );

    /**
     * Set pool paused state
     *
     * @param value bool - true = Pause pool, false = Unpause pool
     */
    function setPoolPaused(bool value) external;

    /**
     * Set active allocated pool shares
     * This is only called by off-chain service
     *
     * @param value uint256 - New active allocated pool shares
     */
    function setActiveAllocatedPoolShares(uint256 value) external;

    /**
     * Calculates the APY in percent for given staking duration (days)
     *
     * @param duration uint256 - Staking duration in days
     *
     * @return value uint256 - APY in percent multiplied by 1e5
     */
    function apy(uint256 duration) external view returns (uint256 value);

    /**
     * Calculates the APR in percent for given staking duration (days)
     *
     * @param duration uint256 - Staking duration in days
     *
     * @return value uint256 - APR in percent multiplied by 1e5
     */
    function apr(uint256 duration) external view returns (uint256 value);

    /**
     * Returns pool paused state
     *
     * @return value bool - true = pool paused, false = pool unpaused
     */
    function poolPaused() external view returns (bool value);

    /**
     * Current pool factor
     *
     * @return value uint256 - Current pool factor
     */
    function currentPoolFactor() external view returns (uint256 value);

    /**
     * Last block timestamp rewards were calculated at
     *
     * @return value uint256 - Last block timestamp rewards were calculated at
     */
    function lastRewardTimestamp() external view returns (uint256 value);

    /**
     * Total amount of allocated pool shares
     *
     * @return value uint256 - Amount of allocated pool shares
     */
    function allocatedPoolShares() external view returns (uint256 value);

    /**
     * Last block timestamp active allocated pool shares were calculated at
     *
     * @return value uint256 - Last block timestamp active allocated pool shares calculated at
     */
    function activeAllocatedPoolShares() external view returns (uint256 value);

    /**
     * Total amount of active (within staking duration) allocated pool shares
     *
     * @return value uint256 - Amount of active allocated pool shares
     */
    function lastActiveAllocatedPoolSharesTimestamp()
        external
        view
        returns (uint256 value);

    /**
     * Accured rewards per pool share
     *
     * @return value uint256 - Accured rewards per pool share at lastRewardTimestamp
     */
    function accRewardsPerShare() external view returns (uint256 value);

    /**
     * Total amount of pool shares available
     *
     * @return value uint256 - Total pool shares available
     */
    function totalPoolShares() external pure returns (uint256 value);

    /**
     * Total amount of token locked inside the pool
     *
     * @return value uint256 - Total amount of token locked
     */
    function totalTokenLocked() external view returns (uint256 value);

    /**
     * Min. staking duration in days
     *
     * @return value uint256 - Min. staking duration
     */
    function minDuration() external pure returns (uint256 value);

    /**
     * Max. staking duration in days
     *
     * @return value uint256 - Max. staking duration
     */
    function maxDuration() external pure returns (uint256 value);

    /**
     * Compounding interval in days
     * Ex. 730 ~= two times per day
     *
     * @return value uint256 - Compounding interval
     */
    function compoundInterval() external pure returns (uint256 value);

    /**
     * Token used for staking
     *
     * @return value IERC20 - Token "instance" used for staking
     */
    function stakeToken() external view returns (IERC20 value);

    /**
     * Token used for staking rewards
     *
     * @return value IWeStakeitToken - Token "instance" used for rewards
     */
    function proofToken() external view returns (IWeStakeitToken value);

    /**
     * Staking pool balance without locked token and allocated rewards
     *
     * @return value uint256 - Pool balance
     */
    function poolBalance() external view returns (uint256 value);

    /**
     * Staking pool balance, calculated with pool factor, without locked
     * token and allocated rewards
     *
     * @param poolFactor_ uint256 - Pool factor
     *
     * @return value uint256 - Pool balance
     */
    function poolBalance(
        uint256 poolFactor_
    ) external view returns (uint256 value);

    /**
     * Returns a single staking pool entry
     *
     * @param tokenId uint256 - Staking token ID
     *
     * @return value PoolEntry - Staking pool entry
     */
    function poolEntry(
        uint256 tokenId
    ) external view returns (PoolEntry memory value);

    /**
     * Calculates the APY in percent for given staking duration
     * and pool factor.
     *
     * @param duration uint256 - Staking duration in days
     * @param factor uint256 - Pool factor
     *
     * @return value uint256 - APY in percent multiplied by 1e5
     */
    function apy(
        uint256 duration,
        uint256 factor
    ) external view returns (uint256 value);

    /**
     * Calculates the ARR in percent for given staking duration
     * and pool factor.
     *
     * @param duration uint256 - Staking duration in days
     * @param factor uint256 - Pool factor
     *
     * @return value uint256 - APR in percent multiplied by 1e5
     */
    function apr(
        uint256 duration,
        uint256 factor
    ) external view returns (uint256 value);

    /**
     * Calculates the pool factor
     *
     * @return value uint256 - Pool factor in wei
     */
    function poolFactor() external view returns (uint256 value);

    /**
     * Calculates the pool factor for given pool balance
     *
     * @param balance uint256 - Staking pool balance
     *
     * @return value uint256 - Pool factor in wei
     */
    function poolFactor(uint256 balance) external view returns (uint256 value);

    /**
     * Return accRewardsPerShare at best matching snapshot
     *
     * @param snapshotId uint256 - Snapshot ID / block timestamp to look for
     *
     * @return snapshotId_ uint256 - Best matching snapshot ID
     * @return snapshotValue uint256 - Value at the snapshot or fallback value, if no snapshot was found
     */
    function accRewardsPerShareAt(
        uint256 snapshotId
    ) external view returns (uint256 snapshotId_, uint256 snapshotValue);

    /**
     * Return lastRewardTimestamp at best matching snapshot
     *
     * @param snapshotId uint256 - Snapshot ID / block timestamp to look for
     *
     * @return snapshotId_ uint256 - Best matching snapshot ID
     * @return snapshotValue uint256 - Value at the snapshot or fallback value, if no snapshot was found
     */
    function lastRewardTimestampAt(
        uint256 snapshotId
    ) external view returns (uint256 snapshotId_, uint256 snapshotValue);

    /**
     * Max. amount a user is able to stake currently
     *
     * @return value uint256 - Max. staking amount
     */
    function maxStakingAmount() external view returns (uint256 value);

    /**
     * Stakes token with the given parameters
     *
     * @param amount uint256 - Amount of token to stake
     * @param duration uint256 - Staking duration in days
     * @param enableAutoCompounding bool - Indicator, if auto compounding should be used
     *
     * @return tokenId uint256 - Proof token ID
     */
    function stake(
        uint256 amount,
        uint256 duration,
        bool enableAutoCompounding
    ) external returns (uint256 tokenId);

    /**
     * Unstakes staking entry
     *
     * @param tokenId uint256 - Proof token ID
     */
    function unstake(uint256 tokenId) external;

    /**
     * Claim rewards for given staking entry
     *
     * @param tokenId uint256 - Proof token ID
     */
    function claimRewards(uint256 tokenId) external;

    /**
     * Return pending / claimable rewards for staking entry
     *
     * @param tokenId uint256 - Proof token ID
     */
    function pendingRewards(
        uint256 tokenId
    ) external view returns (uint256 rewards);

    /**
     * Updates the pool calculations for rewards, etc.
     */
    function updatePool() external;
}


// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
}


// File @openzeppelin/contracts/utils/Context.sol@v4.8.0


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


// File @openzeppelin/contracts/access/Ownable.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/access/IAccessControl.sol@v4.8.0


// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}


// File @openzeppelin/contracts/access/IAccessControlEnumerable.sol@v4.8.0


// OpenZeppelin Contracts v4.4.1 (access/IAccessControlEnumerable.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControlEnumerable declared to support ERC165 detection.
 */
interface IAccessControlEnumerable is IAccessControl {
    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}


// File @openzeppelin/contracts/utils/math/Math.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}


// File @openzeppelin/contracts/utils/Strings.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}


// File @openzeppelin/contracts/utils/introspection/ERC165.sol@v4.8.0


// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


// File @openzeppelin/contracts/access/AccessControl.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.8.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;




/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(account),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}


// File @openzeppelin/contracts/utils/structs/EnumerableSet.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}


// File @openzeppelin/contracts/access/AccessControlEnumerable.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControlEnumerable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Extension of {AccessControl} that allows enumerating the members of each role.
 */
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {_grantRole} to track enumerable memberships
     */
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {_revokeRole} to track enumerable memberships
     */
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}


// File @openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC721/extensions/IERC721Enumerable.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    /**
     * @dev Returns a token ID at a given `index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}


// File contracts/BaseDynamicFeeManager.sol


pragma solidity 0.8.17;







/**
 * @title Base Dynamic Fee Manager
 */
abstract contract BaseDynamicFeeManager is
    IDynamicFeeManager,
    EmergencyGuard,
    AccessControlEnumerable,
    Ownable,
    ReentrancyGuard
{
    // Role allowed to do admin operations like adding to fee whitelist, withdraw, etc.
    bytes32 public constant ADMIN = keccak256("ADMIN");

    // Role allowed to bypass fees
    bytes32 public constant FEE_WHITELIST = keccak256("FEE_WHITELIST");

    // Role allowed to token be sent to without fee
    bytes32 public constant RECEIVER_FEE_WHITELIST =
        keccak256("RECEIVER_FEE_WHITELIST");

    // Role allowed to bypass swap and liquify
    bytes32 public constant BYPASS_SWAP_AND_LIQUIFY =
        keccak256("BYPASS_SWAP_AND_LIQUIFY");

    // Role allowed to bypass wildcard fees
    bytes32 public constant EXCLUDE_WILDCARD_FEE =
        keccak256("EXCLUDE_WILDCARD_FEE");

    // Role allowed to call reflectFees
    bytes32 public constant CALL_REFLECT_FEES = keccak256("CALL_REFLECT_FEES");

    // Fee percentage limit
    uint256 public constant FEE_PERCENTAGE_LIMIT = 10_000; // 10%

    // Fee percentage limit on creation
    uint256 public constant INITIAL_FEE_PERCENTAGE_LIMIT = 25_000; // 25%

    // Transaction fee limit
    uint256 public constant TRANSACTION_FEE_LIMIT = 10_000; // 10%

    // Transaction fee limit on creation
    uint256 public constant INITIAL_TRANSACTION_FEE_LIMIT = 25_000; // 25%

    // Max. amount for fee entries
    uint256 public constant MAX_FEE_AMOUNT = 30;

    // Min. amount for swap / liquify
    uint256 public constant MIN_SWAP_OR_LIQUIFY_AMOUNT = 1 ether;

    // Fee divider
    uint256 internal constant FEE_DIVIDER = 100_000;

    // Wildcard address for fees
    address internal constant WHITELIST_ADDRESS =
        0x000000000000000000000000000000000000dEaD;

    // List of all currently added fees
    FeeEntry[] internal feeEntries;

    // Mapping id to current swap or liquify amounts
    mapping(bytes32 => uint256) internal feeEntryAmounts;

    // Fees enabled state
    bool internal feesEnabled_ = false;

    // Pancake Router address
    IPancakeRouter02 private _pancakeRouter =
        IPancakeRouter02(address(0x10ED43C718714eb63d5aA57B78B54704E256024E));

    // BUSD address
    address private _busdAddress;

    // Fee Decrease status
    bool private _feeDecreased = false;

    // Volume percentage for swap events
    uint256 private _percentageVolumeSwap = 0;

    // Volume percentage for liquify events
    uint256 private _percentageVolumeLiquify = 0;

    // Pancakeswap Pair (WSI <-> BUSD) address
    address private _pancakePairBusdAddress;

    // Pancakeswap Pair (WSI <-> BNB) address
    address private _pancakePairBnbAddress;

    // WeSendit token
    IERC20 private _token;

    // WeStakeit token
    IERC721Enumerable private _weStakeitToken;

    // Staking pool
    IStakingPool private _stakingPool;

    constructor(address wesenditToken) {
        // Add creator to admin role
        _setupRole(ADMIN, _msgSender());

        // Set role admin for roles
        _setRoleAdmin(ADMIN, ADMIN);
        _setRoleAdmin(FEE_WHITELIST, ADMIN);
        _setRoleAdmin(RECEIVER_FEE_WHITELIST, ADMIN);
        _setRoleAdmin(BYPASS_SWAP_AND_LIQUIFY, ADMIN);
        _setRoleAdmin(EXCLUDE_WILDCARD_FEE, ADMIN);
        _setRoleAdmin(CALL_REFLECT_FEES, ADMIN);

        // Create WeSendit token instance
        _token = IERC20(wesenditToken);
    }

    /**
     * Getter & Setter
     */
    function getFee(
        uint256 index
    ) external view override returns (FeeEntry memory fee) {
        return feeEntries[index];
    }

    function getFeeAmount(
        bytes32 id
    ) external view override returns (uint256 amount) {
        return feeEntryAmounts[id];
    }

    function setFeesEnabled(bool value) external override onlyRole(ADMIN) {
        feesEnabled_ = value;

        emit FeeEnabledUpdated(value);
    }

    function setPancakeRouter(address value) external override onlyRole(ADMIN) {
        require(
            value != address(0),
            "DynamicFeeManager: Cannot set Pancake Router to zero address"
        );

        _pancakeRouter = IPancakeRouter02(value);
        emit PancakeRouterUpdated(value);
    }

    function setBusdAddress(address value) external override onlyRole(ADMIN) {
        require(
            value != address(0),
            "DynamicFeeManager: Cannot set BUSD to zero address"
        );

        _busdAddress = value;
        emit BusdAddressUpdated(value);
    }

    function setWeStakeitToken(address value) external onlyRole(ADMIN) {
        // TODO: add override
        _weStakeitToken = IERC721Enumerable(value);
        // TODO: event
    }

    function setStakingPool(address value) external onlyRole(ADMIN) {
        // TODO: add override
        _stakingPool = IStakingPool(value);
        // TODO: event
    }

    function feeDecreased() external view override returns (bool value) {
        return _feeDecreased;
    }

    function decreaseFeeLimits() external override onlyRole(ADMIN) {
        require(
            !_feeDecreased,
            "DynamicFeeManager: Fee limits are already decreased"
        );

        _feeDecreased = true;

        emit FeeLimitsDecreased();
    }

    function emergencyWithdraw(
        uint256 amount
    ) external override onlyRole(ADMIN) {
        super._emergencyWithdraw(amount);
    }

    function emergencyWithdrawToken(
        address tokenToWithdraw,
        uint256 amount
    ) external override onlyRole(ADMIN) {
        super._emergencyWithdrawToken(tokenToWithdraw, amount);
    }

    function setPercentageVolumeSwap(
        uint256 value
    ) external override onlyRole(ADMIN) {
        require(
            value <= 100,
            "DynamicFeeManager: Invalid percentage volume swap value"
        );

        _percentageVolumeSwap = value;

        emit PercentageVolumeSwapUpdated(value);
    }

    function setPercentageVolumeLiquify(
        uint256 value
    ) external override onlyRole(ADMIN) {
        require(
            value <= 100,
            "DynamicFeeManager: Invalid percentage volume liquify value"
        );

        _percentageVolumeLiquify = value;

        emit PercentageVolumeLiquifyUpdated(value);
    }

    function setPancakePairBusdAddress(
        address value
    ) external override onlyRole(ADMIN) {
        require(
            value != address(0),
            "DynamicFeeManager: Cannot set BUSD pair to zero address"
        );

        _pancakePairBusdAddress = value;

        emit PancakePairBusdUpdated(value);
    }

    function setPancakePairBnbAddress(
        address value
    ) external override onlyRole(ADMIN) {
        require(
            value != address(0),
            "DynamicFeeManager: Cannot set BNB pair to zero address"
        );

        _pancakePairBnbAddress = value;

        emit PancakePairBnbUpdated(value);
    }

    function feesEnabled() public view override returns (bool) {
        return feesEnabled_;
    }

    function pancakeRouter()
        public
        view
        override
        returns (IPancakeRouter02 value)
    {
        return _pancakeRouter;
    }

    function busdAddress() public view override returns (address value) {
        return _busdAddress;
    }

    function feePercentageLimit() public view override returns (uint256 value) {
        return
            _feeDecreased ? FEE_PERCENTAGE_LIMIT : INITIAL_FEE_PERCENTAGE_LIMIT;
    }

    function transactionFeeLimit()
        public
        view
        override
        returns (uint256 value)
    {
        return
            _feeDecreased
                ? TRANSACTION_FEE_LIMIT
                : INITIAL_TRANSACTION_FEE_LIMIT;
    }

    function percentageVolumeSwap()
        public
        view
        override
        returns (uint256 value)
    {
        return _percentageVolumeSwap;
    }

    function percentageVolumeLiquify()
        public
        view
        override
        returns (uint256 value)
    {
        return _percentageVolumeLiquify;
    }

    function pancakePairBusdAddress()
        public
        view
        override
        returns (address value)
    {
        return _pancakePairBusdAddress;
    }

    function pancakePairBnbAddress()
        public
        view
        override
        returns (address value)
    {
        return _pancakePairBnbAddress;
    }

    function token() public view override returns (IERC20 value) {
        return _token;
    }

    function weStakeitToken() public view returns (IERC721Enumerable value) {
        // TODO: add override
        return _weStakeitToken;
    }

    function stakingPool() public view returns (IStakingPool value) {
        // TODO: add override
        return _stakingPool;
    }

    /**
     * Swaps half of the token amount and add liquidity on Pancakeswap
     *
     * @param amount uint256 - Amount to use
     * @param destination address - Destination address for the LP tokens
     *
     * @return tokenSwapped uint256 - Amount of token which have been swapped
     */
    function _swapAndLiquify(
        uint256 amount,
        address destination
    ) internal nonReentrant returns (uint256 tokenSwapped) {
        // split the contract balance into halves
        uint256 half = amount / 2;
        uint256 otherHalf = amount - half;

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        _swapTokensForBnb(half, address(this));

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to uniswap
        uint256 tokenLiquified = _addLiquidity(
            otherHalf,
            newBalance,
            destination
        );

        emit SwapAndLiquify(half, newBalance, otherHalf);

        return half + tokenLiquified;
    }

    /**
     * Swaps tokens against BNB on Pancakeswap
     *
     * @param amount uint256 - Amount to use
     * @param destination address - Destination address for BNB
     */
    function _swapTokensForBnb(uint256 amount, address destination) internal {
        // generate the uniswap pair path of token -> wbnb
        address[] memory path = new address[](2);
        path[0] = address(token());
        path[1] = pancakeRouter().WETH();

        require(
            token().approve(address(pancakeRouter()), amount),
            "DynamicFeeManager: Failed to approve token for swap to BNB"
        );

        // make the swap
        pancakeRouter().swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of BNB
            path,
            destination,
            block.timestamp
        );
    }

    /**
     * Swaps tokens against BUSD on Pancakeswap
     *
     * @param amount uint256 - Amount to use
     * @param destination address - Destination address for BUSD
     */
    function _swapTokensForBusd(
        uint256 amount,
        address destination
    ) internal nonReentrant {
        // generate the uniswap pair path of token -> wbnb
        address[] memory path = new address[](2);
        path[0] = address(token());
        path[1] = busdAddress();

        require(
            token().approve(address(pancakeRouter()), amount),
            "DynamicFeeManager: Failed to approve token for swap to BUSD"
        );

        // capture the contract's current balances
        uint256 initialBalance = IERC20(busdAddress()).balanceOf(destination);

        // make the swap
        pancakeRouter().swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of BUSD
            path,
            destination,
            block.timestamp
        );

        // how much BUSD did we just swap into?
        uint256 newBalance = IERC20(busdAddress()).balanceOf(destination) -
            initialBalance;

        emit SwapTokenForBusd(
            address(token()),
            amount,
            newBalance,
            destination
        );
    }

    /**
     * Creates liquidity on Pancakeswap
     *
     * @param tokenAmount uint256 - Amount of token to use
     * @param bnbAmount uint256 - Amount of BNB to use
     * @param destination address - Destination address for the LP tokens
     *
     * @return tokenSwapped uint256 - Amount of token which have been swapped
     */
    function _addLiquidity(
        uint256 tokenAmount,
        uint256 bnbAmount,
        address destination
    ) internal returns (uint256 tokenSwapped) {
        // approve token transfer to cover all possible scenarios
        require(
            token().approve(address(pancakeRouter()), tokenAmount),
            "DynamicFeeManager: Failed to approve token for adding liquidity"
        );

        // add the liquidity
        (tokenSwapped, , ) = pancakeRouter().addLiquidityETH{value: bnbAmount}(
            address(token()),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            destination,
            block.timestamp
        );

        return tokenSwapped;
    }

    /**
     * Returns the amount used for swap / liquify based on volume percentage for swap / liquify
     *
     * @param feeId bytes32 - Fee entry id
     * @param swapOrLiquifyAmount uint256 - Fee entry swap or liquify amount
     * @param percentageVolume uint256 - Volume percentage for swap / liquify
     * @param pancakePairAddress address - Pancakeswap pair address to use for volume
     *
     * @return amount uint256 - Amount used for swap / liquify
     */
    function _getSwapOrLiquifyAmount(
        bytes32 feeId,
        uint256 swapOrLiquifyAmount,
        uint256 percentageVolume,
        address pancakePairAddress
    ) internal view returns (uint256 amount) {
        // If no percentage and fixed amount is set, use balance
        if (percentageVolume == 0 && swapOrLiquifyAmount == 0) {
            return feeEntryAmounts[feeId];
        }

        if (pancakePairAddress == address(0) || percentageVolume == 0) {
            return swapOrLiquifyAmount;
        }

        // Get pancakeswap pair token balance to identify, how many
        // token are currently on the market
        uint256 pancakePairTokenBalance = token().balanceOf(pancakePairAddress);

        // Calculate percentual amount of volume
        uint256 percentualAmount = (pancakePairTokenBalance *
            percentageVolume) / 100;

        // If swap or liquify amount is zero, and percentual amount is
        // higher than collected amount, return collected amount, otherwise
        // return percentual amount
        if (swapOrLiquifyAmount == 0) {
            return
                percentualAmount > feeEntryAmounts[feeId]
                    ? feeEntryAmounts[feeId]
                    : percentualAmount;
        }

        // Do not exceed swap or liquify amount from fee entry
        if (percentualAmount >= swapOrLiquifyAmount) {
            return swapOrLiquifyAmount;
        }

        return percentualAmount;
    }

    /**
     * Checks if the given address is a contract or not
     *
     * @param addr address - Address to check
     *
     * @return isContract bool - Indicator, if checked address is a contract
     */
    function _isContract(address addr) internal view returns (bool isContract) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}


// File hardhat/console.sol@v2.11.2


pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int256)", p0));
	}

	function logUint(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint256 p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256)", p0, p1));
	}

	function log(uint256 p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string)", p0, p1));
	}

	function log(uint256 p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool)", p0, p1));
	}

	function log(uint256 p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address)", p0, p1));
	}

	function log(string memory p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint256 p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool)", p0, p1, p2));
	}

	function log(uint256 p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool)", p0, p1, p2));
	}

	function log(uint256 p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool)", p0, p1, p2));
	}

	function log(uint256 p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool)", p0, p1, p2));
	}

	function log(bool p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool)", p0, p1, p2));
	}

	function log(address p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint256 p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint256)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}


// File @openzeppelin/contracts/utils/StorageSlot.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}


// File @openzeppelin/contracts/utils/Arrays.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Arrays.sol)

pragma solidity ^0.8.0;


/**
 * @dev Collection of functions related to array types.
 */
library Arrays {
    using StorageSlot for bytes32;

    /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).
            if (unsafeAccess(array, mid).value > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && unsafeAccess(array, low - 1).value == element) {
            return low - 1;
        } else {
            return low;
        }
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeAccess(address[] storage arr, uint256 pos) internal pure returns (StorageSlot.AddressSlot storage) {
        bytes32 slot;
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getAddressSlot();
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeAccess(bytes32[] storage arr, uint256 pos) internal pure returns (StorageSlot.Bytes32Slot storage) {
        bytes32 slot;
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getBytes32Slot();
    }

    /**
     * @dev Access an array in an "unsafe" way. Skips solidity "index-out-of-range" check.
     *
     * WARNING: Only use if you are certain `pos` is lower than the array length.
     */
    function unsafeAccess(uint256[] storage arr, uint256 pos) internal pure returns (StorageSlot.Uint256Slot storage) {
        bytes32 slot;
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0, arr.slot)
            slot := add(keccak256(0, 0x20), pos)
        }
        return slot.getUint256Slot();
    }
}


// File @openzeppelin/contracts/utils/Counters.sol@v4.8.0


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}


// File contracts/StakingPoolSnapshot.sol


// Based on https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Snapshot.sol
pragma solidity 0.8.17;


/**
 * Snapshot object structure
 */
struct Snapshots {
    // Snapshot ids
    uint256[] ids;
    // Snapshot values
    uint256[] values;
}

abstract contract StakingPoolSnapshot {
    using Arrays for uint256[];
    using Counters for Counters.Counter;

    // Snapshots for _accRewardsPerShare
    Snapshots internal _accRewardsPerShareSnapshots;

    // Snapshots for _lastRewardTimestamp
    Snapshots internal _lastRewardTimestampSnapshots;

    // Current snapshot id
    Counters.Counter private _currentSnapshotId;

    /**
     * Returns accRewardsPerShare at best matching snapshot
     *
     * @param snapshotId uint256 - Snapshot ID / block timestamp to look for
     * @param currentValue uint256 - Current value used as fallback
     *
     * @return snapshotId_ uint256 - Best matching snapshot ID
     * @return snapshotValue uint256 - Value at the snapshot or fallback value, if no snapshot was found
     */
    function _accRewardsPerShareAt(
        uint256 snapshotId,
        uint256 currentValue
    ) internal view returns (uint256 snapshotId_, uint256 snapshotValue) {
        (bool snapshotted, uint256 id, uint256 value) = _valueAt(
            snapshotId,
            _accRewardsPerShareSnapshots
        );

        return (id, snapshotted ? value : currentValue);
    }

    /**
     * Returns lastRewardTimestamp at best matching snapshot
     *
     * @param snapshotId uint256 - Snapshot ID / block timestamp to look for
     * @param currentValue uint256 - Current value used as fallback
     *
     * @return snapshotId_ uint256 - Best matching snapshot ID
     * @return snapshotValue uint256 - Value at the snapshot or fallback value, if no snapshot was found
     */
    function _lastRewardTimestampAt(
        uint256 snapshotId,
        uint256 currentValue
    ) internal view returns (uint256 snapshotId_, uint256 snapshotValue) {
        (bool snapshotted, uint256 id, uint256 value) = _valueAt(
            snapshotId,
            _lastRewardTimestampSnapshots
        );

        return (id, snapshotted ? value : currentValue);
    }

    /**
     * Triggers a snapshot for current snapshot ID
     */
    function _snapshot() internal returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _getCurrentSnapshotId();
        return currentId;
    }

    /**
     * Updates the current "in-work" snapshot
     *
     * @param snapshots Snapshots - Snapshots struct / object to update
     * @param currentValue uint256 - New value
     */
    function _updateSnapshot(
        Snapshots storage snapshots,
        uint256 currentValue
    ) internal {
        uint256 currentId = _getCurrentSnapshotId();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    /**
     * Current snapshot ID
     */
    function _getCurrentSnapshotId() private view returns (uint256) {
        return block.timestamp;
    }

    /**
     * Last snapshot ID for given array
     *
     * @param ids uint256[] - List of snapshot IDs
     */
    function _lastSnapshotId(
        uint256[] storage ids
    ) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }

    /**
     * Returns the value at best matching snapshot
     *
     * @param snapshotId uint256 - Snapshot ID / block timestamp to look for
     * @param snapshots Snapshots - Snapshots struct / object
     *
     * @return snapshotFound bool - Indicator, if snapshot was available for the given ID
     * @return snapshotId_ uint256 - Best matching snapshot ID
     * @return snapshotValue uint256 - Value at the snapshot or fallback value, if no snapshot was found
     */
    function _valueAt(
        uint256 snapshotId,
        Snapshots storage snapshots
    )
        private
        view
        returns (bool snapshotFound, uint256 snapshotId_, uint256 snapshotValue)
    {
        require(snapshotId > 0, "Staking Pool Snapshot: id is 0");
        require(
            snapshotId <= _getCurrentSnapshotId(),
            "Staking Pool Snapshot: nonexistent id"
        );

        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0, 0);
        } else {
            return (true, snapshots.ids[index], snapshots.values[index]);
        }
    }
}


// File contracts/utils/Trigonometry.sol


pragma solidity ^0.8.0;

/**
 * @notice Solidity library offering basic trigonometry functions where inputs and outputs are
 * integers. Inputs are specified in radians scaled by 1e18, and similarly outputs are scaled by 1e18.
 *
 * This implementation is based off the Solidity trigonometry library written by Lefteris Karapetsas
 * which can be found here: https://github.com/Sikorkaio/sikorka/blob/e75c91925c914beaedf4841c0336a806f2b5f66d/contracts/trigonometry.sol
 *
 * Compared to Lefteris' implementation, this version makes the following changes:
 *   - Uses a 32 bits instead of 16 bits for improved accuracy
 *   - Updated for Solidity 0.8.x
 *   - Various gas optimizations
 *   - Change inputs/outputs to standard trig format (scaled by 1e18) instead of requiring the
 *     integer format used by the algorithm
 *
 * Lefertis' implementation is based off Dave Dribin's trigint C library
 *     http://www.dribin.org/dave/trigint/
 *
 * Which in turn is based from a now deleted article which can be found in the Wayback Machine:
 *     http://web.archive.org/web/20120301144605/http://www.dattalo.com/technical/software/pic/picsine.html
 */
library Trigonometry {
    // Table index into the trigonometric table
    uint256 constant INDEX_WIDTH = 8;
    // Interpolation between successive entries in the table
    uint256 constant INTERP_WIDTH = 16;
    uint256 constant INDEX_OFFSET = 28 - INDEX_WIDTH;
    uint256 constant INTERP_OFFSET = INDEX_OFFSET - INTERP_WIDTH;
    uint32 constant ANGLES_IN_CYCLE = 1073741824;
    uint32 constant QUADRANT_HIGH_MASK = 536870912;
    uint32 constant QUADRANT_LOW_MASK = 268435456;
    uint256 constant SINE_TABLE_SIZE = 256;

    // Pi as an 18 decimal value, which is plenty of accuracy: "For JPL's highest accuracy calculations, which are for
    // interplanetary navigation, we use 3.141592653589793: https://www.jpl.nasa.gov/edu/news/2016/3/16/how-many-decimals-of-pi-do-we-really-need/
    uint256 constant PI = 3141592653589793238;
    uint256 constant TWO_PI = 2 * PI;
    uint256 constant PI_OVER_TWO = PI / 2;

    // The constant sine lookup table was generated by generate_trigonometry.py. We must use a constant
    // bytes array because constant arrays are not supported in Solidity. Each entry in the lookup
    // table is 4 bytes. Since we're using 32-bit parameters for the lookup table, we get a table size
    // of 2^(32/4) + 1 = 257, where the first and last entries are equivalent (hence the table size of
    // 256 defined above)
    uint8 constant entry_bytes = 4; // each entry in the lookup table is 4 bytes
    uint256 constant entry_mask = ((1 << (8 * entry_bytes)) - 1); // mask used to cast bytes32 -> lookup table entry
    bytes constant sin_table =
        hex"00_00_00_00_00_c9_0f_88_01_92_1d_20_02_5b_26_d7_03_24_2a_bf_03_ed_26_e6_04_b6_19_5d_05_7f_00_35_06_47_d9_7c_07_10_a3_45_07_d9_5b_9e_08_a2_00_9a_09_6a_90_49_0a_33_08_bc_0a_fb_68_05_0b_c3_ac_35_0c_8b_d3_5e_0d_53_db_92_0e_1b_c2_e4_0e_e3_87_66_0f_ab_27_2b_10_72_a0_48_11_39_f0_cf_12_01_16_d5_12_c8_10_6e_13_8e_db_b1_14_55_76_b1_15_1b_df_85_15_e2_14_44_16_a8_13_05_17_6d_d9_de_18_33_66_e8_18_f8_b8_3c_19_bd_cb_f3_1a_82_a0_25_1b_47_32_ef_1c_0b_82_6a_1c_cf_8c_b3_1d_93_4f_e5_1e_56_ca_1e_1f_19_f9_7b_1f_dc_dc_1b_20_9f_70_1c_21_61_b3_9f_22_23_a4_c5_22_e5_41_af_23_a6_88_7e_24_67_77_57_25_28_0c_5d_25_e8_45_b6_26_a8_21_85_27_67_9d_f4_28_26_b9_28_28_e5_71_4a_29_a3_c4_85_2a_61_b1_01_2b_1f_34_eb_2b_dc_4e_6f_2c_98_fb_ba_2d_55_3a_fb_2e_11_0a_62_2e_cc_68_1e_2f_87_52_62_30_41_c7_60_30_fb_c5_4d_31_b5_4a_5d_32_6e_54_c7_33_26_e2_c2_33_de_f2_87_34_96_82_4f_35_4d_90_56_36_04_1a_d9_36_ba_20_13_37_6f_9e_46_38_24_93_b0_38_d8_fe_93_39_8c_dd_32_3a_40_2d_d1_3a_f2_ee_b7_3b_a5_1e_29_3c_56_ba_70_3d_07_c1_d5_3d_b8_32_a5_3e_68_0b_2c_3f_17_49_b7_3f_c5_ec_97_40_73_f2_1d_41_21_58_9a_41_ce_1e_64_42_7a_41_d0_43_25_c1_35_43_d0_9a_ec_44_7a_cd_50_45_24_56_bc_45_cd_35_8f_46_75_68_27_47_1c_ec_e6_47_c3_c2_2e_48_69_e6_64_49_0f_57_ee_49_b4_15_33_4a_58_1c_9d_4a_fb_6c_97_4b_9e_03_8f_4c_3f_df_f3_4c_e1_00_34_4d_81_62_c3_4e_21_06_17_4e_bf_e8_a4_4f_5e_08_e2_4f_fb_65_4c_50_97_fc_5e_51_33_cc_94_51_ce_d4_6e_52_69_12_6e_53_02_85_17_53_9b_2a_ef_54_33_02_7d_54_ca_0a_4a_55_60_40_e2_55_f5_a4_d2_56_8a_34_a9_57_1d_ee_f9_57_b0_d2_55_58_42_dd_54_58_d4_0e_8c_59_64_64_97_59_f3_de_12_5a_82_79_99_5b_10_35_ce_5b_9d_11_53_5c_29_0a_cc_5c_b4_20_df_5d_3e_52_36_5d_c7_9d_7b_5e_50_01_5d_5e_d7_7c_89_5f_5e_0d_b2_5f_e3_b3_8d_60_68_6c_ce_60_ec_38_2f_61_6f_14_6b_61_f1_00_3e_62_71_fa_68_62_f2_01_ac_63_71_14_cc_63_ef_32_8f_64_6c_59_bf_64_e8_89_25_65_63_bf_91_65_dd_fb_d2_66_57_3c_bb_66_cf_81_1f_67_46_c7_d7_67_bd_0f_bc_68_32_57_aa_68_a6_9e_80_69_19_e3_1f_69_8c_24_6b_69_fd_61_4a_6a_6d_98_a3_6a_dc_c9_64_6b_4a_f2_78_6b_b8_12_d0_6c_24_29_5f_6c_8f_35_1b_6c_f9_34_fb_6d_62_27_f9_6d_ca_0d_14_6e_30_e3_49_6e_96_a9_9c_6e_fb_5f_11_6f_5f_02_b1_6f_c1_93_84_70_23_10_99_70_83_78_fe_70_e2_cb_c5_71_41_08_04_71_9e_2c_d1_71_fa_39_48_72_55_2c_84_72_af_05_a6_73_07_c3_cf_73_5f_66_25_73_b5_eb_d0_74_0b_53_fa_74_5f_9d_d0_74_b2_c8_83_75_04_d3_44_75_55_bd_4b_75_a5_85_ce_75_f4_2c_0a_76_41_af_3c_76_8e_0e_a5_76_d9_49_88_77_23_5f_2c_77_6c_4e_da_77_b4_17_df_77_fa_b9_88_78_40_33_28_78_84_84_13_78_c7_ab_a1_79_09_a9_2c_79_4a_7c_11_79_8a_23_b0_79_c8_9f_6d_7a_05_ee_ac_7a_42_10_d8_7a_7d_05_5a_7a_b6_cb_a3_7a_ef_63_23_7b_26_cb_4e_7b_5d_03_9d_7b_92_0b_88_7b_c5_e2_8f_7b_f8_88_2f_7c_29_fb_ed_7c_5a_3d_4f_7c_89_4b_dd_7c_b7_27_23_7c_e3_ce_b1_7d_0f_42_17_7d_39_80_eb_7d_62_8a_c5_7d_8a_5f_3f_7d_b0_fd_f7_7d_d6_66_8e_7d_fa_98_a7_7e_1d_93_e9_7e_3f_57_fe_7e_5f_e4_92_7e_7f_39_56_7e_9d_55_fb_7e_ba_3a_38_7e_d5_e5_c5_7e_f0_58_5f_7f_09_91_c3_7f_21_91_b3_7f_38_57_f5_7f_4d_e4_50_7f_62_36_8e_7f_75_4e_7f_7f_87_2b_f2_7f_97_ce_bc_7f_a7_36_b3_7f_b5_63_b2_7f_c2_55_95_7f_ce_0c_3d_7f_d8_87_8d_7f_e1_c7_6a_7f_e9_cb_bf_7f_f0_94_77_7f_f6_21_81_7f_fa_72_d0_7f_fd_88_59_7f_ff_62_15_7f_ff_ff_ff";

    /**
     * @notice Return the sine of a value, specified in radians scaled by 1e18
     * @dev This algorithm for converting sine only uses integer values, and it works by dividing the
     * circle into 30 bit angles, i.e. there are 1,073,741,824 (2^30) angle units, instead of the
     * standard 360 degrees (2pi radians). From there, we get an output in range -2,147,483,647 to
     * 2,147,483,647, (which is the max value of an int32) which is then converted back to the standard
     * range of -1 to 1, again scaled by 1e18
     * @param _angle Angle to convert
     * @return Result scaled by 1e18
     */
    function sin(uint256 _angle) internal pure returns (int256) {
        unchecked {
            // Convert angle from from arbitrary radian value (range of 0 to 2pi) to the algorithm's range
            // of 0 to 1,073,741,824
            _angle = (ANGLES_IN_CYCLE * (_angle % TWO_PI)) / TWO_PI;

            // Apply a mask on an integer to extract a certain number of bits, where angle is the integer
            // whose bits we want to get, the width is the width of the bits (in bits) we want to extract,
            // and the offset is the offset of the bits (in bits) we want to extract. The result is an
            // integer containing _width bits of _value starting at the offset bit
            uint256 interp = (_angle >> INTERP_OFFSET) &
                ((1 << INTERP_WIDTH) - 1);
            uint256 index = (_angle >> INDEX_OFFSET) & ((1 << INDEX_WIDTH) - 1);

            // The lookup table only contains data for one quadrant (since sin is symmetric around both
            // axes), so here we figure out which quadrant we're in, then we lookup the values in the
            // table then modify values accordingly
            bool is_odd_quadrant = (_angle & QUADRANT_LOW_MASK) == 0;
            bool is_negative_quadrant = (_angle & QUADRANT_HIGH_MASK) != 0;

            if (!is_odd_quadrant) {
                index = SINE_TABLE_SIZE - 1 - index;
            }

            bytes memory table = sin_table;
            // We are looking for two consecutive indices in our lookup table
            // Since EVM is left aligned, to read n bytes of data from idx i, we must read from `i * data_len` + `n`
            // therefore, to read two entries of size entry_bytes `index * entry_bytes` + `entry_bytes * 2`
            uint256 offset1_2 = (index + 2) * entry_bytes;

            // This following snippet will function for any entry_bytes <= 15
            uint256 x1_2;
            assembly {
                // mload will grab one word worth of bytes (32), as that is the minimum size in EVM
                x1_2 := mload(add(table, offset1_2))
            }

            // We now read the last two numbers of size entry_bytes from x1_2
            // in example: entry_bytes = 4; x1_2 = 0x00...12345678abcdefgh
            // therefore: entry_mask = 0xFFFFFFFF

            // 0x00...12345678abcdefgh >> 8*4 = 0x00...12345678
            // 0x00...12345678 & 0xFFFFFFFF = 0x12345678
            uint256 x1 = (x1_2 >> (8 * entry_bytes)) & entry_mask;
            // 0x00...12345678abcdefgh & 0xFFFFFFFF = 0xabcdefgh
            uint256 x2 = x1_2 & entry_mask;

            // Approximate angle by interpolating in the table, accounting for the quadrant
            uint256 approximation = ((x2 - x1) * interp) >> INTERP_WIDTH;
            int256 sine = is_odd_quadrant
                ? int256(x1) + int256(approximation)
                : int256(x2) - int256(approximation);
            if (is_negative_quadrant) {
                sine *= -1;
            }

            // Bring result from the range of -2,147,483,647 through 2,147,483,647 to -1e18 through 1e18.
            // This can never overflow because sine is bounded by the above values
            return (sine * 1e18) / 2_147_483_647;
        }
    }

    /**
     * @notice Return the cosine of a value, specified in radians scaled by 1e18
     * @dev This is identical to the sin() method, and just computes the value by delegating to the
     * sin() method using the identity cos(x) = sin(x + pi/2)
     * @dev Overflow when `angle + PI_OVER_TWO > type(uint256).max` is ok, results are still accurate
     * @param _angle Angle to convert
     * @return Result scaled by 1e18
     */
    function cos(uint256 _angle) internal pure returns (int256) {
        unchecked {
            return sin(_angle + PI_OVER_TWO);
        }
    }
}


// File contracts/utils/WeSenditMath.sol


pragma solidity ^0.8.0;

library WeSenditMath {
    /**
     * Calculates staking pool "pool factor" using given parameters
     *
     * @param balance uint256 - Pool balance in wei
     *
     * @return result uint256 - Pool Factor
     */
    function poolFactor(
        uint256 balance
    ) internal pure returns (uint256 result) {
        uint256 pMax = 120_000_000 ether;
        uint256 pMin = 0;

        // Handle overflow
        if (balance > pMax) {
            balance = pMax;
        }

        uint256 PI = Trigonometry.PI; // / 1e13;
        uint256 bracketsOne = (pMax / 1e13) - (balance / 1e13);
        uint256 bracketsTwo = (pMax / 1e18) - (pMin / 1e18);
        uint256 division = bracketsOne / bracketsTwo;
        uint256 bracketsCos = (PI * division) / 1e5;

        uint256 cos;
        uint256 brackets;
        if (bracketsCos >= Trigonometry.PI_OVER_TWO) {
            cos = uint256(Trigonometry.cos(bracketsCos + Trigonometry.PI));
            brackets = (cos + 1e18) / (2 * 1e1);
            // Subtract cos result from brackets result, since we shifted the cos input by PI
            brackets -= (cos / 1e1);
        } else {
            cos = uint256(Trigonometry.cos(bracketsCos));
            brackets = (cos + 1e18) / (2 * 1e1);
        }

        uint256 res = brackets * (100 - 15) + (15 * 1e17);
        return res * 1e1;
    }

    /**
     * Calculates staking pool APY using given parameters
     *
     * @param duration uint256 - Staking duration in days
     * @param factor uint256 - Pool Factor (1e18)
     * @param maxDuration uint256 - Max. allowed staking duration in days
     * @param compoundInterval uint256 - Compounding interval
     *
     * @return result uint256 - Pool APY
     */
    function apy(
        uint256 duration,
        uint256 factor,
        uint256 maxDuration,
        uint256 compoundInterval
    ) internal pure returns (uint256 result) {
        // Handle overflow
        if (duration > maxDuration) {
            duration = maxDuration;
        }

        uint256 _roi = 11 * 1e4; // 110%
        uint256 _poolFactor = factor / 1e14;
        uint256 _compoundInterval = compoundInterval * 1e4;
        uint256 _duration = duration * 1e7;
        uint256 _maxDuration = maxDuration * 1e4;

        uint256 x = 1e7 + (_roi * _poolFactor) / _compoundInterval;
        uint256 y = _compoundInterval * (_duration / _maxDuration);
        uint256 pow = power(x, y / 1e7, 7);

        return pow - 1e7;
    }

    /**
     * Calculates staking pool APR using given parameters
     *
     * @param duration uint256 - Staking duration in days
     * @param factor uint256 - Pool Factor (1e18)
     * @param maxDuration uint256 - Max. allowed staking duration in days
     *
     * @return result uint256 - Pool APR
     */
    function apr(
        uint256 duration,
        uint256 factor,
        uint256 maxDuration
    ) internal pure returns (uint256 result) {
        // Handle overflow
        if (duration > maxDuration) {
            duration = maxDuration;
        }

        uint256 _roi = 11 * 1e4; // 110%
        uint256 _poolFactor = factor / 1e14;
        uint256 _duration = duration * 1e7;
        uint256 _maxDuration = maxDuration * 1e4;

        uint256 x = _roi * _poolFactor;
        uint256 y = _duration / _maxDuration;

        return (x * y) / 1e7;
    }

    /**
     * Calculates the power for the given parameters.
     *
     * @param base uint256 - Base
     * @param exponent uint256 - Exponent
     * @param precision uint256 - Precision used for calculation
     *
     * @return result uint256 - Calculation result
     */
    function power(
        uint256 base,
        uint256 exponent,
        uint256 precision
    ) internal pure returns (uint256 result) {
        if (exponent == 0) {
            return 10 ** precision;
        } else if (exponent == 1) {
            return base;
        } else {
            uint256 answer = base;
            for (uint256 i = 0; i < exponent; i++) {
                answer = (answer * base) / (10 ** precision);
            }
            return answer;
        }
    }
}


// File contracts/BaseStakingPool.sol


pragma solidity 0.8.17;











abstract contract BaseStakingPool is
    IStakingPool,
    StakingPoolSnapshot,
    EmergencyGuard,
    Ownable,
    AccessControlEnumerable,
    ReentrancyGuard
{
    // Role allowed to do admin operations like pausing and emergency withdrawal.
    bytes32 public constant ADMIN = keccak256("ADMIN");

    // Role allowed to update allocatedPoolShares
    bytes32 public constant UPDATE_ALLOCATED_POOL_SHARES =
        keccak256("UPDATE_ALLOCATED_POOL_SHARES");

    // Rewards in token per second
    // Calculation: Max. rewards per 364 days / 31_449_600 (seconds per 364 days)
    uint256 public constant TOKEN_PER_SECOND = 7654263202075702075;

    // Initial pool token balance
    uint256 internal constant INITIAL_POOL_BALANCE = 120_000_000 ether;

    // Seconds per day
    uint256 internal constant SECONDS_PER_DAY = 86400;

    // Seconds per hour
    uint256 internal constant SECONDS_PER_HOUR = 3600;

    // Indicator, if pool is paused (no stake, no unstake, no claim)
    bool internal _poolPaused = false;

    // Indicator, if user emergency unstake is enabled
    bool internal _emergencyUnstakeEnabled = false;

    // Current pool factor, updated on every updatePool() call
    uint256 internal _currentPoolFactor = 100 ether;

    // Timestamp of last block rewards were calculated
    uint256 internal _lastRewardTimestamp;

    // Amount of allocated pool shares
    uint256 internal _allocatedPoolShares;

    // Amount of active allocated pool shares
    uint256 internal _activeAllocatedPoolShares;

    // Timestamp of last block active allocated pool shares were updated
    uint256 internal _lastActiveAllocatedPoolSharesTimestamp;

    // Amount of accured rewards per share, updated on every updatePool() call
    uint256 internal _accRewardsPerShare;

    // Total amount of locked token (excluding rewards)
    uint256 internal _totalTokenLocked;

    // Amount of reserved rewards (claimed, but no unstake yet = no reduction of shares)
    uint256 internal _reservedRewards;

    // Amount of reserved fees (collected, but not withdrawn yet)
    uint256 internal _reservedFees;

    // Token used for staking
    IERC20 private _stakeToken = IERC20(address(0));

    // Token used as staking proof
    IWeStakeitToken private _proofToken = IWeStakeitToken(address(0));

    // Mapping of proof token to staking entry
    mapping(uint256 => PoolEntry) internal _poolEntries;

    /**
     * Checks if tokenId owner equals sender
     *
     * @param tokenId uint256 - Proof token ID
     */
    modifier onlyTokenOwner(uint256 tokenId) {
        require(
            proofToken().ownerOf(tokenId) == _msgSender(),
            "Staking Pool: Caller is not entry owner"
        );
        _;
    }

    /**
     * Checks if pool is paused
     */
    modifier onlyUnpaused() {
        require(
            !poolPaused(),
            "Staking Pool: Pool operations are currently paused"
        );
        _;
    }

    constructor(address stakeTokenAddress, address proofTokenAddress) {
        // Add creator to admin role
        _setupRole(ADMIN, _msgSender());

        // Set role admin for roles
        _setRoleAdmin(ADMIN, ADMIN);
        _setRoleAdmin(UPDATE_ALLOCATED_POOL_SHARES, ADMIN);

        // Setup token
        _stakeToken = IERC20(stakeTokenAddress);
        _proofToken = IWeStakeitToken(proofTokenAddress);
    }

    // Emergency functions
    function emergencyWithdraw(
        uint256 amount
    ) external override onlyRole(ADMIN) {
        super._emergencyWithdraw(amount);
    }

    function emergencyWithdrawToken(
        address token,
        uint256 amount
    ) external override onlyRole(ADMIN) {
        require(
            amount <=
                stakeToken().balanceOf(address(this)) - totalTokenLocked(),
            "Staking Pool: Withdraw amount exceeds available balance"
        );

        super._emergencyWithdrawToken(token, amount);
    }

    function withdrawFee() external onlyRole(ADMIN) {
        stakeToken().transfer(_msgSender(), _reservedFees);

        _reservedFees = 0;
    }

    function setPoolPaused(bool value) external onlyRole(ADMIN) {
        _poolPaused = value;
    }

    function setEmergencyUnstakeEnabled(bool value) external onlyRole(ADMIN) {
        _emergencyUnstakeEnabled = value;
    }

    function setActiveAllocatedPoolShares(
        uint256 value
    ) external onlyRole(UPDATE_ALLOCATED_POOL_SHARES) {
        _activeAllocatedPoolShares = value;
        _lastActiveAllocatedPoolSharesTimestamp = block.timestamp;
    }

    function setReservedRewards(
        uint256 value
    ) external onlyRole(UPDATE_ALLOCATED_POOL_SHARES) {
        _reservedRewards = value;
    }

    function setReservedFees(
        uint256 value
    ) external onlyRole(UPDATE_ALLOCATED_POOL_SHARES) {
        _reservedFees = value;
    }

    function apy(uint256 duration) external view returns (uint256 value) {
        return apy(duration, poolFactor(poolBalance()));
    }

    function apr(uint256 duration) external view returns (uint256 value) {
        return apr(duration, poolFactor(poolBalance()));
    }

    function poolPaused() public view returns (bool value) {
        return _poolPaused;
    }

    function emergencyUnstakeEnabled() public view returns (bool value) {
        return _emergencyUnstakeEnabled;
    }

    function currentPoolFactor() public view returns (uint256 value) {
        return _currentPoolFactor;
    }

    function lastRewardTimestamp() public view returns (uint256 value) {
        return _lastRewardTimestamp;
    }

    function allocatedPoolShares() public view returns (uint256 value) {
        return _allocatedPoolShares;
    }

    function activeAllocatedPoolShares() public view returns (uint256 value) {
        return _activeAllocatedPoolShares;
    }

    function lastActiveAllocatedPoolSharesTimestamp()
        public
        view
        returns (uint256 value)
    {
        return _lastActiveAllocatedPoolSharesTimestamp;
    }

    function accRewardsPerShare() public view returns (uint256 value) {
        return _accRewardsPerShare;
    }

    function totalPoolShares() public pure returns (uint256 value) {
        // Total possible shares per 364 days
        // Calculation: 120_000_000 * 200.60293 (max. APY)
        return 240_723_516 * 1e2;
    }

    function totalTokenLocked() public view returns (uint256 value) {
        return _totalTokenLocked;
    }

    function reservedRewards() public view returns (uint256 value) {
        return _reservedRewards;
    }

    function reservedFees() public view returns (uint256 value) {
        return _reservedFees;
    }

    function minDuration() public pure override returns (uint256 duration) {
        return 7;
    }

    function maxDuration() public pure returns (uint256 value) {
        return 364; // 52 weeks
    }

    function compoundInterval() public pure returns (uint256 value) {
        return 730;
    }

    function stakeToken() public view returns (IERC20 value) {
        return _stakeToken;
    }

    function proofToken() public view returns (IWeStakeitToken value) {
        return _proofToken;
    }

    function poolBalance() public view returns (uint256 value) {
        return poolBalance(currentPoolFactor());
    }

    function poolBalance(
        uint256 poolFactor_
    ) public view returns (uint256 value) {
        // Get current pool balance
        uint256 tokenBalance = stakeToken().balanceOf(address(this));

        uint256 correctedBalance = tokenBalance -
            totalTokenLocked() +
            reservedRewards() -
            reservedFees();

        // Calculate all rewards paid or are claimable until now
        uint256 rewardDebt = activeAllocatedPoolShares() *
            _calculateAccRewardsPerShare(poolFactor_);

        // All fees
        uint256 rewardFee = (rewardDebt * 3) / 100;
        uint256 rewardFeeExternal = rewardFee / 2;

        uint256 availableRewards = rewardDebt - rewardFeeExternal;

        return correctedBalance - availableRewards;
    }

    function poolEntry(
        uint256 tokenId
    ) public view returns (PoolEntry memory entry) {
        return _poolEntries[tokenId];
    }

    function apy(
        uint256 duration,
        uint256 factor
    ) public pure returns (uint256 value) {
        return
            WeSenditMath.apy(
                duration,
                factor,
                maxDuration(),
                compoundInterval()
            );
    }

    function apr(
        uint256 duration,
        uint256 factor
    ) public pure returns (uint256 value) {
        return WeSenditMath.apr(duration, factor, maxDuration());
    }

    function poolFactor() public view returns (uint256 value) {
        return poolFactor(poolBalance());
    }

    function poolFactor(uint256 balance) public pure returns (uint256 value) {
        return WeSenditMath.poolFactor(balance);
    }

    function accRewardsPerShareAt(
        uint256 snapshotId
    ) public view returns (uint256 snapshotId_, uint256 snapshotValue) {
        return _accRewardsPerShareAt(snapshotId, accRewardsPerShare());
    }

    function lastRewardTimestampAt(
        uint256 snapshotId
    ) public view returns (uint256 snapshotId_, uint256 snapshotValue) {
        return _lastRewardTimestampAt(snapshotId, lastRewardTimestamp());
    }

    function maxStakingAmount() public view returns (uint256 value) {
        return _calculateMaxStakingAmount();
    }

    /**
     * Calculates accured rewards per share
     *
     * @return accRewardsPerShare_ uint256 - Accured rewards per share for given parameter
     */
    function _calculateAccRewardsPerShare()
        internal
        view
        returns (uint256 accRewardsPerShare_)
    {
        return
            _calculateAccRewardsPerShare(
                lastRewardTimestamp(),
                currentPoolFactor(),
                accRewardsPerShare()
            );
    }

    /**
     * Calculates accured rewards per share
     *
     * @param poolFactor_ uint256 - Pool factor
     *
     * @return accRewardsPerShare_ uint256 - Accured rewards per share for given parameter
     */
    function _calculateAccRewardsPerShare(
        uint256 poolFactor_
    ) internal view returns (uint256 accRewardsPerShare_) {
        return
            _calculateAccRewardsPerShare(
                lastRewardTimestamp(),
                poolFactor_,
                accRewardsPerShare()
            );
    }

    /**
     * Validates staking duration
     *
     * @param duration uint256 - Staking duration in days
     */
    function _validateStakingDuration(uint256 duration) internal pure {
        // Check for min. / max. duration
        require(
            duration >= minDuration() && duration <= maxDuration(),
            "Staking Pool: Invalid staking duration"
        );

        // Check for full week
        require(
            duration % 7 == 0,
            "Staking Pool: Staking duration needs to be a full week"
        );
    }

    /**
     * Validates staking amount
     *
     * @param amount uint256 - Amount of token to stake
     */
    function _validateStakingAmount(uint256 amount) internal view {
        // Important: check for max. staking amount before transferring token to pool
        require(
            amount <= maxStakingAmount(),
            "Staking Pool: Max. staking amount exceeded"
        );

        require(
            amount + _calculateUserStakingAmount(_msgSender()) <=
                maxStakingAmount(),
            "Staking Pool: User max. staking amount exceeded"
        );

        // CHeck allowance
        uint256 allowance = stakeToken().allowance(_msgSender(), address(this));
        require(allowance >= amount, "Staking Pool: Amount exceeds allowance");
    }

    function _validateClaim(PoolEntry memory entry) internal view {
        // Check if already unstaked
        require(
            entry.isUnstaked == false,
            "Staking Pool: Staking entry was already unstaked"
        );

        // Require entry either to be non auto-compounding or already ended
        require(
            !entry.isAutoCompoundingEnabled ||
                block.timestamp >=
                (entry.startedAt + (entry.duration * SECONDS_PER_DAY)),
            "Staking Pool: Cannot claim before staking end"
        );
    }

    function _validateUnstake(PoolEntry memory entry) internal view {
        // Check if already unstaked
        require(
            !entry.isUnstaked,
            "Staking Pool: Staking entry was already unstaked"
        );

        // Check for staking lock period
        require(
            block.timestamp >=
                entry.startedAt + (entry.duration * SECONDS_PER_DAY),
            "Staking Pool: Staking entry is locked"
        );
    }

    /**
     * Calculates "historic" rewards if we're "out" of staking
     *
     * @param shares uint256 - Staking entry shares
     * @param startTimestamp uint256 - Staking entry start timestamp
     * @param endTimestamp uint256 - Staking entry end timestamp
     *
     * @return rewards uint256 - Available rewards
     */
    function _calculateHistoricRewards(
        uint256 shares,
        uint256 startTimestamp,
        uint256 endTimestamp
    ) internal view returns (uint256 rewards) {
        // Get snapshot values
        (, uint256 lastRewardTimestampSnapshot) = lastRewardTimestampAt(
            endTimestamp
        );
        (, uint256 accRewardsPerShareSnapshot) = accRewardsPerShareAt(
            endTimestamp
        );

        if (lastRewardTimestampSnapshot > endTimestamp) {
            // Pool update was triggered after staking end

            // Calculate duration from staking start to snpashot
            uint256 elapsedSinceStart = lastRewardTimestampSnapshot -
                startTimestamp;

            // Calculate staking entry duration
            uint256 duration = endTimestamp - startTimestamp;

            // Calculate rewards based on ratio
            uint256 partialAccRewardsPerShare = (accRewardsPerShareSnapshot *
                duration) / elapsedSinceStart;

            // Calculate final rewards
            return shares * partialAccRewardsPerShare;
        } else {
            // Pool update was trigger before staking end

            // Calculate duration from lastRewardTimestampSnapshot to endTimestamp
            uint256 duration = endTimestamp - lastRewardTimestampSnapshot;

            // Calculate rewards using snapshot values and remaining duration
            return
                shares *
                _calculateAccRewardsPerShareForDuration(
                    duration,
                    lastRewardTimestampSnapshot,
                    accRewardsPerShareSnapshot
                );
        }
    }

    /**
     * Calculates accured rewards per share
     *
     * @param lastRewardTimestamp_ uint256 - Last reward timestamp
     * @param poolFactor_ uint256 - Pool factor
     * @param initialAccRewardsPerShare_ uint256 - Initial accured rewards per share
     *
     * @return accRewardsPerShare_ uint256 - Accured rewards per share for given parameter
     */
    function _calculateAccRewardsPerShare(
        uint256 lastRewardTimestamp_,
        uint256 poolFactor_,
        uint256 initialAccRewardsPerShare_
    ) private view returns (uint256 accRewardsPerShare_) {
        // Calculate seconds elapsed since last reward update
        uint256 secondsSinceLastRewards = block.timestamp -
            lastRewardTimestamp_;

        // Calculate total rewards since lastRewardTimestamp
        uint256 totalRewards = secondsSinceLastRewards * TOKEN_PER_SECOND;

        // Multiply rewards with pool factor
        uint256 currentRewards = (totalRewards * poolFactor_) / 100 ether;

        // Calculate rewards per share
        return
            initialAccRewardsPerShare_ + (currentRewards / totalPoolShares());
    }

    /**
     * Calculates accured rewards per share for custom duration
     *
     * @param duration uint256 - Duration to calculate rewards for
     * @param lastRewardTimestamp_ uint256 - Last reward timestamp
     * @param initialAccRewardsPerShare_ uint256 - Initial accured rewards per share
     *
     * @return accRewardsPerShare_ uint256 - Accured rewards per share for given parameter
     */
    function _calculateAccRewardsPerShareForDuration(
        uint256 duration,
        uint256 lastRewardTimestamp_,
        uint256 initialAccRewardsPerShare_
    ) private view returns (uint256 accRewardsPerShare_) {
        // Calculate current rewards per shares
        uint256 currentAccRewardsPerShare = _calculateAccRewardsPerShare(
            lastRewardTimestamp(),
            poolFactor(),
            accRewardsPerShare()
        );

        // Calculate difference to "historic" rewards per share
        uint256 futureAccRewardsPerShare = currentAccRewardsPerShare -
            initialAccRewardsPerShare_;

        // Calculate time difference between customLastRewardTimestamp and current block
        uint256 diff = block.timestamp - lastRewardTimestamp_;

        // Calculate rewards per share
        return
            initialAccRewardsPerShare_ +
            ((futureAccRewardsPerShare * duration) / diff);
    }

    /**
     * Calculates max. staking amount
     *
     * @return maxAmount uint256 - Max. amount of token allowed to stake
     */
    function _calculateMaxStakingAmount()
        private
        view
        returns (uint256 maxAmount)
    {
        // Get current pool balance
        uint256 balance = poolBalance();

        // Calculate upper limit (= 80% of initial balance)
        uint256 upperLimit = (INITIAL_POOL_BALANCE * 80) / 100;

        if (balance > upperLimit) {
            // If current pool balance is greater than 80% of initial balance, allow up
            // to 1_000_000 token.
            return 1_000_000 ether;
        } else {
            // If current pool balance is below or equal 80% of initial balance, allow up
            // to (1% * pool balance) token
            return (balance * 1) / 100;
        }
    }

    function _calculateUserStakingAmount(
        address addr
    ) private view returns (uint256 stakingAmount) {
        IERC721Enumerable token = IERC721Enumerable(address(proofToken()));
        uint256 balance = token.balanceOf(addr);
        uint256 amount = 0;

        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = token.tokenOfOwnerByIndex(addr, i);
            amount += _poolEntries[tokenId].amount;
        }

        return amount;
    }
}


// File contracts/interfaces/IWeSenditToken.sol


pragma solidity 0.8.17;


interface IWeSenditToken {
    /**
     * Emitted on transaction unpause
     */
    event Unpaused();

    /**
     * Emitted on dynamic fee manager update
     *
     * @param newAddress address - New dynamic fee manager address
     */
    event DynamicFeeManagerUpdated(address newAddress);

    /**
     * Returns the initial supply
     *
     * @return value uint256 - Initial supply
     */
    function initialSupply() external pure returns (uint256 value);

    /**
     * Returns true if transactions are pause, false if unpaused
     *
     * @param value bool - Indicates if transactions are paused
     */
    function paused() external view returns (bool value);

    /**
     * Sets the transaction pause state to false and therefor, allowing any transactions
     */
    function unpause() external;

    /**
     * Returns the dynamic fee manager
     *
     * @return value IDynamicFeeManager - Dynamic Fee Manager
     */
    function dynamicFeeManager()
        external
        view
        returns (IDynamicFeeManager value);

    /**
     * Sets the dynamic fee manager
     * Can be set to zero address to disable fee reflection.
     *
     * @param value address - New dynamic fee manager address
     */
    function setDynamicFeeManager(address value) external;

    /**
     * Transfers token from <from> to <to> without applying fees
     *
     * @param from address - Sender address
     * @param to address - Receiver address
     * @param amount uin256 - Transaction amount
     */
    function transferFromNoFees(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


// File contracts/BaseWeSenditToken.sol


pragma solidity 0.8.17;



abstract contract BaseWeSenditToken is
    IWeSenditToken,
    EmergencyGuard,
    AccessControlEnumerable,
    Ownable
{
    // Initial token supply
    uint256 public constant INITIAL_SUPPLY = 37_500_000 ether;

    // Total token supply
    uint256 public constant TOTAL_SUPPLY = 1_500_000_000 ether;

    // Role allowed to do admin operations like adding to fee whitelist, withdraw, etc.
    bytes32 public constant ADMIN = keccak256("ADMIN");

    // Role allowed to bypass pause
    bytes32 public constant BYPASS_PAUSE = keccak256("BYPASS_PAUSE");

    // Indicator, if transactions are paused
    bool private _paused = true;

    // Dynamic Fee Manager instance
    IDynamicFeeManager private _dynamicFeeManager;

    constructor() {
        _setupRole(ADMIN, _msgSender());
        _setRoleAdmin(ADMIN, ADMIN);
        _setRoleAdmin(BYPASS_PAUSE, ADMIN);
    }

    /**
     * Getter & Setter
     */
    function initialSupply() external pure override returns (uint256) {
        return INITIAL_SUPPLY;
    }

    function unpause() external override onlyRole(ADMIN) {
        _paused = false;
        emit Unpaused();
    }

    function setDynamicFeeManager(address value)
        external
        override
        onlyRole(ADMIN)
    {
        _dynamicFeeManager = IDynamicFeeManager(value);
        emit DynamicFeeManagerUpdated(value);
    }

    function emergencyWithdraw(uint256 amount)
        external
        override
        onlyRole(ADMIN)
    {
        super._emergencyWithdraw(amount);
    }

    function emergencyWithdrawToken(address token, uint256 amount)
        external
        override
        onlyRole(ADMIN)
    {
        super._emergencyWithdrawToken(token, amount);
    }

    function paused() public view override returns (bool) {
        return _paused;
    }

    function dynamicFeeManager()
        public
        view
        override
        returns (IDynamicFeeManager manager)
    {
        return _dynamicFeeManager;
    }
}


// File contracts/interfaces/IFeeReceiver.sol


pragma solidity 0.8.17;

interface IFeeReceiver {
    /**
     * Callback function on ERC20 receive
     *
     * @param caller address - Calling contract
     * @param token address - Received ERC20 token address
     * @param from address - Sender address
     * @param to address - Receiver address
     * @param amount uint256 - Transaction amount
     */
    function onERC20Received(
        address caller,
        address token,
        address from,
        address to,
        uint256 amount
    ) external;
}


// File contracts/DynamicFeeManager.sol


pragma solidity 0.8.17;



/**
 * @title Dynamic Fee Manager for ERC20 token
 *
 * The dynamic fee manager allows to dynamically add fee rules to ERC20 token transactions.
 * Fees will be applied if the given conditions are met.
 * Additonally, fees can be used to create liquidity on DEX or can be swapped to BUSD.
 */
contract DynamicFeeManager is BaseDynamicFeeManager {
    constructor(address wesenditToken) BaseDynamicFeeManager(wesenditToken) {}

    receive() external payable {}

    function addFee(
        address from,
        address to,
        uint256 percentage,
        address destination,
        bool excludeContracts,
        bool doLiquify,
        bool doSwapForBusd,
        uint256 swapOrLiquifyAmount,
        uint256 expiresAt
    ) external override onlyRole(ADMIN) returns (uint256 index) {
        require(
            feeEntries.length < MAX_FEE_AMOUNT,
            "DynamicFeeManager: Amount of max. fees reached"
        );
        require(
            percentage <= feePercentageLimit(),
            "DynamicFeeManager: Fee percentage exceeds limit"
        );
        require(
            !(doLiquify && doSwapForBusd),
            "DynamicFeeManager: Cannot enable liquify and swap at the same time"
        );

        bytes32 id = _generateIdentifier(
            destination,
            doLiquify,
            doSwapForBusd,
            swapOrLiquifyAmount
        );

        FeeEntry memory feeEntry = FeeEntry(
            id,
            from,
            to,
            percentage,
            destination,
            excludeContracts,
            doLiquify,
            doSwapForBusd,
            swapOrLiquifyAmount,
            expiresAt
        );

        feeEntries.push(feeEntry);

        emit FeeAdded(
            id,
            from,
            to,
            percentage,
            destination,
            excludeContracts,
            doLiquify,
            doSwapForBusd,
            swapOrLiquifyAmount,
            expiresAt
        );

        // Return entry index
        return feeEntries.length - 1;
    }

    function removeFee(uint256 index) external override onlyRole(ADMIN) {
        require(
            index < feeEntries.length,
            "DynamicFeeManager: array out of bounds"
        );

        // Reset current amount for liquify or swap
        bytes32 id = feeEntries[index].id;
        feeEntryAmounts[id] = 0;

        // Remove fee entry from array
        feeEntries[index] = feeEntries[feeEntries.length - 1];
        feeEntries.pop();

        emit FeeRemoved(id, index);
    }

    function reflectFees(
        address from,
        address to,
        uint256 amount
    ) external override returns (uint256 tTotal, uint256 tFees) {
        require(
            hasRole(CALL_REFLECT_FEES, _msgSender()),
            "DynamicFeeManager: Caller is missing required role"
        );

        bool bypassFees = !feesEnabled() ||
            from == owner() ||
            hasRole(ADMIN, from) ||
            hasRole(FEE_WHITELIST, from) ||
            hasRole(RECEIVER_FEE_WHITELIST, to);

        if (bypassFees) {
            return (amount, 0);
        }

        bool bypassSwapAndLiquify = hasRole(ADMIN, to) ||
            hasRole(ADMIN, from) ||
            hasRole(BYPASS_SWAP_AND_LIQUIFY, to) ||
            hasRole(BYPASS_SWAP_AND_LIQUIFY, from);

        // Loop over all fee entries and calculate plus reflect fee
        uint256 feeAmount = feeEntries.length;

        // Keep track of fees applied, to prevent applying more fees than transaction limit
        uint256 totalFeePercentage = 0;
        uint256 txFeeLimit = transactionFeeLimit();

        for (uint256 i = 0; i < feeAmount; i++) {
            FeeEntry memory fee = feeEntries[i];

            if (
                _isFeeEntryValid(fee) &&
                (_isFeeEntryMatching(fee, from, to, amount))
            ) {
                uint256 tFee = _calculateFee(amount, fee.percentage);
                uint256 tempPercentage = totalFeePercentage + fee.percentage;

                if (tFee > 0 && tempPercentage <= txFeeLimit) {
                    tFees = tFees + tFee;
                    totalFeePercentage = tempPercentage;
                    _reflectFee(from, to, tFee, fee, bypassSwapAndLiquify);
                }
            }
        }

        tTotal = amount - tFees;
        require(tTotal > 0, "DynamicFeeManager: invalid total amount");

        return (tTotal, tFees);
    }

    function _isFeeMatchingStakingUnclaim(
        FeeEntry memory fee,
        address to,
        uint256 amount
    ) private view returns (bool matching) {
        // Get users staking nfts balance
        uint256 balance = weStakeitToken().balanceOf(to);

        for (uint256 i = 0; i < balance; i++) {
            // Get staking token id
            uint256 tokenId = weStakeitToken().tokenOfOwnerByIndex(to, i);

            // Get staking entry from pool
            PoolEntry memory entry = stakingPool().poolEntry(tokenId);

            /**
             * Check if entry is:
             * - unstaked (happens right before transfer)
             * - claimed with this block (happens likely directly before transfer)
             * - fee amount is matching 3% of initial stake amount
             */
            if (
                entry.isUnstaked &&
                entry.lastClaimedAt == block.timestamp &&
                (amount * fee.percentage) / FEE_DIVIDER ==
                (entry.amount * fee.percentage) / FEE_DIVIDER
            ) {
                return true;
            }
        }

        return false;
    }

    /**
     * Reflects a single fee
     *
     * @param from address - Sender address
     * @param to address - Receiver address
     * @param tFee uint256 - Fee amount
     * @param fee FeeEntry - Fee Entry
     * @param bypassSwapAndLiquify bool - Indicator, if swap and liquify should be bypassed
     */
    function _reflectFee(
        address from,
        address to,
        uint256 tFee,
        FeeEntry memory fee,
        bool bypassSwapAndLiquify
    ) private {
        if (fee.doLiquify || fee.doSwapForBusd) {
            // add to liquify / swap amount or transfer to fee destination
            require(
                IWeSenditToken(address(token())).transferFromNoFees(
                    from,
                    address(this),
                    tFee
                ),
                "DynamicFeeManager: Fee transfer to manager failed"
            );
            feeEntryAmounts[fee.id] = feeEntryAmounts[fee.id] + tFee;
        } else {
            require(
                IWeSenditToken(address(token())).transferFromNoFees(
                    from,
                    fee.destination,
                    tFee
                ),
                "DynamicFeeManager: Fee transfer to destination failed"
            );
        }

        // Check if swap / liquify amount was reached
        if (
            !bypassSwapAndLiquify &&
            feeEntryAmounts[fee.id] >= MIN_SWAP_OR_LIQUIFY_AMOUNT &&
            feeEntryAmounts[fee.id] >= fee.swapOrLiquifyAmount
        ) {
            // Disable fees, to prevent PancakeSwap pair recursive calls
            feesEnabled_ = false;

            // Check if swap / liquify amount was reached
            uint256 tokenSwapped = 0;

            if (fee.doSwapForBusd && from != pancakePairBusdAddress()) {
                // Calculate amount of token we're going to swap
                tokenSwapped = _getSwapOrLiquifyAmount(
                    fee.id,
                    fee.swapOrLiquifyAmount,
                    percentageVolumeSwap(),
                    pancakePairBusdAddress()
                );

                // Swap token for BUSD
                _swapTokensForBusd(tokenSwapped, fee.destination);
            }

            if (fee.doLiquify && from != pancakePairBnbAddress()) {
                // Swap (BNB) and liquify token
                tokenSwapped = _swapAndLiquify(
                    _getSwapOrLiquifyAmount(
                        fee.id,
                        fee.swapOrLiquifyAmount,
                        percentageVolumeLiquify(),
                        pancakePairBnbAddress()
                    ),
                    fee.destination
                );
            }

            // Subtract amount of swapped token from fee entry amount
            feeEntryAmounts[fee.id] = feeEntryAmounts[fee.id] - tokenSwapped;

            // Enable fees again
            feesEnabled_ = true;
        }

        emit FeeReflected(
            fee.id,
            address(token()),
            from,
            to,
            tFee,
            fee.destination,
            fee.excludeContracts,
            fee.doLiquify,
            fee.doSwapForBusd,
            fee.swapOrLiquifyAmount,
            fee.expiresAt
        );
    }

    /**
     * Checks if the fee entry is still valid
     *
     * @param fee FeeEntry - Fee Entry
     *
     * @return isValid bool - Indicates, if the fee entry is still valid
     */
    function _isFeeEntryValid(
        FeeEntry memory fee
    ) private view returns (bool isValid) {
        return fee.expiresAt == 0 || block.timestamp <= fee.expiresAt;
    }

    /**
     * Checks if the fee entry matches
     *
     * @param fee FeeEntry - Fee Entry
     * @param from address - Sender address
     * @param to address - Receiver address
     *
     * @return matching bool - Indicates, if the fee entry and from / to are matching
     */
    function _isFeeEntryMatching(
        FeeEntry memory fee,
        address from,
        address to,
        uint256 amount
    ) private view returns (bool matching) {
        // Staking pool customization
        if (fee.from == address(stakingPool())) {
            return _isFeeMatchingStakingUnclaim(fee, to, amount);
        }

        return
            ((fee.from == WHITELIST_ADDRESS &&
                fee.to == WHITELIST_ADDRESS &&
                !hasRole(EXCLUDE_WILDCARD_FEE, from) &&
                !hasRole(EXCLUDE_WILDCARD_FEE, to)) &&
                !(fee.excludeContracts && _isContract(from))) ||
            (fee.from == from &&
                fee.to == WHITELIST_ADDRESS &&
                !hasRole(EXCLUDE_WILDCARD_FEE, to)) ||
            (fee.to == to &&
                fee.from == WHITELIST_ADDRESS &&
                !hasRole(EXCLUDE_WILDCARD_FEE, from)) ||
            (fee.to == to && fee.from == from);
    }

    /**
     * Calculates a single fee
     *
     * @param amount uint256 - Transaction amount
     * @param percentage uint256 - Fee percentage
     *
     * @return tFee - Total Fee Amount
     */
    function _calculateFee(
        uint256 amount,
        uint256 percentage
    ) private pure returns (uint256 tFee) {
        return (amount * percentage) / FEE_DIVIDER;
    }

    /**
     * Generates an unique identifier for a fee entry
     *
     * @param destination address - Destination address for the fee
     * @param doLiquify bool - Indicates, if the fee amount should be used to add liquidy on DEX
     * @param doSwapForBusd bool - Indicates, if the fee amount should be swapped to BUSD
     * @param swapOrLiquifyAmount uint256 - Amount for liquidify or swap
     *
     * @return id bytes32 - Unique id
     */
    function _generateIdentifier(
        address destination,
        bool doLiquify,
        bool doSwapForBusd,
        uint256 swapOrLiquifyAmount
    ) private pure returns (bytes32 id) {
        return
            keccak256(
                abi.encodePacked(
                    destination,
                    doLiquify,
                    doSwapForBusd,
                    swapOrLiquifyAmount
                )
            );
    }
}


// File @openzeppelin/contracts/utils/Address.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}


// File @openzeppelin/contracts/token/ERC20/extensions/draft-IERC20Permit.sol@v4.8.0


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


// File @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// File contracts/interfaces/IMultiVestingWallet.sol


// Based on VestingWallet from OpenZeppelin Contracts (last updated v4.8.0) (finance/VestingWallet.sol)
pragma solidity 0.8.17;





interface IMultiVestingWallet {
    event EtherReleased(address indexed beneficiary, uint256 amount);
    event ERC20Released(
        address indexed beneficiary,
        address indexed token,
        uint256 amount
    );

    /**
     * @dev The contract should be able to receive Eth.
     */
    receive() external payable;

    /**
     * @dev Add multiple beneficiaries for ETH.
     */
    function addBeneficiaries(
        address[] calldata beneficiaries,
        uint256[] calldata amounts
    ) external;

    /**
     * @dev Add multiple beneficiaries for token.
     */
    function addBeneficiaries(
        address[] calldata beneficiaries,
        address token,
        uint256[] calldata amounts
    ) external;

    /**
     * @dev Add single beneficiaries for ETH.
     */
    function addBeneficiary(address beneficiary, uint256 amount) external;

    /**
     * @dev Add single beneficiaries for token.
     */
    function addBeneficiary(
        address beneficiary,
        address token,
        uint256 amount
    ) external;

    /**
     * @dev Getter for the start timestamp.
     */
    function start() external view returns (uint256);

    /**
     * @dev Getter for the vesting duration.
     */
    function duration() external view returns (uint256);

    /**
     * @dev Amount of initial eth
     */
    function initial(address beneficiary) external view returns (uint256);

    /**
     * @dev Amount of initial token
     */
    function initial(
        address beneficiary,
        address token
    ) external view returns (uint256);

    /**
     * @dev Amount of eth already released
     */
    function released(address beneficiary) external view returns (uint256);

    /**
     * @dev Amount of token already released
     */
    function released(
        address beneficiary,
        address token
    ) external view returns (uint256);

    /**
     * @dev Getter for the amount of releasable eth.
     */
    function releasable(address beneficiary) external view returns (uint256);

    /**
     * @dev Getter for the amount of releasable `token` tokens. `token` should be the address of an
     * IERC20 contract.
     */
    function releasable(
        address beneficiary,
        address token
    ) external view returns (uint256);

    /**
     * @dev Release the native token (ether) that have already vested.
     *
     * Emits a {EtherReleased} event.
     */
    function release(address beneficiary) external;

    /**
     * @dev Release the tokens that have already vested.
     *
     * Emits a {ERC20Released} event.
     */
    function release(address beneficiary, address token) external;

    /**
     * @dev Calculates the amount of ether that has already vested. Default implementation is a linear vesting curve.
     */
    function vestedAmount(
        address beneficiary,
        uint64 timestamp
    ) external view returns (uint256);

    /**
     * @dev Calculates the amount of tokens that has already vested. Default implementation is a linear vesting curve.
     */
    function vestedAmount(
        address beneficiary,
        address token,
        uint64 timestamp
    ) external view returns (uint256);
}


// File contracts/MultiVestingWallet.sol


// Based on VestingWallet from OpenZeppelin Contracts (last updated v4.8.0) (finance/VestingWallet.sol)
pragma solidity 0.8.17;






contract MultiVestingWallet is
    IMultiVestingWallet,
    Context,
    Ownable,
    EmergencyGuard
{
    uint64 private immutable _start;
    uint64 private immutable _duration;

    // Total initial ETH amount
    uint256 private _totalInitialETH;

    // Mapping from token to total initial token amount
    mapping(address => uint256) private _totalInitialToken;

    // Total released token amount
    uint256 private _totalReleasedETH;

    // Mapping from ttoken to total released token amount
    mapping(address => uint256) private _totalReleasedToken;

    // Mapping from beneficiary address to initial ETH
    mapping(address => uint256) private _userInitialETH;

    // Mapping from beneficiary address to release ETH
    mapping(address => uint256) private _userReleaseETH;

    // Mapping from beneficiary address to token address to initial token
    mapping(address => mapping(address => uint256)) private _userInitialToken;

    // Mapping from beneficiary address to token address to release token
    mapping(address => mapping(address => uint256)) private _userReleasedToken;

    /**
     * @dev Set the start timestamp and vesting duration of the vesting wallet.
     */
    constructor(uint64 startTimestamp, uint64 durationSeconds) payable {
        _start = startTimestamp;
        _duration = durationSeconds;
    }

    receive() external payable virtual {}

    function addBeneficiaries(
        address[] calldata beneficiaries,
        uint256[] calldata amounts
    ) external virtual onlyOwner {
        require(
            beneficiaries.length == amounts.length,
            "MultiVestingWallet: mismatching beneficiaries / amounts pair"
        );

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            addBeneficiary(beneficiaries[i], amounts[i]);
        }
    }

    function addBeneficiaries(
        address[] calldata beneficiaries,
        address token,
        uint256[] calldata amounts
    ) external virtual onlyOwner {
        require(
            beneficiaries.length == amounts.length,
            "MultiVestingWallet: mismatching beneficiaries / amounts pair"
        );

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            addBeneficiary(beneficiaries[i], token, amounts[i]);
        }
    }

    function addBeneficiary(
        address beneficiary,
        uint256 amount
    ) public virtual onlyOwner {
        require(
            address(this).balance + _totalReleasedETH - _totalInitialETH >=
                amount,
            "MultiVestingWallet: ETH amount exceeds balance"
        );

        _userInitialETH[beneficiary] = amount;
        _totalInitialETH += amount;
    }

    function addBeneficiary(
        address beneficiary,
        address token,
        uint256 amount
    ) public virtual onlyOwner {
        require(
            IERC20(token).balanceOf(address(this)) +
                _totalReleasedToken[token] -
                _totalInitialToken[token] >=
                amount,
            "MultiVestingWallet: Token amount exceeds balance"
        );

        _userInitialToken[beneficiary][token] = amount;
        _totalInitialToken[token] += amount;
    }

    function start() public view virtual returns (uint256) {
        return _start;
    }

    function duration() public view virtual returns (uint256) {
        return _duration;
    }

    function initial(
        address beneficiary
    ) public view virtual returns (uint256) {
        return _userInitialETH[beneficiary];
    }

    function initial(
        address beneficiary,
        address token
    ) public view virtual returns (uint256) {
        return _userInitialToken[beneficiary][token];
    }

    function released(
        address beneficiary
    ) public view virtual returns (uint256) {
        return _userReleaseETH[beneficiary];
    }

    function released(
        address beneficiary,
        address token
    ) public view virtual returns (uint256) {
        return _userReleasedToken[beneficiary][token];
    }

    function releasable(
        address beneficiary
    ) public view virtual returns (uint256) {
        return
            vestedAmount(beneficiary, uint64(block.timestamp)) -
            released(beneficiary);
    }

    function releasable(
        address beneficiary,
        address token
    ) public view virtual returns (uint256) {
        return
            vestedAmount(beneficiary, token, uint64(block.timestamp)) -
            released(beneficiary, token);
    }

    function release(address beneficiary) public virtual {
        uint256 amount = releasable(beneficiary);
        _userReleaseETH[beneficiary] += amount;
        _totalReleasedETH += amount;
        emit EtherReleased(beneficiary, amount);
        Address.sendValue(payable(beneficiary), amount);
    }

    function release(address beneficiary, address token) public virtual {
        uint256 amount = releasable(beneficiary, token);
        _userReleasedToken[beneficiary][token] += amount;
        _totalReleasedToken[token] += amount;
        emit ERC20Released(beneficiary, token, amount);
        SafeERC20.safeTransfer(IERC20(token), beneficiary, amount);
    }

    function vestedAmount(
        address beneficiary,
        uint64 timestamp
    ) public view virtual returns (uint256) {
        return _vestingSchedule(_userInitialETH[beneficiary], timestamp);
    }

    function vestedAmount(
        address beneficiary,
        address token,
        uint64 timestamp
    ) public view virtual returns (uint256) {
        return
            _vestingSchedule(_userInitialToken[beneficiary][token], timestamp);
    }

    /**
     * @dev Virtual implementation of the vesting formula. This returns the amount vested, as a function of time, for
     * an asset given its total historical allocation.
     */
    function _vestingSchedule(
        uint256 totalAllocation,
        uint64 timestamp
    ) internal view virtual returns (uint256) {
        if (timestamp < start()) {
            return 0;
        } else if (timestamp > start() + duration()) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start())) / duration();
        }
    }

    function emergencyWithdraw(uint256 amount) external override onlyOwner {
        super._emergencyWithdraw(amount);
    }

    function emergencyWithdrawToken(
        address token,
        uint256 amount
    ) external override onlyOwner {
        super._emergencyWithdrawToken(token, amount);
    }
}


// File contracts/interfaces/IPaymentProcessor.sol


pragma solidity 0.8.17;

struct Payment {
    // Unique identifier for the payment
    // Generated out of (user, timestamp, amount)
    bytes32 id;
    // User address
    address user;
    // Payment amount
    uint256 amount;
    // Time when payment was executed
    uint256 executedAt;
    // Indicated if the payment was refunded
    bool isRefunded;
    // Time when payment was refunded (if not refunded, defaults to zero)
    uint256 refundedAt;
}

interface IPaymentProcessor {
    /**
     * Emitted when a payment was done by an user
     *
     * @param paymentId bytes32 - Unique id of the payment
     * @param user address - User address
     * @param amount uint256 - Added token amount
     */
    event PaymentDone(
        bytes32 indexed paymentId,
        address indexed user,
        uint256 amount
    );

    /**
     * Emitted when a payment was refunded to an user
     *
     * @param paymentId bytes32 - Unique id of the payment
     * @param user address - User address
     * @param amount uint256 - Added token amount
     */
    event PaymentRefunded(
        bytes32 indexed paymentId,
        address indexed user,
        uint256 amount
    );

    /**
     * Returns details about the last payment of an user
     *
     * @param user address - User address
     *
     * @return payment Payment - Last payment object
     */
    function lastPayment(
        address user
    ) external view returns (Payment memory payment);

    /**
     * Returns all payments of a given user
     *
     * @param user address - User address
     *
     * @return payments Payment[] - List of payment object
     */
    function paymentsByUser(
        address user
    ) external view returns (Payment[] memory payments);

    /**
     * Returns a payment of a given user at given index
     *
     * @param user address - User address
     * @param index uint256 - Index of payment
     *
     * @return payment Payment - Payment object
     */
    function paymentAtIndex(
        address user,
        uint256 index
    ) external view returns (Payment memory payment);

    /**
     * Returns a payment by a given id
     *
     * @param paymentId Unique payment id
     *
     * @return payment Payment - Payment object
     */
    function paymentById(
        bytes32 paymentId
    ) external view returns (Payment memory payment);

    /**
     * Returns the count of payment done by an user
     *
     * @param user address - User address
     *
     * @return count uint256 - Count of payments
     */
    function paymentCount(address user) external view returns (uint256 count);

    /**
     * Executes a payment from for the given user
     * (can only be called with EXECUTE_PAYMENT role)
     *
     * @param user address - User address
     * @param amount uint256 - Payment token amount
     */
    function executePayment(address user, uint256 amount) external;

    /**
     * Refunds a payment of the given user
     * (can only be called with REFUND_PAYMENT role)
     *
     * @param paymentId bytes32 - Unique payment id
     */
    function refundPayment(bytes32 paymentId) external;
}


// File contracts/PaymentProcessor.sol


pragma solidity 0.8.17;





contract PaymentProcessor is
    IPaymentProcessor,
    Ownable,
    AccessControlEnumerable,
    ReentrancyGuard,
    EmergencyGuard
{
    // Role allowed to do admin operations like withdrawal.
    bytes32 public constant ADMIN = keccak256("ADMIN");

    // Role allowed to do processor operations like executing and refunding payments.
    bytes32 public constant PROCESSOR = keccak256("PROCESSOR");

    // Token instance used for payments
    IERC20 internal immutable _token;

    // Payments by user
    mapping(address => bytes32[]) internal _paymentsByUser;

    // Payments by id
    mapping(bytes32 => Payment) internal _paymentsById;

    constructor(address tokenAddress) {
        // Add creator to admin role
        _setupRole(ADMIN, _msgSender());

        // Set role admin for roles
        _setRoleAdmin(ADMIN, ADMIN);
        _setRoleAdmin(PROCESSOR, ADMIN);

        // Initialize token instance
        _token = IERC20(tokenAddress);
    }

    function lastPayment(
        address user
    ) external view override returns (Payment memory payment) {
        bytes32[] memory paymentIds = _paymentsByUser[user];
        bytes32 lastPaymentId = paymentIds[paymentIds.length - 1];

        return _paymentsById[lastPaymentId];
    }

    function paymentsByUser(
        address user
    ) external view override returns (Payment[] memory payments) {
        bytes32[] memory paymentIds = _paymentsByUser[user];

        Payment[] memory paymentsArr = new Payment[](paymentIds.length);
        for (uint256 i = 0; i < paymentIds.length; i++) {
            paymentsArr[i] = _paymentsById[paymentIds[i]];
        }

        return paymentsArr;
    }

    function paymentAtIndex(
        address user,
        uint256 index
    ) external view override returns (Payment memory payment) {
        bytes32 paymentId = _paymentsByUser[user][index];

        return _paymentsById[paymentId];
    }

    function paymentById(
        bytes32 paymentId
    ) external view override returns (Payment memory payment) {
        return _paymentsById[paymentId];
    }

    function paymentCount(
        address user
    ) external view override returns (uint256 count) {
        return _paymentsByUser[user].length;
    }

    function executePayment(
        address user,
        uint256 amount
    ) external override onlyRole(PROCESSOR) nonReentrant {
        // Transfer token from user
        require(
            _token.transferFrom(user, address(this), amount),
            "PaymentProcessor: Token transfer failed"
        );

        // Generate unique payment id
        bytes32 paymentId = _generateIdentifier(user, amount, block.timestamp);

        // Create payment object
        Payment memory payment = Payment(
            paymentId,
            user,
            amount,
            block.timestamp,
            false,
            0
        );

        // Add payments to mappings
        _paymentsByUser[user].push(paymentId);
        _paymentsById[paymentId] = payment;

        // Emit event
        emit PaymentDone(paymentId, user, amount);
    }

    function refundPayment(
        bytes32 paymentId
    ) external override onlyRole(PROCESSOR) nonReentrant {
        // Get payment
        Payment memory payment = _paymentsById[paymentId];

        // Ensure it's not refunded yet
        require(
            !payment.isRefunded,
            "PaymentProcessor: Payment was already refunded"
        );

        // Refund token
        require(
            _token.transfer(payment.user, payment.amount),
            "PaymentProcessor: Token transfer failed"
        );

        // Update mappings
        _paymentsById[paymentId].isRefunded = true;
        _paymentsById[paymentId].refundedAt = block.timestamp;

        // Emit event
        emit PaymentRefunded(paymentId, payment.user, payment.amount);
    }

    function emergencyWithdraw(
        uint256 amount
    ) external override onlyRole(ADMIN) {
        super._emergencyWithdraw(amount);
    }

    function emergencyWithdrawToken(
        address tokenToWithdraw,
        uint256 amount
    ) external override onlyRole(ADMIN) {
        super._emergencyWithdrawToken(tokenToWithdraw, amount);
    }

    /**
     * Generates an unique identifier for a payment
     *
     * @param user address - User address
     * @param amount uint256 - Payment amount
     * @param executedAt uint256 - Time when payment was executed
     *
     * @return id bytes32 - Unique id
     */
    function _generateIdentifier(
        address user,
        uint256 amount,
        uint256 executedAt
    ) private pure returns (bytes32 id) {
        return keccak256(abi.encodePacked(user, amount, executedAt));
    }
}


// File contracts/interfaces/IRewardDistributor.sol


pragma solidity 0.8.17;

interface IRewardDistributor {
    /**
     * Emitted when claimable token are added for an user
     *
     * @param user address - User address
     * @param amount uint256 - Added token amount
     */
    event TokenAdded(address indexed user, uint256 amount);

    /**
     * Emitted when token are claimed by an user
     *
     * @param user address - User address
     * @param amount uint256 - Claimed token amount
     */
    event TokenClaimed(address indexed user, uint256 amount);

    /**
     * Emitted when token of an user are slayed
     *
     * @param user address - User address
     * @param amount uint256 - Slayed token amount
     */
    event TokenSlayed(address indexed user, uint256 amount);

    /**
     * Returns the amount of claimable token for an user
     *
     * @param user address - User address
     */
    function claimableToken(
        address user
    ) external view returns (uint256 amount);

    /**
     * Returns the amount of claimed token for an user
     *
     * @param user address - User address
     */
    function claimedToken(address user) external view returns (uint256 amount);

    /**
     * Returns the amount of slayed token for an user
     *
     * @param user address - User address
     */
    function slayedToken(address user) external view returns (uint256 amount);

    /**
     * Returns the timestamp of last user claim
     *
     * @param user address - User address
     */
    function lastClaimedAt(
        address user
    ) external view returns (uint256 timestamp);

    /**
     * Returns the timestamp of last user token slay
     *
     * @param user address - User address
     */
    function lastSlayedAt(
        address user
    ) external view returns (uint256 timestamp);

    /**
     * Returns the amount of fees collected
     */
    function totalFees() external view returns (uint256 amount);

    /**
     * Adds claimable token for an user
     *
     * @param user address - User address
     * @param amount uint256 - Token amount to add
     */
    function addTokenForUser(address user, uint256 amount) external;

    /**
     * Adds claimable token for multiple users
     *
     * @param users address[] - Users addresses
     * @param amounts uint256[] - Token amounts to add
     */
    function addTokenForUsers(
        address[] memory users,
        uint256[] memory amounts
    ) external;

    /**
     * Claims token for a user (msg.sender)
     */
    function claimToken() external;

    /**
     * Slays / return token for the specified user
     *
     * @param user address - User address
     */
    function slayTokenForUser(address user) external;

    /**
     * Slays / return token for multiple users
     *
     * @param users address - Users addresses
     */
    function slayTokenForUsers(address[] memory users) external;
}


// File contracts/RewardDistributor.sol


pragma solidity 0.8.17;





contract RewardDistributor is
    IRewardDistributor,
    Ownable,
    AccessControlEnumerable,
    ReentrancyGuard,
    EmergencyGuard
{
    // Role allowed to do admin operations.
    bytes32 public constant ADMIN = keccak256("ADMIN");

    // Role allowed to do processor operations like adding token to users.
    bytes32 public constant PROCESSOR = keccak256("PROCESSOR");

    // Role allowed to do slayer operations like slaying token.
    bytes32 public constant SLAYER = keccak256("SLAYER");

    // Duration after user token are allowed to be slayed.
    uint256 public constant SLAY_INACTIVE_DURATION = 200 * 24 * 60 * 60; // 200 days in seconds

    // Fee address
    address public constant FEE_ADDRESS =
        0xD70E8C40003AE32b8E82AB5F25607c010532f148;

    // Token instance used for payments
    IERC20 internal immutable _token;

    // Claimable token amount by user
    mapping(address => uint256) internal _claimableByUser;

    // Claimed token amount by user
    mapping(address => uint256) internal _claimedByUser;

    // Slayed token amount by user
    mapping(address => uint256) internal _slayedByUser;

    // Last claim timestamp by user
    mapping(address => uint256) internal _lastClaimedAtByUser;

    // Last slay timestamp by user
    mapping(address => uint256) internal _lastSlayedAtByUser;

    // Total amount of fees collected
    uint256 internal _totalFees;

    constructor(address tokenAddress) {
        // Add creator to admin role
        _setupRole(ADMIN, _msgSender());

        // Set role admin for roles
        _setRoleAdmin(ADMIN, ADMIN);
        _setRoleAdmin(PROCESSOR, ADMIN);
        _setRoleAdmin(SLAYER, ADMIN);

        // Initialize token instance
        _token = IERC20(tokenAddress);
    }

    function claimableToken(
        address user
    ) external view override returns (uint256 amount) {
        return _claimableByUser[user];
    }

    function claimedToken(
        address user
    ) external view override returns (uint256 amount) {
        return _claimedByUser[user];
    }

    function slayedToken(
        address user
    ) external view override returns (uint256 amount) {
        return _slayedByUser[user];
    }

    function lastClaimedAt(
        address user
    ) external view override returns (uint256 timestamp) {
        return _lastClaimedAtByUser[user];
    }

    function lastSlayedAt(
        address user
    ) external view override returns (uint256 timestamp) {
        return _lastSlayedAtByUser[user];
    }

    function totalFees() external view override returns (uint256 amount) {
        return _totalFees;
    }

    function addTokenForUsers(
        address[] memory users,
        uint256[] memory amounts
    ) external override onlyRole(PROCESSOR) {
        // Check if input data is valid
        require(
            users.length == amounts.length,
            "RewardDistributor: Count of users and amounts is mismatching"
        );

        for (uint256 i = 0; i < users.length; i++) {
            addTokenForUser(users[i], amounts[i]);
        }
    }

    function claimToken() external override nonReentrant {
        // Get claimable amount
        address user = _msgSender();
        uint256 amount = _claimableByUser[user];

        // Check amount
        require(
            amount > 0,
            "RewardDistributor: Cannot claim token if claimable amount is zero"
        );

        // Transfer 3% fee
        uint256 fees = (amount * 3) / 100;
        require(
            _token.transfer(FEE_ADDRESS, fees),
            "RewardDistributor: Token transfer failed"
        );

        _totalFees += fees;

        // Send token
        require(
            _token.transfer(user, amount - fees),
            "RewardDistributor: Token transfer failed"
        );

        // Update state
        _claimableByUser[user] -= amount;
        _claimedByUser[user] += amount;

        // Set last claim timestamp
        _lastClaimedAtByUser[user] = block.timestamp;

        // Emit event
        emit TokenClaimed(user, amount);
    }

    function slayTokenForUsers(
        address[] memory users
    ) external override onlyRole(SLAYER) {
        for (uint256 i = 0; i < users.length; i++) {
            slayTokenForUser(users[i]);
        }
    }

    function emergencyWithdraw(
        uint256 amount
    ) external override onlyRole(ADMIN) {
        super._emergencyWithdraw(amount);
    }

    function emergencyWithdrawToken(
        address tokenToWithdraw,
        uint256 amount
    ) external override onlyRole(ADMIN) {
        super._emergencyWithdrawToken(tokenToWithdraw, amount);
    }

    function addTokenForUser(
        address user,
        uint256 amount
    ) public override onlyRole(PROCESSOR) {
        _claimableByUser[user] += amount;

        // Emit event
        emit TokenAdded(user, amount);
    }

    function slayTokenForUser(address user) public override onlyRole(SLAYER) {
        // Get last claim timestamp
        uint256 lastClaimTimestamp = _lastClaimedAtByUser[user];
        require(
            block.timestamp > (lastClaimTimestamp + SLAY_INACTIVE_DURATION),
            "RewardDistributor: Cannot slay token of an active user"
        );

        // Get claimable token amount
        uint256 amount = _claimableByUser[user];
        require(
            amount > 0,
            "RewardDistributor: Cannot slay token if claimable amount is zero"
        );

        // Send token
        require(
            _token.transfer(FEE_ADDRESS, amount),
            "RewardDistributor: Token transfer failed"
        );

        // Update state
        _claimableByUser[user] -= amount;
        _slayedByUser[user] += amount;

        // Set last slay timestamp
        _lastSlayedAtByUser[user] = block.timestamp;

        // Emit event
        emit TokenSlayed(user, amount);
    }
}


// File contracts/StakingPool.sol


pragma solidity 0.8.17;

/**
 * @title WeSendit Staking Pool
 */
contract StakingPool is BaseStakingPool {
    constructor(
        address stakeTokenAddress,
        address proofTokenAddress
    ) BaseStakingPool(stakeTokenAddress, proofTokenAddress) {}

    function stake(
        uint256 amount,
        uint256 duration,
        bool enableAutoCompounding
    ) external onlyUnpaused nonReentrant returns (uint256 value) {
        // Validate inputs
        _validateStakingDuration(duration);
        _validateStakingAmount(amount);

        // Trigger pool update to make sure _accRewardsPerShare is up-to-date
        updatePool();

        // Transfer token to pool
        require(
            stakeToken().transferFrom(_msgSender(), address(this), amount),
            "Staking Pool: Failed to transfer token"
        );

        // Calculate shares multiplier based on max. APY / APR
        uint256 multiplier;
        if (enableAutoCompounding) {
            multiplier = apy(duration, 100 ether);
        } else {
            multiplier = apr(duration, 100 ether);
        }

        // Calculate pool shares for staking entry
        uint256 totalShares = (amount * multiplier) / 1e23;

        // Update global pool state
        _allocatedPoolShares += totalShares;
        _activeAllocatedPoolShares += totalShares;
        _totalTokenLocked += amount;

        // Calculate initial reward debt (similar to PancakeSwap staking / farms)
        uint256 rewardDebt = totalShares * accRewardsPerShare();

        // Create pool entry
        PoolEntry memory entry = PoolEntry(
            amount,
            duration,
            totalShares,
            rewardDebt,
            0,
            0,
            block.timestamp,
            block.timestamp,
            false,
            enableAutoCompounding
        );

        // Mint staking reward NFT
        uint256 tokenId = proofToken().mint(_msgSender());

        // Set pool enty
        _poolEntries[tokenId] = entry;

        // Emit event
        emit Staked(
            tokenId,
            amount,
            duration,
            totalShares,
            enableAutoCompounding
        );

        return tokenId;
    }

    function unstake(
        uint256 tokenId
    ) external onlyUnpaused onlyTokenOwner(tokenId) nonReentrant {
        // Get pool entry
        PoolEntry memory entry = _poolEntries[tokenId];

        // Validate unstake action
        _validateUnstake(entry);

        // Unstake token
        // Check if user got pending rewards
        (uint256 rewards, uint256 totalFee) = _pendingRewards(entry);

        // Claim rewards or unstake if possible
        _claimOrUnstake(tokenId, entry, rewards, totalFee);

        // Trigger pool update
        updatePool();

        // Emit event
        emit Unstaked(
            tokenId,
            entry.amount,
            entry.duration,
            entry.shares,
            entry.isAutoCompoundingEnabled
        );
    }

    function emergencyUnstake(
        uint256 tokenId
    ) external onlyTokenOwner(tokenId) {
        require(
            emergencyUnstakeEnabled(),
            "Staking Pool: Emergency unstake disabled"
        );

        PoolEntry memory entry = _poolEntries[tokenId];
        _unstake(tokenId, entry);
    }

    function claimRewards(
        uint256 tokenId
    ) external onlyUnpaused onlyTokenOwner(tokenId) nonReentrant {
        // Get pool entry
        PoolEntry memory entry = _poolEntries[tokenId];

        // Check if user got pending rewards
        (uint256 rewards, uint256 totalFee) = _pendingRewards(entry);
        require(rewards > 0, "Staking Pool: No rewards available to claim");

        // Claim rewards or unstake if possible
        _claimOrUnstake(tokenId, entry, rewards, totalFee);

        // Trigger pool update
        updatePool();
    }

    function claimMultipleRewards(
        uint256[] memory tokenIds
    ) external onlyUnpaused nonReentrant {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            // Get token ID
            uint256 tokenId = tokenIds[i];

            // Check if token owner is sender
            require(
                proofToken().ownerOf(tokenId) == _msgSender(),
                string(
                    abi.encodePacked(
                        "Staking Pool: Mismatching token owner for id: ",
                        tokenId
                    )
                )
            );

            // Get pool entry
            PoolEntry memory entry = _poolEntries[tokenId];

            // Check if user got pending rewards
            (uint256 rewards, uint256 totalFee) = _pendingRewards(entry);
            if (rewards > 0) {
                // Claim rewards
                _claimOrUnstake(tokenId, entry, rewards, totalFee);
            }
        }

        // Trigger pool update
        updatePool();
    }

    function pendingRewards(
        uint256 tokenId
    ) public view returns (uint256 value) {
        // Get pool entry
        PoolEntry memory entry = poolEntry(tokenId);

        // Calculate pending rewards
        (uint256 rewards, ) = _pendingRewards(entry);
        return rewards;
    }

    function updatePool() public {
        // We've already updated this block
        if (lastRewardTimestamp() >= block.timestamp) {
            return;
        }

        // No one is currently staking, skipping update
        if (allocatedPoolShares() == 0) {
            _lastRewardTimestamp = block.timestamp;
            return;
        }

        // Calculate global pool factor
        _currentPoolFactor = poolFactor();

        // Calculate global rewards per share
        _accRewardsPerShare = _calculateAccRewardsPerShare();

        // Update last reward block
        _lastRewardTimestamp = block.timestamp;

        // Save values for snapshot
        _updateSnapshot(_accRewardsPerShareSnapshots, accRewardsPerShare());
        _updateSnapshot(_lastRewardTimestampSnapshots, lastRewardTimestamp());

        // Execute snapshot
        _snapshot();
    }

    function _claimOrUnstake(
        uint256 tokenId,
        PoolEntry memory entry,
        uint256 rewards,
        uint256 totalFee
    ) private {
        // Validate claim action
        _validateClaim(entry);

        if (rewards > 0) {
            // Claim rewards if available
            _claimRewards(tokenId, rewards, totalFee);

            // Update pool entry
            entry = _poolEntries[tokenId];
        }

        // Check if pool entry is expired and unstake
        if (
            block.timestamp >=
            entry.startedAt + (entry.duration * SECONDS_PER_DAY)
        ) {
            _unstake(tokenId, entry);
        }
    }

    function _pendingRewards(
        PoolEntry memory entry
    ) private view returns (uint256 availableRewards, uint256 totalFee) {
        // If already unstaked, return zero
        if (entry.isUnstaked) {
            return (0, 0);
        }

        // If we're exceeding staking duration, calculate rewards using
        // snapshot values around entry end timestamp and calculate
        // partial rewards
        uint256 durationInSeconds = entry.duration * SECONDS_PER_DAY;
        uint256 endTimestamp = entry.startedAt + durationInSeconds;

        // If we have already claimed this block or claimed after end, we've got all possible rewards
        if (
            entry.lastClaimedAt == block.timestamp ||
            entry.lastClaimedAt >= endTimestamp
        ) {
            return (0, 0);
        }

        // Calculate rewards based on shares
        uint256 rewards;
        if (block.timestamp > endTimestamp) {
            // Calculate historic rewards
            rewards = _calculateHistoricRewards(
                entry.shares,
                entry.startedAt,
                endTimestamp
            );
        } else if (block.timestamp > lastRewardTimestamp()) {
            // If lastRewardTimestamp is in the past, calculate new values here
            rewards = entry.shares * _calculateAccRewardsPerShare(poolFactor());
        } else {
            // If we've just updated, use static values here
            rewards = entry.shares * accRewardsPerShare();
        }

        // Subtract reward debt from rewards
        uint256 totalRewards = rewards - entry.rewardDebt;

        // Prevent underflow
        if (totalRewards < entry.claimedRewards + entry.collectedFees) {
            return (0, 0);
        }

        // Calculate available rewards
        uint256 unclaimedRewards = totalRewards -
            entry.claimedRewards -
            entry.collectedFees;

        // Calculate pool rewards fees
        uint256 fee = (unclaimedRewards * 3) / 100;

        // Return pending rewards without fee and claimed rewards
        return (unclaimedRewards - fee, fee);
    }

    /**
     * Claims rewards for the given entry
     *
     * @param tokenId uint256 - Proof token ID
     * @param rewards uint256 - Pending rewards
     * @param totalFee uint256 - Total fee subtracted from rewards
     */
    function _claimRewards(
        uint256 tokenId,
        uint256 rewards,
        uint256 totalFee
    ) private {
        // Transfer rewards to sender
        require(
            stakeToken().transfer(_msgSender(), rewards),
            "Staking Pool: Failed to transfer rewards"
        );

        // Update staking entry
        _poolEntries[tokenId].claimedRewards += rewards;
        _poolEntries[tokenId].collectedFees += totalFee;
        _poolEntries[tokenId].lastClaimedAt = block.timestamp;

        _reservedRewards += rewards;

        // Emit event
        emit RewardsClaimed(tokenId, rewards);
    }

    function _unstake(uint256 tokenId, PoolEntry memory entry) private {
        // Flag entry as unstaked
        _poolEntries[tokenId].isUnstaked = true;

        // Transfer initial stake amount back to sender
        require(
            stakeToken().transfer(_msgSender(), entry.amount),
            "Staking Pool: Failed to transfer initial stake"
        );

        // Update global pool state
        _allocatedPoolShares -= entry.shares;
        _totalTokenLocked -= entry.amount;

        _reservedRewards -= entry.claimedRewards;
        _reservedFees += entry.collectedFees / 2;

        _activeAllocatedPoolShares -= entry.shares;
    }
}


// File contracts/interfaces/IStakingUtils.sol


pragma solidity 0.8.17;

struct PoolEntryWithRewards {
    PoolEntry poolEntry;
    uint256 tokenId;
    uint256 pendingRewards;
}

interface IStakingUtils {
    /**
     * Returns the staking pool address
     */
    function stakingPool() external view returns (address value);

    /**
     * Returns staking pool APY values for each week
     */
    function apys() external view returns (uint256[] memory value);

    /**
     * Returns staking pool APR values for each week
     */
    function aprs() external view returns (uint256[] memory value);

    /**
     * Returns all staking token ids for a specific address
     *
     * @param addr address - address to get token ids for
     */
    function stakingTokenIds(
        address addr
    ) external view returns (uint256[] memory value);

    /**
     * Returns all staking entries for a specific address, including pending rewards
     *
     * @param addr address - address to get staking entries for
     */
    function stakingEntries(
        address addr
    ) external view returns (PoolEntryWithRewards[] memory value);

    /**
     * Returns a single staking entry for a specific token id
     *
     * @param tokenId uint256 - token id to fetch entry for
     */
    function stakingEntry(
        uint256 tokenId
    ) external view returns (PoolEntryWithRewards memory value);

    /**
     * Returns a bulk of staking entries for start -> start + amount
     *
     * @param start uint256 - token id to start at
     * @param amount uint256 - amount of entries to fetch (exclusive)
     */
    function stakingEntriesBulk(
        uint256 start,
        uint256 amount
    ) external view returns (PoolEntryWithRewards[] memory value);
}


// File contracts/StakingUtils.sol


pragma solidity 0.8.17;




contract StakingUtils is IStakingUtils {
    uint256 private constant STAKING_MAX_WEEKS = 52;
    IStakingPool private _stakingPool;

    constructor(address stakingPoolAddress) {
        _stakingPool = IStakingPool(stakingPoolAddress);
    }

    function stakingPool() external view override returns (address value) {
        return address(_stakingPool);
    }

    function apys() external view override returns (uint256[] memory value) {
        uint256[] memory values = new uint256[](STAKING_MAX_WEEKS);

        for (uint64 i = 1; i <= STAKING_MAX_WEEKS; i++) {
            values[i - 1] = _stakingPool.apy(i * 7);
        }

        return values;
    }

    function aprs() external view override returns (uint256[] memory value) {
        uint256[] memory values = new uint256[](STAKING_MAX_WEEKS);

        for (uint64 i = 1; i <= STAKING_MAX_WEEKS; i++) {
            values[i - 1] = _stakingPool.apr(i * 7);
        }

        return values;
    }

    function stakingEntries(
        address addr
    ) external view override returns (PoolEntryWithRewards[] memory value) {
        uint256[] memory tokenIds = stakingTokenIds(addr);
        PoolEntryWithRewards[] memory poolEntries = new PoolEntryWithRewards[](
            tokenIds.length
        );

        for (uint64 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];

            PoolEntryWithRewards memory poolEntry = PoolEntryWithRewards(
                _stakingPool.poolEntry(tokenId),
                tokenId,
                _stakingPool.pendingRewards(tokenId)
            );

            poolEntries[i] = poolEntry;
        }

        return poolEntries;
    }

    function stakingEntry(
        uint256 tokenId
    ) external view override returns (PoolEntryWithRewards memory value) {
        PoolEntryWithRewards memory poolEntry = PoolEntryWithRewards(
            _stakingPool.poolEntry(tokenId),
            tokenId,
            _stakingPool.pendingRewards(tokenId)
        );

        return poolEntry;
    }

    function stakingEntriesBulk(
        uint256 start,
        uint256 amount
    ) external view returns (PoolEntryWithRewards[] memory value) {
        IERC721Enumerable proofToken = IERC721Enumerable(
            address(_stakingPool.proofToken())
        );

        require(
            proofToken.totalSupply() >= start + amount,
            "StakingUtils: start + amount exceeds total supply"
        );

        PoolEntryWithRewards[] memory poolEntries = new PoolEntryWithRewards[](
            amount
        );

        uint256 arrIndex = 0;
        for (uint256 i = start; i < start + amount; i++) {
            PoolEntryWithRewards memory poolEntry = PoolEntryWithRewards(
                _stakingPool.poolEntry(i),
                i,
                _stakingPool.pendingRewards(i)
            );

            poolEntries[arrIndex] = poolEntry;
            arrIndex++;
        }

        return poolEntries;
    }

    function stakingTokenIds(
        address addr
    ) public view override returns (uint256[] memory value) {
        IERC721Enumerable proofToken = IERC721Enumerable(
            address(_stakingPool.proofToken())
        );

        uint256 balance = proofToken.balanceOf(addr);
        uint256[] memory tokenIds = new uint256[](balance);

        for (uint64 i = 0; i < balance; i++) {
            tokenIds[i] = proofToken.tokenOfOwnerByIndex(addr, i);
        }

        return tokenIds;
    }
}


// File contracts/interfaces/ITokenVault.sol


pragma solidity 0.8.17;

interface ITokenVault {
    /**
     * Emitted on vault lock
     */
    event Locked();

    /**
     * Emitted on vault unlock
     */
    event Unlocked();

    /**
     * Emitted on token withdrawal
     *
     * @param receiver address - Receiver of token
     * @param token address - Token address
     * @param amount uint256 - token amount
     */
    event WithdrawToken(address receiver, address token, uint256 amount);

    /**
     * Locks the vault
     */
    function lock() external;

    /**
     * Unlocks the vault
     */
    function unlock() external;

    /**
     * Withdraws token stores at the contract
     *
     * @param token address - Token to withdraw
     * @param amount uint256 - Amount of token to withdraw
     */
    function withdrawToken(address token, uint256 amount) external;
}


// File contracts/TokenVault.sol


pragma solidity 0.8.17;


contract TokenVault is ITokenVault, Ownable {
    bool public locked = true;

    function lock() external onlyOwner {
        locked = true;
        emit Locked();
    }

    function unlock() external onlyOwner {
        locked = false;
        emit Unlocked();
    }

    function withdrawToken(
        address token,
        uint256 amount
    ) external override onlyOwner {
        require(!locked, "TokenVault: Token vault is locked");

        IERC20(token).transfer(msg.sender, amount);
        emit WithdrawToken(msg.sender, token, amount);
    }
}


// File contracts/VestingWallet.sol


// OpenZeppelin Contracts (last updated v4.7.0) (finance/VestingWallet.sol)
// Modified by the WeSendit Development Team to support VestingManager
pragma solidity 0.8.17;



/**
 * @title VestingWallet
 * @dev This contract handles the vesting of Eth and ERC20 tokens for a given beneficiary. Custody of multiple tokens
 * can be given to this contract, which will release the token to the beneficiary following a given vesting schedule.
 * The vesting schedule is customizable through the {vestedAmount} function.
 *
 * Any token transferred to this contract will follow the vesting schedule as if they were locked from the beginning.
 * Consequently, if the vesting has already started, any amount of tokens sent to this contract will (at least partly)
 * be immediately releasable.
 */
contract VestingWallet is Context {
    event EtherReleased(uint256 amount);
    event ERC20Released(address indexed token, uint256 amount);

    uint256 private _released;
    mapping(address => uint256) private _erc20Released;
    address private immutable _beneficiary;
    uint64 private immutable _start;
    uint64 private immutable _duration;

    /**
     * @dev Set the beneficiary, start timestamp and vesting duration of the vesting wallet.
     */
    constructor(address beneficiaryAddress, uint64 startTimestamp, uint64 durationSeconds) payable {
        require(beneficiaryAddress != address(0), "VestingWallet: beneficiary is zero address");
        _beneficiary = beneficiaryAddress;
        _start = startTimestamp;
        _duration = durationSeconds;
    }

    /**
     * @dev The contract should be able to receive Eth.
     */
    receive() external payable virtual {}

    /**
     * @dev Getter for the beneficiary address.
     */
    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }

    /**
     * @dev Getter for the start timestamp.
     */
    function start() public view virtual returns (uint256) {
        return _start;
    }

    /**
     * @dev Getter for the vesting duration.
     */
    function duration() public view virtual returns (uint256) {
        return _duration;
    }

    /**
     * @dev Amount of eth already released
     */
    function released() public view virtual returns (uint256) {
        return _released;
    }

    /**
     * @dev Amount of token already released
     */
    function released(address token) public view virtual returns (uint256) {
        return _erc20Released[token];
    }

    /**
     * @dev Getter for the amount of releasable eth.
     */
    function releasable() public view virtual returns (uint256) {
        return vestedAmount(uint64(block.timestamp)) - released();
    }

    /**
     * @dev Getter for the amount of releasable `token` tokens. `token` should be the address of an
     * IERC20 contract.
     */
    function releasable(address token) public view virtual returns (uint256) {
        return vestedAmount(token, uint64(block.timestamp)) - released(token);
    }

    /**
     * @dev Release the native token (ether) that have already vested.
     *
     * Emits a {EtherReleased} event.
     */
    function release() public virtual {
        uint256 amount = releasable();
        _released += amount;
        emit EtherReleased(amount);
        Address.sendValue(payable(beneficiary()), amount);
    }

    /**
     * @dev Release the tokens that have already vested.
     *
     * Emits a {ERC20Released} event.
     */
    function release(address token) public virtual {
        uint256 amount = releasable(token);
        _erc20Released[token] += amount;
        emit ERC20Released(token, amount);
        SafeERC20.safeTransfer(IERC20(token), beneficiary(), amount);
    }

    /**
     * @dev Calculates the amount of ether that has already vested. Default implementation is a linear vesting curve.
     */
    function vestedAmount(uint64 timestamp) public view virtual returns (uint256) {
        return _vestingSchedule(address(this).balance + released(), timestamp);
    }

    /**
     * @dev Calculates the amount of tokens that has already vested. Default implementation is a linear vesting curve.
     */
    function vestedAmount(address token, uint64 timestamp) public view virtual returns (uint256) {
        return _vestingSchedule(IERC20(token).balanceOf(address(this)) + released(token), timestamp);
    }

    /**
     * @dev Virtual implementation of the vesting formula. This returns the amount vested, as a function of time, for
     * an asset given its total historical allocation.
     */
    function _vestingSchedule(uint256 totalAllocation, uint64 timestamp) internal view virtual returns (uint256) {
        if (timestamp < start()) {
            return 0;
        } else if (timestamp > start() + duration()) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start())) / duration();
        }
    }
}


// File contracts/WeSenditSender.sol


pragma solidity 0.8.17;


/**
 * @title WeSendit token sender
 */
contract WeSenditSender is Ownable {
    IERC20 private _token;

    constructor(address token) {
        _token = IERC20(token);
    }

    function transferBulk(
        address[] calldata addresses,
        uint256[] calldata amounts
    ) external onlyOwner returns (bool) {
        require(
            addresses.length == amounts.length,
            "WeSenditSender: mismatching addresses / amounts pair"
        );

        for (uint256 i = 0; i < addresses.length; i++) {
            require(
                _token.transferFrom(_msgSender(), addresses[i], amounts[i])
            );
        }

        return true;
    }
}


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v4.8.0


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

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


// File @openzeppelin/contracts/token/ERC20/ERC20.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;



/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}


// File @openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol@v4.8.0


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/ERC20Capped.sol)

pragma solidity ^0.8.0;

/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */
abstract contract ERC20Capped is ERC20 {
    uint256 private immutable _cap;

    /**
     * @dev Sets the value of the `cap`. This value is immutable, it can only be
     * set once during construction.
     */
    constructor(uint256 cap_) {
        require(cap_ > 0, "ERC20Capped: cap is 0");
        _cap = cap_;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    /**
     * @dev See {ERC20-_mint}.
     */
    function _mint(address account, uint256 amount) internal virtual override {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }
}


// File @openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}


// File contracts/WeSenditToken.sol


pragma solidity 0.8.17;



/**
 * @title WeSendit ERC20 token
 */
contract WeSenditToken is BaseWeSenditToken, ERC20Capped, ERC20Burnable {
    constructor(address addressTotalSupply)
        ERC20("WeSendit", "WSI")
        ERC20Capped(TOTAL_SUPPLY)
        BaseWeSenditToken()
    {
        _mint(addressTotalSupply, TOTAL_SUPPLY);
    }

    /**
     * Transfer token from without fee reflection
     *
     * @param from address - Address to transfer token from
     * @param to address - Address to transfer token to
     * @param amount uint256 - Amount of token to transfer
     *
     * @return bool - Indicator if transfer was successful
     */
    function transferFromNoFees(
        address from,
        address to,
        uint256 amount
    ) external virtual override returns (bool) {
        require(
            _msgSender() == address(dynamicFeeManager()),
            "WeSendit: Can only be called by Dynamic Fee Manager"
        );

        return super.transferFrom(from, to, amount);
    }

    /**
     * Transfer token with fee reflection
     *
     * @inheritdoc ERC20
     */
    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        // Reflect fees
        (uint256 tTotal, ) = _reflectFees(_msgSender(), to, amount);

        // Execute normal transfer
        return super.transfer(to, tTotal);
    }

    /**
     * Transfer token from with fee reflection
     *
     * @inheritdoc ERC20
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        // Reflect fees
        (uint256 tTotal, ) = _reflectFees(from, to, amount);

        // Execute normal transfer
        return super.transferFrom(from, to, tTotal);
    }

    /**
     * @inheritdoc ERC20
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        _preValidateTransfer(from);
    }

    // Needed since we inherit from ERC20 and ERC20Capped
    function _mint(address account, uint256 amount)
        internal
        virtual
        override(ERC20, ERC20Capped)
    {
        super._mint(account, amount);
    }

    /**
     * Reflects fees using the dynamic fee manager
     *
     * @param from address - Sender address
     * @param to address - Receiver address
     * @param amount uint256 - Transaction amount
     */
    function _reflectFees(
        address from,
        address to,
        uint256 amount
    ) private returns (uint256 tTotal, uint256 tFees) {
        if (address(dynamicFeeManager()) == address(0)) {
            return (amount, 0);
        } else {
            // Allow dynamic fee manager to spent amount for fees if needed
            _approve(from, address(dynamicFeeManager()), amount);

            // Reflect fees
            (tTotal, tFees) = dynamicFeeManager().reflectFees(from, to, amount);

            // Reset fee manager approval to zero for security reason
            _approve(from, address(dynamicFeeManager()), 0);

            return (tTotal, tFees);
        }
    }

    /**
     * Checks if the minimum transaction amount is exceeded and if pause is enabled
     *
     * @param from address - Sender address
     */
    function _preValidateTransfer(address from) private view {
        /**
         * Only allow transfers if:
         * - token is not paused
         * - sender is owner
         * - sender is admin
         * - sender has bypass role
         */
        require(
            !paused() ||
                from == address(0) ||
                from == owner() ||
                hasRole(ADMIN, from) ||
                hasRole(BYPASS_PAUSE, from),
            "WeSendit: transactions are paused"
        );
    }
}


// File @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


// File @openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol@v4.8.0


// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


// File @openzeppelin/contracts/token/ERC721/ERC721.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;







/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     */
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId, 1);

        // Check that tokenId was not minted by `_beforeTokenTransfer` hook
        require(!_exists(tokenId), "ERC721: token already minted");

        unchecked {
            // Will not overflow unless all 2**256 token ids are minted to the same owner.
            // Given that tokens are minted one by one, it is impossible in practice that
            // this ever happens. Might change if we allow batch minting.
            // The ERC fails to describe this case.
            _balances[to] += 1;
        }

        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId, 1);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId, 1);

        // Update ownership in case tokenId was transferred by `_beforeTokenTransfer` hook
        owner = ERC721.ownerOf(tokenId);

        // Clear approvals
        delete _tokenApprovals[tokenId];

        unchecked {
            // Cannot overflow, as that would require more tokens to be burned/transferred
            // out than the owner initially received through minting and transferring in.
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId, 1);

        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        // Clear approvals from the previous owner
        delete _tokenApprovals[tokenId];

        unchecked {
            // `_balances[from]` cannot overflow for the same reason as described in `_burn`:
            // `from`'s balance is the number of token held, which is at least one before the current
            // transfer.
            // `_balances[to]` could overflow in the conditions described in `_mint`. That would require
            // all 2**256 token ids to be minted, which in practice is impossible.
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId, 1);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits an {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Reverts if the `tokenId` has not been minted yet.
     */
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens will be transferred to `to`.
     * - When `from` is zero, the tokens will be minted for `to`.
     * - When `to` is zero, ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256, /* firstTokenId */
        uint256 batchSize
    ) internal virtual {
        if (batchSize > 1) {
            if (from != address(0)) {
                _balances[from] -= batchSize;
            }
            if (to != address(0)) {
                _balances[to] += batchSize;
            }
        }
    }

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}
}


// File @openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/extensions/ERC721URIStorage.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC721 token with storage based token URI management.
 */
abstract contract ERC721URIStorage is ERC721 {
    using Strings for uint256;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally checks to see if a
     * token-specific URI was set for the token, and if so, it deletes the token URI from
     * the storage mapping.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}


// File @openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol@v4.8.0


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC721/extensions/ERC721Enumerable.sol)

pragma solidity ^0.8.0;


/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);

        if (batchSize > 1) {
            // Will only trigger during construction. Batch transferring (minting) is not available afterwards.
            revert("ERC721Enumerable: consecutive transfers not supported");
        }

        uint256 tokenId = firstTokenId;

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}


// File contracts/WeStakeitToken.sol


pragma solidity 0.8.17;






/**
 * @title WeSendit Staking Token
 */
contract WeStakeitToken is
    IWeStakeitToken,
    ERC721,
    ERC721URIStorage,
    ERC721Enumerable,
    Ownable
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() ERC721("WeStakeit", "sWSI") {}

    function mint(
        address receiver
    ) external onlyOwner returns (uint256 tokenId) {
        tokenId = _tokenIds.current();

        _mint(receiver, tokenId);
        _setTokenURI(
            tokenId,
            string(
                abi.encodePacked(
                    "https://app.wesendit.io/api/tokenMetadata/",
                    Strings.toString(tokenId)
                )
            )
        );

        _tokenIds.increment();
        return tokenId;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(IERC165, ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}


// File contracts/mocks/MockERC20.sol


pragma solidity 0.8.17;




contract MockERC20 is ERC20, Ownable {
    constructor() ERC20("MockERC20", "MERC20") {
        _mint(_msgSender(), 100_000_000 ether);
    }
}


// File contracts/mocks/MockFeeReceiver.sol


pragma solidity 0.8.17;

contract MockFeeReceiver is IFeeReceiver {
    function onERC20Received(
        address caller,
        address token,
        address from,
        address to,
        uint256 amount
    ) external override {}

    receive() external payable {}
}


// File contracts/mocks/MockPancakePair.sol


pragma solidity 0.8.17;


contract MockPancakePair is ReentrancyGuard {
    constructor() {}

    function swap(
        address token,
        address to,
        uint256 amountOutMin
    ) public nonReentrant {
        IERC20(token).transfer(to, amountOutMin);
    }
}


// File contracts/mocks/MockPancakeRouter.sol


pragma solidity 0.8.17;

contract MockPancakeRouter {
    event MockEvent(uint256 value);

    address private immutable _weth;

    // See https://github.com/pancakeswap/pancake-smart-contracts/blob/master/projects/exchange-protocol/contracts/PancakeFactory.sol#L13
    mapping(address => mapping(address => address)) public getPair;

    constructor(
        address weth,
        address busd,
        address wsi,
        address wethPair,
        address busdPair
    ) {
        // BNB
        _weth = weth;

        // BNB <-> WSI
        getPair[weth][wsi] = wethPair;
        getPair[wsi][weth] = wethPair;

        // BUSD <-> WSI
        getPair[busd][wsi] = busdPair;
        getPair[wsi][busd] = busdPair;
    }

    function WETH() public view returns (address) {
        return _weth;
    }

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        public
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity)
    {
        address pair = getPair[_weth][token];

        IERC20(token).transferFrom(msg.sender, pair, amountTokenDesired);

        return (amountTokenDesired, msg.value, 0);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) public {
        require(amountIn > 0, "MockPancakeRouter: Invalid input amount");

        address pair = getPair[path[0]][path[1]];

        IERC20(path[0]).transferFrom(msg.sender, pair, amountIn);
        MockPancakePair(pair).swap(path[1], to, amountIn);
        //payable(to).transfer(amountIn);
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) public payable {
        address pair = getPair[path[0]][path[1]];

        IERC20(path[0]).transfer(pair, msg.value);
        MockPancakePair(pair).swap(path[1], to, amountOutMin);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) public {
        address pair = getPair[path[0]][path[1]];

        IERC20(path[0]).transferFrom(msg.sender, pair, amountIn);
        MockPancakePair(pair).swap(
            path[1],
            to,
            amountOutMin > 0 ? amountOutMin : amountIn
        );
    }
}


// File contracts/mocks/MockNonPayable.sol


pragma solidity 0.8.17;

contract MockNonPayable {
  constructor() {
  }
}