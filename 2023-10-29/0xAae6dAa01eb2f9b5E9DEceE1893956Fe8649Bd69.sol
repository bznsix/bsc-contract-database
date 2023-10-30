// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

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
    function mulDiv(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
        // 512-bit multiply [prod1 prod0] = a * b
        // Compute the product mod 2**256 and mod 2**256 - 1
        // then use the Chinese Remainder Theorem to reconstruct
        // the 512 bit result. The result is stored in two 256
        // variables such that product = prod1 * 2**256 + prod0
        uint256 prod0; // Least significant 256 bits of the product
        uint256 prod1; // Most significant 256 bits of the product
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
        uint256 twos = -denominator & denominator;
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

    /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    /// @param a The multiplicand
    /// @param b The multiplier
    /// @param denominator The divisor
    /// @return result The 256-bit result
    function mulDivRoundingUp(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
        result = mulDiv(a, b, denominator);
        if (mulmod(a, b, denominator) > 0) {
            require(result < type(uint256).max);
            result++;
        }
    }
}

/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128
library TickMath {
    /// @dev The minimum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**-128
    int24 internal constant MIN_TICK = -887272;
    /// @dev The maximum tick that may be passed to #getSqrtRatioAtTick computed from log base 1.0001 of 2**128
    int24 internal constant MAX_TICK = -MIN_TICK;

    /// @dev The minimum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MIN_TICK)
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    /// @dev The maximum value that can be returned from #getSqrtRatioAtTick. Equivalent to getSqrtRatioAtTick(MAX_TICK)
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    /// @notice Calculates sqrt(1.0001^tick) * 2^96
    /// @dev Throws if |tick| > max tick
    /// @param tick The input tick for the above formula
    /// @return sqrtPriceX96 A Fixed point Q64.96 number representing the sqrt of the ratio of the two assets (token1/token0)
    /// at the given tick
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        require(absTick <= uint256(MAX_TICK), "T");

        uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        // this divides by 1<<32 rounding up to go from a Q128.128 to a Q128.96.
        // we then downcast because we know the result always fits within 160 bits due to our tick input constraint
        // we round up in the division so getTickAtSqrtRatio of the output price is always consistent
        sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
    }

    /// @notice Calculates the greatest tick value such that getRatioAtTick(tick) <= ratio
    /// @dev Throws in case sqrtPriceX96 < MIN_SQRT_RATIO, as MIN_SQRT_RATIO is the lowest value getRatioAtTick may
    /// ever return.
    /// @param sqrtPriceX96 The sqrt ratio for which to compute the tick as a Q64.96
    /// @return tick The greatest tick for which the ratio is less than or equal to the input ratio
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        // second inequality must be < because the price can never reach the price at the max tick
        require(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO, "R");
        uint256 ratio = uint256(sqrtPriceX96) << 32;

        uint256 r = ratio;
        uint256 msb = 0;

        assembly {
            let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(5, gt(r, 0xFFFFFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(4, gt(r, 0xFFFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(3, gt(r, 0xFF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(2, gt(r, 0xF))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := shl(1, gt(r, 0x3))
            msb := or(msb, f)
            r := shr(f, r)
        }
        assembly {
            let f := gt(r, 0x1)
            msb := or(msb, f)
        }

        if (msb >= 128) r = ratio >> (msb - 127);
        else r = ratio << (127 - msb);

        int256 log_2 = (int256(msb) - 128) << 64;

        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(63, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(62, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(61, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(60, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(59, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(58, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(57, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(56, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(55, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(54, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(53, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(52, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(51, f))
            r := shr(f, r)
        }
        assembly {
            r := shr(127, mul(r, r))
            let f := shr(128, r)
            log_2 := or(log_2, shl(50, f))
        }

        int256 log_sqrt10001 = log_2 * 255738958999603826347141; // 128.128 number

        int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
        int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);

        tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
    }
}

library OracleLibrary {
    function getQuoteAtTick(int24 tick, uint128 baseAmount, address baseToken, address quoteToken)
        internal
        pure
        returns (uint256 quoteAmount)
    {
        uint160 sqrtRatioX96 = TickMath.getSqrtRatioAtTick(tick);

        // Calculate quoteAmount with better precision if it doesn't overflow when multiplied by itself
        if (sqrtRatioX96 <= type(uint128).max) {
            uint256 ratioX192 = uint256(sqrtRatioX96) * sqrtRatioX96;
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX192, baseAmount, 1 << 192)
                : FullMath.mulDiv(1 << 192, baseAmount, ratioX192);
        } else {
            uint256 ratioX128 = FullMath.mulDiv(sqrtRatioX96, sqrtRatioX96, 1 << 64);
            quoteAmount = baseToken < quoteToken
                ? FullMath.mulDiv(ratioX128, baseAmount, 1 << 128)
                : FullMath.mulDiv(1 << 128, baseAmount, ratioX128);
        }
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a + b;require(c >= a, "SafeMath: addition overflow");return c;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return sub(a, b, "SafeMath: subtraction overflow");}
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {require(b <= a, errorMessage);uint256 c = a - b; return c;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {if (a == 0) {return 0;}uint256 c = a * b;require(c / a == b, "SafeMath: multiplication overflow");return c;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return div(a, b, "SafeMath: division by zero");}
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {require(b > 0, errorMessage);uint256 c = a / b;return c;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return mod(a, b, "SafeMath: modulo by zero");}
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) { require(b != 0, errorMessage);return a % b;}
}

pragma abicoder v2;
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IPancakeV3PoolState {
    function slot0() external view returns (
        uint160 sqrtPriceX96,
        int24 tick,
        uint16 observationIndex,
        uint16 observationCardinality,
        uint16 observationCardinalityNext,
        uint32 feeProtocol,
        bool unlocked
    );
}

contract KoreaAmc {
    using SafeMath for uint256;
    IPancakeV3PoolState public pool;
    IERC20 public usdt;
    IERC20 public amc;
    struct OBJInviter {
        address a;
        bool b;
    }
    mapping(address => uint256) _level; 
    mapping(address => uint256) _joinTime; 
    mapping(address => uint256) _upTime; 
    mapping(address => address[]) _inviters; 
    mapping(address => address) public _userTop; 
    mapping(address => bool) public _isjoin; 
    mapping(address => uint256) addupStcBalance; 
    mapping(address => uint256) addupDynBalance; 
    mapping(address => uint256) atmBalance; 

    mapping(address => uint256) totalRateBalance; 
    mapping(address => uint256) stcRateBalance; 
    mapping(address => uint256) dynRateBalance; 

   
    uint256[9] _rate = [15,12,10,8,8,8,6,6,6];
    uint256[4] _levelRate = [0,8,9,10];
    uint256[4] _joinAmt = [0,500e18,1000e18,2000e18];
    uint256[4] _joinAmtMax = [0,1500e18,3000e18,6000e18];
    address _rewardAddr; 
    address _zero; 
    uint256 _oneday;

    
    struct OBJreg {
        address user;
        address father;
        uint256 timer;
    }
    OBJreg[] public regList;

    struct OBJorder{
        address _user;
        uint256 _total;
        uint256 _usdt;
        uint256 _amc;
        uint256 _timer;
    }
    OBJorder[] public orders;

    bool isReward;
    modifier localReward {
        isReward = true;
        _;
        isReward = false;
    }
    constructor(){
        usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
        amc = IERC20(0x299142a6370e1912156E53fBD4f25D7ba49DdcC5);
        pool = IPancakeV3PoolState(0xC1fEb3e2E411f82BC5892328C17B36B45a1A64c1);
        _zero = address(0x520731EC399dBd5AEAA799C733402734187054FA);
        _rewardAddr = address(0x129BD3b9f5ce720E70025827c7d568529949b464);
        _oneday = 86400;
    }
        
    function getAmount(uint256 _u) view private returns(uint256){
        (, int24 tick,,,,,) = pool.slot0();
        return OracleLibrary.getQuoteAtTick(tick, uint128(_u), address(usdt), address(amc));
    }

    event bidLog(address user, address father, uint256 timer);
    function register(address _father) public {
        address _user = msg.sender;
        require(_father != address(0),"reg father invalid");
        require(!_isCt(_user) && (tx.origin == _user), "reg address error");
        require(_userTop[_user] == address(0),"reg bound error");
        require(_father != _user,"father == me");
        require(_user != _zero,"user == zero node");
        require(_isjoin[_father] || _zero == _father,"father is out");
        _userTop[_user] = _father;
        _inviters[_father].push(_user);
        regList.push(OBJreg(_user, _father, block.timestamp));
        emit bidLog(_user, _father, block.timestamp);
    }

    event joinLog(address indexed _u,uint256 _total, 
                uint256 _usdt, uint256 _amc,uint _time);
    function join(uint256 _index) external {
        require(_index > 0 && _index < 4, "join index error");
        address _user = msg.sender;
        uint256 _time = block.timestamp;
        require(_userTop[_user] != address(0),"join father invalid");
        require(!_isjoin[_user],"address not out");
        
        require(_level[_user] <= _index,"join level error");
        delete addupStcBalance[_user];
        delete addupDynBalance[_user];
        _joinTime[_user] = _time;
        _level[_user] = _index;
        _upTime[_user] = _time;
        _isjoin[_user] = true;
       
        uint256 toUsdt = _joinAmt[_index].mul(70).div(100);
        uint256 toAmc = getAmount(uint128(_joinAmt[_index].mul(30).div(100)));
        require(usdt.transferFrom(_user, address(this), toUsdt),"transfer usdt error");
        require(amc.transferFrom(_user, address(this), toAmc),"transfer amc error");
        orders.push(OBJorder(_user, _joinAmt[_index], toUsdt, toAmc, _time));
        emit joinLog(_user, _joinAmt[_index], toUsdt, toAmc, _time);
    }
    function getUserInivters() view external returns(OBJInviter[] memory obj){
        address _user = msg.sender;
        uint256 len = _inviters[_user].length;
        obj = new OBJInviter[](len);
        if(len == 0)return obj;
        for (uint256 index = 0; index < len; index++) {
            obj[index] = OBJInviter(_inviters[_user][index],_isjoin[_inviters[_user][index]]);
        }
    }
    
    function getUserRate(address _user) view external returns(
        uint256 sRate, uint256 remain, uint256 stcRate, uint256 dynRate,
        uint256 totalRate, uint256 totalStc, uint256 totalDyn,
        uint256 atmRate, uint256 joinTime, uint256 level
    ){
        sRate = _sRateDay(_user); 
        remain = _calc_remain(_user);
        stcRate = addupStcBalance[_user]; 
        dynRate = addupDynBalance[_user]; 

        totalRate = totalRateBalance[_user]; 
        totalStc = stcRateBalance[_user]; 
        totalDyn = dynRateBalance[_user];

        atmRate = atmBalance[_user]; 
        joinTime = _joinTime[_user]; 
        level = _level[_user]; 
    }

    function _sRateDay(address _user) view private returns(uint256 x){
        uint256 a = _calc_sRate(_user);
        uint256 b = _calc_remain(_user);
        x =  a > b ? b : a;
    }

    function _calc_remain(address _user) view private returns(uint256 x){
        x =  _isjoin[_user] ? (_joinAmtMax[_level[_user]].sub(
            addupStcBalance[_user] + addupDynBalance[_user]
        )):0;
    }
    
    function _calc_sRate(address _user) view private returns(uint256 x){
        uint256 _lUser = _joinAmt[_level[_user]].mul(_levelRate[_level[_user]]).div(1000);
        uint256 t = _calc_day(_user);
        x = _isjoin[_user] ? (_lUser.mul(t)) : 0;
    }

    function _calc_day(address _user) view private returns(uint256 x){
        uint256 _bt = block.timestamp - _upTime[_user];
        x = _bt < _oneday ? 0 : ((_bt % _oneday) == 0 ? _bt/_oneday : (_bt - (_bt % _oneday))/_oneday);
    }

    function _calc_recom(address _user) view private returns(uint256 x){
        uint256 len = _inviters[_user].length;
        if(len == 0)return 0;
        for (uint256 i = 0; i < len; i++) {
            if(_isjoin[_inviters[_user][i]])x++;
        }
    }

    event calcStcLog(address _user, uint256 _amt, uint256 _order_time, uint256 _uptime);
    function calcUserRate() external {
        address _user = msg.sender;
        uint256 _tempRate = _calc_sRate(_user);
        uint256 _updateTime = _upTime[_user].add(_calc_day(_user).mul(_oneday));
        require(_isjoin[_user],"you not join");
        require(_tempRate > 0, "you not rate");
        uint256 _allRate = _tempRate.add(addupStcBalance[_user].add(addupDynBalance[_user]));
        if(_allRate >= _joinAmtMax[_level[_user]]){
            _tempRate = _calc_remain(_user);

            stcRateBalance[_user] += _tempRate;
            totalRateBalance[_user] +=_tempRate;
            atmBalance[_user] += _tempRate;
            if(!isReward)_dynReward(_user,_tempRate);

            addupStcBalance[_user] = 0;
            addupDynBalance[_user] = 0;
            _upTime[_user] = _updateTime;
            _isjoin[_user] = false;
            emit calcStcLog(_user, _tempRate, _updateTime, block.timestamp);
            return;
        }
        addupStcBalance[_user] += _tempRate;
        stcRateBalance[_user] += _tempRate;
        totalRateBalance[_user] +=_tempRate;
        atmBalance[_user] += _tempRate;
        _upTime[_user] = _updateTime;
        if(!isReward)_dynReward(_user,_tempRate);
        emit calcStcLog(_user, _tempRate, _updateTime, block.timestamp);
    }
    event calcDynLog(address _from, address _to, uint256 _amt, uint256 _uptime);
    function _dynReward(address _user, uint256 _amount) private localReward{
        address _nowUser = _userTop[_user];
        if(_amount <= 0)return;
        for (uint256 i = 0; i < _rate.length; i++) {
            if(_nowUser == address(0))break;
            if(!_isjoin[_nowUser] || _calc_recom(_nowUser) < i+1){
                _nowUser = _userTop[_nowUser];
                continue;
            }
            uint256 _amt = _amount.mul(_rate[i]).div(100);
            uint256 _surRate = _calc_remain(_nowUser);
            if(_amt >= _surRate){
                uint256 _updateTime = _upTime[_nowUser].add(_calc_day(_nowUser).mul(_oneday));
                dynRateBalance[_nowUser] += _surRate;
                totalRateBalance[_nowUser] +=_surRate;
                atmBalance[_nowUser] += _surRate;

                addupStcBalance[_nowUser] = 0;
                addupDynBalance[_nowUser] = 0;
                _upTime[_nowUser] = _updateTime;
                _isjoin[_nowUser] = false;
                emit calcDynLog(_user, _nowUser, _surRate, block.timestamp);
                _nowUser = _userTop[_nowUser];
                continue;
            }
            addupDynBalance[_nowUser] += _amt;
            dynRateBalance[_nowUser] += _amt;
            totalRateBalance[_nowUser] += _amt;
            atmBalance[_nowUser] += _amt;
            emit calcDynLog(_user, _nowUser, _amt, block.timestamp);
            _nowUser = _userTop[_nowUser];
        }
    }

    function atmUserRate(uint256 _usda, bool _is) external {
        address _user = msg.sender;
        require(!_isCt(_user) && (tx.origin == _user), "atm address error");
        uint256 _atmAmt = atmBalance[_user];
        require(_atmAmt > 0 && _usda > 0,"atm balance zero");
        require(_usda <= _atmAmt, "atm out of range");
        if(_is){
            atmBalance[_user] = _atmAmt.sub(_usda);
            require(usdt.transfer(_user, _usda.mul(97).div(100)),"atm usdt error0");
            require(usdt.transfer(_rewardAddr, _usda.mul(3).div(100)),"atm usdt error1");
        }else{
            atmBalance[_user] = _atmAmt.sub(_usda);
            uint256 to_amc = getAmount(uint128(_usda));
            require(amc.transfer(_user, to_amc.mul(97).div(100)),"atm amc error0");
            require(amc.transfer(_rewardAddr, to_amc.mul(3).div(100)),"atm amc error1");
        }
    }

    function _isCt(address account) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
