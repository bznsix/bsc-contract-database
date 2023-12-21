// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Calculates the average of two numbers. Since these are integers,
     * averages of an even and odd number cannot be represented, and will be
     * rounded down.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address public _owner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value
        );
        require(token.approve(spender, newAllowance));
    }
}

interface ISwapRouter {
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}


contract QJLPSwap is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public immutable NewQJLegion = IERC20(0x2E3A7086623fF9F370fdF4b0738dde2b7B8eD45A);
    IERC20 public immutable NewQJLegionLP = IERC20(0xa1de6f62a0b6506c5fC22D198e7c1E0aB6801Cee);
    IERC20 public immutable OldQJLegion = IERC20(0x8C3eeA7d7b6D2214958908C478b12Fb2e5b2a1c6);
    IERC20 public immutable OldQJLegionLP = IERC20(0x98F83ADfB9Eb640CaF04f6eD98882b7a3c5B63d7);
    IERC20 public immutable USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    ISwapRouter public immutable Router = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    event Swap(address indexed account, uint256 lpAmount);

    constructor() {
        _owner = msg.sender;
        NewQJLegion.approve(address(Router), ~uint256(0));
        USDT.approve(address(Router), ~uint256(0));
        OldQJLegionLP.approve(address(Router), ~uint256(0));
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function swap(uint256 amount) public returns (bool) {
        OldQJLegionLP.transferFrom(msg.sender, address(this), amount);
        uint256 beforeLegion = OldQJLegion.balanceOf(address(this));
        uint256 beforeUSDT = USDT.balanceOf(address(this));
        removeLiquidity(amount);
        uint256 afterUSDT = USDT.balanceOf(address(this));
        uint256 afterLegion = OldQJLegion.balanceOf(address(this));
        uint256 diffUSDT = afterUSDT - beforeUSDT;
        uint256 diffLegion = afterLegion - beforeLegion;
        addLiquidity(msg.sender, diffLegion, diffUSDT);
        emit Swap(msg.sender, amount);
        return true;
    }

    function removeLiquidity(uint256 lpAmount) private   {
        Router.removeLiquidity(
            address(OldQJLegion),
            address(USDT),
            lpAmount,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(address to, uint256 tokenAmount, uint256 uAmount) private   {
        Router.addLiquidity(
            address(NewQJLegion),
            address(USDT),
            tokenAmount,
            uAmount,
            0,
            0,
            to,
            block.timestamp
        );
    }


    function batchTransfer(address token, address[] memory addrs, uint256[] memory amounts) external onlyOwner returns (bool) {
        uint256 len = addrs.length;
        for (uint i = 0; i < len; i++) {
            IERC20(token).transfer(addrs[i], amounts[i]);
        }
        return true;
    }

    function rescueToken(
        address token,
        address recipient,
        uint256 amount
    ) public onlyOwner {
        IERC20(token).transfer(recipient, amount);
    }
}