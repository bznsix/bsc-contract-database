// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IBiswapCallee {
  function BiswapCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

contract FlashSwap is IBiswapCallee {
  address public owner;
  address private constant BISWAP_FACTORY = 0x858E3312ed3A876947EA49d572A7C42DE08af7EE;
  address private constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

  address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
  address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;

  IFactory private constant factory = IFactory(BISWAP_FACTORY);
  IRouter private constant router = IRouter(PANCAKE_ROUTER);
  IPair private immutable pair;

  event Log(string message, uint val);

  constructor() {
    // any BUSD pair(that has better liq, will fulfill our flashloan need). here we choose BUSD/USDT pair
    pair = IPair(factory.getPair(BUSD, USDT));
    owner = msg.sender;
  }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract deployer can call this function");
        _;
    }

  // withdraw any BUSD deposited in the Contract
  function withdrawDeposit() external onlyOwner {
    uint256 contractBalance = IERC20(BUSD).balanceOf(address(this));
    IERC20(BUSD).transfer(owner, contractBalance);
  }
  function flashSwap(uint busdAmount, address _otherAddress, uint8 slippagePercentage) external {
    // Need to pass some data to trigger BiswapCall
    bytes memory data = abi.encode(_otherAddress, busdAmount, slippagePercentage);

    // amount0Out is USDT, amount1Out is BUSD (beacuse pair initialized in the constructor is BUSD/USDT)
    pair.swap(0, busdAmount, address(this), data);
  }

  // This function is called by the BUSD pair contract, NOTE do not interact with this function
  function BiswapCall(address sender, uint _amount0, uint _amount1, bytes calldata data) external {
    require(msg.sender == address(pair), 'not pair');
    require(sender == address(this), 'not sender');

    (address OTHER, uint amount, uint8 slippagePercentage) = abi.decode(data, (address, uint, uint8));

    uint amountReceived = swapTokens(amount, BUSD, OTHER, slippagePercentage); // perform first swap from borrowed BUSD to OTHER token
    swapTokens(amountReceived, OTHER, BUSD, slippagePercentage); // perform second swap from received OTHER token to BUSD

    uint amountToRepay = amount + calcFee(amount); // we need to repay the borrowed BUSD + 0.3009027% fee

    // Repay the borrowed BUSD
    IERC20(BUSD).transfer(address(pair), amountToRepay);
  }

  
  function swapTokens(uint _amt, address token0, address token1, uint8 slippagePercentage) internal returns (uint amountOut) {
    address[] memory path = new address[](2);
    path[0] = token0;
    path[1] = token1;

    IERC20(token0).approve(address(router), _amt);

    uint256[] memory amountsOut = router.getAmountsOut(_amt, path);
    uint256 _amountOut = amountsOut[amountsOut.length - 1];

    uint256 amountOutMin = _amountOut * (100 - slippagePercentage) / 100; // Applying a slippage tolerance of slippagePercentage
    uint256 deadline = block.timestamp + 1 hours;

    uint[] memory amounts = router.swapExactTokensForTokens(_amt, amountOutMin, path, address(this), deadline);

    return amounts[1];
  }

  /**
   * https://docs.uniswap.org/contracts/v2/guides/smart-contract-integration/using-flash-swaps#single-token
   */
  function calcFee(uint amount) internal pure returns (uint fee) {
    return ((amount * 3) / 997);
  }
}

interface IPair {
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IFactory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IRouter {
  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
}

interface IERC20 {
  function totalSupply() external view returns (uint);

  function balanceOf(address account) external view returns (uint);

  function transfer(address recipient, uint amount) external returns (bool);

  function allowance(address owner, address spender) external view returns (uint);

  function approve(address spender, uint amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}