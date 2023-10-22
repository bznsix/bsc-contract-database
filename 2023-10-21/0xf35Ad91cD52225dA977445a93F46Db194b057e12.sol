// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PancakeSwapper.sol";
// import "./PriceFeed.sol";

contract BLBSwap is Ownable, PancakeSwapper {

    constructor(
        uint256 _BLBsPerUSD,
        address _BLB,
        address _BUSD
    ) PancakeSwapper(_BLB, _BUSD) {
        setBLBsPerUSD(_BLBsPerUSD); 
    }

    event Swap(
        address indexed userAddr,
        string indexed tokenIn,
        string indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut 
    );

    function purchaseBLB(
        uint256 amountBUSD
    ) external payable returns(uint256 amountBLB) {

        address purchaser = msg.sender;
        uint256 amountBNB = msg.value;

        if(onPancake) {
            amountBLB = _purchaseBLB(purchaser, amountBUSD, amountBNB);
        } else {
            if(amountBUSD == 0) {
                amountBLB = BLBsForBNB(amountBNB);
                require(blbBalance() >= amountBLB, "insufficient BLB to pay");
                TransferHelper.safeTransfer(BLB, purchaser, amountBLB);
                emit Swap(purchaser, "BNB", "BLB", amountBNB, amountBLB);
            } else {
                require(amountBNB == 0, "not allowed to purchase in BUSD and BNB in sameTime");
                amountBLB = BLBsForUSD(amountBUSD);
                require(blbBalance() >= amountBLB, "insufficient BLB to pay");
                TransferHelper.safeTransferFrom(BUSD, purchaser, address(this), amountBUSD);
                TransferHelper.safeTransfer(BLB, purchaser, amountBLB);
                emit Swap(purchaser, "BUSD", "BLB", amountBUSD, amountBLB);
            }
        }
    }

    function sellBLB(
        uint256 amountBLB,
        bool toBUSD
    ) public returns(uint256 amountOut) {

        address seller = msg.sender;
        TransferHelper.safeTransferFrom(BLB, seller, address(this), amountBLB);

        if(onPancake) {
            _sellBLB(seller, amountBLB, toBUSD);
        } else {
            if(toBUSD) {
                amountOut = USDsForBLB(amountBLB);
                require(busdBalance() >= amountOut, "insufficient BUSD to pay");
                TransferHelper.safeTransfer(BUSD, seller, amountOut);
                emit Swap(seller, "BLB", "BUSD", amountBLB, amountOut);
            } else {
                amountOut = BNBsForBLB(amountBLB);
                require(bnbBalance() >= amountOut, "insufficient BNB to pay");
                payable(seller).transfer(amountOut);
                emit Swap(seller, "BLB", "BNB", amountBLB, amountOut);
            }
        }
    }

    function BLBsForUSD(uint256 amountBUSD) public view returns(uint256) {
        if(onPancake) {
            return _BLBsForUSD(amountBUSD);
        } else {
            return BLBsPerUSD * amountBUSD / 10 ** 18;
        }
    }

    function BLBsForBNB(uint256 amountBNB) public view returns(uint256) {
        if(onPancake) {
            return _BLBsForBNB(amountBNB);
        } else {
            return BLBsForUSD(amountBNB * BNB_BUSD() / 10 ** 18);
        }
    }

    function USDsForBLB(uint256 amountBLB) public view returns(uint256) {
        if(onPancake) {
            return _USDsForBLB(amountBLB);
        } else {
            return amountBLB * 10 ** 18 / BLBsPerUSD;
        }
    }

    function BNBsForBLB(uint256 amountBLB) public view returns(uint256) {
        if(onPancake) {
            return _BNBsForBLB(amountBLB);
        } else {
            return USDsForBLB(amountBLB) * BUSD_BNB() / 10 ** 18;
        }
    }

// administration ---------------------------------------------------------------------------------------

    uint256 public BLBsPerUSD;  //how much BLBs is earned for 1 USD.
    function setBLBsPerUSD(
        uint256 BLBsAmount
    ) public onlyOwner {
        BLBsPerUSD = BLBsAmount;
    }

    function blbBalance() public view returns(uint256) {
        return IERC20(BLB).balanceOf(address(this));
    }
    function busdBalance() public view returns(uint256) {
        return IERC20(BUSD).balanceOf(address(this));
    }
    function bnbBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function withdrawBLB(uint256 amount) public onlyOwner {
        IERC20(BLB).transfer(owner(), amount);
    }
    function withdrawBUSD(uint256 amount) public onlyOwner {
        IERC20(BUSD).transfer(owner(), amount);
    }
    function withdrawBNB(uint256 amount) public onlyOwner {
        payable(owner()).transfer(amount);
    }

    bool public onPancake;
    function setOnPancake() public onlyOwner {
        onPancake = onPancake ? false : true;
    }
    

// // testnet ------------------------------------------------------------------------------------------------------

//     function BUSD_BNB() public override view returns(uint256) {
//         uint256 chainID;
//         assembly{
//             chainID := chainid()
//         }
//         if(chainID == 97) {
//             return Test_USD_BNB();
//         }
//         return super.BUSD_BNB();
//     }

//     function BNB_BUSD() public override view returns(uint256) {
//         uint256 chainID;
//         assembly{
//             chainID := chainid()
//         }
//         if(chainID == 97) {
//             return Test_BNB_USD();
//         }
//         return super.BNB_BUSD();
//     }
}// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import '@pancakeswap/v3-core/contracts/interfaces/callback/IPancakeV3SwapCallback.sol';
import '@pancakeswap/v3-periphery/contracts/libraries/TransferHelper.sol';

