// $MSWAP TEAM BUILDING FOR YEARS IN BLOCKCHAIN AND GAME DEV MODE 


// WANT YOUR OWN SWAPPER CONTACT US AT MARSWAP.EXCHANGE


// PLAYWORLD SWAPPER

//| $$      /$$  /$$$$$$  /$$$$$$$   /$$$$$$  /$$      /$$  /$$$$$$  /$$$$$$$ 
//| $$$    /$$$ /$$__  $$| $$__  $$ /$$__  $$| $$  /$ | $$ /$$__  $$| $$__  $$
//| $$$$  /$$$$| $$  \ $$| $$  \ $$| $$  \__/| $$ /$$$| $$| $$  \ $$| $$  \ $$
//| $$ $$/$$ $$| $$$$$$$$| $$$$$$$/|  $$$$$$ | $$/$$ $$ $$| $$$$$$$$| $$$$$$$/
//| $$  $$$| $$| $$__  $$| $$__  $$ \____  $$| $$$$_  $$$$| $$__  $$| $$____/ 
//| $$\  $ | $$| $$  | $$| $$  \ $$ /$$  \ $$| $$$/ \  $$$| $$  | $$| $$      
//| $$ \/  | $$| $$  | $$| $$  | $$|  $$$$$$/| $$/   \  $$| $$  | $$| $$      
//|/       |/    |/  |/  |/    |/   \______/ |/        \/ |/    |/  |__/



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor () {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}
interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WBNB() external pure returns (address);
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
interface IPancakeRouter02 is IPancakeRouter01 {
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
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract PLYWLDSwapper is ReentrancyGuard {
    bool public swapperEnabled;
    address public owner;
    //
    IPancakeRouter02 router;
    address constant BNB =  0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c ;
    address constant PLYWLD = 0x96C68dAe03a05ae58a839f54A97046dDFa0Cdd5E ; // PLYWLD TOKEN
    event TransferOwnership(address oldOwner,address newOwner);
    event BoughtWithBnb(address);
    event BoughtWithToken(address, address); //sender, token
    constructor () {
        owner=msg.sender;
        router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }
    receive() external payable {
        require(swapperEnabled);
        buyTokens(msg.value, msg.sender);
    }
    function transferOwnership(address newOwner) public {
        require(msg.sender==owner);
        address oldOwner=owner;
        owner=newOwner;
        emit TransferOwnership(oldOwner,owner);
    }
    function enableSwapper(bool enabled) public {
        require(msg.sender==owner);
        swapperEnabled=enabled;
    }
    function TeamWithdrawStrandedToken(address strandedToken) public {
        require(msg.sender==owner);
        IBEP20 token=IBEP20(strandedToken);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
    function getPath(address token0, address token1) internal pure returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = token0;
        path[1] = token1;
        return path;
    }
    function buyTokens(uint amt, address to) internal {
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amt}(
            0,
            getPath(BNB, PLYWLD),
            to,
            block.timestamp
        );
        emit BoughtWithBnb(to);
    }
    function buyWithToken(uint amt, IBEP20 token) external nonReentrant {
        require(token.allowance(msg.sender, address(router)) >= amt);
        try
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amt,
                0,
                getPath(address(token), PLYWLD),
                msg.sender,
                block.timestamp
            ) {
            emit BoughtWithToken(msg.sender, address(token));
        }
        catch {
            revert("Error swapping to PLYWLD TOKEN.");
        }
    }
}