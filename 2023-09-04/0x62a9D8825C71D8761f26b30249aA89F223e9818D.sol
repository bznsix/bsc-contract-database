// SPDX-License-Identifier: BUSL
pragma solidity 0.8.19;

// dependencies
import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "@solmate/utils/SafeTransferLib.sol";

// libraries
import { LibTickMath } from "src/libraries/LibTickMath.sol";
import { IWNative } from "src/libraries/IWNative.sol";

// interfaces
import { IAVManagerV3Gateway } from "src/interfaces/IAVManagerV3Gateway.sol";
import { ICommonV3Pool } from "src/interfaces/ICommonV3Pool.sol";
import { AutomatedVaultManager } from "src/AutomatedVaultManager.sol";
import { PancakeV3Worker } from "src/workers/PancakeV3Worker.sol";

contract AVManagerV3Gateway is IAVManagerV3Gateway {
  using SafeTransferLib for ERC20;

  AutomatedVaultManager public immutable vaultManager;
  address public immutable wNativeToken;

  constructor(address _vaultManager, address _wNativeToken) {
    // sanity check
    AutomatedVaultManager(_vaultManager).vaultTokenImplementation();
    ERC20(_wNativeToken).decimals();

    vaultManager = AutomatedVaultManager(_vaultManager);
    wNativeToken = _wNativeToken;
  }

  function deposit(address _vaultToken, address _token, uint256 _amount, uint256 _minReceived)
    external
    returns (bytes memory _result)
  {
    if (_amount == 0) {
      revert AVManagerV3Gateway_InvalidInput();
    }

    // pull token
    ERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

    // approve AVManagerV3Gateway to vault manager
    ERC20(_token).safeApprove(address(vaultManager), _amount);

    // build deposit params
    AutomatedVaultManager.TokenAmount[] memory _depositParams = _getDepositParams(_token, _amount);
    _result = vaultManager.deposit(msg.sender, _vaultToken, _depositParams, _minReceived);
  }

  function depositETH(address _vaultToken, uint256 _minReceived) external payable returns (bytes memory _result) {
    if (msg.value == 0) {
      revert AVManagerV3Gateway_InvalidInput();
    }
    // convert native to wrap
    IWNative(wNativeToken).deposit{ value: msg.value }();

    // approve AVManagerV3Gateway to vault manager
    ERC20(wNativeToken).safeApprove(address(vaultManager), msg.value);

    // build deposit params
    AutomatedVaultManager.TokenAmount[] memory _depositParams = _getDepositParams(wNativeToken, msg.value);
    // deposit (check slippage inside here)
    _result = vaultManager.deposit(msg.sender, _vaultToken, _depositParams, _minReceived);
  }

  function withdrawMinimize(
    address _vaultToken,
    uint256 _shareToWithdraw,
    AutomatedVaultManager.TokenAmount[] calldata _minAmountOut
  ) external returns (AutomatedVaultManager.TokenAmount[] memory _result) {
    // withdraw
    _result = _withdraw(_vaultToken, _shareToWithdraw, _minAmountOut);
    // check native
    uint256 _length = _result.length;
    for (uint256 _i; _i < _length;) {
      if (_result[_i].token == wNativeToken) {
        IWNative(wNativeToken).withdraw(_result[_i].amount);
        SafeTransferLib.safeTransferETH(msg.sender, _result[_i].amount);
      } else {
        ERC20(_result[_i].token).safeTransfer(msg.sender, _result[_i].amount);
      }

      unchecked {
        ++_i;
      }
    }
  }

  function withdrawConvertAll(address _vaultToken, uint256 _shareToWithdraw, bool _zeroForOne, uint256 _minAmountOut)
    external
    returns (uint256 _amountOut)
  {
    // dump token0 <> token1
    address _worker = vaultManager.getWorker(_vaultToken);
    ERC20 _token0 = PancakeV3Worker(_worker).token0();
    ERC20 _token1 = PancakeV3Worker(_worker).token1();
    ICommonV3Pool _pool = PancakeV3Worker(_worker).pool();

    AutomatedVaultManager.TokenAmount[] memory _minAmountOuts = new AutomatedVaultManager.TokenAmount[](2);
    _minAmountOuts[0].token = address(_token0);
    _minAmountOuts[0].amount = 0;
    _minAmountOuts[1].token = address(_token1);
    _minAmountOuts[1].amount = 0;

    // withdraw
    _withdraw(_vaultToken, _shareToWithdraw, _minAmountOuts);

    ERC20 _tokenOut;
    uint256 _amountIn;
    if (_zeroForOne) {
      _tokenOut = _token1;
      _amountIn = _token0.balanceOf(address(this));
    } else {
      _tokenOut = _token0;
      _amountIn = _token1.balanceOf(address(this));
    }

    // skip swap when amount = 0
    if (_amountIn > 0) {
      _pool.swap(
        address(this),
        _zeroForOne,
        int256(_amountIn),
        _zeroForOne ? LibTickMath.MIN_SQRT_RATIO + 1 : LibTickMath.MAX_SQRT_RATIO - 1,
        abi.encode(address(_token0), address(_token1), _pool.fee())
      );
    }

    _amountOut = _tokenOut.balanceOf(address(this));
    if (_amountOut < _minAmountOut) {
      revert AVManagerV3Gateway_TooLittleReceived();
    }

    // check native
    // transfer to user
    if (address(_tokenOut) == wNativeToken) {
      IWNative(wNativeToken).withdraw(_amountOut);
      SafeTransferLib.safeTransferETH(msg.sender, _amountOut);
    } else {
      _tokenOut.safeTransfer(msg.sender, _amountOut);
    }
  }

  function _getDepositParams(address _token, uint256 _amount)
    internal
    pure
    returns (AutomatedVaultManager.TokenAmount[] memory)
  {
    AutomatedVaultManager.TokenAmount[] memory _depositParams = new AutomatedVaultManager.TokenAmount[](1);
    _depositParams[0] = AutomatedVaultManager.TokenAmount({ token: _token, amount: _amount });
    return _depositParams;
  }

  function pancakeV3SwapCallback(int256 _amount0Delta, int256 _amount1Delta, bytes calldata _data) external {
    (address _token0, address _token1, uint24 _fee) = abi.decode(_data, (address, address, uint24));
    address _pool = address(
      uint160(
        uint256(
          keccak256(
            abi.encodePacked(
              hex"ff",
              0x41ff9AA7e16B8B1a8a8dc4f0eFacd93D02d071c9,
              keccak256(abi.encode(_token0, _token1, _fee)),
              bytes32(0x6ce8eb472fa82df5469c6ab6d485f17c3ad13c8cd7af59b3d4a8026c5ce0f7e2)
            )
          )
        )
      )
    );

    if (msg.sender != _pool) {
      revert AVManagerV3Gateway_NotPool();
    }

    if (_amount0Delta > 0) {
      ERC20(_token0).safeTransfer(msg.sender, uint256(_amount0Delta));
    } else {
      ERC20(_token1).safeTransfer(msg.sender, uint256(_amount1Delta));
    }
  }

  function _withdraw(
    address _vaultToken,
    uint256 _shareToWithdraw,
    AutomatedVaultManager.TokenAmount[] memory _minAmountOuts
  ) internal returns (AutomatedVaultManager.TokenAmount[] memory _result) {
    // pull token
    ERC20(_vaultToken).safeTransferFrom(msg.sender, address(this), _shareToWithdraw);
    // withdraw
    _result = vaultManager.withdraw(_vaultToken, _shareToWithdraw, _minAmountOuts);
  }

  receive() external payable { }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {ERC20} from "../tokens/ERC20.sol";

/// @notice Safe ETH and ERC20 transfer library that gracefully handles missing return values.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/utils/SafeTransferLib.sol)
/// @dev Use with caution! Some functions in this library knowingly create dirty bits at the destination of the free memory pointer.
/// @dev Note that none of the functions in this library check that a token has code at all! That responsibility is delegated to the caller.
library SafeTransferLib {
    /*//////////////////////////////////////////////////////////////
                             ETH OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferETH(address to, uint256 amount) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Transfer the ETH and store if it succeeded or not.
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }

        require(success, "ETH_TRANSFER_FAILED");
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), from) // Append the "from" argument.
            mstore(add(freeMemoryPointer, 36), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 68), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 100 because the length of our calldata totals up like so: 4 + 32 * 3.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }

        require(success, "TRANSFER_FROM_FAILED");
    }

    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "TRANSFER_FAILED");
    }

    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;

        /// @solidity memory-safe-assembly
        assembly {
            // Get a pointer to some free memory.
            let freeMemoryPointer := mload(0x40)

            // Write the abi-encoded calldata into memory, beginning with the function selector.
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), to) // Append the "to" argument.
            mstore(add(freeMemoryPointer, 36), amount) // Append the "amount" argument.

            success := and(
                // Set success to whether the call reverted, if not we check it either
                // returned exactly 1 (can't just be non-zero data), or had no return data.
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                // We use 68 because the length of our calldata totals up like so: 4 + 32 * 2.
                // We use 0 and 32 to copy up to 32 bytes of return data into the scratch space.
                // Counterintuitively, this call must be positioned second to the or() call in the
                // surrounding and() call or else returndatasize() will be zero during the computation.
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }

        require(success, "APPROVE_FAILED");
    }
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

/// @title Math library for computing sqrt prices from ticks and vice versa
/// @notice Computes sqrt price for ticks of size 1.0001, i.e. sqrt(1.0001^tick) as fixed point Q64.96 numbers. Supports
/// prices between 2**-128 and 2**128
/// @dev Edit by Alpaca Finance to make it compatible with Solidity 0.8.19
/// @dev Previous code is commented out, find previous by "previous:" keyword
library LibTickMath {
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
    // previous: require(absTick <= uint256(MAX_TICK), "T");
    require(absTick <= uint256(int256(MAX_TICK)), "T");

    uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
    if (absTick & 0x2 != 0) {
      ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
    }
    if (absTick & 0x4 != 0) {
      ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
    }
    if (absTick & 0x8 != 0) {
      ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
    }
    if (absTick & 0x10 != 0) {
      ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
    }
    if (absTick & 0x20 != 0) {
      ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
    }
    if (absTick & 0x40 != 0) {
      ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
    }
    if (absTick & 0x80 != 0) {
      ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
    }
    if (absTick & 0x100 != 0) {
      ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
    }
    if (absTick & 0x200 != 0) {
      ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
    }
    if (absTick & 0x400 != 0) {
      ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
    }
    if (absTick & 0x800 != 0) {
      ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
    }
    if (absTick & 0x1000 != 0) {
      ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
    }
    if (absTick & 0x2000 != 0) {
      ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
    }
    if (absTick & 0x4000 != 0) {
      ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
    }
    if (absTick & 0x8000 != 0) {
      ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
    }
    if (absTick & 0x10000 != 0) {
      ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
    }
    if (absTick & 0x20000 != 0) {
      ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
    }
    if (absTick & 0x40000 != 0) {
      ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
    }
    if (absTick & 0x80000 != 0) {
      ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;
    }

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
// SPDX-License-Identifier: BUSL
pragma solidity 0.8.19;

interface IWNative {
  function deposit() external payable;

  function transfer(address to, uint256 value) external returns (bool);

  function withdraw(uint256) external;
}
// SPDX-License-Identifier: BUSL
pragma solidity 0.8.19;

import { AutomatedVaultManager } from "src/AutomatedVaultManager.sol";

interface IAVManagerV3Gateway {
  error AVManagerV3Gateway_InvalidInput();
  error AVManagerV3Gateway_InvalidAddress();
  error AVManagerV3Gateway_TooLittleReceived();
  error AVManagerV3Gateway_NotPool();

  function deposit(address _vaultToken, address _token, uint256 _amount, uint256 _minReceived)
    external
    returns (bytes memory _result);

  function depositETH(address _vaultToken, uint256 _minReceived) external payable returns (bytes memory _result);

  function withdrawMinimize(
    address _vaultToken,
    uint256 _shareToWithdraw,
    AutomatedVaultManager.TokenAmount[] calldata _minAmountOut
  ) external returns (AutomatedVaultManager.TokenAmount[] memory _result);

  function withdrawConvertAll(address _vaultToken, uint256 _shareToWithdraw, bool _zeroForOne, uint256 _minAmountOut)
    external
    returns (uint256 _amountOut);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ICommonV3Pool {
  struct Slot0 {
    uint160 sqrtPriceX96;
    int24 tick;
    uint16 observationIndex;
    uint16 observationCardinality;
    uint16 observationCardinalityNext;
    uint32 feeProtocol;
    bool unlocked;
  }

  function slot0()
    external
    view
    returns (
      uint160 sqrtPriceX96,
      int24 tick,
      uint16 observationIndex,
      uint16 observationCardinality,
      uint16 observationCardinalityNext,
      uint32 feeProtocol,
      bool unlocked
    );

  function token0() external view returns (address);

  function token1() external view returns (address);

  function fee() external view returns (uint24);

  function liquidity() external view returns (uint128);

  function tickSpacing() external view returns (int24);

  function tickBitmap(int16 index) external view returns (uint256);

  function ticks(int24 index)
    external
    view
    returns (
      uint128 liquidityGross,
      int128 liquidityNet,
      uint256 feeGrowthOutside0X128,
      uint256 feeGrowthOutside1X128,
      int56 tickCumulativeOutside,
      uint160 secondsPerLiquidityOutsideX128,
      uint32 secondsOutside,
      bool initialized
    );

  function swap(
    address recipient,
    bool zeroForOne,
    int256 amountSpecified,
    uint160 sqrtPriceLimitX96,
    bytes calldata data
  ) external returns (int256 amount0, int256 amount1);

  function feeGrowthGlobal0X128() external view returns (uint256);

  function feeGrowthGlobal1X128() external view returns (uint256);
}
// SPDX-License-Identifier: BUSL
pragma solidity 0.8.19;

// dependencies
import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "@solmate/utils/SafeTransferLib.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { Ownable2StepUpgradeable } from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import { ClonesUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/ClonesUpgradeable.sol";

// contracts
import { AutomatedVaultERC20 } from "src/AutomatedVaultERC20.sol";
import { BaseOracle } from "src/oracles/BaseOracle.sol";

// interfaces
import { IExecutor } from "src/interfaces/IExecutor.sol";
import { IVaultOracle } from "src/interfaces/IVaultOracle.sol";
import { IAutomatedVaultERC20 } from "src/interfaces/IAutomatedVaultERC20.sol";

// libraries
import { LibShareUtil } from "src/libraries/LibShareUtil.sol";
import { MAX_BPS } from "src/libraries/Constants.sol";

contract AutomatedVaultManager is Initializable, Ownable2StepUpgradeable, ReentrancyGuardUpgradeable {
  ///////////////
  // Libraries //
  ///////////////
  using SafeTransferLib for ERC20;
  using LibShareUtil for uint256;

  ////////////
  // Errors //
  ////////////
  error AutomatedVaultManager_InvalidMinAmountOut();
  error AutomatedVaultManager_TokenMismatch();
  error AutomatedVaultManager_VaultNotExist(address _vaultToken);
  error AutomatedVaultManager_WithdrawExceedBalance();
  error AutomatedVaultManager_Unauthorized();
  error AutomatedVaultManager_TooMuchEquityLoss();
  error AutomatedVaultManager_TooMuchLeverage();
  error AutomatedVaultManager_BelowMinimumDeposit();
  error AutomatedVaultManager_TooLittleReceived();
  error AutomatedVaultManager_TokenNotAllowed();
  error AutomatedVaultManager_InvalidParams();
  error AutomatedVaultManager_ExceedCapacity();
  error AutomatedVaultManager_EmergencyPaused();

  ////////////
  // Events //
  ////////////
  event LogOpenVault(address indexed _vaultToken, OpenVaultParams _vaultParams);
  event LogDeposit(
    address indexed _vaultToken,
    address indexed _user,
    TokenAmount[] _deposits,
    uint256 _shareReceived,
    uint256 _equityChanged
  );
  event LogWithdraw(
    address indexed _vaultToken,
    address indexed _user,
    uint256 _sharesWithdrawn,
    uint256 _withdrawFee,
    uint256 _equityChanged
  );
  event LogManage(address _vaultToken, bytes[] _executorParams, uint256 _equityBefore, uint256 _equityAfter);
  event LogSetVaultManager(address indexed _vaultToken, address _manager, bool _isOk);
  event LogSetAllowToken(address indexed _vaultToken, address _token, bool _isAllowed);
  event LogSetVaultTokenImplementation(address _prevImplementation, address _newImplementation);
  event LogSetToleranceBps(address _vaultToken, uint16 _toleranceBps);
  event LogSetMaxLeverage(address _vaultToken, uint8 _maxLeverage);
  event LogSetMinimumDeposit(address _vaultToken, uint32 _compressedMinimumDeposit);
  event LogSetManagementFeePerSec(address _vaultToken, uint32 _managementFeePerSec);
  event LogSetMangementFeeTreasury(address _managementFeeTreasury);
  event LogSetWithdrawalFeeTreasury(address _withdrawalFeeTreasury);
  event LogSetWithdrawalFeeBps(address _vaultToken, uint16 _withdrawalFeeBps);
  event LogSetCapacity(address _vaultToken, uint32 _compressedCapacity);
  event LogSetIsDepositPaused(address _vaultToken, bool _isPaused);
  event LogSetIsWithdrawPaused(address _vaultToken, bool _isPaused);
  event LogSetExemptWithdrawalFee(address _user, bool _isExempt);

  /////////////
  // Structs //
  /////////////
  struct TokenAmount {
    address token;
    uint256 amount;
  }

  struct VaultInfo {
    // === Slot 1 === // 160 + 32 + 32 + 8 + 16 + 8
    address worker;
    // Deposit
    uint32 compressedMinimumDeposit;
    uint32 compressedCapacity;
    bool isDepositPaused;
    // Withdraw
    uint16 withdrawalFeeBps;
    bool isWithdrawalPaused;
    // === Slot 2 === // 160 + 32 + 40
    address executor;
    // Management fee
    uint32 managementFeePerSec;
    uint40 lastManagementFeeCollectedAt;
    // === Slot 3 === // 160 + 16 + 8
    address vaultOracle;
    // Manage
    uint16 toleranceBps;
    uint8 maxLeverage;
  }

  ///////////////
  // Constants //
  ///////////////
  uint256 constant MAX_MANAGEMENT_FEE_PER_SEC = 10e16 / uint256(365 days); // 10% per year
  uint256 constant MINIMUM_DEPOSIT_SCALE = 1e16; // 0.01 USD
  uint256 constant CAPACITY_SCALE = 1e18; // 1 USD

  /////////////////////
  // State variables //
  /////////////////////
  address public vaultTokenImplementation;
  address public managementFeeTreasury;
  address public withdrawalFeeTreasury;
  /// @dev execution scope to tell downstream contracts (Bank, Worker, etc.)
  /// that current executor is acting on behalf of vault and can be trusted
  address public EXECUTOR_IN_SCOPE;

  mapping(address => VaultInfo) public vaultInfos; // vault's ERC20 address => vault info
  mapping(address => mapping(address => bool)) public isManager; // vault's ERC20 address => manager address => is manager
  mapping(address => mapping(address => bool)) public allowTokens; // vault's ERC20 address => token address => is allowed
  mapping(address => bool) public workerExisted; // worker address => is existed
  mapping(address => bool) public isExemptWithdrawalFee;

  ///////////////
  // Modifiers //
  ///////////////
  modifier collectManagementFee(address _vaultToken) {
    uint256 _lastCollectedFee = vaultInfos[_vaultToken].lastManagementFeeCollectedAt;
    if (block.timestamp > _lastCollectedFee) {
      uint256 _pendingFee = pendingManagementFee(_vaultToken);
      IAutomatedVaultERC20(_vaultToken).mint(managementFeeTreasury, _pendingFee);
      vaultInfos[_vaultToken].lastManagementFeeCollectedAt = uint40(block.timestamp);
    }
    _;
  }

  modifier onlyExistedVault(address _vaultToken) {
    if (vaultInfos[_vaultToken].worker == address(0)) {
      revert AutomatedVaultManager_VaultNotExist(_vaultToken);
    }
    _;
  }

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  function initialize(address _vaultTokenImplementation, address _managementFeeTreasury, address _withdrawalFeeTreasury)
    external
    initializer
  {
    if (
      _vaultTokenImplementation == address(0) || _managementFeeTreasury == address(0)
        || _withdrawalFeeTreasury == address(0)
    ) {
      revert AutomatedVaultManager_InvalidParams();
    }

    Ownable2StepUpgradeable.__Ownable2Step_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();

    vaultTokenImplementation = _vaultTokenImplementation;
    managementFeeTreasury = _managementFeeTreasury;
    withdrawalFeeTreasury = _withdrawalFeeTreasury;
  }

  /// @notice Calculate pending management fee
  /// @dev Return as share amount
  /// @param _vaultToken an address of vault token
  /// @return _pendingFee an amount of share pending for minting as a form of management fee
  function pendingManagementFee(address _vaultToken) public view returns (uint256 _pendingFee) {
    uint256 _lastCollectedFee = vaultInfos[_vaultToken].lastManagementFeeCollectedAt;

    if (block.timestamp > _lastCollectedFee) {
      unchecked {
        _pendingFee = (
          IAutomatedVaultERC20(_vaultToken).totalSupply() * vaultInfos[_vaultToken].managementFeePerSec
            * (block.timestamp - _lastCollectedFee)
        ) / 1e18;
      }
    }
  }

  function deposit(address _depositFor, address _vaultToken, TokenAmount[] calldata _depositParams, uint256 _minReceive)
    external
    onlyExistedVault(_vaultToken)
    collectManagementFee(_vaultToken)
    nonReentrant
    returns (bytes memory _result)
  {
    VaultInfo memory _cachedVaultInfo = vaultInfos[_vaultToken];

    if (_cachedVaultInfo.isDepositPaused) {
      revert AutomatedVaultManager_EmergencyPaused();
    }

    _pullTokens(_vaultToken, _cachedVaultInfo.executor, _depositParams);

    ///////////////////////////
    // Executor scope opened //
    ///////////////////////////
    EXECUTOR_IN_SCOPE = _cachedVaultInfo.executor;
    // Accrue interest and reinvest before execute to ensure fair interest and profit distribution
    IExecutor(_cachedVaultInfo.executor).onUpdate(_cachedVaultInfo.worker, _vaultToken);

    (uint256 _totalEquityBefore,) =
      IVaultOracle(_cachedVaultInfo.vaultOracle).getEquityAndDebt(_vaultToken, _cachedVaultInfo.worker);

    _result = IExecutor(_cachedVaultInfo.executor).onDeposit(_cachedVaultInfo.worker, _vaultToken);
    EXECUTOR_IN_SCOPE = address(0);
    ///////////////////////////
    // Executor scope closed //
    ///////////////////////////

    uint256 _equityChanged;
    {
      (uint256 _totalEquityAfter, uint256 _debtAfter) =
        IVaultOracle(_cachedVaultInfo.vaultOracle).getEquityAndDebt(_vaultToken, _cachedVaultInfo.worker);
      if (_totalEquityAfter + _debtAfter > _cachedVaultInfo.compressedCapacity * CAPACITY_SCALE) {
        revert AutomatedVaultManager_ExceedCapacity();
      }
      _equityChanged = _totalEquityAfter - _totalEquityBefore;
    }

    if (_equityChanged < _cachedVaultInfo.compressedMinimumDeposit * MINIMUM_DEPOSIT_SCALE) {
      revert AutomatedVaultManager_BelowMinimumDeposit();
    }

    uint256 _shareReceived =
      _equityChanged.valueToShare(IAutomatedVaultERC20(_vaultToken).totalSupply(), _totalEquityBefore);
    if (_shareReceived < _minReceive) {
      revert AutomatedVaultManager_TooLittleReceived();
    }
    IAutomatedVaultERC20(_vaultToken).mint(_depositFor, _shareReceived);

    emit LogDeposit(_vaultToken, _depositFor, _depositParams, _shareReceived, _equityChanged);
  }

  function manage(address _vaultToken, bytes[] calldata _executorParams)
    external
    collectManagementFee(_vaultToken)
    nonReentrant
    returns (bytes[] memory _result)
  {
    // 0. Validate
    if (!isManager[_vaultToken][msg.sender]) {
      revert AutomatedVaultManager_Unauthorized();
    }

    VaultInfo memory _cachedVaultInfo = vaultInfos[_vaultToken];

    ///////////////////////////
    // Executor scope opened //
    ///////////////////////////
    EXECUTOR_IN_SCOPE = _cachedVaultInfo.executor;
    // 1. Update the vault
    // Accrue interest and reinvest before execute to ensure fair interest and profit distribution
    IExecutor(_cachedVaultInfo.executor).onUpdate(_cachedVaultInfo.worker, _vaultToken);

    // 2. execute manage
    (uint256 _totalEquityBefore,) =
      IVaultOracle(_cachedVaultInfo.vaultOracle).getEquityAndDebt(_vaultToken, _cachedVaultInfo.worker);

    // Set executor execution scope (worker, vault token) so that we don't have to pass them through multicall
    IExecutor(_cachedVaultInfo.executor).setExecutionScope(_cachedVaultInfo.worker, _vaultToken);
    _result = IExecutor(_cachedVaultInfo.executor).multicall(_executorParams);
    IExecutor(_cachedVaultInfo.executor).sweepToWorker();
    IExecutor(_cachedVaultInfo.executor).setExecutionScope(address(0), address(0));

    EXECUTOR_IN_SCOPE = address(0);
    ///////////////////////////
    // Executor scope closed //
    ///////////////////////////

    // 3. Check equity loss < threshold
    (uint256 _totalEquityAfter, uint256 _debtAfter) =
      IVaultOracle(_cachedVaultInfo.vaultOracle).getEquityAndDebt(_vaultToken, _cachedVaultInfo.worker);

    // _totalEquityAfter  < _totalEquityBefore * _cachedVaultInfo.toleranceBps / MAX_BPS;
    if (_totalEquityAfter * MAX_BPS < _totalEquityBefore * _cachedVaultInfo.toleranceBps) {
      revert AutomatedVaultManager_TooMuchEquityLoss();
    }

    // 4. Check leverage exceed max leverage
    // (debt + equity) / equity > max leverage
    // debt + equity = max leverage * equity
    // debt = (max leverage * equity) - equity
    // debt = (leverage - 1) * equity
    if (_debtAfter > (_cachedVaultInfo.maxLeverage - 1) * _totalEquityAfter) {
      revert AutomatedVaultManager_TooMuchLeverage();
    }

    emit LogManage(_vaultToken, _executorParams, _totalEquityBefore, _totalEquityAfter);
  }

  function withdraw(address _vaultToken, uint256 _sharesToWithdraw, TokenAmount[] calldata _minAmountOuts)
    external
    onlyExistedVault(_vaultToken)
    collectManagementFee(_vaultToken)
    nonReentrant
    returns (AutomatedVaultManager.TokenAmount[] memory _results)
  {
    VaultInfo memory _cachedVaultInfo = vaultInfos[_vaultToken];

    if (_cachedVaultInfo.isWithdrawalPaused) {
      revert AutomatedVaultManager_EmergencyPaused();
    }

    // Revert if withdraw shares more than balance
    if (_sharesToWithdraw > IAutomatedVaultERC20(_vaultToken).balanceOf(msg.sender)) {
      revert AutomatedVaultManager_WithdrawExceedBalance();
    }

    uint256 _actualWithdrawAmount;
    // Safe to do unchecked because we already checked withdraw amount < balance and max bps won't overflow anyway
    unchecked {
      _actualWithdrawAmount = isExemptWithdrawalFee[msg.sender]
        ? _sharesToWithdraw
        : (_sharesToWithdraw * (MAX_BPS - _cachedVaultInfo.withdrawalFeeBps)) / MAX_BPS;
    }

    ///////////////////////////
    // Executor scope opened //
    ///////////////////////////
    EXECUTOR_IN_SCOPE = _cachedVaultInfo.executor;

    // Accrue interest and reinvest before execute to ensure fair interest and profit distribution
    IExecutor(_cachedVaultInfo.executor).onUpdate(_cachedVaultInfo.worker, _vaultToken);

    (uint256 _totalEquityBefore,) =
      IVaultOracle(_cachedVaultInfo.vaultOracle).getEquityAndDebt(_vaultToken, _cachedVaultInfo.worker);

    // Execute withdraw
    // Executor should send withdrawn funds back here to check slippage
    _results =
      IExecutor(_cachedVaultInfo.executor).onWithdraw(_cachedVaultInfo.worker, _vaultToken, _actualWithdrawAmount);

    EXECUTOR_IN_SCOPE = address(0);
    ///////////////////////////
    // Executor scope closed //
    ///////////////////////////

    uint256 _equityChanged;
    {
      (uint256 _totalEquityAfter,) =
        IVaultOracle(_cachedVaultInfo.vaultOracle).getEquityAndDebt(_vaultToken, _cachedVaultInfo.worker);
      _equityChanged = _totalEquityBefore - _totalEquityAfter;
    }

    uint256 _withdrawalFee;
    // Safe to do unchecked because _actualWithdrawAmount < _sharesToWithdraw from above
    unchecked {
      _withdrawalFee = _sharesToWithdraw - _actualWithdrawAmount;
    }

    // Burn shares per requested amount before transfer out
    IAutomatedVaultERC20(_vaultToken).burn(msg.sender, _sharesToWithdraw);
    // Mint withdrawal fee to withdrawal treasury
    if (_withdrawalFee != 0) {
      IAutomatedVaultERC20(_vaultToken).mint(withdrawalFeeTreasury, _withdrawalFee);
    }
    // Net shares changed would be `_actualWithdrawAmount`

    // Transfer withdrawn funds to user
    // Tokens should be transferred from executor to here during `onWithdraw`
    {
      uint256 _len = _results.length;
      if (_minAmountOuts.length < _len) {
        revert AutomatedVaultManager_InvalidMinAmountOut();
      }
      address _token;
      uint256 _amount;
      for (uint256 _i; _i < _len;) {
        _token = _results[_i].token;
        _amount = _results[_i].amount;

        // revert result token != min amount token
        if (_token != _minAmountOuts[_i].token) {
          revert AutomatedVaultManager_TokenMismatch();
        }

        // Check slippage
        if (_amount < _minAmountOuts[_i].amount) {
          revert AutomatedVaultManager_TooLittleReceived();
        }

        ERC20(_token).safeTransfer(msg.sender, _amount);
        unchecked {
          ++_i;
        }
      }
    }

    // Assume `tx.origin` is user for tracking purpose
    emit LogWithdraw(_vaultToken, tx.origin, _sharesToWithdraw, _withdrawalFee, _equityChanged);
  }

  /////////////////////
  // Admin functions //
  /////////////////////

  struct OpenVaultParams {
    address worker;
    address vaultOracle;
    address executor;
    uint32 compressedMinimumDeposit;
    uint32 compressedCapacity;
    uint32 managementFeePerSec;
    uint16 withdrawalFeeBps;
    uint16 toleranceBps;
    uint8 maxLeverage;
  }

  function openVault(string calldata _name, string calldata _symbol, OpenVaultParams calldata _params)
    external
    onlyOwner
    returns (address _vaultToken)
  {
    // Prevent duplicate worker between vaults
    if (workerExisted[_params.worker]) {
      revert AutomatedVaultManager_InvalidParams();
    }
    // Validate parameters
    _validateToleranceBps(_params.toleranceBps);
    _validateMaxLeverage(_params.maxLeverage);
    _validateMinimumDeposit(_params.compressedMinimumDeposit);
    _validateManagementFeePerSec(_params.managementFeePerSec);
    _validateWithdrawalFeeBps(_params.withdrawalFeeBps);
    // Sanity check oracle
    BaseOracle(_params.vaultOracle).maxPriceAge();
    // Sanity check executor
    if (IExecutor(_params.executor).vaultManager() != address(this)) {
      revert AutomatedVaultManager_InvalidParams();
    }

    // Deploy vault token with ERC-1167 minimal proxy
    _vaultToken = ClonesUpgradeable.clone(vaultTokenImplementation);
    AutomatedVaultERC20(_vaultToken).initialize(_name, _symbol);

    // Update states
    vaultInfos[_vaultToken] = VaultInfo({
      worker: _params.worker,
      vaultOracle: _params.vaultOracle,
      executor: _params.executor,
      compressedMinimumDeposit: _params.compressedMinimumDeposit,
      compressedCapacity: _params.compressedCapacity,
      isDepositPaused: false,
      withdrawalFeeBps: _params.withdrawalFeeBps,
      isWithdrawalPaused: false,
      managementFeePerSec: _params.managementFeePerSec,
      lastManagementFeeCollectedAt: uint40(block.timestamp),
      toleranceBps: _params.toleranceBps,
      maxLeverage: _params.maxLeverage
    });
    workerExisted[_params.worker] = true;

    emit LogOpenVault(_vaultToken, _params);
  }

  function setVaultTokenImplementation(address _implementation) external onlyOwner {
    emit LogSetVaultTokenImplementation(vaultTokenImplementation, _implementation);
    vaultTokenImplementation = _implementation;
  }

  function setManagementFeePerSec(address _vaultToken, uint32 _managementFeePerSec)
    external
    onlyOwner
    onlyExistedVault(_vaultToken)
  {
    _validateManagementFeePerSec(_managementFeePerSec);
    vaultInfos[_vaultToken].managementFeePerSec = _managementFeePerSec;

    emit LogSetManagementFeePerSec(_vaultToken, _managementFeePerSec);
  }

  function setManagementFeeTreasury(address _managementFeeTreasury) external onlyOwner {
    if (_managementFeeTreasury == address(0)) {
      revert AutomatedVaultManager_InvalidParams();
    }
    managementFeeTreasury = _managementFeeTreasury;

    emit LogSetMangementFeeTreasury(_managementFeeTreasury);
  }

  function setWithdrawalFeeTreasury(address _withdrawalFeeTreasury) external onlyOwner {
    if (_withdrawalFeeTreasury == address(0)) {
      revert AutomatedVaultManager_InvalidParams();
    }
    withdrawalFeeTreasury = _withdrawalFeeTreasury;
    emit LogSetWithdrawalFeeTreasury(_withdrawalFeeTreasury);
  }

  function setExemptWithdrawalFee(address _user, bool _isExempt) external onlyOwner {
    isExemptWithdrawalFee[_user] = _isExempt;
    emit LogSetExemptWithdrawalFee(_user, _isExempt);
  }

  //////////////////////////////
  // Per vault config setters //
  //////////////////////////////

  function setVaultManager(address _vaultToken, address _manager, bool _isOk) external onlyOwner {
    isManager[_vaultToken][_manager] = _isOk;
    emit LogSetVaultManager(_vaultToken, _manager, _isOk);
  }

  function setAllowToken(address _vaultToken, address _token, bool _isAllowed)
    external
    onlyOwner
    onlyExistedVault(_vaultToken)
  {
    allowTokens[_vaultToken][_token] = _isAllowed;

    emit LogSetAllowToken(_vaultToken, _token, _isAllowed);
  }

  function setToleranceBps(address _vaultToken, uint16 _toleranceBps) external onlyOwner onlyExistedVault(_vaultToken) {
    _validateToleranceBps(_toleranceBps);
    vaultInfos[_vaultToken].toleranceBps = _toleranceBps;

    emit LogSetToleranceBps(_vaultToken, _toleranceBps);
  }

  function setMaxLeverage(address _vaultToken, uint8 _maxLeverage) external onlyOwner onlyExistedVault(_vaultToken) {
    _validateMaxLeverage(_maxLeverage);
    vaultInfos[_vaultToken].maxLeverage = _maxLeverage;

    emit LogSetMaxLeverage(_vaultToken, _maxLeverage);
  }

  function setMinimumDeposit(address _vaultToken, uint32 _compressedMinimumDeposit)
    external
    onlyOwner
    onlyExistedVault(_vaultToken)
  {
    _validateMinimumDeposit(_compressedMinimumDeposit);
    vaultInfos[_vaultToken].compressedMinimumDeposit = _compressedMinimumDeposit;

    emit LogSetMinimumDeposit(_vaultToken, _compressedMinimumDeposit);
  }

  function setWithdrawalFeeBps(address _vaultToken, uint16 _withdrawalFeeBps)
    external
    onlyOwner
    onlyExistedVault(_vaultToken)
  {
    _validateWithdrawalFeeBps(_withdrawalFeeBps);
    vaultInfos[_vaultToken].withdrawalFeeBps = _withdrawalFeeBps;

    emit LogSetWithdrawalFeeBps(_vaultToken, _withdrawalFeeBps);
  }

  function setCapacity(address _vaultToken, uint32 _compressedCapacity)
    external
    onlyOwner
    onlyExistedVault(_vaultToken)
  {
    vaultInfos[_vaultToken].compressedCapacity = _compressedCapacity;
    emit LogSetCapacity(_vaultToken, _compressedCapacity);
  }

  function setIsDepositPaused(address[] calldata _vaultTokens, bool _isPaused) external onlyOwner {
    uint256 _len = _vaultTokens.length;
    for (uint256 _i; _i < _len;) {
      vaultInfos[_vaultTokens[_i]].isDepositPaused = _isPaused;
      emit LogSetIsDepositPaused(_vaultTokens[_i], _isPaused);
      unchecked {
        ++_i;
      }
    }
  }

  function setIsWithdrawPaused(address[] calldata _vaultTokens, bool _isPaused) external onlyOwner {
    uint256 _len = _vaultTokens.length;
    for (uint256 _i; _i < _len;) {
      vaultInfos[_vaultTokens[_i]].isWithdrawalPaused = _isPaused;
      emit LogSetIsWithdrawPaused(_vaultTokens[_i], _isPaused);
      unchecked {
        ++_i;
      }
    }
  }

  //////////////////////
  // Getter functions //
  //////////////////////

  function getWorker(address _vaultToken) external view returns (address _worker) {
    _worker = vaultInfos[_vaultToken].worker;
  }

  ///////////////////////
  // Private functions //
  ///////////////////////

  function _pullTokens(address _vaultToken, address _destination, TokenAmount[] calldata _deposits) internal {
    uint256 _depositLength = _deposits.length;
    for (uint256 _i; _i < _depositLength;) {
      if (!allowTokens[_vaultToken][_deposits[_i].token]) {
        revert AutomatedVaultManager_TokenNotAllowed();
      }
      ERC20(_deposits[_i].token).safeTransferFrom(msg.sender, _destination, _deposits[_i].amount);
      unchecked {
        ++_i;
      }
    }
  }

  /// @dev Valid value: withdrawalFeeBps <= 1000
  function _validateWithdrawalFeeBps(uint16 _withdrawalFeeBps) internal pure {
    if (_withdrawalFeeBps > 1000) {
      revert AutomatedVaultManager_InvalidParams();
    }
  }

  /// @dev Valid value range: 9500 <= toleranceBps <= 10000
  function _validateToleranceBps(uint16 _toleranceBps) internal pure {
    if (_toleranceBps > MAX_BPS || _toleranceBps < 9500) {
      revert AutomatedVaultManager_InvalidParams();
    }
  }

  /// @dev Valid value range: 1 <= maxLeverage <= 10
  function _validateMaxLeverage(uint8 _maxLeverage) internal pure {
    if (_maxLeverage > 10 || _maxLeverage < 1) {
      revert AutomatedVaultManager_InvalidParams();
    }
  }

  function _validateMinimumDeposit(uint32 _compressedMinimumDeposit) internal pure {
    if (_compressedMinimumDeposit == 0) {
      revert AutomatedVaultManager_InvalidParams();
    }
  }

  /// @dev Valid value range: 0 <= managementFeePerSec <= 10% per year
  function _validateManagementFeePerSec(uint32 _managementFeePerSec) internal pure {
    if (_managementFeePerSec > MAX_MANAGEMENT_FEE_PER_SEC) {
      revert AutomatedVaultManager_InvalidParams();
    }
  }
}
// SPDX-License-Identifier: BUSL
pragma solidity 0.8.19;

// dependencies
import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { SafeTransferLib } from "@solmate/utils/SafeTransferLib.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { Ownable2StepUpgradeable } from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

// interfaces
import { AutomatedVaultManager } from "src/AutomatedVaultManager.sol";
import { IZapV3 } from "src/interfaces/IZapV3.sol";
import { ICommonV3Pool } from "src/interfaces/ICommonV3Pool.sol";
import { ICommonV3PositionManager } from "src/interfaces/ICommonV3PositionManager.sol";
import { IPancakeV3Router } from "src/interfaces/pancake-v3/IPancakeV3Router.sol";
import { IPancakeV3MasterChef } from "src/interfaces/pancake-v3/IPancakeV3MasterChef.sol";

// libraries
import { LibTickMath } from "src/libraries/LibTickMath.sol";
import { MAX_BPS } from "src/libraries/Constants.sol";

contract PancakeV3Worker is Initializable, Ownable2StepUpgradeable, ReentrancyGuardUpgradeable {
  using SafeTransferLib for ERC20;

  error PancakeV3Worker_Unauthorized();
  error PancakeV3Worker_PositionExist();
  error PancakeV3Worker_PositionNotExist();
  error PancakeV3Worker_InvalidParams();

  ERC20 public token0;
  ERC20 public token1;

  // packed slot
  ICommonV3Pool public pool;
  uint24 public poolFee;
  int24 public posTickLower;
  int24 public posTickUpper;
  bool public isToken0Base;

  // packed slot
  address public performanceFeeBucket;
  uint16 public tradingPerformanceFeeBps;
  uint16 public rewardPerformanceFeeBps;
  uint40 public lastHarvest;

  uint256 public nftTokenId;

  IZapV3 public zapV3;
  ERC20 public cake;
  ICommonV3PositionManager public nftPositionManager;
  IPancakeV3Router public router;
  IPancakeV3MasterChef public masterChef;
  AutomatedVaultManager public vaultManager;

  mapping(address => bytes) public cakeToTokenPath;

  /// Modifier
  modifier onlyExecutorInScope() {
    if (msg.sender != vaultManager.EXECUTOR_IN_SCOPE()) {
      revert PancakeV3Worker_Unauthorized();
    }
    _;
  }

  /// Events
  event LogOpenPosition(
    uint256 indexed _tokenId,
    address _caller,
    int24 _tickLower,
    int24 _tickUpper,
    uint256 _amount0Increased,
    uint256 _amount1Increased
  );
  event LogIncreasePosition(
    uint256 indexed _tokenId,
    address _caller,
    int24 _tickLower,
    int24 _tickUpper,
    uint256 _amount0Increased,
    uint256 _amount1Increased
  );
  event LogClosePosition(
    uint256 indexed _tokenId, address _caller, uint256 _amount0Out, uint256 _amount1Out, uint128 _liquidityOut
  );
  event LogDecreasePosition(
    uint256 indexed _tokenId, address _caller, uint256 _amount0Out, uint256 _amount1Out, uint128 _liquidityOut
  );
  event LogHarvest(
    uint256 _token0Earned,
    uint256 _token1Earned,
    uint16 _tradingPerformanceFeeBps,
    uint256 _cakeEarned,
    uint16 _rewardPerformanceFeeBps
  );
  event LogTransferToExecutor(address indexed _token, address _to, uint256 _amount);
  event LogSetTradingPerformanceFee(uint16 _prevTradingPerformanceFeeBps, uint16 _newTradingPerformanceFeeBps);
  event LogSetRewardPerformanceFee(uint16 _prevRewardPerformanceFeeBps, uint16 _newRewardPerformanceFeeBps);
  event LogSetPerformanceFeeBucket(address _prevPerformanceFeeBucket, address _newPerformanceFeeBucket);
  event LogSetCakeToTokenPath(address _toToken, bytes _path);

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  struct ConstructorParams {
    address vaultManager;
    address positionManager;
    address pool;
    bool isToken0Base;
    address router;
    address masterChef;
    address zapV3;
    address performanceFeeBucket;
    uint16 tradingPerformanceFeeBps;
    uint16 rewardPerformanceFeeBps;
    bytes cakeToToken0Path;
    bytes cakeToToken1Path;
  }

  function initialize(ConstructorParams calldata _params) external initializer {
    Ownable2StepUpgradeable.__Ownable2Step_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();

    // Validate params
    // performance fee should not be more than 30%
    if (_params.tradingPerformanceFeeBps > 3000 || _params.rewardPerformanceFeeBps > 3000) {
      revert PancakeV3Worker_InvalidParams();
    }
    if (_params.performanceFeeBucket == address(0)) {
      revert PancakeV3Worker_InvalidParams();
    }
    // Sanity check
    AutomatedVaultManager(_params.vaultManager).vaultTokenImplementation();

    vaultManager = AutomatedVaultManager(_params.vaultManager);

    nftPositionManager = ICommonV3PositionManager(_params.positionManager);
    pool = ICommonV3Pool(_params.pool);
    isToken0Base = _params.isToken0Base;
    router = IPancakeV3Router(_params.router);
    masterChef = IPancakeV3MasterChef(_params.masterChef);
    poolFee = ICommonV3Pool(_params.pool).fee();
    token0 = ERC20(ICommonV3Pool(_params.pool).token0());
    token1 = ERC20(ICommonV3Pool(_params.pool).token1());
    cake = ERC20(IPancakeV3MasterChef(_params.masterChef).CAKE());

    zapV3 = IZapV3(_params.zapV3);

    tradingPerformanceFeeBps = _params.tradingPerformanceFeeBps;
    rewardPerformanceFeeBps = _params.rewardPerformanceFeeBps;
    performanceFeeBucket = _params.performanceFeeBucket;

    cakeToTokenPath[address(token0)] = _params.cakeToToken0Path;
    cakeToTokenPath[address(token1)] = _params.cakeToToken1Path;
  }

  /// @dev Can't open position for pool that doesn't have CAKE reward (masterChef pid == 0).
  function openPosition(int24 _tickLower, int24 _tickUpper, uint256 _amountIn0, uint256 _amountIn1)
    external
    nonReentrant
    onlyExecutorInScope
  {
    // Can't open position if already exist. Use `increasePosition` instead.
    if (nftTokenId != 0) {
      revert PancakeV3Worker_PositionExist();
    }
    {
      // Prevent open out-of-range position
      (, int24 _currTick,,,,,) = pool.slot0();
      if (_tickLower > _currTick || _currTick > _tickUpper) {
        revert PancakeV3Worker_InvalidParams();
      }
    }

    // SLOAD
    ERC20 _token0 = token0;
    ERC20 _token1 = token1;

    // Prepare optimal tokens for adding liquidity
    (uint256 _amount0Desired, uint256 _amount1Desired) = _prepareOptimalTokensForIncrease(
      address(_token0), address(_token1), _tickLower, _tickUpper, _amountIn0, _amountIn1
    );

    // SLOAD
    ICommonV3PositionManager _nftPositionManager = nftPositionManager;
    // Mint new position and stake it with masterchef
    _token0.safeApprove(address(_nftPositionManager), _amount0Desired);
    _token1.safeApprove(address(_nftPositionManager), _amount1Desired);
    (uint256 _nftTokenId,, uint256 _amount0, uint256 _amount1) = _nftPositionManager.mint(
      ICommonV3PositionManager.MintParams({
        token0: address(_token0),
        token1: address(_token1),
        fee: poolFee,
        tickLower: _tickLower,
        tickUpper: _tickUpper,
        amount0Desired: _amount0Desired,
        amount1Desired: _amount1Desired,
        amount0Min: 0,
        amount1Min: 0,
        recipient: address(this),
        deadline: block.timestamp
      })
    );

    // Update token id
    nftTokenId = _nftTokenId;

    // Stake to PancakeMasterChefV3
    // NOTE: masterChef won't accept transfer from nft that associate with pool that doesn't have masterChef pid
    // aka no CAKE reward
    _nftPositionManager.safeTransferFrom(address(this), address(masterChef), _nftTokenId);

    // Update worker ticks config
    posTickLower = _tickLower;
    posTickUpper = _tickUpper;

    emit LogOpenPosition(_nftTokenId, msg.sender, _tickLower, _tickUpper, _amount0, _amount1);
  }

  function increasePosition(uint256 _amountIn0, uint256 _amountIn1) external nonReentrant onlyExecutorInScope {
    // Can't increase position if position not exist. Use `openPosition` instead.
    if (nftTokenId == 0) {
      revert PancakeV3Worker_PositionNotExist();
    }

    // SLOAD
    ERC20 _token0 = token0;
    ERC20 _token1 = token1;
    int24 _tickLower = posTickLower;
    int24 _tickUpper = posTickUpper;

    // Prepare optimal tokens for adding liquidity
    (uint256 _amount0Desired, uint256 _amount1Desired) = _prepareOptimalTokensForIncrease(
      address(_token0), address(_token1), _tickLower, _tickUpper, _amountIn0, _amountIn1
    );

    // Increase existing position liquidity
    // SLOAD
    IPancakeV3MasterChef _masterChef = masterChef;
    uint256 _nftTokenId = nftTokenId;

    _token0.safeApprove(address(_masterChef), _amount0Desired);
    _token1.safeApprove(address(_masterChef), _amount1Desired);
    (, uint256 _amount0, uint256 _amount1) = _masterChef.increaseLiquidity(
      IPancakeV3MasterChef.IncreaseLiquidityParams({
        tokenId: _nftTokenId,
        amount0Desired: _amount0Desired,
        amount1Desired: _amount1Desired,
        amount0Min: 0,
        amount1Min: 0,
        deadline: block.timestamp
      })
    );

    emit LogIncreasePosition(_nftTokenId, msg.sender, _tickLower, _tickUpper, _amount0, _amount1);
  }

  function _prepareOptimalTokensForIncrease(
    address _token0,
    address _token1,
    int24 _tickLower,
    int24 _tickUpper,
    uint256 _amountIn0,
    uint256 _amountIn1
  ) internal returns (uint256 _amount0Desired, uint256 _amount1Desired) {
    // Revert if not enough balance
    if (ERC20(_token0).balanceOf(address(this)) < _amountIn0 || ERC20(_token1).balanceOf(address(this)) < _amountIn1) {
      revert PancakeV3Worker_InvalidParams();
    }
    (, int24 _currTick,,,,,) = pool.slot0();
    if (_tickLower <= _currTick && _currTick <= _tickUpper) {
      (_amount0Desired, _amount1Desired) = _prepareOptimalTokensForIncreaseInRange(
        address(_token0), address(_token1), _tickLower, _tickUpper, _amountIn0, _amountIn1
      );
    } else {
      (_amount0Desired, _amount1Desired) = _prepareOptimalTokensForIncreaseOutOfRange(
        address(_token0), address(_token1), _currTick, _tickLower, _tickUpper, _amountIn0, _amountIn1
      );
    }
  }

  function _prepareOptimalTokensForIncreaseInRange(
    address _token0,
    address _token1,
    int24 _tickLower,
    int24 _tickUpper,
    uint256 _amountIn0,
    uint256 _amountIn1
  ) internal returns (uint256 _optimalAmount0, uint256 _optimalAmount1) {
    // Calculate zap in amount and direction.
    (uint256 _amountSwap, uint256 _minAmountOut, bool _zeroForOne) = zapV3.calc(
      IZapV3.CalcParams({
        pool: address(pool),
        amountIn0: _amountIn0,
        amountIn1: _amountIn1,
        tickLower: _tickLower,
        tickUpper: _tickUpper
      })
    );

    // Find out tokenIn and tokenOut
    address _tokenIn;
    address _tokenOut;
    if (_zeroForOne) {
      _tokenIn = address(_token0);
      _tokenOut = address(_token1);
    } else {
      _tokenIn = address(_token1);
      _tokenOut = address(_token0);
    }

    // Swap
    ERC20(_tokenIn).safeApprove(address(router), _amountSwap);
    uint256 _amountOut = router.exactInputSingle(
      IPancakeV3Router.ExactInputSingleParams({
        tokenIn: _tokenIn,
        tokenOut: _tokenOut,
        fee: poolFee,
        recipient: address(this),
        amountIn: _amountSwap,
        amountOutMinimum: _minAmountOut,
        sqrtPriceLimitX96: 0
      })
    );

    if (_zeroForOne) {
      _optimalAmount0 = _amountIn0 - _amountSwap;
      _optimalAmount1 = _amountIn1 + _amountOut;
    } else {
      _optimalAmount0 = _amountIn0 + _amountOut;
      _optimalAmount1 = _amountIn1 - _amountSwap;
    }
  }

  function _prepareOptimalTokensForIncreaseOutOfRange(
    address _token0,
    address _token1,
    int24 _currTick,
    int24 _tickLower,
    int24 _tickUpper,
    uint256 _amountIn0,
    uint256 _amountIn1
  ) internal returns (uint256 _optimalAmount0, uint256 _optimalAmount1) {
    // If out of upper range (currTick > tickUpper), we swap token0 for token1
    // and vice versa, to push price closer to range.
    // We only want to swap until price move back in range so
    // we will swap until price hit the first tick within range.
    if (_currTick > _tickUpper) {
      if (_amountIn0 > 0) {
        uint256 _token0Before = ERC20(_token0).balanceOf(address(this));
        // zero for one swap
        ERC20(_token0).safeApprove(address(router), _amountIn0);
        uint256 _amountOut = router.exactInputSingle(
          IPancakeV3Router.ExactInputSingleParams({
            tokenIn: _token0,
            tokenOut: _token1,
            fee: poolFee,
            recipient: address(this),
            amountIn: _amountIn0,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: LibTickMath.getSqrtRatioAtTick(_tickUpper) - 1 // swap until passed upper tick
           })
        );
        // Update optimal amount
        _optimalAmount0 = _amountIn0 + ERC20(_token0).balanceOf(address(this)) - _token0Before;
        _optimalAmount1 = _amountIn1 + _amountOut;
      }
    } else {
      if (_amountIn1 > 0) {
        uint256 _token1Before = ERC20(_token1).balanceOf(address(this));
        // one for zero swap
        ERC20(_token1).safeApprove(address(router), _amountIn1);
        uint256 _amountOut = router.exactInputSingle(
          IPancakeV3Router.ExactInputSingleParams({
            tokenIn: _token1,
            tokenOut: _token0,
            fee: poolFee,
            recipient: address(this),
            amountIn: _amountIn1,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: LibTickMath.getSqrtRatioAtTick(_tickLower) + 1 // swap until passed lower tick
           })
        );
        // Update optimal amount
        _optimalAmount0 = _amountIn0 + _amountOut;
        _optimalAmount1 = _amountIn1 + ERC20(_token1).balanceOf(address(this)) - _token1Before;
      }
    }

    // Also prepare in range if tick is back in range after swap
    (, _currTick,,,,,) = pool.slot0();
    if (_tickLower <= _currTick && _currTick <= _tickUpper) {
      return _prepareOptimalTokensForIncreaseInRange(
        _token0, _token1, _tickLower, _tickUpper, _optimalAmount0, _optimalAmount1
      );
    }
  }

  /// @dev Closing position (burning NFT) requires NFT to be empty (no tokens, rewards remain).
  /// Executor should handle claiming rewards before closing position.
  function closePosition() external nonReentrant onlyExecutorInScope {
    uint256 _prevNftTokenId = nftTokenId;
    if (_prevNftTokenId == 0) {
      revert PancakeV3Worker_PositionNotExist();
    }

    // Reset nftTokenId
    nftTokenId = 0;

    IPancakeV3MasterChef _masterChef = masterChef;
    IPancakeV3MasterChef.UserPositionInfo memory _positionInfo = _masterChef.userPositionInfos(_prevNftTokenId);
    (uint256 _amount0, uint256 _amount1) = _decreaseLiquidity(_prevNftTokenId, _masterChef, _positionInfo.liquidity);
    _masterChef.burn(_prevNftTokenId);

    emit LogClosePosition(_prevNftTokenId, msg.sender, _amount0, _amount1, _positionInfo.liquidity);
  }

  function decreasePosition(uint128 _liquidity)
    external
    nonReentrant
    onlyExecutorInScope
    returns (uint256 _amount0, uint256 _amount1)
  {
    uint256 _nftTokenId = nftTokenId;
    if (_nftTokenId == 0) {
      revert PancakeV3Worker_PositionNotExist();
    }

    (_amount0, _amount1) = _decreaseLiquidity(_nftTokenId, masterChef, _liquidity);
  }

  function _decreaseLiquidity(uint256 _nftTokenId, IPancakeV3MasterChef _masterChef, uint128 _liquidity)
    internal
    returns (uint256 _amount0, uint256 _amount1)
  {
    // claim all rewards accrued before removing liquidity from LP
    _harvest();

    if (_liquidity != 0) {
      _masterChef.decreaseLiquidity(
        IPancakeV3MasterChef.DecreaseLiquidityParams({
          tokenId: _nftTokenId,
          liquidity: _liquidity,
          amount0Min: 0,
          amount1Min: 0,
          deadline: block.timestamp
        })
      );
      (_amount0, _amount1) = _masterChef.collect(
        IPancakeV3MasterChef.CollectParams({
          tokenId: _nftTokenId,
          recipient: address(this),
          amount0Max: type(uint128).max,
          amount1Max: type(uint128).max
        })
      );
      emit LogDecreasePosition(_nftTokenId, msg.sender, _amount0, _amount1, _liquidity);
    }
  }

  /// @notice claim trading fee and harvest reward from masterchef.
  /// @dev This is a routine for update worker state from pending rewards.
  function harvest() external {
    _harvest();
  }

  struct HarvestFeeLocalVars {
    uint256 fee0;
    uint256 fee1;
    uint256 cakeRewards;
    uint16 tradingPerformanceFeeBps;
    uint16 rewardPerformanceFeeBps;
  }

  /**
   * @dev Perform the actual claim and harvest.
   * 1. claim trading fee and harvest reward
   * 2. collect performance fee based
   */
  function _harvest() internal {
    // Skip harvest if already done before in same block
    if (block.timestamp == lastHarvest) return;
    lastHarvest = uint40(block.timestamp);

    uint256 _nftTokenId = nftTokenId;
    // If tokenId is 0, then nothing to harvest
    if (_nftTokenId == 0) return;

    HarvestFeeLocalVars memory _vars;

    // SLOADs
    address _performanceFeeBucket = performanceFeeBucket;
    ERC20 _token0 = token0;
    ERC20 _token1 = token1;
    ERC20 _cake = cake;
    IPancakeV3MasterChef _masterChef = masterChef;

    // Handle trading fee
    (_vars.fee0, _vars.fee1) = _masterChef.collect(
      IPancakeV3MasterChef.CollectParams({
        tokenId: _nftTokenId,
        recipient: address(this),
        amount0Max: type(uint128).max,
        amount1Max: type(uint128).max
      })
    );
    // Collect performance fee on collected trading fee
    _vars.tradingPerformanceFeeBps = tradingPerformanceFeeBps;
    if (_vars.fee0 > 0) {
      // Safe to unchecked because fee always less than MAX_BPS
      unchecked {
        _token0.safeTransfer(_performanceFeeBucket, _vars.fee0 * _vars.tradingPerformanceFeeBps / MAX_BPS);
      }
    }
    if (_vars.fee1 > 0) {
      // Safe to unchecked because fee always less than MAX_BPS
      unchecked {
        _token1.safeTransfer(_performanceFeeBucket, _vars.fee1 * _vars.tradingPerformanceFeeBps / MAX_BPS);
      }
    }

    // Handle CAKE rewards
    _vars.cakeRewards = _masterChef.harvest(_nftTokenId, address(this));
    if (_vars.cakeRewards > 0) {
      uint256 _cakePerformanceFee;
      // Collect CAKE performance fee
      // Safe to unchecked because fee always less than MAX_BPS
      unchecked {
        _vars.rewardPerformanceFeeBps = rewardPerformanceFeeBps;
        _cakePerformanceFee = _vars.cakeRewards * _vars.rewardPerformanceFeeBps / MAX_BPS;
        _cake.safeTransfer(_performanceFeeBucket, _cakePerformanceFee);
      }

      // Sell CAKE for token0 or token1, if any
      // Find out need to sell CAKE to which side by checking currTick
      (, int24 _currTick,,,,,) = pool.slot0();
      address _tokenOut = address(_token0);
      if (_currTick - posTickLower > posTickUpper - _currTick) {
        // If currTick is closer to tickUpper, then we will sell CAKE for token1
        _tokenOut = address(_token1);
      }

      if (_tokenOut != address(_cake)) {
        IPancakeV3Router _router = router;
        // Swap reward after fee to token0 or token1
        // Safe to unchecked because _cakePerformanceFee is always less than _vars.cakeRewards (see above)
        uint256 _swapAmount;
        unchecked {
          _swapAmount = _vars.cakeRewards - _cakePerformanceFee;
        }
        _cake.safeApprove(address(_router), _swapAmount);
        // Swap CAKE for token0 or token1 based on predefined v3 path
        _router.exactInput(
          IPancakeV3Router.ExactInputParams({
            path: cakeToTokenPath[_tokenOut],
            recipient: address(this),
            amountIn: _swapAmount,
            amountOutMinimum: 0
          })
        );
      }
    }

    emit LogHarvest(
      _vars.fee0, _vars.fee1, _vars.tradingPerformanceFeeBps, _vars.cakeRewards, _vars.rewardPerformanceFeeBps
    );
  }

  /// @notice Transfer undeployed token out
  /// @param _token Token to be transfered
  /// @param _amount The amount to transfer
  function transferToExecutor(address _token, uint256 _amount) external nonReentrant onlyExecutorInScope {
    if (_amount == 0) {
      revert PancakeV3Worker_InvalidParams();
    }
    // msg.sender is executor in scope
    ERC20(_token).safeTransfer(msg.sender, _amount);
    emit LogTransferToExecutor(_token, msg.sender, _amount);
  }

  /// =================
  /// Admin functions
  /// =================

  function setTradingPerformanceFee(uint16 _newTradingPerformanceFeeBps) external onlyOwner {
    // performance fee should not be more than 30%
    if (_newTradingPerformanceFeeBps > 3000) {
      revert PancakeV3Worker_InvalidParams();
    }
    emit LogSetTradingPerformanceFee(tradingPerformanceFeeBps, _newTradingPerformanceFeeBps);
    tradingPerformanceFeeBps = _newTradingPerformanceFeeBps;
  }

  function setRewardPerformanceFee(uint16 _newRewardPerformanceFeeBps) external onlyOwner {
    // performance fee should not be more than 30%
    if (_newRewardPerformanceFeeBps > 3000) {
      revert PancakeV3Worker_InvalidParams();
    }
    emit LogSetRewardPerformanceFee(rewardPerformanceFeeBps, _newRewardPerformanceFeeBps);
    rewardPerformanceFeeBps = _newRewardPerformanceFeeBps;
  }

  function setPerformanceFeeBucket(address _newPerformanceFeeBucket) external onlyOwner {
    if (_newPerformanceFeeBucket == address(0)) {
      revert PancakeV3Worker_InvalidParams();
    }
    emit LogSetPerformanceFeeBucket(performanceFeeBucket, _newPerformanceFeeBucket);
    performanceFeeBucket = _newPerformanceFeeBucket;
  }

  function setCakeToTokenPath(address _toToken, bytes calldata _path) external onlyOwner {
    // Revert if invalid length or first token is not cake or last token is not _toToken
    if (
      _path.length < 43 || address(bytes20(_path[:20])) != address(cake)
        || address(bytes20(_path[_path.length - 20:])) != _toToken
    ) {
      revert PancakeV3Worker_InvalidParams();
    }
    cakeToTokenPath[_toToken] = _path;
    emit LogSetCakeToTokenPath(_toToken, _path);
  }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)

pragma solidity ^0.8.0;

import "./OwnableUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2StepUpgradeable is Initializable, OwnableUpgradeable {
    function __Ownable2Step_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable2Step_init_unchained() internal onlyInitializing {
    }
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library ClonesUpgradeable {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt
    ) internal view returns (address predicted) {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}
// SPDX-License-Identifier: BUSL
pragma solidity 0.8.19;

import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract AutomatedVaultERC20 is ERC20, Initializable {
  address public vaultManager;

  error AutomatedVaultERC20_Unauthorized();

  modifier onlyVaultManager() {
    if (msg.sender != vaultManager) revert AutomatedVaultERC20_Unauthorized();
    _;
  }

  constructor() ERC20("", "", 18) {
    _disableInitializers();
  }

  function initialize(string calldata _name, string calldata _symbol) external initializer {
    name = _name;
    symbol = _symbol;
    vaultManager = msg.sender;
  }

  /// @notice Mint tokens. Only controller can call.
  /// @param _to Address to mint to.
  /// @param _amount Amount to mint.
  function mint(address _to, uint256 _amount) external onlyVaultManager {
    _mint(_to, _amount);
  }

  /// @notice Burn tokens. Only controller can call.
  /// @param _from Address to burn from.
  /// @param _amount Amount to burn.
  function burn(address _from, uint256 _amount) external onlyVaultManager {
    _burn(_from, _amount);
  }
}
// SPDX-License-Identifier: BUSL
pragma solidity 0.8.19;

// dependencies
import { Ownable2StepUpgradeable } from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import { SafeCastUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";

// interfaces
import { IChainlinkAggregator } from "src/interfaces/IChainlinkAggregator.sol";

abstract contract BaseOracle is Ownable2StepUpgradeable {
  /// Libraries
  using SafeCastUpgradeable for int256;

  /// Errors
  error BaseOracle_PriceTooOld();
  error BaseOracle_InvalidPrice();

  /// Events
  event LogSetMaxPriceAge(uint16 prevMaxPriceAge, uint16 maxPriceAge);
  event LogSetPriceFeedOf(address indexed token, address prevPriceFeed, address priceFeed);

  /// States
  uint16 public maxPriceAge;
  mapping(address => IChainlinkAggregator) public priceFeedOf;

  /// @notice Set price feed of a token.
  /// @param _token Token address.
  /// @param _newPriceFeed New price feed address.
  function setPriceFeedOf(address _token, address _newPriceFeed) external onlyOwner {
    // Sanity check
    IChainlinkAggregator(_newPriceFeed).latestRoundData();

    emit LogSetPriceFeedOf(_token, address(priceFeedOf[_token]), _newPriceFeed);
    priceFeedOf[_token] = IChainlinkAggregator(_newPriceFeed);
  }

  /// @notice Set max price age.
  /// @param _newMaxPriceAge Max price age in seconds.
  function setMaxPriceAge(uint16 _newMaxPriceAge) external onlyOwner {
    emit LogSetMaxPriceAge(maxPriceAge, _newMaxPriceAge);
    maxPriceAge = _newMaxPriceAge;
  }

  /// @notice Fetch token price from price feed. Revert if price too old or negative.
  /// @param _token Token address.
  /// @return _price Price of the token in 18 decimals.
  function _safeGetTokenPriceE18(address _token) internal view returns (uint256 _price) {
    // SLOAD
    IChainlinkAggregator _priceFeed = priceFeedOf[_token];
    (, int256 _answer,, uint256 _updatedAt,) = _priceFeed.latestRoundData();
    // Safe to use unchecked since `block.timestamp` will at least equal to `_updatedAt` in the same block
    // even somehow it underflows it would revert anyway
    unchecked {
      if (block.timestamp - _updatedAt > maxPriceAge) {
        revert BaseOracle_PriceTooOld();
      }
    }
    if (_answer <= 0) {
      revert BaseOracle_InvalidPrice();
    }
    // Normalize to 18 decimals
    return _answer.toUint256() * (10 ** (18 - _priceFeed.decimals()));
  }

  function getTokenPrice(address _token) external view returns (uint256 _price) {
    _price = _safeGetTokenPriceE18(_token);
  }
}
// SPDX-License-Identifier: BUSL
pragma solidity 0.8.19;

import { IMulticall } from "src/interfaces/IMulticall.sol";
import { AutomatedVaultManager } from "src/AutomatedVaultManager.sol";

interface IExecutor is IMulticall {
  function vaultManager() external view returns (address);

  function setExecutionScope(address _worker, address _vaultToken) external;

  function onDeposit(address _worker, address _vaultToken) external returns (bytes memory _result);

  function onWithdraw(address _worker, address _vaultToken, uint256 _sharesToWithdraw)
    external
    returns (AutomatedVaultManager.TokenAmount[] memory);

  function onUpdate(address _worker, address _vaultToken) external returns (bytes memory _result);

  function sweepToWorker() external;
}
// SPDX-License-Identifier: BUSL
pragma solidity 0.8.19;

interface IVaultOracle {
  function getEquityAndDebt(address _vaultToken, address _worker)
    external
    view
    returns (uint256 _equityUSD, uint256 _debtUSD);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { IERC20 } from "src/interfaces/IERC20.sol";

interface IAutomatedVaultERC20 is IERC20 {
  function mint(address _to, uint256 _amount) external;
  function burn(address _from, uint256 _amount) external;
}
// SPDX-License-Identifier: BUSL
pragma solidity 0.8.19;

import { LibFullMath } from "./LibFullMath.sol";

library LibShareUtil {
  function shareToValue(uint256 _shareAmount, uint256 _totalValue, uint256 _totalShare) internal pure returns (uint256) {
    if (_totalShare == 0) return _shareAmount;
    return LibFullMath.mulDiv(_shareAmount, _totalValue, _totalShare);
  }

  function valueToShare(uint256 _tokenAmount, uint256 _totalShare, uint256 _totalValue) internal pure returns (uint256) {
    if (_totalShare == 0) return _tokenAmount;
    return LibFullMath.mulDiv(_tokenAmount, _totalShare, _totalValue);
  }

  function valueToShareRoundingUp(uint256 _tokenAmount, uint256 _totalShare, uint256 _totalValue)
    internal
    pure
    returns (uint256)
  {
    uint256 _shares = valueToShare(_tokenAmount, _totalShare, _totalValue);
    uint256 _shareValues = shareToValue(_shares, _totalValue, _totalShare);
    if (_shareValues + 1 == _tokenAmount) {
      _shares += 1;
    }
    return _shares;
  }

  function shareToValueRoundingUp(uint256 _shareAmount, uint256 _totalValue, uint256 _totalShare)
    internal
    pure
    returns (uint256)
  {
    uint256 _values = shareToValue(_shareAmount, _totalValue, _totalShare);
    uint256 _valueShares = valueToShare(_values, _totalShare, _totalValue);
    if (_valueShares + 1 == _shareAmount) {
      _values += 1;
    }
    return _values;
  }
}
// SPDX-License-Identifier: BUSL
pragma solidity 0.8.19;

uint256 constant MAX_BPS = 10_000;
// SPDX-License-Identifier: BUSL
pragma solidity 0.8.19;

interface IZapV3 {
  struct CalcParams {
    address pool;
    uint256 amountIn0;
    uint256 amountIn1;
    int24 tickLower;
    int24 tickUpper;
  }

  function calc(CalcParams calldata params)
    external
    returns (uint256 swapAmount, uint256 expectAmountOut, bool isZeroForOne);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ICommonV3PositionManager {
  struct MintParams {
    address token0;
    address token1;
    uint24 fee;
    int24 tickLower;
    int24 tickUpper;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    address recipient;
    uint256 deadline;
  }

  function mint(MintParams calldata params)
    external
    payable
    returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);

  function positions(uint256 tokenId)
    external
    view
    returns (
      uint96 nonce,
      address operator,
      address token0,
      address token1,
      uint24 fee,
      int24 tickLower,
      int24 tickUpper,
      uint128 liquidity,
      uint256 feeGrowthInside0LastX128,
      uint256 feeGrowthInside1LastX128,
      uint128 tokensOwed0,
      uint128 tokensOwed1
    );

  struct CollectParams {
    uint256 tokenId;
    address recipient;
    uint128 amount0Max;
    uint128 amount1Max;
  }

  function collect(CollectParams calldata params) external returns (uint128 amount0, uint128 amount1);

  function safeTransferFrom(address from, address to, uint256 tokenId) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via PancakeSwap V3
interface IPancakeV3Router {
  struct ExactInputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
  }

  /// @notice Swaps `amountIn` of one token for as much as possible of another token
  /// @dev Setting `amountIn` to 0 will cause the contract to look up its own balance,
  /// and swap the entire amount, enabling contracts to send tokens before calling this function.
  /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
  /// @return amountOut The amount of the received token
  function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

  struct ExactInputParams {
    bytes path;
    address recipient;
    uint256 amountIn;
    uint256 amountOutMinimum;
  }

  /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
  /// @dev Setting `amountIn` to 0 will cause the contract to look up its own balance,
  /// and swap the entire amount, enabling contracts to send tokens before calling this function.
  /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
  /// @return amountOut The amount of the received token
  function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

  struct ExactOutputSingleParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    address recipient;
    uint256 amountOut;
    uint256 amountInMaximum;
    uint160 sqrtPriceLimitX96;
  }

  /// @notice Swaps as little as possible of one token for `amountOut` of another token
  /// that may remain in the router after the swap.
  /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
  /// @return amountIn The amount of the input token
  function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

  struct ExactOutputParams {
    bytes path;
    address recipient;
    uint256 amountOut;
    uint256 amountInMaximum;
  }

  /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
  /// that may remain in the router after the swap.
  /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
  /// @return amountIn The amount of the input token
  function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}
// SPDX-License-Identifier: BUSL
pragma solidity 0.8.19;

interface IPancakeV3MasterChef {
  function CAKE() external view returns (address);

  struct IncreaseLiquidityParams {
    uint256 tokenId;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
  }

  function increaseLiquidity(IncreaseLiquidityParams memory params)
    external
    payable
    returns (uint128 liquidity, uint256 amount0, uint256 amount1);

  struct DecreaseLiquidityParams {
    uint256 tokenId;
    uint128 liquidity;
    uint256 amount0Min;
    uint256 amount1Min;
    uint256 deadline;
  }

  function decreaseLiquidity(DecreaseLiquidityParams memory params) external returns (uint256 amount0, uint256 amount1);

  struct CollectParams {
    uint256 tokenId;
    address recipient;
    uint128 amount0Max;
    uint128 amount1Max;
  }

  function collect(CollectParams calldata params) external returns (uint256 amount0, uint256 amount1);

  function harvest(uint256 tokenId, address to) external returns (uint256);

  function updateLiquidity(uint256 tokenId) external;

  function withdraw(uint256 tokenId, address to) external returns (uint256);

  function sweepToken(address token, uint256 amountMinimum, address to) external;

  function burn(uint256 tokenId) external;

  struct UserPositionInfo {
    uint128 liquidity;
    uint128 boostLiquidity;
    int24 tickLower;
    int24 tickUpper;
    uint256 rewardGrowthInside;
    uint256 reward;
    address user;
    uint256 pid;
    uint256 boostMultiplier;
  }

  function userPositionInfos(uint256 tokenId) external view returns (UserPositionInfo memory);

  function pendingCake(uint256 _tokenId) external view returns (uint256 reward);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```solidity
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 *
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Returns the highest version that has been initialized. See {reinitializer}.
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Returns `true` if the contract is currently initializing. See {onlyInitializing}.
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/SafeCast.sol)
// This file was procedurally generated from scripts/generate/templates/SafeCast.js.

pragma solidity ^0.8.0;

/**
 * @dev Wrappers over Solidity's uintXX/intXX casting operators with added overflow
 * checks.
 *
 * Downcasting from uint256/int256 in Solidity does not revert on overflow. This can
 * easily result in undesired exploitation or bugs, since developers usually
 * assume that overflows raise errors. `SafeCast` restores this intuition by
 * reverting the transaction when such an operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * Can be combined with {SafeMath} and {SignedSafeMath} to extend it to smaller types, by performing
 * all math on `uint256` and `int256` and then downcasting.
 */
library SafeCastUpgradeable {
    /**
     * @dev Returns the downcasted uint248 from uint256, reverting on
     * overflow (when the input is greater than largest uint248).
     *
     * Counterpart to Solidity's `uint248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    /**
     * @dev Returns the downcasted uint240 from uint256, reverting on
     * overflow (when the input is greater than largest uint240).
     *
     * Counterpart to Solidity's `uint240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    /**
     * @dev Returns the downcasted uint232 from uint256, reverting on
     * overflow (when the input is greater than largest uint232).
     *
     * Counterpart to Solidity's `uint232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    /**
     * @dev Returns the downcasted uint224 from uint256, reverting on
     * overflow (when the input is greater than largest uint224).
     *
     * Counterpart to Solidity's `uint224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.2._
     */
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    /**
     * @dev Returns the downcasted uint216 from uint256, reverting on
     * overflow (when the input is greater than largest uint216).
     *
     * Counterpart to Solidity's `uint216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    /**
     * @dev Returns the downcasted uint208 from uint256, reverting on
     * overflow (when the input is greater than largest uint208).
     *
     * Counterpart to Solidity's `uint208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    /**
     * @dev Returns the downcasted uint200 from uint256, reverting on
     * overflow (when the input is greater than largest uint200).
     *
     * Counterpart to Solidity's `uint200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    /**
     * @dev Returns the downcasted uint192 from uint256, reverting on
     * overflow (when the input is greater than largest uint192).
     *
     * Counterpart to Solidity's `uint192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    /**
     * @dev Returns the downcasted uint184 from uint256, reverting on
     * overflow (when the input is greater than largest uint184).
     *
     * Counterpart to Solidity's `uint184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    /**
     * @dev Returns the downcasted uint176 from uint256, reverting on
     * overflow (when the input is greater than largest uint176).
     *
     * Counterpart to Solidity's `uint176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    /**
     * @dev Returns the downcasted uint168 from uint256, reverting on
     * overflow (when the input is greater than largest uint168).
     *
     * Counterpart to Solidity's `uint168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    /**
     * @dev Returns the downcasted uint160 from uint256, reverting on
     * overflow (when the input is greater than largest uint160).
     *
     * Counterpart to Solidity's `uint160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    /**
     * @dev Returns the downcasted uint152 from uint256, reverting on
     * overflow (when the input is greater than largest uint152).
     *
     * Counterpart to Solidity's `uint152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    /**
     * @dev Returns the downcasted uint144 from uint256, reverting on
     * overflow (when the input is greater than largest uint144).
     *
     * Counterpart to Solidity's `uint144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    /**
     * @dev Returns the downcasted uint136 from uint256, reverting on
     * overflow (when the input is greater than largest uint136).
     *
     * Counterpart to Solidity's `uint136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    /**
     * @dev Returns the downcasted uint128 from uint256, reverting on
     * overflow (when the input is greater than largest uint128).
     *
     * Counterpart to Solidity's `uint128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v2.5._
     */
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    /**
     * @dev Returns the downcasted uint120 from uint256, reverting on
     * overflow (when the input is greater than largest uint120).
     *
     * Counterpart to Solidity's `uint120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    /**
     * @dev Returns the downcasted uint112 from uint256, reverting on
     * overflow (when the input is greater than largest uint112).
     *
     * Counterpart to Solidity's `uint112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    /**
     * @dev Returns the downcasted uint104 from uint256, reverting on
     * overflow (when the input is greater than largest uint104).
     *
     * Counterpart to Solidity's `uint104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    /**
     * @dev Returns the downcasted uint96 from uint256, reverting on
     * overflow (when the input is greater than largest uint96).
     *
     * Counterpart to Solidity's `uint96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.2._
     */
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    /**
     * @dev Returns the downcasted uint88 from uint256, reverting on
     * overflow (when the input is greater than largest uint88).
     *
     * Counterpart to Solidity's `uint88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    /**
     * @dev Returns the downcasted uint80 from uint256, reverting on
     * overflow (when the input is greater than largest uint80).
     *
     * Counterpart to Solidity's `uint80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    /**
     * @dev Returns the downcasted uint72 from uint256, reverting on
     * overflow (when the input is greater than largest uint72).
     *
     * Counterpart to Solidity's `uint72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    /**
     * @dev Returns the downcasted uint64 from uint256, reverting on
     * overflow (when the input is greater than largest uint64).
     *
     * Counterpart to Solidity's `uint64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v2.5._
     */
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    /**
     * @dev Returns the downcasted uint56 from uint256, reverting on
     * overflow (when the input is greater than largest uint56).
     *
     * Counterpart to Solidity's `uint56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    /**
     * @dev Returns the downcasted uint48 from uint256, reverting on
     * overflow (when the input is greater than largest uint48).
     *
     * Counterpart to Solidity's `uint48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    /**
     * @dev Returns the downcasted uint40 from uint256, reverting on
     * overflow (when the input is greater than largest uint40).
     *
     * Counterpart to Solidity's `uint40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    /**
     * @dev Returns the downcasted uint32 from uint256, reverting on
     * overflow (when the input is greater than largest uint32).
     *
     * Counterpart to Solidity's `uint32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v2.5._
     */
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    /**
     * @dev Returns the downcasted uint24 from uint256, reverting on
     * overflow (when the input is greater than largest uint24).
     *
     * Counterpart to Solidity's `uint24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    /**
     * @dev Returns the downcasted uint16 from uint256, reverting on
     * overflow (when the input is greater than largest uint16).
     *
     * Counterpart to Solidity's `uint16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v2.5._
     */
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    /**
     * @dev Returns the downcasted uint8 from uint256, reverting on
     * overflow (when the input is greater than largest uint8).
     *
     * Counterpart to Solidity's `uint8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v2.5._
     */
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    /**
     * @dev Converts a signed int256 into an unsigned uint256.
     *
     * Requirements:
     *
     * - input must be greater than or equal to 0.
     *
     * _Available since v3.0._
     */
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    /**
     * @dev Returns the downcasted int248 from int256, reverting on
     * overflow (when the input is less than smallest int248 or
     * greater than largest int248).
     *
     * Counterpart to Solidity's `int248` operator.
     *
     * Requirements:
     *
     * - input must fit into 248 bits
     *
     * _Available since v4.7._
     */
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
    }

    /**
     * @dev Returns the downcasted int240 from int256, reverting on
     * overflow (when the input is less than smallest int240 or
     * greater than largest int240).
     *
     * Counterpart to Solidity's `int240` operator.
     *
     * Requirements:
     *
     * - input must fit into 240 bits
     *
     * _Available since v4.7._
     */
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
    }

    /**
     * @dev Returns the downcasted int232 from int256, reverting on
     * overflow (when the input is less than smallest int232 or
     * greater than largest int232).
     *
     * Counterpart to Solidity's `int232` operator.
     *
     * Requirements:
     *
     * - input must fit into 232 bits
     *
     * _Available since v4.7._
     */
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
    }

    /**
     * @dev Returns the downcasted int224 from int256, reverting on
     * overflow (when the input is less than smallest int224 or
     * greater than largest int224).
     *
     * Counterpart to Solidity's `int224` operator.
     *
     * Requirements:
     *
     * - input must fit into 224 bits
     *
     * _Available since v4.7._
     */
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
    }

    /**
     * @dev Returns the downcasted int216 from int256, reverting on
     * overflow (when the input is less than smallest int216 or
     * greater than largest int216).
     *
     * Counterpart to Solidity's `int216` operator.
     *
     * Requirements:
     *
     * - input must fit into 216 bits
     *
     * _Available since v4.7._
     */
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
    }

    /**
     * @dev Returns the downcasted int208 from int256, reverting on
     * overflow (when the input is less than smallest int208 or
     * greater than largest int208).
     *
     * Counterpart to Solidity's `int208` operator.
     *
     * Requirements:
     *
     * - input must fit into 208 bits
     *
     * _Available since v4.7._
     */
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
    }

    /**
     * @dev Returns the downcasted int200 from int256, reverting on
     * overflow (when the input is less than smallest int200 or
     * greater than largest int200).
     *
     * Counterpart to Solidity's `int200` operator.
     *
     * Requirements:
     *
     * - input must fit into 200 bits
     *
     * _Available since v4.7._
     */
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
    }

    /**
     * @dev Returns the downcasted int192 from int256, reverting on
     * overflow (when the input is less than smallest int192 or
     * greater than largest int192).
     *
     * Counterpart to Solidity's `int192` operator.
     *
     * Requirements:
     *
     * - input must fit into 192 bits
     *
     * _Available since v4.7._
     */
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
    }

    /**
     * @dev Returns the downcasted int184 from int256, reverting on
     * overflow (when the input is less than smallest int184 or
     * greater than largest int184).
     *
     * Counterpart to Solidity's `int184` operator.
     *
     * Requirements:
     *
     * - input must fit into 184 bits
     *
     * _Available since v4.7._
     */
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
    }

    /**
     * @dev Returns the downcasted int176 from int256, reverting on
     * overflow (when the input is less than smallest int176 or
     * greater than largest int176).
     *
     * Counterpart to Solidity's `int176` operator.
     *
     * Requirements:
     *
     * - input must fit into 176 bits
     *
     * _Available since v4.7._
     */
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
    }

    /**
     * @dev Returns the downcasted int168 from int256, reverting on
     * overflow (when the input is less than smallest int168 or
     * greater than largest int168).
     *
     * Counterpart to Solidity's `int168` operator.
     *
     * Requirements:
     *
     * - input must fit into 168 bits
     *
     * _Available since v4.7._
     */
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
    }

    /**
     * @dev Returns the downcasted int160 from int256, reverting on
     * overflow (when the input is less than smallest int160 or
     * greater than largest int160).
     *
     * Counterpart to Solidity's `int160` operator.
     *
     * Requirements:
     *
     * - input must fit into 160 bits
     *
     * _Available since v4.7._
     */
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
    }

    /**
     * @dev Returns the downcasted int152 from int256, reverting on
     * overflow (when the input is less than smallest int152 or
     * greater than largest int152).
     *
     * Counterpart to Solidity's `int152` operator.
     *
     * Requirements:
     *
     * - input must fit into 152 bits
     *
     * _Available since v4.7._
     */
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
    }

    /**
     * @dev Returns the downcasted int144 from int256, reverting on
     * overflow (when the input is less than smallest int144 or
     * greater than largest int144).
     *
     * Counterpart to Solidity's `int144` operator.
     *
     * Requirements:
     *
     * - input must fit into 144 bits
     *
     * _Available since v4.7._
     */
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
    }

    /**
     * @dev Returns the downcasted int136 from int256, reverting on
     * overflow (when the input is less than smallest int136 or
     * greater than largest int136).
     *
     * Counterpart to Solidity's `int136` operator.
     *
     * Requirements:
     *
     * - input must fit into 136 bits
     *
     * _Available since v4.7._
     */
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
    }

    /**
     * @dev Returns the downcasted int128 from int256, reverting on
     * overflow (when the input is less than smallest int128 or
     * greater than largest int128).
     *
     * Counterpart to Solidity's `int128` operator.
     *
     * Requirements:
     *
     * - input must fit into 128 bits
     *
     * _Available since v3.1._
     */
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
    }

    /**
     * @dev Returns the downcasted int120 from int256, reverting on
     * overflow (when the input is less than smallest int120 or
     * greater than largest int120).
     *
     * Counterpart to Solidity's `int120` operator.
     *
     * Requirements:
     *
     * - input must fit into 120 bits
     *
     * _Available since v4.7._
     */
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
    }

    /**
     * @dev Returns the downcasted int112 from int256, reverting on
     * overflow (when the input is less than smallest int112 or
     * greater than largest int112).
     *
     * Counterpart to Solidity's `int112` operator.
     *
     * Requirements:
     *
     * - input must fit into 112 bits
     *
     * _Available since v4.7._
     */
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
    }

    /**
     * @dev Returns the downcasted int104 from int256, reverting on
     * overflow (when the input is less than smallest int104 or
     * greater than largest int104).
     *
     * Counterpart to Solidity's `int104` operator.
     *
     * Requirements:
     *
     * - input must fit into 104 bits
     *
     * _Available since v4.7._
     */
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
    }

    /**
     * @dev Returns the downcasted int96 from int256, reverting on
     * overflow (when the input is less than smallest int96 or
     * greater than largest int96).
     *
     * Counterpart to Solidity's `int96` operator.
     *
     * Requirements:
     *
     * - input must fit into 96 bits
     *
     * _Available since v4.7._
     */
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
    }

    /**
     * @dev Returns the downcasted int88 from int256, reverting on
     * overflow (when the input is less than smallest int88 or
     * greater than largest int88).
     *
     * Counterpart to Solidity's `int88` operator.
     *
     * Requirements:
     *
     * - input must fit into 88 bits
     *
     * _Available since v4.7._
     */
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
    }

    /**
     * @dev Returns the downcasted int80 from int256, reverting on
     * overflow (when the input is less than smallest int80 or
     * greater than largest int80).
     *
     * Counterpart to Solidity's `int80` operator.
     *
     * Requirements:
     *
     * - input must fit into 80 bits
     *
     * _Available since v4.7._
     */
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
    }

    /**
     * @dev Returns the downcasted int72 from int256, reverting on
     * overflow (when the input is less than smallest int72 or
     * greater than largest int72).
     *
     * Counterpart to Solidity's `int72` operator.
     *
     * Requirements:
     *
     * - input must fit into 72 bits
     *
     * _Available since v4.7._
     */
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
    }

    /**
     * @dev Returns the downcasted int64 from int256, reverting on
     * overflow (when the input is less than smallest int64 or
     * greater than largest int64).
     *
     * Counterpart to Solidity's `int64` operator.
     *
     * Requirements:
     *
     * - input must fit into 64 bits
     *
     * _Available since v3.1._
     */
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
    }

    /**
     * @dev Returns the downcasted int56 from int256, reverting on
     * overflow (when the input is less than smallest int56 or
     * greater than largest int56).
     *
     * Counterpart to Solidity's `int56` operator.
     *
     * Requirements:
     *
     * - input must fit into 56 bits
     *
     * _Available since v4.7._
     */
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
    }

    /**
     * @dev Returns the downcasted int48 from int256, reverting on
     * overflow (when the input is less than smallest int48 or
     * greater than largest int48).
     *
     * Counterpart to Solidity's `int48` operator.
     *
     * Requirements:
     *
     * - input must fit into 48 bits
     *
     * _Available since v4.7._
     */
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
    }

    /**
     * @dev Returns the downcasted int40 from int256, reverting on
     * overflow (when the input is less than smallest int40 or
     * greater than largest int40).
     *
     * Counterpart to Solidity's `int40` operator.
     *
     * Requirements:
     *
     * - input must fit into 40 bits
     *
     * _Available since v4.7._
     */
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
    }

    /**
     * @dev Returns the downcasted int32 from int256, reverting on
     * overflow (when the input is less than smallest int32 or
     * greater than largest int32).
     *
     * Counterpart to Solidity's `int32` operator.
     *
     * Requirements:
     *
     * - input must fit into 32 bits
     *
     * _Available since v3.1._
     */
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
    }

    /**
     * @dev Returns the downcasted int24 from int256, reverting on
     * overflow (when the input is less than smallest int24 or
     * greater than largest int24).
     *
     * Counterpart to Solidity's `int24` operator.
     *
     * Requirements:
     *
     * - input must fit into 24 bits
     *
     * _Available since v4.7._
     */
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
    }

    /**
     * @dev Returns the downcasted int16 from int256, reverting on
     * overflow (when the input is less than smallest int16 or
     * greater than largest int16).
     *
     * Counterpart to Solidity's `int16` operator.
     *
     * Requirements:
     *
     * - input must fit into 16 bits
     *
     * _Available since v3.1._
     */
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
    }

    /**
     * @dev Returns the downcasted int8 from int256, reverting on
     * overflow (when the input is less than smallest int8 or
     * greater than largest int8).
     *
     * Counterpart to Solidity's `int8` operator.
     *
     * Requirements:
     *
     * - input must fit into 8 bits
     *
     * _Available since v3.1._
     */
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     *
     * _Available since v3.0._
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        // Note: Unsafe cast below is okay because `type(int256).max` is guaranteed to be positive
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IChainlinkAggregator {
  function decimals() external view returns (uint8);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
// SPDX-License-Identifier: BUSL
pragma solidity 0.8.19;

interface IMulticall {
  function multicall(bytes[] calldata data) external returns (bytes[] memory results);
}
// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

/// @dev Interface of the ERC20 standard as defined in the EIP.
/// @dev This includes the optional name, symbol, and decimals metadata.
interface IERC20 {
  /// @dev Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
  event Transfer(address indexed from, address indexed to, uint256 value);

  /// @dev Emitted when the allowance of a `spender` for an `owner` is set, where `value`
  /// is the new allowance.
  event Approval(address indexed owner, address indexed spender, uint256 value);

  /// @notice Returns the amount of tokens in existence.
  function totalSupply() external view returns (uint256);

  /// @notice Returns the amount of tokens owned by `account`.
  function balanceOf(address account) external view returns (uint256);

  /// @notice Moves `amount` tokens from the caller's account to `to`.
  function transfer(address to, uint256 amount) external returns (bool);

  /// @notice Returns the remaining number of tokens that `spender` is allowed
  /// to spend on behalf of `owner`
  function allowance(address owner, address spender) external view returns (uint256);

  /// @notice Sets `amount` as the allowance of `spender` over the caller's tokens.
  /// @dev Be aware of front-running risks: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
  function approve(address spender, uint256 amount) external returns (bool);

  /// @notice Moves `amount` tokens from `from` to `to` using the allowance mechanism.
  /// `amount` is then deducted from the caller's allowance.
  function transferFrom(address from, address to, uint256 amount) external returns (bool);

  /// @notice Returns the name of the token.
  function name() external view returns (string memory);

  /// @notice Returns the symbol of the token.
  function symbol() external view returns (string memory);

  /// @notice Returns the decimals places of the token.
  function decimals() external view returns (uint8);
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
/// @dev Edit by Alpaca Finance to make it compatible with Solidity 0.8.19
/// @dev Previous code is commented out, find previous by "previous:" keyword
library LibFullMath {
  /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
  /// @param a The multiplicand
  /// @param b The multiplier
  /// @param denominator The divisor
  /// @return result The 256-bit result
  /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
  function mulDiv(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
    // previous: no unchecked
    unchecked {
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
      // previous: uint256 twos = -denominator & denominator;
      uint256 twos = denominator & (~denominator + 1);
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
    }
    return result;
  }

  /// @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
  /// @param a The multiplicand
  /// @param b The multiplier
  /// @param denominator The divisor
  /// @return result The 256-bit result
  function mulDivRoundingUp(uint256 a, uint256 b, uint256 denominator) internal pure returns (uint256 result) {
    result = mulDiv(a, b, denominator);
    // previous: no unchecked
    unchecked {
      if (mulmod(a, b, denominator) > 0) {
        require(result < type(uint256).max);
        result++;
      }
    }
  }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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