interface IwERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
    function balanceOf(address _owner) external view returns(uint256);
}

interface IV3Factory {
    function getPool(address token0, address token1, uint24 fee) external view returns(address);
}

interface IV3PairPool {
    struct Slot0 {
        // the current price
        uint160 sqrtPriceX96;
        // the current tick
        int24 tick;
        // the most-recently updated index of the observations array
        uint16 observationIndex;
        // the current maximum number of observations that are being stored
        uint16 observationCardinality;
        // the next maximum number of observations to store, triggered in observations.write
        uint16 observationCardinalityNext;
        // the current protocol fee for token0 and token1,
        // 2 uint32 values store in a uint32 variable (fee/PROTOCOL_FEE_DENOMINATOR)
        uint32 feeProtocol;
        // whether the pool is locked
        bool unlocked;
    }
    function slot0() external view returns(Slot0 memory);
    function token0() external view returns(address);
    function token1() external view returns(address);
}

interface IV3SwapRouter is IPancakeV3SwapCallback {

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 amountOut;
        uint256 amountInMaximum;
    }
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}

library pricer {
    
    function getPrice0(uint256 sqrtPriceX96) internal pure returns(uint256) {
        uint256 denom = ((2 ** 96) ** 2);
        denom /= 10 ** 18;
        return (sqrtPriceX96 ** 2) / denom;
    }

    function getPrice1(uint256 sqrtPriceX96) internal pure returns(uint256) {
        uint256 denom = (sqrtPriceX96 ** 2) / 10 ** 18;
        return ((2 ** 96) ** 2) / denom;
    }
}

