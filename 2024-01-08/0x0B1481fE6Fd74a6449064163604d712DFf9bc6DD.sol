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
// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/Math.sol)

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
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
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
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1, "Math: mulDiv overflow");

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
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
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
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
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
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
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
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

interface IBribe {
    function _deposit(uint amount, uint tokenId) external;
    function _withdraw(uint amount, uint tokenId) external;
    function getRewardForOwner(uint tokenId, address[] memory tokens) external;
    function notifyRewardAmount(address token, uint amount) external;
    function left(address token) external view returns (uint);
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

interface IBribeFactory {
    function createBribe() external returns (address);
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

interface IGauge {
    function notifyRewardAmount(address token, uint amount) external;
    function getReward(address account, address[] memory tokens) external;
    function claimFees() external returns (uint claimed0, uint claimed1);
    function left(address token) external view returns (uint);
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

interface IGaugeFactory {
    function createGauge(address, address, address) external returns (address);
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

interface IMinter {
    function update_period() external returns (uint);
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

interface IPair {
    function burn(address to) external returns (uint amount0, uint amount1);
    function claimFees() external returns (uint, uint);
    function getAmountOut(uint amountIn, address tokenIn) external view returns (uint);
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function mint(address to) external returns (uint liquidity);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    function stable() external view returns (bool);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function tokens() external returns (address, address);
    function transferFrom(address src, address dst, uint amount) external returns (bool);
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

interface IPairFactory {
    function admin() external view returns (address);
    function feeManagers(address feeManager) external view returns (bool);
    function allPairsLength() external view returns (uint);
    function isPair(address pair) external view returns (bool);
    function pairCodeHash() external pure returns (bytes32);
    function getPair(address tokenA, address token, bool stable) external view returns (address);
    function createPair(address tokenA, address tokenB, bool stable) external returns (address pair);
    function getInitializable() external view returns (address, address, bool);
    function setPause(bool _state) external;
    function isPaused() external view returns (bool);
    function getFee(bool _stable) external view returns(uint256);
    function getRealFee(address _pair) external view returns(uint256);
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

interface IVotingEscrow {

    struct Point {
        int128 bias;
        int128 slope; // # -dweight / dt
        uint256 ts;
        uint256 blk; // block
    }

