// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

interface IPancakeSwapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
            address indexed sender,
            uint amount0In,
            uint amount1In,
            uint amount0Out,
            uint amount1Out,
            address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IPancakeSwapRouter{
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

interface IPancakeSwapFactory {
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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

contract AutoTradeContract is Ownable {
    IPancakeSwapRouter public router;
    IPancakeSwapPair public pairContract;
    address public pair;
    uint256 public tradingPeriod;
    uint256 public lastTradingTime;

   	constructor() {
        // // ========= BSC Testnet ========== //
        // router = IPancakeSwapRouter(0xD99D1c33F9fC3444f8101754aBC46c52416550D1); // bsc testnet
        // pair = IPancakeSwapFactory(router.factory()).getPair(0xfAFF90d6e743E528E77e2Bb7881dAbc34A62103F, 0xd7803dE72362e1443709C01899BE4c9b0E457376);
        // if (pair == address(0)) {
        //     pair = IPancakeSwapFactory(router.factory()).createPair(
        //         0xfAFF90d6e743E528E77e2Bb7881dAbc34A62103F, // BUSD on testnet
        //         0xd7803dE72362e1443709C01899BE4c9b0E457376 // PLOT on testnet
        //     );
        // }
        // ERC20Detailed(0xfAFF90d6e743E528E77e2Bb7881dAbc34A62103F).approve(0xD99D1c33F9fC3444f8101754aBC46c52416550D1, 10000000000000000000000000); // Pancakeswap Router on bsc testnet
        // ERC20Detailed(0xd7803dE72362e1443709C01899BE4c9b0E457376).approve(0xD99D1c33F9fC3444f8101754aBC46c52416550D1, 10000000000000000000000000); // Pancakeswap Router on bsc testnet
        // ERC20Detailed(0xfAFF90d6e743E528E77e2Bb7881dAbc34A62103F).approve(0x6725F303b657a9451d8BA641348b6761A6CC7a17, 10000000000000000000000000); // Pancakeswap Factory on bsc testnet
        // ERC20Detailed(0xd7803dE72362e1443709C01899BE4c9b0E457376).approve(0x6725F303b657a9451d8BA641348b6761A6CC7a17, 10000000000000000000000000); // Pancakeswap Factory on bsc testnet
        // ERC20Detailed(0xfAFF90d6e743E528E77e2Bb7881dAbc34A62103F).approve(pair, 10000000000000000000000000);
        // ERC20Detailed(0xd7803dE72362e1443709C01899BE4c9b0E457376).approve(pair, 10000000000000000000000000);

        // ========= BSC Testnet ========== //
        router = IPancakeSwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E); // bsc mainnet
        pair = IPancakeSwapFactory(router.factory()).getPair(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56, 0x3e63e9C8F2297E3C027f8444b4591E2583d8780B);
        if (pair == address(0)) {
            pair = IPancakeSwapFactory(router.factory()).createPair(
                0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56, // BUSD
                0x3e63e9C8F2297E3C027f8444b4591E2583d8780B // PLOT
            );
        }
        ERC20Detailed(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56).approve(0x10ED43C718714eb63d5aA57B78B54704E256024E, 10000000000000000000000000); // Pancakeswap Router on bsc testnet
        ERC20Detailed(0x3e63e9C8F2297E3C027f8444b4591E2583d8780B).approve(0x10ED43C718714eb63d5aA57B78B54704E256024E, 10000000000000000000000000); // Pancakeswap Router on bsc testnet
        ERC20Detailed(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56).approve(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73, 10000000000000000000000000); // Pancakeswap Factory on bsc testnet
        ERC20Detailed(0x3e63e9C8F2297E3C027f8444b4591E2583d8780B).approve(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73, 10000000000000000000000000); // Pancakeswap Factory on bsc testnet
        ERC20Detailed(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56).approve(pair, 10000000000000000000000000);
        ERC20Detailed(0x3e63e9C8F2297E3C027f8444b4591E2583d8780B).approve(pair, 10000000000000000000000000);
   	}

    function buyPLOT(uint amount, address to) public onlyOwner returns (uint[] memory amounts)  {
        address[] memory path = new address[](2);
        path[0] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        path[1] = 0x3e63e9C8F2297E3C027f8444b4591E2583d8780B;
        lastTradingTime = block.timestamp;
        return router.swapExactTokensForTokens(amount, 0, path, to, block.timestamp);
    }

    function sellPLOT(uint amount, address to) public onlyOwner returns (uint[] memory amounts){
        address[] memory path = new address[](2);
        path[0] = 0x3e63e9C8F2297E3C027f8444b4591E2583d8780B;
        path[1] = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
        lastTradingTime = block.timestamp;
        return router.swapExactTokensForTokens(amount, 0, path, to, block.timestamp);
    }

    function withdrawBUSD(uint amount) public onlyOwner {
        ERC20Detailed(0x3e63e9C8F2297E3C027f8444b4591E2583d8780B).transfer(msg.sender, amount);
    }

    function withdrawPLOT(uint amount) public onlyOwner {
        ERC20Detailed(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56).transfer(msg.sender, amount);
    }

    function createLiquidity() public onlyOwner {
        router.addLiquidity(
            0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56,
            0x3e63e9C8F2297E3C027f8444b4591E2583d8780B,
            100000000000000000000000,
            100000000000000000000000,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function setTradingPeriod(uint256 forMinutes) public onlyOwner {
        tradingPeriod = forMinutes;
    }
}
