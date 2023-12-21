// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Callback for IAlgebraPoolActions#swap
/// @notice Any contract that calls IAlgebraPoolActions#swap must implement this interface
/// @dev Credit to Uniswap Labs under GPL-2.0-or-later license:
/// https://github.com/Uniswap/v3-core/tree/main/contracts/interfaces
interface IAlgebraSwapCallback {
  /// @notice Called to `msg.sender` after executing a swap via IAlgebraPool#swap.
  /// @dev In the implementation you must pay the pool tokens owed for the swap.
  /// The caller of this method must be checked to be a AlgebraPool deployed by the canonical AlgebraFactory.
  /// amount0Delta and amount1Delta can both be 0 if no tokens were swapped.
  /// @param amount0Delta The amount of token0 that was sent (negative) or must be received (positive) by the pool by
  /// the end of the swap. If positive, the callback must send that amount of token0 to the pool.
  /// @param amount1Delta The amount of token1 that was sent (negative) or must be received (positive) by the pool by
  /// the end of the swap. If positive, the callback must send that amount of token1 to the pool.
  /// @param data Any data passed through by the caller via the IAlgebraPoolActions#swap call
  function algebraSwapCallback(
    int256 amount0Delta,
    int256 amount1Delta,
    bytes calldata data
  ) external;
}// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.5;
pragma abicoder v2;

