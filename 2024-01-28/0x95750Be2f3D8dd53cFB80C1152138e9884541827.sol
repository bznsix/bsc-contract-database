// SPDX-License-Identifier: MIT

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControlUpgradeable {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account)
        external
        view
        returns (bool);

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
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

import "../libs/utils/LUtil.sol";

interface IEventEmitter {
    function grantEventCallerRole(address eventCaller) external;

    function emitCalculateRandomNumber(address roundAddress, uint256 number)
        external;

    function emitSetTicket(
        address roundAddress,
        address owner,
        uint256 ticketKey,
        uint8[] calldata ticket
    ) external;

    function emitCalculateWinningTickets(
        address roundAddress,
        uint256 page,
        uint256 ticketKey,
        address ticketOwner,
        uint8[] calldata ticket
    ) external;

    function emitPayWinners(
        address roundAddress,
        uint256 page,
        uint256 ticketKey,
        LUtil.WinnerCategory category,
        address ticketOwner,
        uint256 winningAmount,
        uint256 ticketsCount
    ) external;

    function emitChangeRoundStatus(
        address roundAddress,
        LUtil.RoundStatus status
    ) external;

    function emitWithdraw(
        address roundAddress,
        address to,
        uint256 amount
    ) external;

    function emitDistribution(
        address roundAddress,
        address receiver,
        LUtil.Distribution distribution,
        uint256 amount
    ) external;
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

import "../libs/utils/LUtil.sol";

interface IGame {
    function getStatus() external view returns (LUtil.GameStatus);

    function getCurrentRoundNumber() external view returns (uint256);

    function getCurrentRoundAddress() external view returns (address);

    function getRounds(
        uint256 page,
        uint16 resultsPerPage,
        bool isReversed
    ) external view returns (address[] memory);

    function getRoundsFromIndex(
        uint256 index,
        uint16 resultsPerPage,
        bool isReversed
    ) external view returns (address[] memory);

    function isRoundExist(address roundAddress)
        external
        view
        returns (bool, uint256);

    function approvePay(LUtil.Wallets wallet, uint256 amount) external;

    function resetJackpot() external;
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

import "./IGame.sol";
import "./IPrizePool.sol";

interface ILottery is IGame, IPrizePool {
    function getTicketPrice() external view returns (uint256);
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

import "../libs/utils/LUtil.sol";

interface IPlatform {
    function getStatus() external view returns (LUtil.PlatformStatus);

    function getTokenAddress(address gameAddress)
        external
        view
        returns (address);

    function getBonusTokenAddress(address gameAddress)
        external
        view
        returns (address);

    function getGameConfig(address _gameAddress)
        external
        view
        returns (
            bool,
            bool,
            bool,
            bool
        );

    function getRoundDeployerAddress() external view returns (address);

    function getReferralSystemAddress() external view returns (address);

    function getPlatformOwnerAddress() external view returns (address);

    function getBuybackTreasuryAddress() external view returns (address);

    function getRevenueTreasuryAddress() external view returns (address);

    function getBuybackReceiverAddress() external view returns (address);

    function getRouterAddress() external view returns (address);

    function getEventEmitterAddress() external view returns (address);

    function getLinkTokenAddress() external view returns (address);

    function getVRFWrapperAddress() external view returns (address);

    function getCallbackGasLimit() external view returns (uint32);

    function getLinkFee() external view returns (uint256);

    function getGames(
        uint256 page,
        uint16 resultsPerPage,
        bool isReversed
    ) external view returns (address[] memory);

    function isGameExist(address game) external view returns (bool);

    function isRoundExist(address roundAddress)
        external
        view
        returns (
            bool,
            uint256,
            address
        );

    function setTokenAddress(address gameAddress, address tokenAddress)
        external;

    function setBonusTokenAddress(
        address gameAddress,
        address bonusTokenAddress
    ) external;
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

interface IPlatformAdmin {
    function getPlatformAddress() external view returns (address);
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

import "../libs/utils/LUtil.sol";
import "./IPlatformAdmin.sol";

interface IPrizePool is IPlatformAdmin {
    function getJackpotRequireMin() external view returns (uint256);

    function getWalletAddress(LUtil.Wallets walletIndex)
        external
        view
        returns (address);
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

interface IReferral {
    function isExist(address referral) external view returns (bool);

    function getReferrer(address referral) external view returns (address);

    function updateUserPoints(
        address roundAddress,
        address user,
        uint256 ticketsCount
    ) external;

    function setReferrer(address referral, address referrer) external;

    function startProcessing(address roundAddress) external;

    function setRefunded(address roundAddress) external;
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

import "../libs/utils/LUtil.sol";

interface IRound {
    function getStatus() external view returns (LUtil.RoundStatus);

    function getRoundPoolAmount() external view returns (uint256);

    function getRevenueAmount() external view returns (uint256);

    function getPrizePoolBalances()
        external
        view
        returns (LUtil.PrizeWallet[] memory);

    function setTicket(uint8[] calldata ticket, address owner) external;

    function startProcessing() external payable;

    // function getRandomNumber() external payable;

    function fundBalance(LUtil.PrizeWallet[] calldata balances) external;

    function payPage(LUtil.WinnerCategory category, uint256 page) external;

    function suspend() external;

    function resume() external;

    function refund() external;
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

import "../libs/utils/LUtil.sol";

interface IWallet {
    function balance() external view returns (uint256);

    function approve(address approver, uint256 amount) external;

