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
pragma solidity ^0.8.0;

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
library FullMath {
    /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product

        // todo unchecked
        unchecked {
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division
            if (prod1 == 0) {
                require(denominator > 0);
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }

            // Make sure the result is less than 2**256.
            // Also prevents denominator == 0
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0]
            // Compute remainder using mulmod
            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            // Subtract 256 bit number from 512 bit number
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator
            // Compute largest power of two divisor of denominator.
            // Always >= 1.
            uint256 twos = (~denominator + 1) & denominator;
            // Divide denominator by power of two
            assembly {
                denominator := div(denominator, twos)
            }

            // Divide [prod1 prod0] by the factors of two
            assembly {
                prod0 := div(prod0, twos)
            }
            // Shift in bits from prod1 into prod0. For this we need
            // to flip `twos` such that it is 2**256 / twos.
            // If twos is zero, then it becomes one
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }

            prod0 |= prod1 * twos;

            // Invert denominator mod 2**256
            // Now that denominator is an odd number, it has an inverse
            // modulo 2**256 such that denominator * inv = 1 mod 2**256.
            // Compute the inverse by starting with a seed that is correct
            // correct for four bits. That is, denominator * inv = 1 mod 2**4
            uint256 inv = (3 * denominator) ^ 2;
            // Now use Newton-Raphson iteration to improve the precision.
            // Thanks to Hensel's lifting lemma, this also works in modular
            // arithmetic, doubling the correct bits in each step.

            inv *= 2 - denominator * inv; // inverse mod 2**8
            inv *= 2 - denominator * inv; // inverse mod 2**16
            inv *= 2 - denominator * inv; // inverse mod 2**32
            inv *= 2 - denominator * inv; // inverse mod 2**64
            inv *= 2 - denominator * inv; // inverse mod 2**128
            inv *= 2 - denominator * inv; // inverse mod 2**256

            // Because the division is now exact we can divide by multiplying
            // with the modular inverse of denominator. This will give us the
            // correct result modulo 2**256. Since the precoditions guarantee
            // that the outcome is less than 2**256, this is the final result.
            // We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inv;
            return result;
        }
    }

    /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    function mulDivRoundingUp(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./libraries/TransferHelper.sol";
import "./libraries/FullMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PresaleMarket is Ownable {
    using TransferHelper for address;
    using FullMath for uint256;

    event StageAdded(uint256 stageId, uint256 price, uint256 totalLimit, uint256 lockDuration);
    event Deposited(address indexed user, uint256 stageId, uint256 depositId, uint256 amount, uint256 paid);
    event Claimed(address indexed user, uint256 depositId, uint256 amount);

    struct StageInfo {
        uint256 price; // scale by 10**8
        uint256 totalLimit;
        uint256 leftLimit;
        uint256 lockDuration;
    }

    struct DepositInfo {
        address user;
        uint256 amount;
        uint256 claimed;
        uint256 createdAt;
        uint256 lastClaimedAt;
        uint256 fullReleaseAt;
    }

    address public usdt;
    address public tokenForSale;
    address public treasury;
    
    uint256 public currentStage;
    uint256 public depositsCount;

    StageInfo[] private _stageInfos;
    DepositInfo[] private _depositInfos;
    mapping(address => uint256[]) private _userDepositIds;

    constructor(
        address usdt_,
        address tokenForSale_,
        address treasury_
    ) {
        usdt = usdt_;
        tokenForSale = tokenForSale_;
        treasury = treasury_;
    }

    function addStage(uint256 price, uint256 totalLimit, uint256 lockDuration) external onlyOwner {
        StageInfo memory info = StageInfo({
            price: price,
            totalLimit: totalLimit,
            leftLimit: totalLimit,
            lockDuration: lockDuration
        });
        _stageInfos.push(info);
        emit StageAdded(_stageInfos.length - 1, price, totalLimit, lockDuration);
    }

    function withdraw(address token, address to, uint256 amount) external onlyOwner {
        token.safeTransfer(to, amount);
    }

    function getStageInfo(uint256 stageId) external view returns (StageInfo memory stageInfo) {
        stageInfo = _stageInfos[stageId];
    }

    function getDepositInfoById(uint256 depositId) external view returns (DepositInfo memory depositInfo) {
        depositInfo = _depositInfos[depositId];
    }

    function getUserDepositIds(address user) external view returns (uint256[] memory ids) {
        ids = _userDepositIds[user];
    }

    function deposit(uint256 amount) external returns (uint256 paid, uint256 depositId) {
        StageInfo memory stageInfo = _stageInfos[currentStage];
        require(stageInfo.leftLimit >= amount, "not enough left");
        stageInfo.leftLimit -= amount;

        paid = amount.mulDiv(stageInfo.price, 10**8);
        usdt.safeTransferFrom(msg.sender, treasury, paid);

        depositId = depositsCount;
        DepositInfo memory depositInfo = DepositInfo({
            user: msg.sender,
            amount: amount,
            claimed: 0,
            createdAt: block.timestamp,
            lastClaimedAt: 0,
            fullReleaseAt: block.timestamp + stageInfo.lockDuration
        });
        _depositInfos.push(depositInfo);
        _userDepositIds[msg.sender].push(depositId);

        depositsCount++;
        _stageInfos[currentStage] = stageInfo;

        emit Deposited(msg.sender, currentStage, depositId, amount, paid);

        if (stageInfo.leftLimit == 0 && _stageInfos.length - 1 > currentStage) {
            currentStage++;
        }
    }

    function cliam(uint256 depositId) external returns (uint256 amount) {
        amount = _claim(depositId);
    }

    function batchClaim(uint256[] calldata depositIds) external returns (uint256[] memory amounts) {
        uint256 length = depositIds.length;
        amounts = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            amounts[i] = _claim(depositIds[i]);
        }
    }

    function claimAll() external returns (uint256 amount) {
        uint256[] memory ids = _userDepositIds[msg.sender];
        uint256 length = ids.length;
        for (uint256 i = 0; i < length; i++) {
            amount += _claim(ids[i]);
        }
    }

    function getClaimable(uint256[] calldata depositIds) external view returns (uint256[] memory amounts) {
        uint256 length = depositIds.length;
        for (uint256 i = 0; i < length; i++) {
            DepositInfo memory info = _depositInfos[depositIds[i]];

            if (info.lastClaimedAt < info.fullReleaseAt) {
                if (block.timestamp >= info.fullReleaseAt) {
                    amounts[i] = info.amount - info.claimed;
                } else {
                    uint256 fullTime = info.fullReleaseAt - info.createdAt;
                    uint256 pastTime = block.timestamp - info.createdAt;
                    amounts[i] = info.amount * pastTime / fullTime - info.claimed;
                }
            }
        }
    }

    function _claim(uint256 depositId) internal returns (uint256 amount) {
        DepositInfo memory info = _depositInfos[depositId];
        require(info.user == msg.sender, "forbidden");

        if (info.lastClaimedAt < info.fullReleaseAt) {
            if (block.timestamp >= info.fullReleaseAt) {
                amount = info.amount - info.claimed;
            } else {
                uint256 fullTime = info.fullReleaseAt - info.createdAt;
                uint256 pastTime = block.timestamp - info.createdAt;
                amount = info.amount * pastTime / fullTime - info.claimed;
            }
            if (amount > 0) {
                info.claimed += amount;
                _depositInfos[depositId] = info;
                tokenForSale.safeTransfer(msg.sender, amount);
                emit Claimed(msg.sender, depositId, amount);
            }
        }
    }
}