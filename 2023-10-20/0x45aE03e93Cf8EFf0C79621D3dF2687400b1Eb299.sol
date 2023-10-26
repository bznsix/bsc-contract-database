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
pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
pragma solidity >=0.5.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}
// SPDX-License-Identifier: MIT

pragma solidity >=0.8.17;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

contract EGSmartRouter is Ownable {
    using TransferHelper for address;
    address public routerAddress;
    address public WETH;

    address public burnAddress;
    uint public burnFee;

    address public treasuryAddress;
    uint public treasuryFee;

    receive() external payable {}

    constructor(address _routerAddress) {
        require(
            _routerAddress != address(0),
            "EGSwapSmartRouter: zero address"
        );
        routerAddress = _routerAddress;
        WETH = IUniswapV2Router02(routerAddress).WETH();
    }

    function setBurnAddress(address _burnAddress) external onlyOwner {
        require(_burnAddress != address(0), "EGSwapSmartRouter: zero address");
        burnAddress = _burnAddress;
    }

    function setTreasuryAddress(address _treasuryAddress) external onlyOwner {
        require(
            _treasuryAddress != address(0),
            "EGSwapSmartRouter: zero address"
        );
        treasuryAddress = _treasuryAddress;
    }

    // range [0 ~ 99999], 125 means 0.125%
    function setBurnFee(uint _burnFee) external onlyOwner {
        burnFee = _burnFee;
    }

    // range [0 ~ 99999], 125 means 0.125%
    function setTreasuryFee(uint _treasuryFee) external onlyOwner {
        treasuryFee = _treasuryFee;
    }

    function calcBurnFee(uint256 amount) public view returns (uint256) {
        return (amount * burnFee) / 100000;
    }

    function calcTreasuryFee(uint256 amount) public view returns (uint256) {
        return (amount * treasuryFee) / 100000;
    }

    function calcRouterFee(uint256 amount) public view returns (uint256) {
        return calcBurnFee(amount) + calcTreasuryFee(amount);
    }

    function transferToTreasury(
        address token,
        uint256 amount,
        uint deadline,
        bool fee
    ) internal {
        require(amount > 0, "EGSwapSmartRouter: zero amount");
        require(
            IERC20(token).balanceOf(address(this)) >= amount,
            "EGSwapSmartRouter: insufficient balance to treasury"
        );

        // if pair(token, WETH) exists, swap to WETH  pancakeswap and transfer to trasury address
        if (
            IUniswapV2Factory(IUniswapV2Router02(routerAddress).factory())
                .getPair(token, WETH) == address(0)
        ) {
            token.safeTransfer(treasuryAddress, amount);
        } else {
            token.safeApprove(routerAddress, amount);
            address[] memory path = new address[](2);
            path[0] = token;
            path[1] = WETH;
            if (fee) {
                IUniswapV2Router02(routerAddress)
                    .swapExactTokensForETHSupportingFeeOnTransferTokens(
                        amount,
                        0,
                        path,
                        treasuryAddress,
                        deadline
                    );
            } else {
                IUniswapV2Router02(routerAddress).swapExactTokensForETH(
                    amount,
                    0,
                    path,
                    treasuryAddress,
                    deadline
                );
            }
        }
    }

    function transferToBurn(address token, uint256 amount) internal {
        require(amount > 0, "EGSwapSmartRouter: zero amount");
        require(
            IERC20(token).balanceOf(address(this)) >= amount,
            "EGSwapSmartRouter: insufficient balance to burn"
        );

        token.safeTransfer(burnAddress, amount);
    }

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) public view returns (uint[] memory amounts) {
        return
            IUniswapV2Router02(routerAddress).getAmountsOut(
                amountIn - calcRouterFee(amountIn),
                path
            );
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        require(path.length >= 2, "EGSwapSmartRouter: invalid path");

        amounts = getAmountsOut(amountIn, path);
        require(
            amounts[0] == amountIn - calcRouterFee(amountIn),
            "EGSwapSmartRouter: invalid fee calculation"
        );

        address tokenIn = path[0];
        tokenIn.safeTransferFrom(msg.sender, address(this), amountIn);

        tokenIn.safeApprove(routerAddress, amounts[0]);
        IUniswapV2Router02(routerAddress).swapExactTokensForTokens(
            amounts[0],
            amountOutMin,
            path,
            to,
            deadline
        );

        if (burnFee > 0) {
            // transfer to burn address
            transferToBurn(tokenIn, calcBurnFee(amountIn));
        }
        if (treasuryFee > 0) {
            // transfer to treasury address
            transferToTreasury(tokenIn, calcTreasuryFee(amountIn), deadline, false);
        }
    }

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        require(
            path.length >= 2 && path[path.length - 1] == WETH,
            "EGSwapSmartRouter: invalid path"
        );

        amounts = getAmountsOut(amountIn, path);
        require(
            amounts[0] == amountIn - calcRouterFee(amountIn),
            "EGSwapSmartRouter: invalid fee calculation"
        );

        address tokenIn = path[0];
        tokenIn.safeTransferFrom(msg.sender, address(this), amountIn);

        tokenIn.safeApprove(routerAddress, amounts[0]);
        IUniswapV2Router02(routerAddress).swapExactTokensForETH(
            amounts[0],
            amountOutMin,
            path,
            to,
            deadline
        );

        if (burnFee > 0) {
            // transfer to burn address
            transferToBurn(tokenIn, calcBurnFee(amountIn));
        }
        if (treasuryFee > 0) {
            // transfer to treasury address
            transferToTreasury(tokenIn, calcTreasuryFee(amountIn), deadline, false);
        }
    }

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts) {
        require(
            path.length >= 2 && path[0] == WETH,
            "EGSwapSmartRouter: invalid path"
        );

        uint amountIn = msg.value;

        amounts = getAmountsOut(amountIn, path);
        require(
            amounts[0] == amountIn - calcRouterFee(amountIn),
            "EGSwapSmartRouter: invalid fee calculation"
        );

        IUniswapV2Router02(routerAddress).swapExactETHForTokens{
            value: amounts[0]
        }(amountOutMin, path, to, deadline);

        if (burnFee > 0) {
            // transfer to burn address
            TransferHelper.safeTransferETH(burnAddress, calcBurnFee(amountIn));
        }
        if (treasuryFee > 0) {
            // transfer to treasury address
            TransferHelper.safeTransferETH(
                treasuryAddress,
                calcTreasuryFee(amountIn)
            );
        }
    }

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) public view returns (uint[] memory amounts) {
        return
            IUniswapV2Router02(routerAddress).getAmountsIn(
                amountOut + calcRouterFee(amountOut),
                path
            );
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        require(path.length >= 2, "EGSwapSmartRouter: invalid path");

        amounts = getAmountsIn(amountOut, path);
        require(
            amounts[amounts.length - 1] == amountOut + calcRouterFee(amountOut),
            "EGSwapSmartRouter: invalid fee calculation"
        );

        address tokenIn = path[0];
        tokenIn.safeTransferFrom(msg.sender, address(this), amounts[0]);

        tokenIn.safeApprove(routerAddress, amounts[0]);
        IUniswapV2Router02(routerAddress).swapTokensForExactTokens(
            amounts[amounts.length - 1],
            amountInMax,
            path,
            address(this),
            deadline
        );

        address tokenOut = path[path.length - 1];
        tokenOut.safeTransfer(to, amountOut);
        if (burnFee > 0) {
            // transfer to burn address
            transferToBurn(tokenOut, calcBurnFee(amountOut));
        }
        if (treasuryFee > 0) {
            // transfer to treasury address
            transferToTreasury(tokenOut, calcTreasuryFee(amountOut), deadline, false);
        }
    }

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts) {
        require(
            path.length >= 2 && path[0] == WETH,
            "EGSwapSmartRouter: invalid path"
        );

        amounts = getAmountsIn(amountOut, path);
        require(
            amounts[amounts.length - 1] == amountOut + calcRouterFee(amountOut),
            "EGSwapSmartRouter: invalid fee calculation"
        );

        IUniswapV2Router02(routerAddress).swapETHForExactTokens{
            value: msg.value
        }(amounts[amounts.length - 1], path, address(this), deadline);

        address tokenOut = path[path.length - 1];
        tokenOut.safeTransfer(to, amountOut);
        if (burnFee > 0) {
            // transfer to burn address
            transferToBurn(tokenOut, calcBurnFee(amountOut));
        }
        if (treasuryFee > 0) {
            // transfer to treasury address
            transferToTreasury(tokenOut, calcTreasuryFee(amountOut), deadline, false);
        }

        if (msg.value > amounts[0])
            TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]); // refund dust eth, if any
    }

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        require(
            path.length >= 2 && path[path.length - 1] == WETH,
            "EGSwapSmartRouter: invalid path"
        );

        amounts = getAmountsIn(amountOut, path);
        require(
            amounts[amounts.length - 1] == amountOut + calcRouterFee(amountOut),
            "EGSwapSmartRouter: invalid fee calculation"
        );

        address tokenIn = path[0];
        tokenIn.safeTransferFrom(msg.sender, address(this), amounts[0]);

        tokenIn.safeApprove(routerAddress, amounts[0]);
        IUniswapV2Router02(routerAddress).swapTokensForExactETH(
            amounts[amounts.length - 1],
            amountInMax,
            path,
            address(this),
            deadline
        );

        TransferHelper.safeTransferETH(to, amountOut);
        if (burnFee > 0) {
            // transfer to burn address
            TransferHelper.safeTransferETH(burnAddress, calcBurnFee(amountOut));
        }
        if (treasuryFee > 0) {
            // transfer to treasury address
            TransferHelper.safeTransferETH(
                treasuryAddress,
                calcTreasuryFee(amountOut)
            );
        }
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external {
        require(path.length >= 2, "EGSwapSmartRouter: invalid path");

        address tokenIn = path[0];
        uint _amountBefore = IERC20(tokenIn).balanceOf(address(this));
        tokenIn.safeTransferFrom(msg.sender, address(this), amountIn);
        uint _amountIn = IERC20(tokenIn).balanceOf(address(this)) -
            _amountBefore;

        uint _amount = _amountIn - calcRouterFee(_amountIn);
        tokenIn.safeApprove(routerAddress, _amount);
        IUniswapV2Router02(routerAddress)
            .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                _amount,
                amountOutMin,
                path,
                to,
                deadline
            );

        if (burnFee > 0) {
            // transfer to burn address
            transferToBurn(tokenIn, calcBurnFee(_amountIn));
        }
        if (treasuryFee > 0) {
            // transfer to treasury address
            transferToTreasury(tokenIn, calcTreasuryFee(_amountIn), deadline, true);
        }
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external {
        require(
            path.length >= 2 && path[path.length - 1] == WETH,
            "EGSwapSmartRouter: invalid path"
        );

        address tokenIn = path[0];
        uint _amountBefore = IERC20(tokenIn).balanceOf(address(this));
        tokenIn.safeTransferFrom(msg.sender, address(this), amountIn);
        uint _amountIn = IERC20(tokenIn).balanceOf(address(this)) -
            _amountBefore;

        uint _amount = _amountIn - calcRouterFee(_amountIn);
        tokenIn.safeApprove(routerAddress, _amount);
        IUniswapV2Router02(routerAddress)
            .swapExactTokensForETHSupportingFeeOnTransferTokens(
                _amount,
                amountOutMin,
                path,
                to,
                deadline
            );

        if (burnFee > 0) {
            // transfer to burn address
            transferToBurn(tokenIn, calcBurnFee(_amountIn));
        }

        if (treasuryFee > 0) {
            // transfer to treasury address
            transferToTreasury(tokenIn, calcTreasuryFee(_amountIn), deadline, true);
        }
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable {
        require(
            path.length >= 2 && path[0] == WETH,
            "EGSwapSmartRouter: invalid path"
        );

        uint amountIn = msg.value;
        uint _amountIn = amountIn - calcRouterFee(amountIn);

        IUniswapV2Router02(routerAddress)
            .swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: _amountIn
        }(amountOutMin, path, to, deadline);

        if (burnFee > 0) {
            // transfer to burn address
            TransferHelper.safeTransferETH(burnAddress, calcBurnFee(amountIn));
        }
        if (treasuryFee > 0) {
            // transfer to treasury address
            TransferHelper.safeTransferETH(
                treasuryAddress,
                calcTreasuryFee(amountIn)
            );
        }
    }
}