contract PancakeSwapper {
    using pricer for uint160;

    IV3SwapRouter internal constant swapRouter = IV3SwapRouter(0x13f4EA83D0bd40E75C8222255bc855a974568Dd4);
    IV3Factory internal constant factory = IV3Factory(0x0BFbCF9fa4f9C56B0F40a671Ad40E0805A091865);
    address internal constant wBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint24 internal constant poolFee = 500;
    address public BUSD;
    address public BLB;

    constructor(address _BLB, address _BUSD) {
        BLB = _BLB;
        BUSD = _BUSD;
    }

    function _BLBsForBNB(uint256 amountBNB) internal view returns(uint256) {
        return amountBNB * BNB_BLB() / 10 ** 18;
    }
    function _BLBsForUSD(uint256 amountBUSD) internal view returns(uint256) {
        return amountBUSD * BUSD_BLB() / 10 ** 18;
    }
    function _BNBsForBLB(uint256 amountBLB) internal view returns(uint256) {
        return amountBLB * BLB_BNB() / 10 ** 18;
    }
    function _USDsForBLB(uint256 amountBLB) internal view returns(uint256) {
        return amountBLB * BLB_BUSD() / 10 ** 18;
    }

    function BUSD_BNB() public virtual view returns(uint256) {
        IV3PairPool pool = IV3PairPool(factory.getPool(wBNB, BUSD, poolFee));
        (uint160 sqrtPriceX96) = pool.slot0().sqrtPriceX96;
        return pool.token0() == wBNB ? sqrtPriceX96.getPrice1() : sqrtPriceX96.getPrice0();
    }

    function BNB_BUSD() public virtual view returns(uint256) {
        IV3PairPool pool = IV3PairPool(factory.getPool(wBNB, BUSD, poolFee));
        (uint160 sqrtPriceX96) = pool.slot0().sqrtPriceX96;
        return pool.token0() == wBNB ? sqrtPriceX96.getPrice0() : sqrtPriceX96.getPrice1();
    }

    function BLB_BNB() public virtual view returns(uint256) {
        IV3PairPool pool = IV3PairPool(factory.getPool(BLB, wBNB, poolFee));
        (uint160 sqrtPriceX96) = pool.slot0().sqrtPriceX96;
        return pool.token0() == BLB ? sqrtPriceX96.getPrice0() : sqrtPriceX96.getPrice1();
    }

    function BNB_BLB() public virtual view returns(uint256) {
        IV3PairPool pool = IV3PairPool(factory.getPool(BLB, wBNB, poolFee));
        (uint160 sqrtPriceX96) = pool.slot0().sqrtPriceX96;
        return pool.token0() == BLB ? sqrtPriceX96.getPrice1() : sqrtPriceX96.getPrice0();
    }

    function BLB_BUSD() public virtual view returns(uint256) {
        return BLB_BNB() * BNB_BUSD() / 10 ** 18;
    }

    function BUSD_BLB() public virtual view returns(uint256) {
        return BUSD_BNB() * BNB_BLB() / 10 ** 18;
    }


    function _purchaseBLB(
        address userAddr,
        uint256 amountBUSD,
        uint256 amountBNB
    ) internal returns(uint256 amountBLB) {


        IV3SwapRouter.ExactInputParams memory params;

        if(amountBUSD == 0) {
            IwERC20 wbnb = IwERC20(wBNB);
            wbnb.deposit{value: amountBNB}();

            TransferHelper.safeApprove(wBNB, address(swapRouter), amountBNB);
            params = IV3SwapRouter.ExactInputParams({
                path: abi.encodePacked(wBNB, poolFee, BLB),
                recipient: userAddr,
                amountIn: amountBNB,
                amountOutMinimum: 0
            });

        } else {
            require(amountBNB == 0, "not allowed to purchase in BUSD and BNB in sameTime");
            TransferHelper.safeTransferFrom(BUSD, userAddr, address(this), amountBUSD);
            TransferHelper.safeApprove(BUSD, address(swapRouter), amountBUSD);
            
            params = IV3SwapRouter.ExactInputParams({
                path: abi.encodePacked(BUSD, poolFee, wBNB, poolFee, BLB),
                recipient: userAddr,
                amountIn: amountBUSD,
                amountOutMinimum: 0
            });
        }
        
        amountBLB = swapRouter.exactInput(params);
    }

    function _sellBLB(
        address userAddr,
        uint256 amountBLB,
        bool toBUSD
    ) internal returns(uint256 amountOut) {

        TransferHelper.safeTransferFrom(BLB, userAddr, address(this), amountBLB);
        TransferHelper.safeApprove(BLB, address(swapRouter), amountBLB);

        if(toBUSD) {
            IV3SwapRouter.ExactInputParams memory params = IV3SwapRouter.ExactInputParams({
                path: abi.encodePacked(BLB, poolFee, wBNB, poolFee, BUSD),
                recipient: userAddr,
                amountIn: amountBLB,
                amountOutMinimum: 0
            });

            amountOut = swapRouter.exactInput(params);

        } else {

            IV3SwapRouter.ExactInputParams memory params = IV3SwapRouter.ExactInputParams({
                path: abi.encodePacked(BLB, poolFee, wBNB),
                recipient: address(this),
                amountIn: amountBLB,
                amountOutMinimum: 0
            });

            amountOut = swapRouter.exactInput(params);
            IwERC20 wbnb = IwERC20(wBNB);
            wbnb.withdraw(amountOut);
            payable(userAddr).transfer(amountOut);
        }
    }

    receive() external payable{}
}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Callback for IPancakeV3PoolActions#swap
/// @notice Any contract that calls IPancakeV3PoolActions#swap must implement this interface
interface IPancakeV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IPancakeV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a PancakeV3Pool deployed by the canonical PancakeV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IPancakeV3PoolActions#swap call
    function pancakeV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

library TransferHelper {
    /// @notice Transfers tokens from the targeted address to the given destination
    /// @notice Errors with 'STF' if transfer fails
    /// @param token The contract address of the token to be transferred
    /// @param from The originating address from which the tokens will be transferred
    /// @param to The destination address of the transfer
    /// @param value The amount to be transferred
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    /// @notice Transfers tokens from msg.sender to a recipient
    /// @dev Errors with ST if transfer fails
    /// @param token The contract address of the token which will be transferred
    /// @param to The recipient of the transfer
    /// @param value The value of the transfer
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    /// @notice Approves the stipulated contract to spend the given allowance in the given token
    /// @dev Errors with 'SA' if transfer fails
    /// @param token The contract address of the token to be approved
    /// @param to The target of the approval
    /// @param value The amount of the given token the target will be allowed to spend
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    /// @notice Transfers ETH to the recipient address
    /// @dev Fails with `STE`
    /// @param to The destination of the transfer
    /// @param value The value to be transferred
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
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