    function user_point_epoch(uint tokenId) external view returns (uint);
    function epoch() external view returns (uint);
    function user_point_history(uint tokenId, uint loc) external view returns (Point memory);
    function point_history(uint loc) external view returns (Point memory);
    function checkpoint() external;
    function deposit_for(uint tokenId, uint value) external;
    function token() external view returns (address);
    function user_point_history__ts(uint tokenId, uint idx) external view returns (uint);
    function locked__end(uint _tokenId) external view returns (uint);
    function locked__amount(uint _tokenId) external view returns (uint);
    function approve(address spender, uint tokenId) external;
    function balanceOfNFT(uint) external view returns (uint);
    function isApprovedOrOwner(address, uint) external view returns (bool);
    function ownerOf(uint) external view returns (address);
    function transferFrom(address, address, uint) external;
    function totalSupply() external view returns (uint);
    function supply() external view returns (uint);
    function create_lock_for(uint, uint, address) external returns (uint);
    function lockVote(uint tokenId) external;
    function isVoteExpired(uint tokenId) external view returns (bool);
    function voteExpiry(uint _tokenId) external view returns (uint);
    function attach(uint tokenId) external;
    function detach(uint tokenId) external;
    function voting(uint tokenId) external;
    function abstain(uint tokenId) external;
    function voted(uint tokenId) external view returns (bool);
    function withdraw(uint tokenId) external;
    function create_lock(uint value, uint duration) external returns (uint);
    function setVoter(address voter) external;
    function balanceOf(address owner) external view returns (uint);
    function safeTransferFrom(address from, address to, uint tokenId) external;
    function burn(uint _tokenId) external;
    function setAdmin(address _admin) external;
    function setArtProxy(address _proxy) external;
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IVotingEscrow} from "./interfaces/IVotingEscrow.sol";
import {IPairFactory} from "./interfaces/IPairFactory.sol";
import {IPair} from "./interfaces/IPair.sol";
import {IGaugeFactory} from "./interfaces/IGaugeFactory.sol";
import {IBribeFactory} from "./interfaces/IBribeFactory.sol";
import {IGauge} from "./interfaces/IGauge.sol";
import {IBribe} from "./interfaces/IBribe.sol";
import {IMinter} from "./interfaces/IMinter.sol";

contract Voter {

    address public immutable _ve; // the ve token that governs these contracts
    address public immutable factory; // the BaseV1Factory
    address internal immutable base;
    address public gaugeFactory;
    address public immutable bribeFactory;
    uint internal constant DURATION = 7 days; // rewards are released over 7 days
    address public minter;
    address public admin;
    address public pendingAdmin;
    uint256 public whitelistingFee;
    bool public permissionMode;

    uint public totalWeight; // total voting weight

    address[] public allGauges; // all gauges viable for incentives
    mapping(address => address) public gauges; // pair => maturity => gauge
    mapping(address => address) public poolForGauge; // gauge => pool
    mapping(address => address) public bribes; // gauge => bribe
    mapping(address => uint256) public weights; // gauge => weight
    mapping(uint => mapping(address => uint256)) public votes; // nft => gauge => votes
    mapping(uint => address[]) public gaugeVote; // nft => gauge
    mapping(uint => uint) public usedWeights;  // nft => total voting weight of user
    mapping(address => bool) public isGauge;
    mapping(address => bool) public isLive; // gauge => status (live or not)
    mapping(address => bool) public feeManagers;

    mapping(address => bool) public isWhitelisted;
    mapping(address => mapping(address => bool)) public isReward;
    mapping(address => mapping(address => bool)) public isBribe;


    mapping(address => uint) public claimable;
    uint internal index;
    mapping(address => uint) internal supplyIndex;

    event GaugeCreated(address indexed gauge, address creator, address indexed bribe, address indexed pair);
    event Voted(address indexed voter, uint tokenId, uint256 weight);
    event Abstained(uint tokenId, uint256 weight);
    event Deposit(address indexed lp, address indexed gauge, uint tokenId, uint amount);
    event Withdraw(address indexed lp, address indexed gauge, uint tokenId, uint amount);
    event NotifyReward(address indexed sender, address indexed reward, uint amount);
    event DistributeReward(address indexed sender, address indexed gauge, uint amount);
    event Attach(address indexed owner, address indexed gauge, uint tokenId);
    event Detach(address indexed owner, address indexed gauge, uint tokenId);
    event Whitelisted(address indexed whitelister, address indexed token);
    event Delisted(address indexed delister, address indexed token);
    event GaugeKilled(address indexed gauge);
    event GaugeRevived(address indexed gauge);
    event GaugeNotProcessed(address indexed gauge);
    event GaugeProcessed(address indexed gauge);
    event ErrorClaimingGaugeRewards(address indexed gauge, address[] tokens);
    event ErrorClaimingBribeRewards(address indexed bribe, address[] tokens);
    event ErrorClaimingGaugeFees(address indexed gauge);
    event ErrorClaimingBribeFees(address indexed bribe, uint tokenId, address[] tokens);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Voter: only admin");
        _;
    }
    
    /// @dev Only calls from the enabled fee managers are accepted.
    modifier onlyFeeManagers() 
    {
        require(feeManagers[msg.sender], 'Voter: only fee manager');
        _;
    }
    
    modifier checkPermissionMode() {
        if(permissionMode) {
            require(msg.sender == admin, "Permission Mode Is Active");
        }
        _;
    }

