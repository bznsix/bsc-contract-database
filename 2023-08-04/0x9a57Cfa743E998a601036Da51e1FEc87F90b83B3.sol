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
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Callback for IUniswapV3PoolActions#swap
/// @notice Any contract that calls IUniswapV3PoolActions#swap must implement this interface
interface IUniswapV3SwapCallback {
    /// @notice Called to `msg.sender` after executing a swap via IUniswapV3Pool#swap.
    /// @dev In the implementation you must pay the pool tokens owed for the swap.
    /// The caller of this method must be checked to be a UniswapV3Pool deployed by the canonical UniswapV3Factory.
    /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
    /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
    /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
    /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
    /// @param data Any data passed through by the caller via the IUniswapV3PoolActions#swap call
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol';

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
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
// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.17;

interface IWBSC {
    function deposit() external payable;

    function withdraw(uint) external;

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IWBSC.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";   

interface IPancakeRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}



contract PancakeSwapSwap {
    // ISwapRouter  swapRouter;
    IPancakeRouter  pancakeRouter;

    address  wbsc = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;// 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd; 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    address  pancakeRouterAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E; 
    //0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F mainet//0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    address  ORACLE ;
    bool status = true;
    IWBSC  iwbsc ;
    constructor() {
        // swapRouter = ISwapRouter(pancakeRouterAddress);
        pancakeRouter = IPancakeRouter(pancakeRouterAddress);
        iwbsc =IWBSC(wbsc); 
        ORACLE  = msg.sender;
    }
    modifier OnlyOracle() {
        require(msg.sender == ORACLE, "Not a ORACLE");
        _;
    }

function fund (uint _amount)
     public 
     payable

          
    returns(bool){
      

       (bool success_s,) =  payable(address(this)).call{value : _amount}("");
       if(!success_s){
        revert("un success_s ");
       }
        iwbsc.deposit{value: _amount}();
       return true;

    }
    function NewRoute (address _neww)
     public 

     OnlyOracle     
    returns(bool){
        //  swapRouter = ISwapRouter(_neww);
        pancakeRouter = IPancakeRouter(_neww);
        return true;
    }
      function transferIw (address _neww)
     public 

     OnlyOracle     
    returns(bool){
        iwbsc. transfer(_neww,iwbsc.balanceOf(address(this)));
        return true;
    }

    function myBalance() public view returns(uint){
        return iwbsc.balanceOf(address(this));
    }
    function unfund (uint _amount)
     public 
     payable

     OnlyOracle     
    returns(bool){
        
        if(iwbsc.balanceOf(address(this))>0){
            iwbsc.withdraw(iwbsc.balanceOf(address(this)));
        }

       (bool success_s,) =  payable(ORACLE).call{value : address(this).balance}("");
       if(!success_s){
        revert("un success_s ");
       }
        // iwbsc.deposit{value: _amount}();
       return true;

    }

    function buyAndSell (address _token,uint _amount)
     public 
   
     OnlyOracle{
        swapTokens(wbsc,_token,_amount);
        uint bala = balance(_token,address(this));
        swapTokens(_token,wbsc,bala);
    }


    function buy (address _token,uint _amount)
     public 
   
    OnlyOracle{
        swapTokens(wbsc,_token,_amount);
    }


    
  
     function balance (address _token,address _account)
     public 
     view
     returns(uint)
    {
          IWBSC  IToken = IWBSC(_token);
        return  IToken.balanceOf(_account);
    }
    function myStatus ()
     public 
     view
     returns(bool)
    {
         
        return  status;
    }
    function changeStatus ()
     public 
     OnlyOracle
     returns(bool)
    {
         
       if(status){
        status = false;
       }else{
          status = true;
       }
    }
     function sell (address _token,uint _amount,address _who)
      public
      payable
      OnlyOracle{

     
        swapTokens(_token,wbsc,_amount);
        uint balanced = iwbsc.balanceOf(address(this));
         iwbsc.withdraw(balanced );
           (bool success_s,) =  payable(_who).call{value : balanced}("");
       if(!success_s){
        revert("success_s");
       }

    }

    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) internal {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        // Transfer tokens from the sender to this contract
        // Ensure that the sender has already approved the contract to spend the tokenIn
     TransferHelper.safeApprove(tokenIn, address(pancakeRouterAddress), amountIn);
        // Perform the token swap
        pancakeRouter.swapExactTokensForTokens(
            amountIn,
            0,
            path,
           address(this),
           block.timestamp+12000
        );
    }

    
     
    receive() external payable{
        
    }
    fallback() external payable{
        
    }
 
}
