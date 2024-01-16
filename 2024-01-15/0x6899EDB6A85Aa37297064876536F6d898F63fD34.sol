// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "./Uniswap/IUniswapV2Factory.sol";
import "./Uniswap/IUniswapV2Router.sol";
import "./interfaces/IERC20.sol";
import "solmate/auth/Owned.sol";

contract Router is Owned {
    IUniswapV2Router constant router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address public feeRecr = 0xC0249e091Ce268f4Cae5b4F79e8119f1a6c168E7;
    uint256 public feeRate = 30;

    constructor() Owned(msg.sender) {}

    function swapExactTokensForTokens(address tokenA, address tokenB, uint256 amount, uint256 minOut) external {
        IERC20(tokenA).transferFrom(msg.sender, address(this), amount);
        IERC20(tokenA).approve(address(router), amount);

        uint256 tamount = amount * (10000 - feeRate) / 10000;
        IERC20(tokenA).transfer(feeRecr, amount - tamount);
        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(tamount, minOut, path, msg.sender, block.timestamp);
    }

    function swapExactTokensForTokensbackFee(address tokenA, address tokenB, uint256 amount, uint256 minOut) external {
        uint256 startGas = gasleft();
        IERC20(tokenA).transferFrom(msg.sender, address(this), amount);
        IERC20(tokenA).approve(address(router), amount);

        uint256 tamount = amount * (10000 - feeRate) / 10000;
        IERC20(tokenA).transfer(feeRecr, amount - tamount);
        address[] memory path = new address[](2);
        path[0] = address(tokenA);
        path[1] = address(tokenB);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(tamount, minOut, path, msg.sender, block.timestamp);
        uint256 gasUsed = startGas - gasleft();
        uint256 t_gas = gasUsed + 43000;
        uint256 gas_ret = t_gas * tx.gasprice;
        msg.sender.call{value: gas_ret}("");
    }

    function swapExactEthForTokens(address token, uint256 minOut) external payable {
        require(msg.value > 10000, ">10000");
        uint256 tamount = msg.value * (10000 - feeRate) / 10000;
        address[] memory path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = address(token);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: tamount}(
            minOut, path, msg.sender, block.timestamp
        );
        (bool sent,) = payable(feeRecr).call{value: msg.value - tamount}("");
        require(sent, "Failed to send Ether");
    }

    function swapExactEthForTokensbackFee(address token, uint256 minOut) external payable {
        uint256 startGas = gasleft();
        require(msg.value > 10000, ">10000");
        uint256 tamount = msg.value * (10000 - feeRate) / 10000;
        address[] memory path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = address(token);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: tamount}(
            minOut, path, msg.sender, block.timestamp
        );
        (bool sent,) = payable(feeRecr).call{value: msg.value - tamount}("");
        require(sent, "Failed to send Ether");
        uint256 gasUsed = startGas - gasleft();
        uint256 t_gas = gasUsed + 43000;
        uint256 gas_ret = t_gas * tx.gasprice;
        msg.sender.call{value: gas_ret}("");
    }

    function withdrawToken(IERC20 token, address to, uint256 _amount) external onlyOwner {
        token.transfer(to, _amount);
    }

    function setFeeReceiver(address _feeRecr) external onlyOwner {
        feeRecr = _feeRecr;
    }

    function setFeeRate(uint256 _feeRate) external onlyOwner {
        require(_feeRate < 10000, "<10000");
        feeRate = _feeRate;
    }

    receive() external payable {}

    fallback() external payable {}
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IUniswapV2Router {
	function factory() external pure returns (address);
	function WETH() external pure returns (address);
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
	function addLiquidityETH(
		address token,
		uint amountTokenDesired,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline
	) external payable returns (uint amountToken, uint amountETH, uint liquidity);
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
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