    constructor(address __ve, address _factory, address  _gauges, address _bribes) {
        require(
            __ve != address(0) &&
            _factory != address(0) &&
            _gauges != address(0) &&
            _bribes != address(0),
            "Voter: zero address provided in constructor"
        );
        _ve = __ve;
        factory = _factory;
        base = IVotingEscrow(__ve).token();
        gaugeFactory = _gauges;
        bribeFactory = _bribes;
        minter = msg.sender;
        admin = msg.sender;
        permissionMode = false;
        whitelistingFee = 625000e18;
        
        feeManagers[msg.sender] = true;
        feeManagers[0x0c5D52630c982aE81b78AB2954Ddc9EC2797bB9c] = true;
        feeManagers[0x726461FA6e788bd8a79986D36F1992368A3e56eA] = true;
    }

    // simple re-entrancy check
    uint internal _unlocked = 1;
    modifier lock() {
        require(_unlocked == 1);
        _unlocked = 2;
        _;
        _unlocked = 1;
    }

    function initialize(address[] memory _tokens, address _minter) external {
        require(msg.sender == minter);
        for (uint i = 0; i < _tokens.length; i++) {
            _whitelist(_tokens[i]);
        }
        
        minter = _minter;
    }

    function setAdmin(address _admin) external onlyAdmin {
        pendingAdmin = _admin;
    }

    function acceptAdmin() external {
        require(msg.sender == pendingAdmin);
        admin = pendingAdmin;
    }
    
    function enablePermissionMode() external onlyAdmin {
        require(!permissionMode, "Permission Mode Enabled");
        permissionMode = true;
    }

    function disablePermissionMode() external onlyAdmin {
        require(permissionMode, "Permission Mode Disabled");
        permissionMode = false;
    }
    
    function manageFeeManager(address feeManager, bool _value) external onlyAdmin
    {
        feeManagers[feeManager] = _value;
    }

    function setReward(address _gauge, address _token, bool _status) external onlyAdmin {
        isReward[_gauge][_token] = _status;
    }

    function setBribe(address _bribe, address _token, bool _status) external onlyAdmin {
        isBribe[_bribe][_token] = _status;
    }
    
    function setWhitelistingFee(uint256 _fee) external onlyFeeManagers {
        require(_fee > 0, 'Fee must be greater than zero');
        whitelistingFee = _fee;
    }

    function killGauge(address _gauge) external onlyAdmin {
        require(isLive[_gauge], "gauge is not live");
        distribute(_gauge);
        isLive[_gauge] = false;
        claimable[_gauge] = 0;
        emit GaugeKilled(_gauge);
    }

    function reviveGauge(address _gauge) external onlyAdmin {
        require(!isLive[_gauge], "gauge is live");
        isLive[_gauge] = true;
        emit GaugeRevived(_gauge);
    }

    function reset(uint _tokenId) external {
        require(IVotingEscrow(_ve).isApprovedOrOwner(msg.sender, _tokenId));
        _reset(_tokenId);
        IVotingEscrow(_ve).abstain(_tokenId);
    }

    function _reset(uint _tokenId) internal {
        require(IVotingEscrow(_ve).isVoteExpired(_tokenId),"Vote Locked!");
        address[] storage _gaugeVote = gaugeVote[_tokenId];
        uint _gaugeVoteCnt = _gaugeVote.length;
        uint256 _totalWeight = 0;

        for (uint i = 0; i < _gaugeVoteCnt; i++) {
            address _gauge = _gaugeVote[i];
            uint256 _votes = votes[_tokenId][_gauge];
            if (_votes != 0) {
                _updateFor(_gauge);
                weights[_gauge] -= _votes;
                votes[_tokenId][_gauge] -= _votes;
                IBribe(bribes[_gauge])._withdraw(uint256(_votes), _tokenId);
                _totalWeight += _votes;
                emit Abstained(_tokenId, _votes);
            }
        }
        totalWeight -= uint256(_totalWeight);
        usedWeights[_tokenId] = 0;
        delete gaugeVote[_tokenId];
    }

