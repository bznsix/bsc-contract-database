/**
 *Submitted for verification at BscScan.com on 2023-12-21
*/

// SPDX-License-Identifier: MIT
// File: contracts/ISwapRouter.sol


pragma solidity ^0.8.0;
interface ISwapRouter {

    function swapEstimate(address[2] calldata path,bool status_b,uint256 amount_) external view returns (uint256,uint256,uint256);

    function swap(address[2] calldata path,bool status_b,uint256 amount_) external;

    //添加LP
    function addLP(address[2] calldata path,uint256 tokenAmount_, uint256 uAmount_) external;
    
    //提取LP
    function extractLP(address[2] calldata path) external;

    //获取价格
    function priceOf(address[2] calldata path) external view returns (uint256);
}
// File: contracts/ILP.sol


pragma solidity ^0.8.0;
interface ILP {

    //添加LP
    function addLP(uint256 tokenAmount_, address msg_sender_) external;
    
    //提取LP
    function extractLP(uint256 tokenAmount_, address msg_sender_) external;

    //获取LP
    function getLP(address msg_sender_) external view returns (uint256[2] memory);

    //获取奖励
    function getAward(address msg_sender_) external view returns (uint256[3] memory);

    //领取奖励
    function drawAward(address msg_sender_) external;
}
// File: contracts/IFactory.sol


pragma solidity ^0.8.0;

interface IFactory{
    function getPairAddr(address tokenA, address tokenB) external view returns(address);
    function getTokenAddr(address pairAddr) external view returns(address[2] memory);
    function getLPRouter() external view returns (address);
    function getUniswap() external view returns (IUniswapV2Router02);
}

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

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.19;

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

// File: contracts/Ownable.sol



pragma solidity ^0.8.0;

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function _setOwner(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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

// File: contracts/LPRouter.sol






pragma solidity ^0.8.0;
contract LPRouter is Ownable{
    address public _factory;//工厂合约

    constructor(address factory_){
        _factory = factory_;
        _setOwner(msg.sender);
    }

    function getPair(address[2] calldata path) public view returns(address){
        return IFactory(_factory).getPairAddr(path[0],path[1]);
    }


    //添加LP
    function addLP(address[2] calldata path,uint256 tokenAmount_) public{
        address pair = getPair(path);
        ILP(pair).addLP(tokenAmount_,msg.sender);
    }
    
    //提取LP
    function extractLP(address[2] calldata path,uint256 tokenAmount_) public{
        address pair = getPair(path);
        ILP(pair).extractLP(tokenAmount_,msg.sender);
    }

    //获取LP
    function getLP(address[2] calldata path,address userAddr) public view returns (uint256[2] memory){
        address pair = getPair(path);
        return ILP(pair).getLP(userAddr);
    }

    //领取奖励
    function drawAward(address[2] calldata path) public{
        address pair = getPair(path);
        return ILP(pair).drawAward(msg.sender);
    }

    //获取奖励
    function getAward(address[2] calldata path,address userAddr) public view returns (uint256[3] memory){
        address pair = getPair(path);
        return ILP(pair).getAward(userAddr);
    }

    function getTokenPrice(address[2] calldata val) public view returns (uint256 tokenPrice){
        address[] memory path = new address[](2);
        path[0] = val[0];
        path[1] = val[1];
        tokenPrice = IFactory(_factory).getUniswap().getAmountsOut(1000000000000000000,path)[1];
        return tokenPrice;
    }

    //获取价格
    function priceOf(address[2] calldata path) public view returns (uint256){
        return getTokenPrice(path);
    }

    //设置工厂
    function setFactory(address factory_) public onlyOwner{
        _factory = factory_;
    }
}