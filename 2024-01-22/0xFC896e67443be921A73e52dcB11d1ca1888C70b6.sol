// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
        address msgSender =  msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

contract AutoSwap {
    //IUniswapV2Router02 public pancakeSwapRouter;
    IUniswapV2Router01 public pancakeSwapRouter01;
    IUniswapV2Router02 public pancakeSwapRouter02;
    address public token;
    address public owner;
    
    receive() external payable {}

    constructor(address _pancakeSwapRouter, address _token) {
        //pancakeSwapRouter = IUniswapV2Router02(_pancakeSwapRouter);
        pancakeSwapRouter01 = IUniswapV2Router01(_pancakeSwapRouter);
        pancakeSwapRouter02 = IUniswapV2Router02(_pancakeSwapRouter);
        token = _token;
        token = _token;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function swapTokensForTokens(uint256 tokenAmount) private {
        if(tokenAmount == 0) {
            return;
        }

    address[] memory path = new address[](2);
        path[0] = token; //交易的起始代币
        path[1] = pancakeSwapRouter02.WETH(); //交易的目标代币

        IERC20(token).approve(address(pancakeSwapRouter02), tokenAmount); //授权薄饼交易该代币

        pancakeSwapRouter02.swapExactTokensForTokensSupportingFeeOnTransferTokens( //这是实际执行代币交换的函数调用
            tokenAmount, //要交换的代币数量
            0, //用户愿意接受最小的目标代币数量
            path, //定义交易路径
            address(this), //接收交换后代币的地址
            block.timestamp //当前时间戳
        );
    }


    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        
        IERC20(token).approve(address(pancakeSwapRouter01), tokenAmount);
        pancakeSwapRouter01.addLiquidity(
            token, //添加到流动池中的代币合约
            address(this), //流动池中BNB的地址
            ethAmount, //BNB数量
            tokenAmount, //代币数量
            0, // 滑点（接受币的最小数量）
            0, // 滑点（接受BNB的最小数量
            address(this), //LP接收地址
            block.timestamp //当前交易时间戳
        );
    }

    // 获取合约中的代币余额
    function getTokenBalance() public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    // 提取合约中的WBNB（或其他代币）
    function withdrawToken(address _token) public onlyOwner {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(msg.sender, balance);
    }

    //提取合约中的BNB
    function withdrawTokenbnb(uint256 _amt) public onlyOwner {
		require((address(this).balance >= _amt), "Insufficient amount of native currency in this contract to transfer out. Please contact the contract owner to top up the native currency.");
		payable(msg.sender).transfer(_amt);
	}

    //管理员同时调用买币和添加流动性
    function executeSwapAndLiquidity(uint256 tokenAmount, uint256 ethAmount) public onlyOwner {
        swapTokensForTokens(tokenAmount);
        addLiquidity(tokenAmount, ethAmount);
    }

    //管理员调用买币
    function executeSwap(uint256 tokenAmount) public onlyOwner {
        swapTokensForTokens(tokenAmount);
    }

    //管理员调用添加流动性
    function executeLiquidity(uint256 tokenAmount, uint256 ethAmount) public onlyOwner {
        addLiquidity(tokenAmount, ethAmount);
    }

    // 允许合约所有者设置新的token地址
    function setTokenAddress(address newTokenAddress) public onlyOwner {
        token = newTokenAddress;
    }

    // 允许合约所有者设置新的PancakeSwap路由器地址
    function setPancakeSwapRouterAddress(address newRouterAddress) public onlyOwner {
        pancakeSwapRouter01 = IUniswapV2Router01(newRouterAddress);
        pancakeSwapRouter02 = IUniswapV2Router02(newRouterAddress);
    }
}