    function poke(uint _tokenId) external {
        require(IVotingEscrow(_ve).isApprovedOrOwner(msg.sender, _tokenId));
        address[] memory _gaugeVote = gaugeVote[_tokenId];
        uint _gaugeCnt = _gaugeVote.length;
        uint256[] memory _weights = new uint256[](_gaugeCnt);

        for (uint i = 0; i < _gaugeCnt; i++) {
            _weights[i] = votes[_tokenId][_gaugeVote[i]];
        }

        _vote(_tokenId, _gaugeVote, _weights);
    }

    function _vote(uint _tokenId, address[] memory _gaugeVote, uint256[] memory _weights) internal {
        _reset(_tokenId);
        // Lock vote for 1 WEEK
        IVotingEscrow(_ve).lockVote(_tokenId);
        uint _gaugeCnt = _gaugeVote.length;
        uint256 _weight = IVotingEscrow(_ve).balanceOfNFT(_tokenId);
        uint256 _totalVoteWeight = 0;
        uint256 _totalWeight = 0;
        uint256 _usedWeight = 0;

        for (uint i = 0; i < _gaugeCnt; i++) {
            _totalVoteWeight += _weights[i];
        }

        for (uint i = 0; i < _gaugeCnt; i++) {
            address _gauge = _gaugeVote[i];
            if (isGauge[_gauge]) {
                uint256 _gaugeWeight = _weights[i] * _weight / _totalVoteWeight;
                require(votes[_tokenId][_gauge] == 0);
                require(_gaugeWeight != 0);
                _updateFor(_gauge);

                gaugeVote[_tokenId].push(_gauge);

                weights[_gauge] += _gaugeWeight;
                votes[_tokenId][_gauge] += _gaugeWeight;
                IBribe(bribes[_gauge])._deposit(_gaugeWeight, _tokenId);
                _usedWeight += _gaugeWeight;
                _totalWeight += _gaugeWeight;
                emit Voted(msg.sender, _tokenId, _gaugeWeight);
            }
        }
        if (_usedWeight > 0) IVotingEscrow(_ve).voting(_tokenId);
        totalWeight += _totalWeight;
        usedWeights[_tokenId] = _usedWeight;
    }

    // @param _tokenId The id of the veNFT to vote with
    // @param _gaugeVote The list of gauges to vote for
    // @param _weights The list of weights to vote for each gauge
    // @notice the sum of weights is the total weight of the veNFT at max
    function vote(uint tokenId, address[] calldata _gaugeVote, uint256[] calldata _weights) external {
        require(IVotingEscrow(_ve).isApprovedOrOwner(msg.sender, tokenId));
        require(_gaugeVote.length == _weights.length);
        uint _lockEnd = IVotingEscrow(_ve).locked__end(tokenId);
        require(_nextPeriod() <= _lockEnd, "lock expires soon");
        _vote(tokenId, _gaugeVote, _weights);
    }

    function whitelist(address _token) public checkPermissionMode {
        _safeTransferFrom(base, msg.sender, address(0), whitelistingFee);
        _whitelist(_token);
    }
    
    function whitelistBatch(address[] memory _tokens) external onlyAdmin {
        for (uint i = 0; i < _tokens.length; i++) {
            _whitelist(_tokens[i]);
        }
    }

    function _whitelist(address _token) internal {
        require(!isWhitelisted[_token]);
        isWhitelisted[_token] = true;
        emit Whitelisted(msg.sender, _token);
    }
    
    function delist(address _token) public onlyAdmin {
        require(isWhitelisted[_token], "!whitelisted");
        isWhitelisted[_token] = false;
        emit Delisted(msg.sender, _token);
    }

