// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


contract PancakeSwap {
  address public owner;
  address private constant BISWAP_FACTORY = 0x858E3312ed3A876947EA49d572A7C42DE08af7EE;
  address private constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

  address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
  address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;

  IPancakeFactory private constant factory = IPancakeFactory(BISWAP_FACTORY);
  IPancakeRouter private constant router = IPancakeRouter(PANCAKE_ROUTER);
  IPancakePair private immutable pair;

  constructor() {
    // any BUSD pair, as we only borrowing BUSD. here we choose BUSD/USDT pair
    pair = IPancakePair(factory.getPair(BUSD, USDT));
    owner = msg.sender;
  }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract deployer can call this function");
        _;
    }

  function withdrawDeposit() external onlyOwner {
    uint256 contractBalance = IERC20(BUSD).balanceOf(address(this));
    IERC20(BUSD).transfer(owner, contractBalance);
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

  // make sure you have enough BUSD in your smart contract to perform swaps
  function swap(uint busdAmount, address _otherAddress, uint8 slippagePercentage) external {
    uint amountReceived = swapTokens(busdAmount, BUSD, _otherAddress, slippagePercentage); // perform first swap from borrowed BUSD to OTHER token
    swapTokens(amountReceived, _otherAddress, BUSD, slippagePercentage); // perform second swap from received OTHER token to BUSD
  }
}

interface IPancakePair {
  function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
}

interface IPancakeFactory {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IPancakeRouter {
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