import './IAlgebraSwapCallback.sol';

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Algebra
/// @dev Credit to Uniswap Labs under GPL-2.0-or-later license:
/// https://github.com/Uniswap/v3-periphery
interface ISwapRouter is IAlgebraSwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 limitSqrtPrice;
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
        uint160 limitSqrtPrice;
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

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @dev Unlike standard swaps, handles transferring from user before the actual swap.
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingleSupportingFeeOnTransferTokens(ExactInputSingleParams calldata params) external returns (uint256 amountOut);
}// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface IThenianChef {
    
    // Functions
    function addKeeper(address[] calldata _keepers) external;
    function removeKeeper(address[] calldata _keepers) external;
    function setRewardPerSecond(uint256 _rewardPerSecond) external;
    function setDistributionRate(uint256 amount) external;
    function pendingReward(address _user) external view returns (uint256);
    function stakedTokenIds(address _user) external view returns (uint256[] memory);
    function deposit(uint256[] calldata tokenIds) external;
    function withdraw(uint256[] calldata tokenIds) external;
    function harvest() external;
    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4);

    // Public Variables
    function TOKEN() external view returns (address);
    function NFT() external view returns (address);
    function poolInfo() external view returns (uint256, uint256);
    function tokenOwner(uint256 tokenId) external view returns (address);
    function userInfo(address user) external view returns (uint256, int256, uint256[] memory);
    function isKeeper(address keeper) external view returns (bool);
    function rewardPerSecond() external view returns (uint256);
    function ACC_TOKEN_PRECISION() external view returns (uint256);
    function distributePeriod() external view returns (uint256);
    function lastDistributedTime() external view returns (uint256);

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface IPair {
    function allowance(address, address) external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function burn(address to) external returns (uint amount0, uint amount1);
    function claimFees() external returns (uint claimed0, uint claimed1);
    function claimStakingFees() external;
    function current(address tokenIn, uint amountIn) external view returns (uint amountOut);
    function currentCumulativePrices() external view returns (uint reserve0Cumulative, uint reserve1Cumulative, uint blockTimestamp);
    function decimals() external view returns (uint8);
    function fees() external view returns (address);
    function getAmountOut(uint amountIn, address tokenIn) external view returns (uint);
    function getReserves() external view returns (uint _reserve0, uint _reserve1, uint _blockTimestampLast);
    function isStable() external view returns(bool);
    function metadata() external view returns (uint dec0, uint dec1, uint r0, uint r1, bool st, address t0, address t1);
    function mint(address to) external returns (uint liquidity);
    function name() external view returns (string memory);
    function nonces(address) external view returns (uint);
    function prices(address tokenIn, uint amountIn, uint points) external view returns (uint[] memory);
    function quote(address tokenIn, uint amountIn, uint granularity) external view returns (uint amountOut);
    function sample(address tokenIn, uint amountIn, uint points, uint window) external view returns (uint[] memory);
    function skim(address to) external;
    function stable() external view returns (bool);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function symbol() external view returns (string memory);
    function sync() external;
    function tokens() external view returns (address, address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function totalSupply() external view returns (uint);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRouter {

    struct route { 
        address from; 
        address to; 
        bool stable; 
    }

    function sortTokens(address tokenA, address tokenB) external pure returns (address token0, address token1);
    function pairFor(address tokenA, address tokenB, bool stable) external view returns (address pair);
    function quoteLiquidity(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getReserves(address tokenA, address tokenB, bool stable) external view returns (uint reserveA, uint reserveB);
    function getAmountOut(uint amountIn, address tokenIn, address tokenOut) external view returns (uint amount, bool stable);
    function getAmountsOut(uint amountIn, route[] memory routes) external view returns (uint[] memory amounts);
    function isPair(address pair) external view returns (bool);
    function quoteAddLiquidity(address tokenA, address tokenB, bool stable, uint amountADesired, uint amountBDesired) external view returns (uint amountA, uint amountB, uint liquidity);
    function quoteRemoveLiquidity(address tokenA, address tokenB, bool stable, uint liquidity) external view returns (uint amountA, uint amountB);
    function addLiquidity(address tokenA, address tokenB, bool stable, uint amountADesired, uint amountBDesired, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(address token, bool stable, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external  returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(address tokenA, address tokenB, bool stable, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(address token, bool stable, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(address tokenA, address tokenB, bool stable, uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(address token, bool stable, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokensSimple(uint amountIn, uint amountOutMin, address tokenFrom, address tokenTo, bool stable, address to, uint deadline) external  returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, route[] calldata routes, address to, uint deadline) external  returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, route[] calldata routes, address to, uint deadline) external   returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, route[] calldata routes, address to, uint deadline) external  returns (uint[] memory amounts);
    function UNSAFE_swapExactTokensForTokens(uint[] memory amounts, route[] calldata routes, address to, uint deadline) external  returns (uint[] memory);
    function removeLiquidityETHSupportingFeeOnTransferTokens(address token, bool stable, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external  returns (uint amountToken, uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address token, bool stable, uint liquidity, uint amountTokenMin, uint amountETHMin, address to, uint deadline, bool approveMax, uint8 v, bytes32 r, bytes32 s) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint amountIn,uint amountOutMin,route[] calldata routes,address to,uint deadline) external ;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint amountOutMin, route[] calldata routes, address to, uint deadline) external  ;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint amountIn, uint amountOutMin, route[] calldata routes, address to, uint deadline) external ;

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ThenianFeeConverterRouter.sol";
import '../interfaces/Pairs/IPair.sol';
import "../interfaces/Masterchef/IThenianChef.sol";


contract ThenianFeeConverter is Ownable, ThenianFeeConverterRouter {

 
    modifier keeper() {
        require(isKeeper[msg.sender] == true || msg.sender == owner(), 'not keeper');
        _;
    }


    constructor() {
        rewardToken = 0xF4C8E32EaDEC4BFe97E0F595AdD0f4450a863a11;
        isKeeper[msg.sender] == true;
        isPaused = false;
    }


    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    KEEPER
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    /// @notice Claim SolidlyPairs fees
    function claimFees() external keeper {
        uint i = 0;
        uint _len = pairs.length;
        address[] memory _pairs = new address[](_len);
        _pairs = pairs;

        for(i; i <_len; i++){
            try IPair(_pairs[i]).claimStakingFees() {
                emit ClaimFee(_pairs[i], block.timestamp);
            }
            catch {
                emit ClaimFeeError(_pairs[i], block.timestamp);
            }
        }

    }

 

    /// @notice Swap all the tokens
    function swap() external keeper {
        _swapInternal(0, tokens.length);
    }

    /// @notice swap a certain amount of token 
    function swap(uint256 from, uint256 to) external keeper {
        _swapInternal(from, to);
    }

    /// @notice execute the swap and update masterchef distribution rate
    function _swapInternal(uint256 from, uint256 to) internal {
        require(!isPaused, 'TFC: paused');
        
        uint256 _balance;
        address _token;
        uint256 i;

        for(i=from; i < to; i++){
            _token = tokens[i];
            _balance = IERC20(_token).balanceOf(address(this));
            if(_balance > 0) _swap(_token, _balance); 
        }

        _balance = IERC20(rewardToken).balanceOf(address(this));
        if(_balance > 0){
            _safeTransfer(rewardToken, masterchef, _balance);
            IThenianChef(masterchef).setDistributionRate(_balance);
        }
        
        emit StakingReward(block.timestamp, _balance);

    }



    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    VIEW
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */
    /// @notice view length of all tokens
    function tokensLength() external view returns(uint256) {
        return tokens.length;
    }

    /// @notice view length of all solidly pairs
    function pairsLength() external view returns(uint256) {
        return pairs.length;
    }



    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    OWNER
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */
    
    ///@notice claim any pair. Used if ClaimFeeError() is emitted 
    function claimSingleFee(address _pair) external onlyOwner {
        require(_pair != address(0), "TFC: ZeroAddress");
        IPair(_pair).claimStakingFees();
        emit ClaimFee(_pair, block.timestamp);
    }


    ///@notice set Masterchef distriubtion given this.balance 
    function updateMasterchefDistributionRate() external onlyOwner {
        uint _balance = IERC20(rewardToken).balanceOf(address(this));
        _safeTransfer(rewardToken, masterchef, _balance);
        IThenianChef(masterchef).setDistributionRate(_balance);
        emit StakingReward(block.timestamp, _balance);
    }



    /// @notice Add Solidly volatile or stable pair
    /// @dev    Fusion pairs send directly the fees via FeeVault, no need to add pair
    /// @param _pair pair to add
    function addPair(address[] calldata _pair) external onlyOwner {
        uint i = 0;
        address _singlePair = address(0);
        for(i; i < _pair.length; i++){
            _singlePair = _pair[i];
            require(_singlePair != address(0), "TFC: ZeroAddress");
            if(!isPair[_singlePair]){
                pairs.push(_singlePair);
                isPair[_singlePair] = true;
                emit AddPair(_singlePair);
            }
        }
    }

    /// @notice Remove Solidly volatile or stable pair
    function removePair(address _pair) external onlyOwner {
        uint i = 0;
        uint len = pairs.length;
        for(i; i < len; i++){
            if(pairs[i] == _pair){
                pairs[i] = pairs[len -1];
                pairs.pop();
                isPair[_pair] = false;
                emit RemovePair(_pair);
                break;
            }
        }
    }

    /// @notice Add a token to the tokens list
    function addToken(address[] calldata _tokens) external onlyOwner {
        address _token;
        for(uint i = 0; i < _tokens.length; i++){
            _token = _tokens[i];
            require(_token != address(0), "TFC: ZeroAddress");
            tokens.push(_token);
            isToken[_token] = true;
            _safeApprove(_token, routerAlgebra, 0);
            _safeApprove(_token, routerAlgebra, type(uint).max);
            _safeApprove(_token, routerSolidly, 0);
            _safeApprove(_token, routerSolidly, type(uint).max);
            emit AddToken(_token);
        }
    }

    /// @notice Remove a token from the token list
    function removeToken(address _token) external onlyOwner {
        uint i = 0;
        uint len = tokens.length;
        for(i; i < len; i++){
            if(tokens[i] == _token){
                tokens[i] = tokens[len -1];
                tokens.pop();
                isToken[_token] = false;
                _safeApprove(_token, routerAlgebra, 0);
                _safeApprove(_token, routerSolidly, 0);
                emit RemoveToken(_token);
                break;
            }
        }
    }

    /// @notice Set the path for a given token
    /// @dev    deadline, amountIn and amountOutMinimum;are set during swap
    ///         TokenOut is RewardToken! 
    /// @param _token   the starting token
    /// @param path     the path in bytes (see ISwapRouter.ExactInputParams)
    function setPathToToken(address _token, bytes calldata path) external onlyOwner {
        tokenToPath[_token] = path;
        hasPath[_token] = true;
        emit SetPath(_token, path);
    }

    /// @notice Remove the path from a given token
    function removePathFromToken(address _token) external onlyOwner {
        tokenToPath[_token] = "";
        hasPath[_token] = false;
        emit RemovePath(_token);
    }


    ///@notice in case token get stuck.
    function withdrawERC20(address _token, uint256 _amount) external onlyOwner {
        require(_token != address(0), "TFC: ZeroAddress");
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "TCF: !amount");
        _safeTransfer(_token, msg.sender, _amount);
        emit WithdrawERC20(_token, msg.sender, _amount);
    }
    
    /// @notice Set a new keeper
    function setKeeper(address _keeper) external onlyOwner {
        require(_keeper != address(0), "TFC: ZeroAddress");
        require(isKeeper[_keeper] == false, "TFC: keeper");
        isKeeper[_keeper] = true;
        emit SetKeeper(_keeper);
    }

    /// @notice Remove a keeper
    function removeKeeper(address _keeper) external onlyOwner {
        require(_keeper != address(0), "TFC: ZeroAddress");
        require(isKeeper[_keeper] == true, "TFC: !keeper");
        isKeeper[_keeper] = false;
        emit RemoveKeeper(_keeper);
    }
    
    /// @notice Set the solidly router
    function setRouterSolidly(address _router) external onlyOwner {
        require(_router != address(0), "TFC: ZeroAddress");
        routerSolidly = _router;
        emit SetSolidlyRouter(_router);
    }

    /// @notice Set the algebra router
    function setRouterAlgebra(address _router) external onlyOwner {
        require(_router != address(0), "TFC: ZeroAddress");
        routerAlgebra = _router;
        emit SetAlgebraRouter(_router);
    }

    /// @notice Set the masterchef
    function setMasterchef(address _masterchef) external onlyOwner {
        require(_masterchef != address(0), "TFC: ZeroAddress");
        masterchef = _masterchef;
        emit SetMasterchef(_masterchef);
    }

    /// @notice Set Reward token 
    /// @dev    Paths end with the reward token, if a new token is set check them 
    function setRewardToken(address _token) external onlyOwner {
        require(_token != address(0), "TFC: ZeroAddress");
        rewardToken = _token;
        emit SetRewardToken(_token);
    }

    /// @notice Swap a token using Algebra input single
    function swapManualInputSingleAlgebra(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, uint160 _limitSqrtPrice) external onlyOwner returns (uint256 _amountOut) {
        return _swapManualInputSingleAlgebra(_tokenIn, _tokenOut, _amountIn, _amountOutMin, _limitSqrtPrice); 
    }

    ///@notice Swap a token using Solidly router 
    function swapManualV2(uint amountIn,uint amountOutMin, IRouter.route[] calldata _routes) external onlyOwner returns (uint[] memory amounts) {
        return _swapManualV2(amountIn, amountOutMin, _routes, block.timestamp + 600);
    }


    /// @notice (Un)Pause the swap function
    function triggerPause() external onlyOwner {
        isPaused = !isPaused;
        emit TriggerPause(isPaused);
    }





}// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ThenianFeeConverterStorageAndEvents.sol"; 
import "../interfaces/Algebra/ISwapRouter.sol"; 
import '../interfaces/Router/IRouter.sol';



abstract contract ThenianFeeConverterRouter is ThenianFeeConverterStorageAndEvents {


    /// @notice Internal swap on Algebra router
    function _swap(address _tokenIn, uint256 _amountIn) internal {

        if(hasPath[_tokenIn]){
            ISwapRouter.ExactInputParams memory eip = ISwapRouter.ExactInputParams({
            path: tokenToPath[_tokenIn],
            recipient: address(this),
            deadline: block.timestamp + 600,
            amountIn: _amountIn,
            amountOutMinimum: 0
            });

            if(IERC20(_tokenIn).allowance(address(this), routerAlgebra) < _amountIn) {
                _safeApprove(_tokenIn, routerAlgebra, 0);
                _safeApprove(_tokenIn, routerAlgebra, type(uint).max);
            }

            try ISwapRouter(routerAlgebra).exactInput(eip) returns (uint256 _amountOut) {
                require(_amountOut > 0, 'TFCR: amountOut 0');
                emit Swap(_tokenIn, _amountIn, _amountOut);
            }
            catch {
                emit SwapError(_tokenIn, _amountIn, block.timestamp);
            }
        }

    }


    function _swapManualInputSingleAlgebra(address _tokenIn, address _tokenOut, uint256 _amountIn, uint256 _amountOutMin, uint160 _limitSqrtPrice) internal returns (uint256 _amountOut) {

        ISwapRouter.ExactInputSingleParams memory eisp = ISwapRouter.ExactInputSingleParams({
            tokenIn: _tokenIn,
            tokenOut: _tokenOut,
            recipient: address(this),
            deadline: block.timestamp + 600,
            amountIn: _amountIn,
            amountOutMinimum: _amountOutMin,
            limitSqrtPrice: _limitSqrtPrice
        });

        if(IERC20(_tokenIn).allowance(address(this), routerAlgebra) < _amountIn) {
            _safeApprove(_tokenIn, routerAlgebra, 0);
            _safeApprove(_tokenIn, routerAlgebra, type(uint).max);
        }

        _amountOut = ISwapRouter(routerAlgebra).exactInputSingle(eisp);
        emit Swap(_tokenIn, _amountIn, _amountOut);
    }


    /// @notice Internal swap on Solidly router
    function _swapManualV2(uint _amountIn,uint _amountOutMin, IRouter.route[] calldata _routes,uint deadline) internal returns (uint[] memory amounts){
        address _tokenIn = _routes[0].from;
        
        if(IERC20(_tokenIn).allowance(address(this), routerSolidly) < _amountIn) {
            _safeApprove(_tokenIn, routerAlgebra, 0);
            _safeApprove(_tokenIn, routerAlgebra, type(uint).max);
        }

        amounts = IRouter(routerSolidly).swapExactTokensForTokens(_amountIn, _amountOutMin, _routes, address(this), deadline);
        emit Swap(_tokenIn, _amountIn, amounts[amounts.length-1]);
    }




    
    /* -----------------------------------------------------------------------------
    --------------------------------------------------------------------------------
                                    Helper
    --------------------------------------------------------------------------------
    ----------------------------------------------------------------------------- */

    
    function _safeTransfer(address token,address to,uint256 value) internal {
        require(token.code.length > 0);
        (bool success, bytes memory data) =
        token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function _safeApprove(address token,address spender,uint256 value) internal {
        require(token.code.length > 0);
        require((value == 0) || (IERC20(token).allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, spender, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))));
    }

}// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;


abstract contract ThenianFeeConverterStorageAndEvents {

    bool public isPaused;

    address constant public wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public masterchef;  // theNFT chef
    address public routerSolidly = 0xd4ae6eCA985340Dd434D38F470aCCce4DC78D109;
    address public routerAlgebra = 0x327Dd3208f0bCF590A66110aCB6e5e6941A4EfA0;
    address public rewardToken; // $THE
    address[] public tokens;    // used to swap tokens
    address[] public pairs;     // used to claim fee from Pair.sol
    
    

    mapping(address => bytes) public tokenToPath;
    mapping(address => bool) public hasPath;
    mapping(address => bool) public isKeeper;
    mapping(address => bool) public isToken;
    mapping(address => bool) public isPair;

    
    event StakingReward(uint256 _timestamp, uint256 _wbnbAmount);
    event ClaimFee(address indexed _pair, uint256 timestamp);
    event ClaimFeeError(address indexed _pair, uint256 timestamp);
    event SwapError(address indexed _tokenIn, uint256 _balanceIn, uint256 timestamp);  
    event Swap(address indexed _tokenIn, uint256 _balanceIn, uint256 _balanceOut);  
    event AddPair(address indexed _pair);
    event RemovePair(address indexed _pair);
    event AddToken(address indexed token);
    event RemoveToken(address indexed token);
    event SetPath(address indexed token, bytes path);
    event RemovePath(address indexed token);
    event WithdrawERC20(address indexed token, address receiver, uint256 amount);
    event SetKeeper(address indexed keeper);
    event RemoveKeeper(address indexed keeper);
    event SetSolidlyRouter(address indexed router);
    event SetAlgebraRouter(address indexed router);
    event SetMasterchef(address indexed chef);
    event SetRewardToken(address indexed token);
    event TriggerPause(bool newState);



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