    function createGauge(address _pair) external returns (address) {
        require(gauges[_pair] == address(0x0), "exists");
        require(IPairFactory(factory).isPair(_pair), "!pair");
        (address _tokenA, address _tokenB) = IPair(_pair).tokens();
        require(isWhitelisted[_tokenA] && isWhitelisted[_tokenB], "!whitelisted");
        address _bribe = IBribeFactory(bribeFactory).createBribe();
        address _gauge = IGaugeFactory(gaugeFactory).createGauge(_pair, _bribe, _ve);
        IERC20(base).approve(_gauge, type(uint).max);
        bribes[_gauge] = _bribe;
        gauges[_pair] = _gauge;
        poolForGauge[_gauge] = _pair;
        isGauge[_gauge] = true;
        isLive[_gauge] = true;
        isReward[_gauge][_tokenA] = true;
        isReward[_gauge][_tokenB] = true;
        isReward[_gauge][base] = true;
        isBribe[_bribe][_tokenA] = true;
        isBribe[_bribe][_tokenB] = true;
        _updateFor(_gauge);
        allGauges.push(_gauge);
        emit GaugeCreated(_gauge, msg.sender, _bribe, _pair);
        return _gauge;
    }

    function attachTokenToGauge(uint tokenId, address account) external {
        require(isGauge[msg.sender]);
        if (tokenId > 0) IVotingEscrow(_ve).attach(tokenId);
        emit Attach(account, msg.sender, tokenId);
    }

    function emitDeposit(uint tokenId, address account, uint amount) external {
        require(isGauge[msg.sender]);
        emit Deposit(account, msg.sender, tokenId, amount);
    }

    function detachTokenFromGauge(uint tokenId, address account) external {
        require(isGauge[msg.sender]);
        if (tokenId > 0) IVotingEscrow(_ve).detach(tokenId);
        emit Detach(account, msg.sender, tokenId);
    }

    function emitWithdraw(uint tokenId, address account, uint amount) external {
        require(isGauge[msg.sender]);
        emit Withdraw(account, msg.sender, tokenId, amount);
    }

    function length() external view returns (uint) {
        return allGauges.length;
    }

    // @notice called by Minter contract to distribute weekly rewards
    // @param _amount the amount of tokens distributed
    function notifyRewardAmount(uint amount) external {
        _safeTransferFrom(base, msg.sender, address(this), amount); // transfer the distro in
        uint256 _ratio = amount * 1e18 / totalWeight; // 1e18 adjustment is removed during claim
        if (_ratio > 0) {
            index += _ratio;
        }
        emit NotifyReward(msg.sender, base, amount);
    }

    function updateFor(address[] memory _gauges) external {
        for (uint i = 0; i < _gauges.length; i++) {
            _updateFor(_gauges[i]);
        }
    }

    function updateForRange(uint start, uint end) public {
        for (uint i = start; i < end; i++) {
            _updateFor(allGauges[i]);
        }
    }

    function updateAll() external {
        updateForRange(0, allGauges.length);
    }

    // @notice update a gauge eligibility for rewards to the current index
    // @param _gauge the gauge to update
    function updateGauge(address _gauge) external {
        _updateFor(_gauge);
    }

    function _updateFor(address _gauge) internal {
        uint256 _supplied = weights[_gauge];
        if (_supplied > 0) {
            uint _supplyIndex = supplyIndex[_gauge];
            uint _index = index; // get global index0 for accumulated distro
            supplyIndex[_gauge] = _index; // update _gauge current position to global position
            uint _delta = _index - _supplyIndex; // see if there is any difference that need to be accrued
            if (_delta > 0) {
                uint _share = uint(_supplied) * _delta / 1e18; // add accrued difference for each supplied token
                if (isLive[_gauge]) {
                    claimable[_gauge] += _share;
                }
            }
        } else {
            supplyIndex[_gauge] = index; // new users are set to the default global state
        }
    }

    // @notice allow a gauge depositor to claim earned rewards if any
    // @param _gauges list of gauges contracts to claim rewards on
    // @param _tokens list of  tokens to claim
    function claimRewards(address[] memory _gauges, address[][] memory _tokens) external {
        for (uint i = 0; i < _gauges.length; i++) {
            try IGauge(_gauges[i]).getReward(msg.sender, _tokens[i]) {
                
            } catch {
                emit ErrorClaimingGaugeRewards(_gauges[i], _tokens[i]);
            }
        }
    }