    function transferTo(address recipient, uint256 amount) external;
}
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address payable);

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
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
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
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Bonus {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    function transferToOwner(address from, uint256 amount)
        external
        returns (bool);

    function transferFromOwner(address recipient, uint256 amount)
        external
        returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataBonus is IERC20Bonus {
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

pragma solidity ^0.8.0;

import "./IERC20.sol";

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
pragma solidity ^0.8.0;

interface LinkTokenInterface {
    function allowance(address owner, address spender)
        external
        view
        returns (uint256 remaining);

    function approve(address spender, uint256 value)
        external
        returns (bool success);

    function balanceOf(address owner) external view returns (uint256 balance);

    function decimals() external view returns (uint8 decimalPlaces);

    function decreaseApproval(address spender, uint256 addedValue)
        external
        returns (bool success);

    function increaseApproval(address spender, uint256 subtractedValue)
        external;

    function name() external view returns (string memory tokenName);

    function symbol() external view returns (string memory tokenSymbol);

    function totalSupply() external view returns (uint256 totalTokensIssued);

    function transfer(address to, uint256 value)
        external
        returns (bool success);

    function transferAndCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool success);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFV2WrapperInterface {
    /**
     * @return the request ID of the most recent VRF V2 request made by this wrapper. This should only
     * be relied option within the same transaction that the request was made.
     */
    function lastRequestId() external view returns (uint256);

    /**
     * @notice Calculates the price of a VRF request with the given callbackGasLimit at the current
     * @notice block.
     *
     * @dev This function relies on the transaction gas price which is not automatically set during
     * @dev simulation. To estimate the price at a specific gas price, use the estimatePrice function.
     *
     * @param _callbackGasLimit is the gas limit used to estimate the price.
     */
    function calculateRequestPrice(uint32 _callbackGasLimit)
        external
        view
        returns (uint256);

    /**
     * @notice Estimates the price of a VRF request with a specific gas limit and gas price.
     *
     * @dev This is a convenience function that can be called in simulation to better understand
     * @dev pricing.
     *
     * @param _callbackGasLimit is the gas limit used to estimate the price.
     * @param _requestGasPriceWei is the gas price in wei used for the estimation.
     */
    function estimateRequestPrice(
        uint32 _callbackGasLimit,
        uint256 _requestGasPriceWei
    ) external view returns (uint256);
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

import "../../interfaces/IRound.sol";
import "../../interfaces/IGame.sol";

library LLottery {
    function getTicketLength() public pure returns (uint8) {
        return 0x6;
    }

    function getMinNumber() public pure returns (uint8) {
        return 0x1;
    }

    function getMaxNumber() public pure returns (uint8) {
        return 0x2d;
    }

    function validateTickets(uint8[][] calldata numbersArray) external {
        IRound round = IRound(IGame(address(this)).getCurrentRoundAddress());
        for (uint256 index = 0; index < numbersArray.length; index++) {
            require(
                numbersArray[index].length == getTicketLength(),
                "LLottery: invalid ticket length"
            );

            for (
                uint256 numIndex = 0;
                numIndex < getTicketLength();
                numIndex++
            ) {
                require(
                    numbersArray[index][numIndex] > getMinNumber() - 1 &&
                        numbersArray[index][numIndex] < getMaxNumber() + 1,
                    "LLottery: invalid numbers range"
                );
                for (
                    uint256 idx = numIndex + 1;
                    idx < getTicketLength();
                    idx++
                ) {
                    require(
                        numbersArray[index][numIndex] !=
                            numbersArray[index][idx],
                        "LLottery: dublicated number error"
                    );
                }
            }

            round.setTicket(numbersArray[index], msg.sender);
        }
    }
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

import "../../../interfaces/token/IERC20Metadata.sol";
import "../../../interfaces/token/IERC20Bonus.sol";
import "../../../interfaces/IWallet.sol";
import "../../../interfaces/IPlatform.sol";
import "../../../interfaces/IReferral.sol";
import "../../utils/LUtil.sol";
import "../../../utils/structs/EnumerableSetUpgradeable.sol";
import "../../../interfaces/swap-core/IUniswapV2Router02.sol";
import "../../token/SafeERC20.sol";
import "../../../interfaces/IEventEmitter.sol";
import "../../../interfaces/ILottery.sol";

library LPrizePool {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
    using SafeERC20 for IERC20Metadata;

    function getPoolsCount() public pure returns (uint8) {
        return 0x6;
    }

    function getCommonPrizePoolPercent() public pure returns (uint16) {
        return 0xC350; // 50000 - 50%
    }

    function getReferrerPurposePercent() public pure returns (uint16) {
        return 0x1388; // 5000 - 5%
    }

    function getRevenuePurposePercent() public pure returns (uint16) {
        return 0x4FD3; // 20435 - 20,435 %
    }

    function getPlatformPurposePercent() public pure returns (uint16) {
        return 0x4C6D; // 19565 - 19,565%
    }

    function getULXBuybackPercent() public pure returns (uint16) {
        return 0x1388; // 5000 - 5%
    }

    function getBurnPurposePercent() public pure returns (uint16) {
        return 0x1388; // 5000 - 5%
    }

    function getBonusPurposePercent() public pure returns (uint16) {
        return 0x0; // 0 - 0%
    }

    function getJackpotPercent() public pure returns (uint16) {
        return 0x5014; // 20500 - 20,50 %
    }

    function getCategoryTwoPercent() public pure returns (uint16) {
        return 0x3C8C; // 15500 - 15,50 %
    }

    function getCategoryThreePercent() public pure returns (uint16) {
        return 0x251C; // 9500 - 9,50%
    }

    function getCategoryFourPercent() public pure returns (uint16) {
        return 0x34BC; // 13500 - 13,50%
    }

    function getCategoryFivePercent() public pure returns (uint16) {
        return 0x7918; // 31000 - 31%
    }

    function getBoosterPercent() public pure returns (uint16) {
        return 0x2710; // 10000 - 10%
    }

    function getBoosterFundLimit() public pure returns (uint256) {
        return 0x2DC6C0; // 3 kk USDT 0x2DC6C0 * 10 ^ 6 && 90 kk ULX 0x55D4A80 * 10 ^ 18
    }

    function getJackpotMinimumAmount() public pure returns (uint256) {
        return 0xF4240; // 1 kk USDT 0xF4240 * 10 ^ 6 && 30 kk ULX 0x1C9C380 * 10 ^ 18
    }

    //The function to distribute funds from prize pool to categories
    bytes4 private constant SELECTOR =
        bytes4(keccak256(bytes("transfer(address,uint256)")));

    function _getToken(address tokenAddress)
        private
        pure
        returns (IERC20Metadata token)
    {
        token = IERC20Metadata(tokenAddress);
    }

    function _getTokenBalanceOf(address tokenAddress, address account)
        private
        view
        returns (uint256 balance)
    {
        balance = _getToken(tokenAddress).balanceOf(account);
    }

    function _getGameConfig(IPlatform platform, address gameAddress)
        private
        view
        returns (
            bool isBonusAvailable,
            bool isBurnAvailable,
            bool isBuybackAvailable,
            bool isRevenueAvailable
        )
    {
        (
            isBonusAvailable,
            isBurnAvailable,
            isBuybackAvailable,
            isRevenueAvailable
        ) = platform.getGameConfig(gameAddress);
    }

    function _emitDistribution(
        IPlatform platform,
        address gameAddress,
        address receiver,
        LUtil.Distribution distribution,
        uint256 amount
    ) private {
        IEventEmitter(platform.getEventEmitterAddress()).emitDistribution(
            ILottery(gameAddress).getCurrentRoundAddress(),
            receiver,
            distribution,
            amount
        );
    }

    function _approve(
        address tokenAddress,
        address approveAddress,
        uint256 amount
    ) private {
        _getToken(tokenAddress).approve(approveAddress, amount);
    }

    function _safeTransfer(
        address tokenAddress,
        address to,
        uint256 amount,
        IPlatform platform,
        address gameAddress,
        LUtil.Distribution distribution
    ) private {
        _getToken(tokenAddress).safeTransfer(to, amount);
        _emitDistribution(platform, gameAddress, to, distribution, amount);
    }

    function _swapWETH(
        address wethAddress,
        address treasuryAddress,
        address routerAddress,
        uint256 amount,
        IPlatform platform,
        address gameAddress,
        address tokenAddress
    ) private {
        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = wethAddress;
        uint256[] memory amountsOut = IUniswapV2Router02(routerAddress)
            .getAmountsOut(amount, path);
        if (amountsOut[amountsOut.length - 1] > 0) {
            uint256 amountOutMin = amountsOut[amountsOut.length - 1] -
                (amountsOut[amountsOut.length - 1] * 0xa) /
                0x64;
            _approve(tokenAddress, routerAddress, amount);
            IUniswapV2Router02(routerAddress).swapExactTokensForETH(
                amount,
                amountOutMin,
                path,
                treasuryAddress,
                block.timestamp + 30
            );
            _emitDistribution(
                platform,
                gameAddress,
                treasuryAddress,
                LUtil.Distribution.BUYBACK,
                amount
            );
            _approve(tokenAddress, routerAddress, 0);
        } else {
            _safeTransfer(
                tokenAddress,
                treasuryAddress,
                amount,
                platform,
                gameAddress,
                LUtil.Distribution.BUYBACK
            );
        }
    }

    function _distributePlartformPercent(
        IPlatform platform,
        address gameAddress,
        address tokenAddress,
        uint256 amount,
        address buyer
    ) private returns (uint256 platformPercent, uint256 roundPrize) {
        (bool isBonusAvailable, , , bool isRevenueAvailable) = _getGameConfig(
            platform,
            gameAddress
        );

        platformPercent = getPlatformPurposePercent();
        if (isBonusAvailable) {
            IERC20Bonus bonusToken = IERC20Bonus(
                platform.getBonusTokenAddress(gameAddress)
            );
            bonusToken.transferFromOwner(
                buyer,
                (amount * getBonusPurposePercent()) / 0x186A0
            );
        }

        roundPrize = (amount * getCommonPrizePoolPercent()) / 0x186A0;
        {
            IReferral referralSystem = IReferral(
                platform.getReferralSystemAddress()
            );
            address referrer = referralSystem.getReferrer(buyer);

            if (referrer == address(0)) {
                platformPercent += getReferrerPurposePercent();
            } else {
                _safeTransfer(
                    tokenAddress,
                    referrer,
                    (amount * getReferrerPurposePercent()) / 0x186A0,
                    platform,
                    gameAddress,
                    LUtil.Distribution.REFERRER
                );
            }
            address revenueReceiver = isRevenueAvailable
                ? address(referralSystem)
                : platform.getRevenueTreasuryAddress();
            _safeTransfer(
                tokenAddress,
                revenueReceiver,
                (amount * getRevenuePurposePercent()) / 0x186A0,
                platform,
                gameAddress,
                LUtil.Distribution.REVENUE
            );
        }
    }

    function _distribute(
        EnumerableSetUpgradeable.AddressSet storage wallets,
        IPlatform platform,
        address gameAddress,
        address tokenAddress,
        uint256 platformPercent,
        uint256 amount,
        uint256 roundPrize
    ) private {
        (, bool isBurnAvailable, bool isBuybackAvailable, ) = _getGameConfig(
            platform,
            gameAddress
        );

        IUniswapV2Router02 router = IUniswapV2Router02(
            platform.getRouterAddress()
        );
        _safeTransfer(
            tokenAddress,
            platform.getPlatformOwnerAddress(),
            (amount * platformPercent) / 0x186A0,
            platform,
            gameAddress,
            LUtil.Distribution.PLATFORM
        );

        if (isBurnAvailable) {
            _safeTransfer(
                tokenAddress,
                platform.getBuybackTreasuryAddress(),
                (amount * getBurnPurposePercent()) / 0x186A0,
                platform,
                gameAddress,
                LUtil.Distribution.BURN
            );
        } else if (isBuybackAvailable) {
            _swapWETH(
                router.WETH(),
                platform.getBuybackTreasuryAddress(),
                address(router),
                (amount * getULXBuybackPercent()) / 0x186A0,
                platform,
                gameAddress,
                tokenAddress
            );
        } else {
            _safeTransfer(
                tokenAddress,
                platform.getBuybackReceiverAddress(),
                (amount * getULXBuybackPercent()) / 0x186A0,
                platform,
                gameAddress,
                LUtil.Distribution.BUYBACK_RECEIVER
            );
        }

        _safeTransfer(
            tokenAddress,
            wallets.at(uint256(LUtil.Wallets.CATEGORY2_WALLET)),
            (roundPrize * getCategoryTwoPercent()) / 0x186A0,
            platform,
            gameAddress,
            LUtil.Distribution.CATEGORY2_WALLET
        );
        _safeTransfer(
            tokenAddress,
            wallets.at(uint256(LUtil.Wallets.CATEGORY3_WALLET)),
            (roundPrize * getCategoryThreePercent()) / 0x186A0,
            platform,
            gameAddress,
            LUtil.Distribution.CATEGORY3_WALLET
        );
        _safeTransfer(
            tokenAddress,
            wallets.at(uint256(LUtil.Wallets.CATEGORY4_WALLET)),
            (roundPrize * getCategoryFourPercent()) / 0x186A0,
            platform,
            gameAddress,
            LUtil.Distribution.CATEGORY4_WALLET
        );
        _safeTransfer(
            tokenAddress,
            wallets.at(uint256(LUtil.Wallets.CATEGORY5_WALLET)),
            (roundPrize * getCategoryFivePercent()) / 0x186A0,
            platform,
            gameAddress,
            LUtil.Distribution.CATEGORY5_WALLET
        );
    }

    function _distributeJackpot(
        EnumerableSetUpgradeable.AddressSet storage wallets,
        IPlatform platform,
        address gameAddress,
        address tokenAddress,
        uint256 roundPrize,
        uint256 jackpotRequireMin
    ) private returns (uint256) {
        uint256 boosterFundLimit = getBoosterFundLimit() *
            10**_getToken(tokenAddress).decimals();

        uint256 jackpotAmount = (roundPrize * getJackpotPercent()) / 0x186A0;
        if (
            _getTokenBalanceOf(
                tokenAddress,
                wallets.at(uint256(LUtil.Wallets.BOOSTER_WALLET))
            ) > boosterFundLimit
        ) {
            jackpotAmount += (roundPrize * getBoosterPercent()) / 0x186A0;
        } else {
            if (
                _getTokenBalanceOf(
                    tokenAddress,
                    wallets.at(uint256(LUtil.Wallets.JACKPOT_WALLET))
                ) < jackpotRequireMin
            ) {
                uint256 amount_ = (roundPrize * (getBoosterPercent() / 0x2)) /
                    0x186A0;
                jackpotAmount += amount_;
                jackpotRequireMin += amount_;
                _safeTransfer(
                    tokenAddress,
                    wallets.at(uint256(LUtil.Wallets.BOOSTER_WALLET)),
                    amount_,
                    platform,
                    gameAddress,
                    LUtil.Distribution.BOOSTER_WALLET
                );
            } else {
                _safeTransfer(
                    tokenAddress,
                    wallets.at(uint256(LUtil.Wallets.BOOSTER_WALLET)),
                    (roundPrize * getBoosterPercent()) / 0x186A0,
                    platform,
                    gameAddress,
                    LUtil.Distribution.BOOSTER_WALLET
                );
            }
        }

        _safeTransfer(
            tokenAddress,
            wallets.at(uint256(LUtil.Wallets.JACKPOT_WALLET)),
            jackpotAmount,
            platform,
            gameAddress,
            LUtil.Distribution.JACKPOT_WALLET
        );
        return jackpotRequireMin;
    }

    function distribute(
        EnumerableSetUpgradeable.AddressSet storage wallets,
        address platformAddress,
        address gameAddress,
        address buyer,
        uint256 amount,
        uint256 jackpotRequireMin
    ) external returns (uint256) {
        require(amount > 0, "PRIZEPOOL: Amount must be more than 0");
        address tokenAddress = IPlatform(platformAddress).getTokenAddress(
            gameAddress
        );

        (
            uint256 platformPercent,
            uint256 roundPrize
        ) = _distributePlartformPercent(
                IPlatform(platformAddress),
                gameAddress,
                tokenAddress,
                amount,
                buyer
            );

        _distribute(
            wallets,
            IPlatform(platformAddress),
            gameAddress,
            tokenAddress,
            platformPercent,
            amount,
            roundPrize
        );

        return
            _distributeJackpot(
                wallets,
                IPlatform(platformAddress),
                gameAddress,
                tokenAddress,
                roundPrize,
                jackpotRequireMin
            );
    }

    function approve(
        EnumerableSetUpgradeable.AddressSet storage wallets,
        LUtil.Wallets wallet,
        address roundAddress,
        uint256 amount
    ) internal {
        IWallet(wallets.at(uint256(wallet))).approve(roundAddress, amount);
    }
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

import "../../../interfaces/token/IERC20.sol";
import "../../../interfaces/ILottery.sol";
import "../../../utils/structs/EnumerableSet.sol";
import "../../utils/LUtil.sol";
import "../../utils/array/LArray.sol";
import "../../lottery/LLottery.sol";
import "../../lottery/pool/LPrizePool.sol";
import "../../../Wallet.sol";
import "../../token/SafeERC20.sol";
import "../../../interfaces/IEventEmitter.sol";

library LRound {
    struct TicketStorage {
        mapping(uint256 => address) _ticketOwners;
        mapping(uint256 => uint8[]) _ticketNumbers;
        mapping(uint8 => uint256[]) _ticketsPool;
        mapping(uint256 => bool) _ticketProcessed;
        mapping(uint256 => bool) _ticketPayed;
        mapping(address => uint256[]) _ownerTickets;
        uint256 _ticketsCount;
        uint256 _processedPages;
    }

    using EnumerableSet for EnumerableSet.UintSet;
    using LRound for LUtil.PrizeWallet[];

    using SafeERC20 for IERC20;

    function getPoolLength() public pure returns (uint8) {
        return 0x6;
    }

    function getTicketsPerProcessing() public pure returns (uint16) {
        return 0x3E8;
    }

    function getTicketsPerPay() public pure returns (uint16) {
        return 0x3E8;
    }

    function isOpen(LUtil.RoundStatus status) public pure {
        require(status == LUtil.RoundStatus.OPEN, "ROUND: status not opened");
    }

    function isProcessing(LUtil.RoundStatus status) public pure {
        require(
            status == LUtil.RoundStatus.PROCESSING,
            "ROUND: status not in processing"
        );
    }

    function isPaying(LUtil.RoundStatus status) public pure {
        require(
            status == LUtil.RoundStatus.PAYING,
            "ROUND: status not in paying"
        );
    }

    function isPayed(LUtil.RoundStatus status) public pure {
        require(
            status == LUtil.RoundStatus.PAYED,
            "ROUND: status not in payed"
        );
    }

    function isRefund(LUtil.RoundStatus status) public pure {
        require(
            status == LUtil.RoundStatus.REFUND,
            "ROUND: status not in refund"
        );
    }

    function isCalculatedWinners(LUtil.RoundStatus status) public pure {
        require(
            status == LUtil.RoundStatus.CALCULATED_WINNERS,
            "ROUND: status not in calculating winners"
        );
    }

    function isFundedOrPaying(LUtil.RoundStatus status) public pure {
        require(
            (status == LUtil.RoundStatus.FUNDED) ||
                (status == LUtil.RoundStatus.PAYING),
            "ROUND: status not in funded or paying"
        );
    }

    function ifHasWinningNumbers(LUtil.RoundStatus status) public pure {
        require(
            status >= LUtil.RoundStatus.PROCESSING,
            "ROUND: does not have winning numbers - round opened or refunded or generating"
        );
    }

    function ifFunded(LUtil.RoundStatus status) public pure {
        require(
            status >= LUtil.RoundStatus.FUNDED,
            "ROUND: not funded - round opened or refunded or generating or processing or calculated winners"
        );
    }

    function isClosed(LUtil.RoundStatus status) public pure {
        require(status == LUtil.RoundStatus.CLOSED, "ROUND: not payed");
    }

    function _getLottery(address lotteryAddress)
        private
        pure
        returns (ILottery lottery)
    {
        lottery = ILottery(lotteryAddress);
    }

    function _getPagesByLimit(uint256 size, uint16 resultsPerPage)
        private
        pure
        returns (uint256 pages)
    {
        pages = LArray.getPagesByLimit(size, resultsPerPage);
    }

    function _getPositions(
        uint256 size,
        uint256 page,
        uint16 resultsPerPage
    )
        private
        pure
        returns (
            uint256 startIndex,
            uint256 stopIndex,
            uint256 elementsCount
        )
    {
        (startIndex, stopIndex, elementsCount) = LArray.getPositions(
            size,
            page,
            resultsPerPage
        );
    }

    function _getPlatform(address lotteryAddress)
        private
        view
        returns (IPlatform platform)
    {
        platform = IPlatform(_getLottery(lotteryAddress).getPlatformAddress());
    }

    function _getToken(address lotteryAddress)
        private
        view
        returns (IERC20 token)
    {
        token = IERC20(
            _getPlatform(lotteryAddress).getTokenAddress(lotteryAddress)
        );
    }

    function _getWalletAddress(address lotteryAddress, LUtil.Wallets wallet)
        private
        view
        returns (address walletAddress)
    {
        walletAddress = _getLottery(lotteryAddress).getWalletAddress(wallet);
    }

    function _roundExists(address lotteryAddress, address roundAddress)
        private
        view
    {
        (bool isExist, ) = _getLottery(lotteryAddress).isRoundExist(
            roundAddress
        );
        require(isExist, "round does not exist");
    }

    function _createTicketObject(
        TicketStorage storage tickets,
        uint256 index,
        bool isInitial,
        LUtil.WinnerCategory category,
        address ticketOwner
    ) private view returns (LUtil.TicketObject memory ticket) {
        uint256 ticketKey;
        if (isInitial) {
            ticketKey = index + 1;
        } else if (!isInitial && ticketOwner != address(0)) {
            ticketKey = tickets._ownerTickets[ticketOwner][index];
        } else {
            ticketKey = tickets._ticketsPool[uint8(category) + 1][index];
        }
        address owner = ticketOwner != address(0)
            ? ticketOwner
            : tickets._ticketOwners[ticketKey];

        ticket = LUtil.TicketObject(
            ticketKey,
            owner,
            tickets._ticketNumbers[ticketKey],
            true
        );
    }

    function _createTicketObjects(
        TicketStorage storage tickets,
        uint256 page,
        uint16 resultsPerPage,
        bool isInitial,
        LUtil.WinnerCategory category,
        address ticketOwner
    ) private view returns (LUtil.TicketObject[] memory _tickets) {
        uint256 size;
        if (isInitial && ticketOwner == address(0)) {
            size = tickets._ticketsCount;
        } else if (!isInitial && ticketOwner != address(0)) {
            size = tickets._ownerTickets[ticketOwner].length;
        } else {
            size = tickets._ticketsPool[uint8(category) + 1].length;
        }

        (
            uint256 startIndex,
            uint256 stopIndex,
            uint256 elementsCount
        ) = _getPositions(size, page, resultsPerPage);

        _tickets = new LUtil.TicketObject[](elementsCount);

        if (elementsCount == 0) return _tickets;

        uint256 index_ = 0;
        for (uint256 index = startIndex; index < stopIndex + 1; index++) {
            _tickets[index_] = _createTicketObject(
                tickets,
                index,
                isInitial,
                category,
                ticketOwner
            );
            index_++;
        }
    }

    function _isPayedCategory(
        TicketStorage storage tickets,
        LUtil.WinnerCategory category
    ) private view returns (bool) {
        uint8 _category = uint8(category) + 1;
        require(
            tickets._ticketsPool[_category].length > 0,
            "winners pool empty"
        );
        uint256 pages = _getPagesByLimit(
            tickets._ticketsPool[_category].length,
            getTicketsPerPay()
        );

        for (uint256 page = 1; page < pages + 1; page++) {
            if (
                !tickets._ticketPayed[
                    tickets._ticketsPool[_category][
                        getTicketsPerPay() * (page - 1)
                    ]
                ]
            ) return false;
        }
        return true;
    }

    function _isProcessed(TicketStorage storage tickets)
        private
        view
        returns (bool)
    {
        if (tickets._ticketsCount == 0) return true;
        return
            tickets._processedPages ==
            _getPagesByLimit(tickets._ticketsCount, getTicketsPerProcessing());
    }

    function _addAmount(
        TicketStorage storage tickets,
        LUtil.WinnerPay[] memory ticketsOwners,
        uint256 index,
        LUtil.WinnerCategory category,
        uint256 amount
    ) private view {
        bool isExist;
        uint256 i = 0;
        {
            while (i < ticketsOwners.length && ticketsOwners[i].isValid) {
                if (
                    ticketsOwners[i].recipient ==
                    tickets._ticketOwners[
                        tickets._ticketsPool[uint8(category) + 1][index]
                    ]
                ) {
                    ticketsOwners[i].ticketsCount++;
                    ticketsOwners[i].amount +=
                        amount /
                        tickets._ticketsPool[uint8(category) + 1].length;
                    isExist = true;
                }
                i++;
            }
        }

        if (!isExist) {
            ticketsOwners[i] = LUtil.WinnerPay(
                tickets._ticketOwners[
                    tickets._ticketsPool[uint8(category) + 1][index]
                ],
                amount / tickets._ticketsPool[uint8(category) + 1].length,
                1,
                true
            );
        }
    }

    function _generateWinners(
        TicketStorage storage tickets,
        LUtil.PrizeWallet storage wallet,
        LUtil.WinnerCategory category,
        uint256 page
    ) private returns (LUtil.WinnerPay[] memory) {
        (
            uint256 startIndex,
            uint256 stopIndex,
            uint256 elementsCount
        ) = _getPositions(
                tickets._ticketsPool[uint8(category) + 1].length,
                page,
                getTicketsPerPay()
            );
        LUtil.WinnerPay[] memory ticketsOwners = new LUtil.WinnerPay[](
            elementsCount
        );
        if (elementsCount == 0) {
            return ticketsOwners;
        }

        require(
            !tickets._ticketPayed[
                tickets._ticketsPool[uint8(category) + 1][startIndex]
            ],
            "page already payed"
        );
        tickets._ticketPayed[
            tickets._ticketsPool[uint8(category) + 1][startIndex]
        ] = true;

        for (uint256 index = startIndex; index < stopIndex + 1; index++) {
            _addAmount(tickets, ticketsOwners, index, category, wallet.amount);
        }

        return ticketsOwners;
    }

    function _safeTransferFrom(
        address lotteryAddress,
        address from,
        address to,
        uint256 amount
    ) private {
        _getToken(lotteryAddress).safeTransferFrom(from, to, amount);
    }

    function _safeTransferFromToBooster(
        address lotteryAddress,
        LUtil.Wallets wallet,
        uint256 poolAmount,
        uint256 percent
    ) private {
        _safeTransferFrom(
            lotteryAddress,
            _getWalletAddress(lotteryAddress, wallet),
            _getWalletAddress(lotteryAddress, LUtil.Wallets.BOOSTER_WALLET),
            (poolAmount * percent) / 0x186A0
        );
    }

    function _lotteryApprovePay(
        ILottery lottery,
        LUtil.Wallets wallet,
        uint256 amount
    ) private {
        lottery.approvePay(wallet, amount);
    }

    function _approveWinnersPay(
        TicketStorage storage tickets,
        LUtil.PrizeWallet[] storage wallets,
        ILottery lottery,
        LUtil.Wallets wallet,
        LUtil.WinnerCategory winnerCategory
    ) private {
        if (tickets._ticketsPool[uint8(winnerCategory) + 1].length > 0) {
            if (winnerCategory == LUtil.WinnerCategory.JACKPOT) {
                lottery.resetJackpot();
                if (
                    _getToken(address(lottery)).balanceOf(
                        wallets[uint256(wallet)].wallet
                    ) < wallets[uint256(wallet)].amount
                )
                    _lotteryApprovePay(
                        lottery,
                        LUtil.Wallets.BOOSTER_WALLET,
                        wallets[0].amount
                    );
            }
            _lotteryApprovePay(
                lottery,
                wallet,
                wallets[uint256(wallet)].amount
            );
        }
    }

    function _emitCalculateWinningTickets(
        TicketStorage storage tickets,
        address eventEmitterAddress,
        address roundAddress,
        uint256 page,
        uint256 ticketKey
    ) private {
        IEventEmitter(eventEmitterAddress).emitCalculateWinningTickets(
            roundAddress,
            page,
            ticketKey,
            tickets._ticketOwners[ticketKey],
            tickets._ticketNumbers[ticketKey]
        );
    }

    function isPayedPages(TicketStorage storage tickets)
        public
        view
        returns (bool)
    {
        LUtil.WinnerCategory[5] memory categories;
        categories = [
            LUtil.WinnerCategory.JACKPOT,
            LUtil.WinnerCategory.CATEGORY2,
            LUtil.WinnerCategory.CATEGORY3,
            LUtil.WinnerCategory.CATEGORY4,
            LUtil.WinnerCategory.CATEGORY5
        ];
        for (uint256 i = 0; i < categories.length; i++) {
            LUtil.WinnerCategory category = categories[i];
            if (
                getCategoryTicketsCount(tickets, category) != 0 &&
                !_isPayedCategory(tickets, category)
            ) {
                return false;
            }
        }
        return true;
    }

    function getUserTicketsCount(TicketStorage storage tickets, address owner)
        public
        view
        returns (uint256)
    {
        return tickets._ownerTickets[owner].length;
    }

    function getTicketsCount(TicketStorage storage tickets)
        public
        view
        returns (uint256)
    {
        return tickets._ticketsCount;
    }

    function getCategoryTicketsCount(
        TicketStorage storage tickets,
        LUtil.WinnerCategory category
    ) public view returns (uint256) {
        return tickets._ticketsPool[uint8(category) + 1].length;
    }

    function getPaginatedTickets(
        TicketStorage storage tickets,
        uint256 page,
        uint16 resultsPerPage
    ) public view returns (LUtil.TicketObject[] memory) {
        return
            _createTicketObjects(
                tickets,
                page,
                resultsPerPage,
                true,
                LUtil.WinnerCategory.CATEGORY5,
                address(0)
            );
    }

    function getPaginatedUserTickets(
        TicketStorage storage tickets,
        address owner,
        uint256 page,
        uint16 resultsPerPage
    ) external view returns (LUtil.TicketObject[] memory _tickets) {
        return
            _createTicketObjects(
                tickets,
                page,
                resultsPerPage,
                false,
                LUtil.WinnerCategory.CATEGORY5,
                owner
            );
    }

    function getPaginatedWinners(
        TicketStorage storage tickets,
        LUtil.WinnerCategory category,
        uint256 page,
        uint16 resultsPerPage
    ) public view returns (LUtil.TicketObject[] memory) {
        return
            _createTicketObjects(
                tickets,
                page,
                resultsPerPage,
                false,
                category,
                address(0)
            );
    }

    function getTicketsCountPerCategory(
        TicketStorage storage tickets,
        LUtil.WinnerCategory category
    ) public view returns (uint256) {
        return tickets._ticketsPool[uint8(category) + 1].length;
    }

    function calculateTicketAmount(
        LUtil.PrizeWallet[] storage balances,
        LUtil.WinnerCategory category,
        uint256 ticketCount
    ) public view returns (uint256) {
        if (ticketCount == 0) ticketCount++;
        return balances[uint8(category)].amount / ticketCount;
    }

    function checkPagePayed(
        TicketStorage storage tickets,
        LUtil.WinnerCategory category,
        uint256 page
    ) public view returns (bool) {
        (uint256 startIndex, , ) = _getPositions(
            tickets._ticketsPool[uint8(category) + 1].length,
            page,
            getTicketsPerPay()
        );
        return
            tickets._ticketPayed[
                tickets._ticketsPool[uint8(category) + 1][startIndex]
            ];
    }

    function emitChangeStatusEvent(
        TicketStorage storage tickets,
        address lotteryAddress,
        address roundAddress,
        address eventEmitterAddress,
        LUtil.RoundStatus status
    ) public {
        _roundExists(lotteryAddress, roundAddress);
        IEventEmitter(eventEmitterAddress).emitChangeRoundStatus(
            roundAddress,
            status
        );
    }

    function emitWithdrawEvent(
        TicketStorage storage tickets,
        address lotteryAddress,
        address roundAddress,
        address eventEmitterAddress,
        address to,
        uint256 amount
    ) public {
        _roundExists(lotteryAddress, roundAddress);
        IEventEmitter(eventEmitterAddress).emitWithdraw(
            roundAddress,
            to,
            amount
        );
    }

    function setTicket(
        TicketStorage storage tickets,
        uint8[] memory ticket,
        address owner,
        address roundAddress,
        address eventEmitterAddress
    ) public {
        tickets._ticketsCount++;

        for (uint256 index = 0; index < LLottery.getTicketLength(); index++) {
            tickets._ticketNumbers[tickets._ticketsCount].push(ticket[index]);
        }

        tickets._ticketOwners[tickets._ticketsCount] = owner;
        tickets._ownerTickets[owner].push(tickets._ticketsCount);
        IEventEmitter(eventEmitterAddress).emitSetTicket(
            roundAddress,
            owner,
            tickets._ticketsCount,
            tickets._ticketNumbers[tickets._ticketsCount]
        );
    }

    function calculateWinnersGroupsPage(
        TicketStorage storage tickets,
        uint256 page,
        EnumerableSet.UintSet storage numbers,
        address roundAddress,
        address eventEmitterAddress
    ) public returns (bool) {
        (
            uint256 startIndex,
            uint256 stopIndex,
            uint256 elementsCount
        ) = _getPositions(
                tickets._ticketsCount,
                page,
                getTicketsPerProcessing()
            );
        if (elementsCount == 0) {
            return _isProcessed(tickets);
        }

        require(
            !tickets._ticketProcessed[startIndex + 1],
            "page already processed"
        );
        tickets._ticketProcessed[startIndex + 1] = true;
        tickets._processedPages++;

        for (uint256 index = startIndex; index < stopIndex + 1; index++) {
            uint256 numIndex = 0;
            uint8 coincidenceCount = 0;
            uint256 ticketKey = index + 1;

            while (numIndex < LLottery.getTicketLength()) {
                if (
                    numbers.contains(
                        tickets._ticketNumbers[ticketKey][numIndex]
                    )
                ) {
                    coincidenceCount++;
                }
                numIndex++;
            }

            if (coincidenceCount > 1) {
                tickets
                    ._ticketsPool[
                        LLottery.getTicketLength() + 1 - coincidenceCount
                    ]
                    .push(ticketKey);
                _emitCalculateWinningTickets(
                    tickets,
                    eventEmitterAddress,
                    roundAddress,
                    page,
                    ticketKey
                );
            }
        }

        return _isProcessed(tickets);
    }

    function payPage(
        TicketStorage storage tickets,
        LUtil.PrizeWallet[] storage wallets,
        LUtil.WinnerCategory category,
        uint256 page,
        address lotteryAddress,
        address roundAddress,
        address eventEmitterAddress
    ) public {
        (, , uint256 elementsCount) = _getPositions(
            tickets._ticketsPool[uint8(category) + 1].length,
            page,
            getTicketsPerPay()
        );

        LUtil.WinnerPay[] memory ticketsOwners = _generateWinners(
            tickets,
            wallets[uint8(category)],
            category,
            page
        );
        uint256 index = 0;

        while (index < elementsCount && ticketsOwners[index].isValid) {
            if (
                _getToken(lotteryAddress).balanceOf(
                    wallets[uint8(category)].wallet
                ) < ticketsOwners[index].amount
            ) {
                _lotteryApprovePay(
                    _getLottery(lotteryAddress),
                    LUtil.Wallets.BOOSTER_WALLET,
                    ticketsOwners[index].amount
                );
                _safeTransferFrom(
                    lotteryAddress,
                    wallets[uint256(LUtil.Wallets.BOOSTER_WALLET)].wallet,
                    ticketsOwners[index].recipient,
                    ticketsOwners[index].amount
                );
            } else {
                _safeTransferFrom(
                    lotteryAddress,
                    wallets[uint8(category)].wallet,
                    ticketsOwners[index].recipient,
                    ticketsOwners[index].amount
                );
            }
            uint256 ticketKey = tickets._ticketsPool[uint8(category) + 1][
                index
            ];
            IEventEmitter(eventEmitterAddress).emitPayWinners(
                roundAddress,
                page,
                ticketKey,
                category,
                ticketsOwners[index].recipient,
                ticketsOwners[index].amount,
                ticketsOwners[index].ticketsCount
            );
            index++;
        }
    }

    function calculateRandomNumbers(
        EnumerableSet.UintSet storage set,
        uint256 salt,
        address roundAddress,
        address eventEmitterAddress
    ) public {
        uint256 randNonce;
        while (set.length() < LLottery.getTicketLength()) {
            uint256 randomNumber = (uint256(
                keccak256(abi.encodePacked(salt, randNonce))
            ) % LLottery.getMaxNumber()) + 1;
            set.add(randomNumber);
            randNonce++;
            IEventEmitter(eventEmitterAddress).emitCalculateRandomNumber(
                roundAddress,
                randomNumber
            );
        }
    }

    function transferToBooster(
        LUtil.PrizeWallet[] storage wallets,
        address lotteryAddress,
        uint256 roundAmount
    ) public {
        uint256 poolAmount = (roundAmount *
            LPrizePool.getCommonPrizePoolPercent()) / 0x186A0;

        uint256 jackpotPercent = LPrizePool.getJackpotPercent();
        if (
            _getToken(lotteryAddress).balanceOf(
                _getWalletAddress(lotteryAddress, LUtil.Wallets.JACKPOT_WALLET)
            ) < _getLottery(lotteryAddress).getJackpotRequireMin()
        ) {
            jackpotPercent += (LPrizePool.getBoosterPercent() / 0x2);
        }

        _safeTransferFromToBooster(
            lotteryAddress,
            LUtil.Wallets.JACKPOT_WALLET,
            poolAmount,
            jackpotPercent
        );
        _safeTransferFromToBooster(
            lotteryAddress,
            LUtil.Wallets.CATEGORY2_WALLET,
            poolAmount,
            LPrizePool.getCategoryTwoPercent()
        );
        _safeTransferFromToBooster(
            lotteryAddress,
            LUtil.Wallets.CATEGORY3_WALLET,
            poolAmount,
            LPrizePool.getCategoryThreePercent()
        );
        _safeTransferFromToBooster(
            lotteryAddress,
            LUtil.Wallets.CATEGORY4_WALLET,
            poolAmount,
            LPrizePool.getCategoryFourPercent()
        );
        _safeTransferFromToBooster(
            lotteryAddress,
            LUtil.Wallets.CATEGORY5_WALLET,
            poolAmount,
            LPrizePool.getCategoryFivePercent()
        );
    }

    function approveWinnersPay(
        TicketStorage storage tickets,
        LUtil.PrizeWallet[] storage wallets,
        address lotteryAddress
    ) public {
        _approveWinnersPay(
            tickets,
            wallets,
            _getLottery(lotteryAddress),
            LUtil.Wallets.JACKPOT_WALLET,
            LUtil.WinnerCategory.JACKPOT
        );
        _approveWinnersPay(
            tickets,
            wallets,
            _getLottery(lotteryAddress),
            LUtil.Wallets.CATEGORY2_WALLET,
            LUtil.WinnerCategory.CATEGORY2
        );
        _approveWinnersPay(
            tickets,
            wallets,
            _getLottery(lotteryAddress),
            LUtil.Wallets.CATEGORY3_WALLET,
            LUtil.WinnerCategory.CATEGORY3
        );
        _approveWinnersPay(
            tickets,
            wallets,
            _getLottery(lotteryAddress),
            LUtil.Wallets.CATEGORY4_WALLET,
            LUtil.WinnerCategory.CATEGORY4
        );
        _approveWinnersPay(
            tickets,
            wallets,
            _getLottery(lotteryAddress),
            LUtil.Wallets.CATEGORY5_WALLET,
            LUtil.WinnerCategory.CATEGORY5
        );
    }
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

import "../../libs/utils/LUtil.sol";
import "../../interfaces/IGame.sol";
import "../../libs/referral/LReferral.sol";
import "../../utils/structs/EnumerableSetUpgradeable.sol";

library LPlatform {
    bytes32 public constant ownerRole =
        0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0;
    bytes32 public constant adminRole =
        0xf23ec0bb4210edd5cba85afd05127efcd2fc6a781bfed49188da1081670b22d8;

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    function isGamesClosed(EnumerableSetUpgradeable.AddressSet storage games)
        public
        view
        returns (bool isClosed)
    {
        isClosed = true;

        for (uint256 index = 0; index < games.length(); index++) {
            IGame game = IGame(games.at(index));
            if (game.getStatus() != LUtil.GameStatus.CLOSED) {
                isClosed = false;
                break;
            }
        }
    }

    function isRoundExist(
        EnumerableSetUpgradeable.AddressSet storage games,
        address roundAddress
    )
        public
        view
        returns (
            bool isRoundExist_,
            uint256 roundIndex,
            address gameAddress
        )
    {
        require(roundAddress != address(0), "LPLATFORM: round address is zero");
        for (uint256 index = 0; index < games.length(); index++) {
            IGame game = IGame(games.at(index));
            (isRoundExist_, roundIndex) = game.isRoundExist(roundAddress);

            if (isRoundExist_) {
                gameAddress = games.at(index);
                break;
            }
        }
    }
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

import "../../interfaces/IPlatform.sol";
import "../../interfaces/IGame.sol";

library LReferral {
    uint256 public constant category4Points = 25;
    uint256 public constant category5Points = 5;

    enum ReferralCategories {
        FIRST,
        SECOND,
        THIRD,
        FOURTH,
        FIFTH
    }
    enum ReferralRoundStatus {
        EMPTY,
        PROCESSING,
        PAYING,
        CLOSED,
        REFUNDED
    }

    function getProcessingRoundsCount() public pure returns (uint8) {
        return 0xe;
    }

    function getCategoriesCount() public pure returns (uint8) {
        return 0x5;
    }

    function getPayLimit() public pure returns (uint16) {
        return 0x3E8;
    }

    function getCalculateUserLimit() public pure returns (uint16) {
        return 0x3E8;
    }

    function getCategoryRequirePoints(ReferralCategories refCategory)
        public
        pure
        returns (uint16 count)
    {
        return getCategoryUintRequirePoints(uint8(refCategory));
    }

    function getCategoryUintRequirePoints(uint8 refCategory)
        public
        pure
        returns (uint16 count)
    {
        if (refCategory == uint8(ReferralCategories.FIRST)) return 0x3e8;
        if (refCategory == uint8(ReferralCategories.SECOND)) return 0x1f4;
        if (refCategory == uint8(ReferralCategories.THIRD)) return 0x64;
        if (refCategory == uint8(ReferralCategories.FOURTH)) return 0x19;
        if (refCategory == uint8(ReferralCategories.FIFTH)) return 0x5;
    }

    function isExistInCategories(
        address user,
        uint256 points,
        uint256 upAmount
    ) public pure returns (bool) {
        if (user == address(0)) return false;
        if (
            points < getCategoryRequirePoints(ReferralCategories.FIFTH) &&
            points + upAmount >
            getCategoryRequirePoints(ReferralCategories.FIFTH) - 1
        ) return true;
        return false;
    }

    function isExistInCategories(address user, uint256 points)
        public
        pure
        returns (bool)
    {
        if (user == address(0)) return false;
        if (points > getCategoryRequirePoints(ReferralCategories.FIFTH) - 1)
            return true;
        return false;
    }

    function getCategoriesCountArray() public pure returns (uint256[] memory) {
        uint256[] memory catCounts = new uint256[](getCategoriesCount());

        catCounts[0] = getCategoryRequirePoints(ReferralCategories.FIRST);
        catCounts[1] = getCategoryRequirePoints(ReferralCategories.SECOND);
        catCounts[2] = getCategoryRequirePoints(ReferralCategories.THIRD);
        catCounts[3] = getCategoryRequirePoints(ReferralCategories.FOURTH);
        catCounts[4] = getCategoryRequirePoints(ReferralCategories.FIFTH);

        return catCounts;
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../interfaces/token/IERC20.sol";
import "../../utils/Address.sol";

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

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                oldAllowance + value
            )
        );
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    oldAllowance - value
                )
            );
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        bytes memory approvalCall = abi.encodeWithSelector(
            token.approve.selector,
            spender,
            value
        );

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(token.approve.selector, spender, 0)
            );
            _callOptionalReturn(token, approvalCall);
        }
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

        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        require(
            returndata.length == 0 || abi.decode(returndata, (bool)),
            "SafeERC20: ERC20 operation did not succeed"
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data)
        private
        returns (bool)
    {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success &&
            (returndata.length == 0 || abi.decode(returndata, (bool))) &&
            Address.isContract(address(token));
    }
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

import "../../../utils/structs/EnumerableSetUpgradeable.sol";

library LArray {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    modifier nonZeroResultsPage(uint256 number) {
        require(number > 0, "LArray: results per page cant be 0");
        _;
    }

    function getPaginatedArray(
        address[] storage array,
        uint256 page,
        uint16 resultsPerPage
    ) external view returns (address[] memory cuttedArray) {
        (
            uint256 startIndex,
            uint256 stopIndex,
            uint256 elementsCount
        ) = getPositions(array.length, page, resultsPerPage);
        cuttedArray = new address[](elementsCount);

        uint256 iterator;
        for (uint256 index = startIndex; index < stopIndex + 1; index++) {
            cuttedArray[iterator] = array[index];
            iterator++;
        }
    }

    function getPaginatedArrayReversed(
        address[] storage array,
        uint256 page,
        uint16 resultsPerPage
    ) external view returns (address[] memory cuttedArray) {
        (
            uint256 startIndex,
            uint256 stopIndex,
            uint256 elementsCount
        ) = getPositionsReversed(array.length, page, resultsPerPage);
        cuttedArray = new address[](elementsCount);

        uint256 iterator;
        uint256 index = startIndex;
        while (index >= stopIndex) {
            cuttedArray[iterator] = array[index];
            iterator++;

            if (index == stopIndex) {
                break;
            }
            index--;
        }
    }

    function getPaginatedArray(
        uint256[] storage array,
        uint256 page,
        uint16 resultsPerPage
    ) external view returns (uint256[] memory cuttedArray) {
        (
            uint256 startIndex,
            uint256 stopIndex,
            uint256 elementsCount
        ) = getPositions(array.length, page, resultsPerPage);
        cuttedArray = new uint256[](elementsCount);

        uint256 iterator;
        for (uint256 index = startIndex; index < stopIndex + 1; index++) {
            cuttedArray[iterator] = array[index];
            iterator++;
        }
    }

    function getPaginatedArray(
        EnumerableSetUpgradeable.AddressSet storage set,
        uint256 page,
        uint16 resultsPerPage
    ) external view returns (address[] memory cuttedArray) {
        (
            uint256 startIndex,
            uint256 stopIndex,
            uint256 elementsCount
        ) = getPositions(set.length(), page, resultsPerPage);
        cuttedArray = new address[](elementsCount);

        uint256 iterator;
        for (uint256 index = startIndex; index < stopIndex + 1; index++) {
            cuttedArray[iterator] = set.at(index);
            iterator++;
        }
    }

    function getPaginatedArrayReversed(
        EnumerableSetUpgradeable.AddressSet storage set,
        uint256 page,
        uint16 resultsPerPage
    ) external view returns (address[] memory cuttedArray) {
        (
            uint256 startIndex,
            uint256 stopIndex,
            uint256 elementsCount
        ) = getPositionsReversed(set.length(), page, resultsPerPage);
        cuttedArray = new address[](elementsCount);

        uint256 iterator;
        uint256 index = startIndex;
        while (index >= stopIndex && iterator < elementsCount) {
            cuttedArray[iterator] = set.at(index);
            iterator++;

            if (index == stopIndex) {
                break;
            }
            index--;
        }
    }

    function getPaginatedArrayFromIndex(
        EnumerableSetUpgradeable.AddressSet storage set,
        uint256 index,
        uint16 resultsPerPage
    ) external view returns (address[] memory cuttedArray) {
        (uint256 stopIndex, uint256 elementsCount) = getPositionsFromIndex(
            set.length(),
            index,
            resultsPerPage
        );
        cuttedArray = new address[](elementsCount);

        uint256 iterator;
        for (; index < stopIndex + 1; index++) {
            cuttedArray[iterator] = set.at(index);
            iterator++;
        }
    }

    function getPaginatedArrayFromIndexReversed(
        EnumerableSetUpgradeable.AddressSet storage set,
        uint256 index,
        uint16 resultsPerPage
    ) external view returns (address[] memory) {
        (
            uint256 stopIndex,
            uint256 elementsCount
        ) = getPositionsFromIndexReversed(set.length(), index, resultsPerPage);
        address[] memory cuttedArray = new address[](elementsCount);

        uint256 iterator;
        while (index >= stopIndex && iterator < elementsCount) {
            cuttedArray[iterator] = set.at(index);
            iterator++;

            if (index == stopIndex) {
                break;
            }
            index--;
        }

        return cuttedArray;
    }

    function isExistOnPage(
        EnumerableSetUpgradeable.AddressSet storage set,
        address element,
        uint256 page,
        uint16 resultsPerPage
    ) external view returns (bool isExist) {
        (uint256 startIndex, uint256 stopIndex, ) = getPositions(
            set.length(),
            page,
            resultsPerPage
        );

        if (set.contains(element)) {
            uint256 index = set.getIndex(element);
            if (index > 0 && index - 1 >= startIndex && index - 1 <= stopIndex)
                isExist = true;
        }
    }

    function isExistOnPage(
        address[] storage array,
        address element,
        uint256 page,
        uint16 resultsPerPage
    ) external view returns (bool isExist) {
        (uint256 startIndex, uint256 stopIndex, ) = getPositions(
            array.length,
            page,
            resultsPerPage
        );

        for (uint256 index = startIndex; index <= stopIndex; index++) {
            if (array[index] == element) {
                isExist = true;
                break;
            }
        }
    }

    function getPositions(
        uint256 size,
        uint256 page,
        uint16 resultPerPage
    )
        public
        pure
        nonZeroResultsPage(resultPerPage)
        returns (
            uint256 startIndex,
            uint256 stopIndex,
            uint256 elementsCount
        )
    {
        require(page > 0, "LArray: Invalid page");
        uint256 lastIndex = resultPerPage * page - 1;

        startIndex = resultPerPage * (page - 1);
        if (size > 0) stopIndex = lastIndex > size - 1 ? size - 1 : lastIndex;
        else stopIndex = size;
        if (size <= resultPerPage) elementsCount = size;
        else
            elementsCount = lastIndex > size - 1
                ? lastIndex - (lastIndex - size) - (resultPerPage * (page - 1))
                : resultPerPage;
    }

    function getPositionsFromIndex(
        uint256 size,
        uint256 index,
        uint16 resultPerPage
    )
        public
        pure
        nonZeroResultsPage(resultPerPage)
        returns (uint256 stopIndex, uint256 elementsCount)
    {
        require(index >= 0 && index < size, "LArray: Invalid index");
        uint256 lastIndex = resultPerPage + index - 1;

        stopIndex = lastIndex > size - 1 ? size - 1 : lastIndex;
        if (size <= resultPerPage) elementsCount = size;
        else
            elementsCount = lastIndex > size - 1
                ? lastIndex - (lastIndex - size) - index
                : resultPerPage;
    }

    function getPositionsReversed(
        uint256 size,
        uint256 page,
        uint16 resultPerPage
    )
        public
        pure
        nonZeroResultsPage(resultPerPage)
        returns (
            uint256 startIndex,
            uint256 stopIndex,
            uint256 elementsCount
        )
    {
        require(page > 0, "LArray: Invalid page");
        startIndex = size > 0 ? size - ((page - 1) * resultPerPage) - 1 : 0;
        stopIndex = startIndex + 1 > resultPerPage
            ? (startIndex + 1) - resultPerPage
            : 0;

        elementsCount = startIndex >= resultPerPage
            ? resultPerPage
            : startIndex + 1;
        if (size < 1) elementsCount = 0;
    }

    function getPositionsFromIndexReversed(
        uint256 size,
        uint256 index,
        uint16 resultPerPage
    )
        public
        pure
        nonZeroResultsPage(resultPerPage)
        returns (uint256 stopIndex, uint256 elementsCount)
    {
        require(index >= 0 && index < size, "LArray: Invalid index");
        uint256 startIndex;
        startIndex = index;
        stopIndex = startIndex + 1 > resultPerPage
            ? (startIndex + 1) - resultPerPage
            : 0;

        elementsCount = startIndex >= resultPerPage
            ? resultPerPage
            : startIndex + 1;
        if (size < 1) elementsCount = 0;
    }

    function getPagesByLimit(uint256 size, uint16 limit)
        public
        pure
        returns (uint256)
    {
        if (size < limit) return 1;
        if (size % limit == 0) return size / limit;
        return size / limit + 1;
    }
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

library LUtil {
    enum PlatformStatus {
        OPENED,
        RUNNING,
        CLOSING,
        CLOSED
    }
    enum GameStatus {
        OPENED,
        RUNNING,
        CLOSING,
        CLOSED
    }
    enum RoundStatus {
        OPEN,
        REFUND,
        GENERATING,
        PROCESSING,
        CALCULATED_WINNERS,
        FUNDED,
        PAYING,
        PAYED,
        CLOSED
    }
    enum WinnerCategory {
        JACKPOT,
        CATEGORY2,
        CATEGORY3,
        CATEGORY4,
        CATEGORY5
    }
    enum Wallets {
        JACKPOT_WALLET,
        CATEGORY2_WALLET,
        CATEGORY3_WALLET,
        CATEGORY4_WALLET,
        CATEGORY5_WALLET,
        BOOSTER_WALLET
    }
    enum Distribution {
        REFERRER,
        REVENUE,
        PLATFORM,
        BURN,
        BUYBACK,
        BUYBACK_RECEIVER,
        CATEGORY2_WALLET,
        CATEGORY3_WALLET,
        CATEGORY4_WALLET,
        CATEGORY5_WALLET,
        BOOSTER_WALLET,
        JACKPOT_WALLET
    }

    struct PrizeWallet {
        string key;
        address wallet;
        uint256 amount;
    }

    struct WinnerPay {
        address recipient;
        uint256 amount;
        uint256 ticketsCount;
        bool isValid;
    }

    /// All the needed info around a ticket
    struct TicketObject {
        uint256 key;
        address owner;
        uint8[] numbers;
        bool isValid;
    }

    struct DistributionFlags {
        bool isBonusAvailable;
        bool isBurnAvailable;
        bool isBuybackAvailable;
        bool isRevenueAvailable;
    }
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

import "./interfaces/IRound.sol";
import "./interfaces/ILottery.sol";
import "./interfaces/IPlatform.sol";
import "./libs/utils/LUtil.sol";
import "./libs/lottery/LLottery.sol";
import "./libs/lottery/round/LRound.sol";
import "./libs/lottery/pool/LPrizePool.sol";
import "./libs/platform/LPlatform.sol";
import "./libs/token/SafeERC20.sol";
import "./utils/structs/EnumerableSet.sol";
import "./security/Pausable.sol";
import "./access/Ownable.sol";
import "./interfaces/access/IAccessControlUpgradeable.sol";
import "./VRFV2WrapperConsumerBase.sol";

contract Round is IRound, VRFV2WrapperConsumerBase, Pausable, Ownable {
    uint16 private constant _REQUEST_CONFIRMATIONS = 3;
    uint32 private constant _WORDS_NUMBER = 1;

    uint256 private _randomResult;
    uint256 private _roundPoolAmount;

    EnumerableSet.UintSet private _winningNumbers;

    LUtil.RoundStatus private _status;
    LUtil.PrizeWallet[] private _balances;
    LRound.TicketStorage private _ticketStorage;

    mapping(address => bool) private _withdrawedUser;

    using LRound for LUtil.PrizeWallet[];
    using LRound for LRound.TicketStorage;
    using LRound for LUtil.RoundStatus;
    using EnumerableSet for EnumerableSet.UintSet;
    using LRound for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;

    event CalculateWinningTickets(
        address indexed roundAddress,
        uint256 page,
        uint256 indexed ticketKey,
        address indexed ticketOwner,
        uint8[] ticket
    );
    event PayWinners(
        address indexed roundAddress,
        uint256 page,
        uint256 ticketKey,
        LUtil.WinnerCategory indexed category,
        address indexed ticketOwner,
        uint256 winningAmount,
        uint256 ticketsCount
    );
    event ChangeRoundStatus(
        address indexed roundAddress,
        LUtil.RoundStatus indexed status
    );
    event Withdraw(
        address indexed roundAddress,
        address indexed to,
        uint256 amount
    );

    modifier onlyRole(bytes32 role) {
        require(
            IAccessControlUpgradeable(address(_getPlatform())).hasRole(
                role,
                _msgSender()
            ),
            "ROUND: permissions denied for msg.sender"
        );
        _;
    }

    receive() external payable {}

    constructor(address linkTokenAddress, address vrfV2Wrapper)
        VRFV2WrapperConsumerBase(
            linkTokenAddress, // LINK Token
            vrfV2Wrapper // VRF Coordinator
        )
    {}

    function _getEventEmitterAddress()
        private
        view
        returns (address eventEmitterAddress)
    {
        eventEmitterAddress = _getPlatform().getEventEmitterAddress();
    }

    function _getLottery() private view returns (ILottery lottery) {
        lottery = ILottery(owner());
    }

    function _getPlatform() private view returns (IPlatform platform) {
        platform = IPlatform(_getLottery().getPlatformAddress());
    }

    function _getToken() private view returns (IERC20 token) {
        token = IERC20(_getPlatform().getTokenAddress(owner()));
    }

    function _getRoundPoolAmount()
        private
        view
        returns (uint256 roundPoolAmount)
    {
        roundPoolAmount =
            _getLottery().getTicketPrice() *
            _ticketStorage.getTicketsCount();
    }

    function _emitChangeStatusEvent() private {
        _ticketStorage.emitChangeStatusEvent(
            owner(),
            address(this),
            _getEventEmitterAddress(),
            _status
        );
    }

    function _lotteryApprovePay(LUtil.Wallets wallet, uint256 amount) private {
        _getLottery().approvePay(wallet, amount / 0x186A0);
    }

    function _statusIfOpened() private view {
        _status.isOpen();
    }

    function _statusIfFunded() private view {
        _status.ifFunded();
    }

    function getTicketsCount() public view returns (uint256) {
        return _ticketStorage.getTicketsCount();
    }

    function getUserTicketsCount() external view returns (uint256) {
        return _ticketStorage.getUserTicketsCount(_msgSender());
    }

    function getUserTickets(uint256 page, uint16 resultsPerPage)
        external
        view
        returns (LUtil.TicketObject[] memory)
    {
        return
            _ticketStorage.getPaginatedUserTickets(
                _msgSender(),
                page,
                resultsPerPage
            );
    }

    function getCategoryTicketsCount(LUtil.WinnerCategory category)
        public
        view
        returns (uint256)
    {
        return _ticketStorage.getCategoryTicketsCount(category);
    }

    function getProcessingLimit() public pure returns (uint256) {
        return LRound.getTicketsPerProcessing();
    }

    function getPayLimit() public pure returns (uint256) {
        return LRound.getTicketsPerPay();
    }

    function getStatus() public view override returns (LUtil.RoundStatus) {
        return _status;
    }

    function getCategoryAmount(LUtil.WinnerCategory category)
        public
        view
        returns (uint256)
    {
        _statusIfFunded();
        return _balances[uint8(category)].amount;
    }

    function getCategoryAmountPerTicket(LUtil.WinnerCategory category)
        public
        view
        returns (uint256)
    {
        _statusIfFunded();
        return
            _balances.calculateTicketAmount(
                category,
                _ticketStorage._ticketsPool[uint8(category) + 1].length
            );
    }

    function getRoundPoolAmount() external view override returns (uint256) {
        return _roundPoolAmount;
    }

    function getWinners(
        LUtil.WinnerCategory category,
        uint256 page,
        uint16 resultsPerPage
    ) external view returns (LUtil.TicketObject[] memory) {
        return
            _ticketStorage.getPaginatedWinners(category, page, resultsPerPage);
    }

    function getTickets(uint256 page, uint16 resultsPerPage)
        external
        view
        returns (LUtil.TicketObject[] memory)
    {
        return _ticketStorage.getPaginatedTickets(page, resultsPerPage);
    }

    function getRevenueAmount() external view returns (uint256) {
        return
            (_roundPoolAmount * LPrizePool.getRevenuePurposePercent()) /
            0x186A0;
    }

    function getWinningNumbers() external view returns (uint256[] memory) {
        _status.ifHasWinningNumbers();
        return _winningNumbers.values();
    }

    function getPrizePoolBalances()
        external
        view
        returns (LUtil.PrizeWallet[] memory)
    {
        _statusIfFunded();
        return _balances;
    }

    function isUserWithdrawed(address user) public view returns (bool) {
        return _withdrawedUser[user];
    }

    function getRandomResult() public view returns (uint256) {
        return _randomResult;
    }

    function withdraw() external {
        _status.isRefund();
        uint256 userTickets = _ticketStorage.getUserTicketsCount(_msgSender());
        require(!isUserWithdrawed(_msgSender()), "ROUND: already withdrawed");
        require(userTickets > 0, "ROUND: empty tickets");

        _withdrawedUser[_msgSender()] = true;
        uint256 withdrawableAmount = (_roundPoolAmount * userTickets) /
            _ticketStorage.getTicketsCount();

        _getToken().safeTransferFrom(
            _getLottery().getWalletAddress(LUtil.Wallets.BOOSTER_WALLET),
            _msgSender(),
            withdrawableAmount
        );

        _ticketStorage.emitWithdrawEvent(
            owner(),
            address(this),
            _getEventEmitterAddress(),
            _msgSender(),
            withdrawableAmount
        );
    }

    function setTicket(uint8[] calldata ticket, address ticketOwner)
        external
        override
        onlyOwner
    {
        _statusIfOpened();

        _ticketStorage.setTicket(
            ticket,
            ticketOwner,
            address(this),
            _getEventEmitterAddress()
        );
    }

    function startProcessing() external payable override onlyOwner {
        _statusIfOpened();
        _status = LUtil.RoundStatus.GENERATING;

        _roundPoolAmount = _getRoundPoolAmount();

        _getRandomNumber();
        // _setWinningNumbers();
        _emitChangeStatusEvent();
    }

    /**
     * @dev after calculating categories we approving amount of pools to pay
     */
    function calculateWinnersGroupsPage(uint256 page)
        external
        onlyRole(LPlatform.adminRole)
    {
        _status.isProcessing();

        bool isProcessed = _ticketStorage.calculateWinnersGroupsPage(
            page,
            _winningNumbers,
            address(this),
            _getEventEmitterAddress()
        );
        if (isProcessed) {
            _status = LUtil.RoundStatus.CALCULATED_WINNERS;
            _emitChangeStatusEvent();
        }
    }

    function fundBalance(LUtil.PrizeWallet[] calldata balances)
        external
        onlyOwner
    {
        _status.isCalculatedWinners();

        for (uint256 index = 0; index < balances.length; index++) {
            _balances.push(balances[index]);
        }
        _ticketStorage.approveWinnersPay(_balances, owner());
        _status = LUtil.RoundStatus.FUNDED;

        _emitChangeStatusEvent();
    }

    function payPage(LUtil.WinnerCategory category, uint256 page)
        external
        override
        onlyRole(LPlatform.adminRole)
    {
        _status.isFundedOrPaying();

        _status = LUtil.RoundStatus.PAYING;
        _ticketStorage.payPage(
            _balances,
            category,
            page,
            owner(),
            address(this),
            _getEventEmitterAddress()
        );

        if (_ticketStorage.isPayedPages()) {
            _status = LUtil.RoundStatus.PAYED;
            _resetPay();
            _emitChangeStatusEvent();
        }
    }

    function closeRound() external onlyRole(LPlatform.adminRole) {
        _status.isPayed();

        _status = LUtil.RoundStatus.CLOSED;

        _emitChangeStatusEvent();
    }

    function suspend() external override onlyOwner {
        _pause();

        uint256 jackpotWalletAmount = _getRoundPoolAmount() *
            LPrizePool.getJackpotPercent();
        if (
            _getToken().balanceOf(
                _getLottery().getWalletAddress(LUtil.Wallets.JACKPOT_WALLET)
            ) < _getLottery().getJackpotRequireMin()
        ) {
            jackpotWalletAmount +=
                _getRoundPoolAmount() *
                (LPrizePool.getBoosterPercent() / 0x2);
        }

        _lotteryApprovePay(LUtil.Wallets.JACKPOT_WALLET, jackpotWalletAmount);
        _lotteryApprovePay(
            LUtil.Wallets.CATEGORY2_WALLET,
            _getRoundPoolAmount() * LPrizePool.getCategoryTwoPercent()
        );
        _lotteryApprovePay(
            LUtil.Wallets.CATEGORY3_WALLET,
            _getRoundPoolAmount() * LPrizePool.getCategoryThreePercent()
        );
        _lotteryApprovePay(
            LUtil.Wallets.CATEGORY4_WALLET,
            _getRoundPoolAmount() * LPrizePool.getCategoryFourPercent()
        );
        _lotteryApprovePay(
            LUtil.Wallets.CATEGORY5_WALLET,
            _getRoundPoolAmount() * LPrizePool.getCategoryFivePercent()
        );
    }

    function resume() external override onlyOwner {
        _statusIfOpened();
        _unpause();
        _resetPay();
    }

    function refund()
        external
        override
        onlyRole(LPlatform.adminRole)
        whenPaused
    {
        _statusIfOpened();
        _status = LUtil.RoundStatus.REFUND;

        _roundPoolAmount = _getRoundPoolAmount();
        _getLottery().approvePay(
            LUtil.Wallets.BOOSTER_WALLET,
            _roundPoolAmount
        );
        _balances.transferToBooster(owner(), _roundPoolAmount);

        _emitChangeStatusEvent();
    }

    // function _setWinningNumbers() private {
    //     _winningNumbers.add(2);
    //     _winningNumbers.add(5);
    //     _winningNumbers.add(8);
    //     _winningNumbers.add(9);
    //     _winningNumbers.add(25);
    //     _winningNumbers.add(44);
    //     _status = LUtil.RoundStatus.PROCESSING;
    //     _emitChangeStatusEvent();
    // }

    function _resetPay() private {
        ILottery lottery = _getLottery();
        lottery.approvePay(LUtil.Wallets.JACKPOT_WALLET, 0);
        lottery.approvePay(LUtil.Wallets.CATEGORY2_WALLET, 0);
        lottery.approvePay(LUtil.Wallets.CATEGORY3_WALLET, 0);
        lottery.approvePay(LUtil.Wallets.CATEGORY4_WALLET, 0);
        lottery.approvePay(LUtil.Wallets.CATEGORY5_WALLET, 0);
    }

    /**
     * Callback function used by VRF Coordinator V2
     */
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        _randomResult = _randomWords[_WORDS_NUMBER - 1];
        _winningNumbers.calculateRandomNumbers(
            _randomResult,
            address(this),
            _getEventEmitterAddress()
        );
        _status = LUtil.RoundStatus.PROCESSING;
        _emitChangeStatusEvent();
    }

    function _getRandomNumber() private returns (uint256 requestId) {
        requestId = requestRandomness(
            _getPlatform().getCallbackGasLimit(),
            _REQUEST_CONFIRMATIONS,
            _WORDS_NUMBER
        );
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
// SPDX-License-Identifier: MIT

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
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
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
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionCallWithValue(
                target,
                data,
                0,
                "Address: low-level call failed"
            );
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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
        return
            verifyCallResultFromTarget(
                target,
                success,
                returndata,
                errorMessage
            );
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

    function _revert(bytes memory returndata, string memory errorMessage)
        private
        pure
    {
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
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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
    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
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
    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
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

    function _getIndex(Set storage set, bytes32 value)
        private
        view
        returns (uint256)
    {
        return set._indexes[value];
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
    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
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
    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
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
    function values(Bytes32Set storage set)
        internal
        view
        returns (bytes32[] memory)
    {
        return _values(set._inner);
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
    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
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
    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
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
    function values(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    function getIndex(AddressSet storage set, address value)
        internal
        view
        returns (uint256)
    {
        return _getIndex(set._inner, bytes32(uint256(uint160(value))));
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
    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
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
    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
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
    function values(UintSet storage set)
        internal
        view
        returns (uint256[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT

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
 */
library EnumerableSetUpgradeable {
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
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
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
    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
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
    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
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

    /**
     * @dev custom function to get element index
     */
    function _getIndex(Set storage set, bytes32 value)
        private
        view
        returns (uint256)
    {
        return set._indexes[value];
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
    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
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
    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
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
    function values(Bytes32Set storage set)
        internal
        view
        returns (bytes32[] memory)
    {
        return _values(set._inner);
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
    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
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
    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
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
    function values(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    function getIndex(AddressSet storage set, address value)
        internal
        view
        returns (uint256)
    {
        return _getIndex(set._inner, bytes32(uint256(uint160(value))));
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
    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
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
    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
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
    function values(UintSet storage set)
        internal
        view
        returns (uint256[] memory)
    {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/token/LinkTokenInterface.sol";
import "./interfaces/VRFV2WrapperInterface.sol";

/** *******************************************************************************
 * @notice Interface for contracts using VRF randomness through the VRF V2 wrapper
 * ********************************************************************************
 * @dev PURPOSE
 *
 * @dev Create VRF V2 requests without the need for subscription management. Rather than creating
 * @dev and funding a VRF V2 subscription, a user can use this wrapper to create one off requests,
 * @dev paying up front rather than at fulfillment.
 *
 * @dev Since the price is determined using the gas price of the request transaction rather than
 * @dev the fulfillment transaction, the wrapper charges an additional premium on callback gas
 * @dev usage, in addition to some extra overhead costs associated with the VRFV2Wrapper contract.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFV2WrapperConsumerBase. The consumer must be funded
 * @dev with enough LINK to make the request, otherwise requests will revert. To request randomness,
 * @dev call the 'requestRandomness' function with the desired VRF parameters. This function handles
 * @dev paying for the request based on the current pricing.
 *
 * @dev Consumers must implement the fullfillRandomWords function, which will be called during
 * @dev fulfillment with the randomness result.
 */
abstract contract VRFV2WrapperConsumerBase {
    // solhint-disable-next-line chainlink-solidity/prefix-immutable-variables-with-i
    LinkTokenInterface internal immutable LINK;
    // solhint-disable-next-line chainlink-solidity/prefix-immutable-variables-with-i
    VRFV2WrapperInterface internal immutable VRF_V2_WRAPPER;

    /**
     * @param _link is the address of LinkToken
     * @param _vrfV2Wrapper is the address of the VRFV2Wrapper contract
     */
    constructor(address _link, address _vrfV2Wrapper) {
        LINK = LinkTokenInterface(_link);
        VRF_V2_WRAPPER = VRFV2WrapperInterface(_vrfV2Wrapper);
    }

    /**
     * @dev Requests randomness from the VRF V2 wrapper.
     *
     * @param _callbackGasLimit is the gas limit that should be used when calling the consumer's
     *        fulfillRandomWords function.
     * @param _requestConfirmations is the number of confirmations to wait before fulfilling the
     *        request. A higher number of confirmations increases security by reducing the likelihood
     *        that a chain re-org changes a published randomness outcome.
     * @param _numWords is the number of random words to request.
     *
     * @return requestId is the VRF V2 request ID of the newly created randomness request.
     */
    // solhint-disable-next-line chainlink-solidity/prefix-internal-functions-with-underscore
    function requestRandomness(
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations,
        uint32 _numWords
    ) internal returns (uint256 requestId) {
        LINK.transferAndCall(
            address(VRF_V2_WRAPPER),
            VRF_V2_WRAPPER.calculateRequestPrice(_callbackGasLimit),
            abi.encode(_callbackGasLimit, _requestConfirmations, _numWords)
        );
        return VRF_V2_WRAPPER.lastRequestId();
    }

    /**
     * @notice fulfillRandomWords handles the VRF V2 wrapper response. The consuming contract must
     * @notice implement it.
     *
     * @param _requestId is the VRF V2 request ID.
     * @param _randomWords is the randomness result.
     */
    // solhint-disable-next-line chainlink-solidity/prefix-internal-functions-with-underscore
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal virtual;

    function rawFulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) external {
        // solhint-disable-next-line custom-errors
        require(
            msg.sender == address(VRF_V2_WRAPPER),
            "only VRF V2 wrapper can fulfill"
        );
        fulfillRandomWords(_requestId, _randomWords);
    }
}
//SPDX-License-Identifier: UNLICENSED

pragma solidity >0.8.0 <0.9.0;

import "./interfaces/IWallet.sol";
import "./interfaces/IPlatform.sol";
import "./interfaces/ILottery.sol";
import "./interfaces/token/IERC20.sol";
import "./libs/utils/LUtil.sol";
import "./access/Ownable.sol";

abstract contract Wallet is IWallet, Ownable {
    bytes4 private constant SELECTOR =
        bytes4(keccak256(bytes("transfer(address,uint256)")));

    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(SELECTOR, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TRANSFER_FAILED"
        );
    }

    function balance() public view override returns (uint256) {
        return IERC20(_getTokenAddress()).balanceOf(address(this));
    }

    function transferTo(address recipient, uint256 amount)
        external
        override
        onlyOwner
    {
        _safeTransfer(_getTokenAddress(), recipient, amount);
    }

    function _getTokenAddress() internal view returns (address) {
        address tokenAddress = IPlatform(ILottery(owner()).getPlatformAddress())
            .getTokenAddress(owner());
        require(tokenAddress != address(0), "Wallet: Invalid token address");
        return tokenAddress;
    }

    function approve(address approver, uint256 amount)
        external
        override
        onlyOwner
    {
        IERC20(_getTokenAddress()).approve(approver, amount);
    }
}

contract BoosterWallet is Wallet {
    function topUpJackpot(address jackpot, uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be more than 0");
        _safeTransfer(_getTokenAddress(), jackpot, amount);
    }
}

contract GameWallet is Wallet {}

contract JackpotWallet is Wallet {}