    // @notice allow a voter to claim earned bribes if any
    // @param _bribes list of bribes contracts to claims bribes on
    // @param _tokens list of the tokens to claim
    // @param _tokenId the ID of veNFT to claim bribes for
    function claimBribes(address[] memory _bribes, address[][] memory _tokens, uint _tokenId) external {
        require(IVotingEscrow(_ve).isApprovedOrOwner(msg.sender, _tokenId));
        for (uint i = 0; i < _bribes.length; i++) {
            try IBribe(_bribes[i]).getRewardForOwner(_tokenId, _tokens[i]) {
                
            } catch {
                emit ErrorClaimingBribeRewards(_bribes[i], _tokens[i]);
            }
        }
    }

    // @notice allow voter to claim earned fees
    // @param _fees list of bribes contracts to claim fees on
    // @param _tokens list of the tokens to claim
    // @param _tokenId the ID of veNFT to claim fees for
    function claimFees(address[] memory _fees, address[][] memory _tokens, uint _tokenId) external {
        require(IVotingEscrow(_ve).isApprovedOrOwner(msg.sender, _tokenId));
        for (uint i = 0; i < _fees.length; i++) {
            try IBribe(_fees[i]).getRewardForOwner(_tokenId, _tokens[i]) {
                
            } catch {
                emit ErrorClaimingBribeFees(_fees[i], _tokenId, _tokens[i]);
            }
        }
    }

    // @notice distribute earned fees to the bribe contract for a given gauge
    // @param _gauges the gauges to distribute fees for
    function distributeFees(address[] memory _gauges) external {
        for (uint i = 0; i < _gauges.length; i++) {
            try IGauge(_gauges[i]).claimFees() {
                
            } catch {
                emit ErrorClaimingGaugeFees(_gauges[i]);
            }
        }
    }

    // @notice distribute earned fees to the bribe contract for all gauges
    function distroFees() external {
        for (uint i = 0; i < allGauges.length; i++) {
            try IGauge(allGauges[i]).claimFees() {
                
            } catch {
                emit ErrorClaimingGaugeFees(allGauges[i]);
            }
        }
    }

    // @notice distribute fair share of rewards to a gauge
    // @param _gauge the gauge to distribute rewards to
    function distribute(address _gauge) public lock {
        IMinter(minter).update_period();
        _updateFor(_gauge);
        uint _claimable = claimable[_gauge];
        if (_claimable > IGauge(_gauge).left(base) && _claimable / DURATION > 0) {
            claimable[_gauge] = 0;
            IGauge(_gauge).notifyRewardAmount(base, _claimable);
            emit DistributeReward(msg.sender, _gauge, _claimable);
        }
    }

    function distro() external {
        distributeRange(0, allGauges.length);
    }

    function distributeRange(uint start, uint finish) public {
        for (uint x = start; x < finish; x++) {
            try this.distribute(allGauges[x]) {
                emit GaugeProcessed(allGauges[x]);
            } catch {
                emit GaugeNotProcessed(allGauges[x]);
            }
        }
    }

    function distributeGauges(address[] memory _gauges) external {
        for (uint x = 0; x < _gauges.length; x++) {
            try this.distribute(_gauges[x]) {
                emit GaugeProcessed(allGauges[x]);
            } catch {
                emit GaugeNotProcessed(allGauges[x]);
            }
        }
    }

    // @notice current active vote period
    // @return the UNIX timestamp of the beginning of the current vote period
    function _activePeriod() internal view returns (uint activePeriod) {
        activePeriod = block.timestamp / DURATION * DURATION;
    }

    // @notice next vote period
    // @return the UNIX timestamp of the beginning of the next vote period
    function _nextPeriod() internal view returns(uint nextPeriod) {
        nextPeriod = (block.timestamp + DURATION) / DURATION * DURATION;
    }

    function _safeTransferFrom(address token, address from, address to, uint256 value) internal {
        require(token.code.length > 0);
        (bool success, bytes memory data) =
        token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))));
    }
}