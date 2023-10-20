// SPDX-License-Identifier: MIT 

// TG: https://t.me/PepeCraftBSC

pragma solidity ^0.8.19;

abstract contract Context {
  constructor() {
  }

  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view returns (bytes memory) {
    this;
    return msg.data;
  }
}

abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    _setOwner(_msgSender());
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public virtual onlyOwner {
    _setOwner(address(0));
  }

  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "new owner is the zero address");
    _setOwner(newOwner);
  }

  function _setOwner(address newOwner) private {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

interface IFactoryV2 {
  event PairCreated(address indexed token0, address indexed token1, address lpPair, uint);
  function getPair(address tokenA, address tokenB) external view returns (address lpPair);
  function createPair(address tokenA, address tokenB) external returns (address lpPair);
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

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

interface IV2Pair {
  function factory() external view returns (address);
  function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
  function sync() external;
}

interface IRouter01 {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);
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
  function swapExactETHForTokens(
      uint amountOutMin, 
      address[] calldata path, 
      address to, uint deadline
  ) external payable returns (uint[] memory amounts);
  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
  function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IERC20 {
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

interface IRouter02 is IRouter01 {
  function swapExactTokensForETHSupportingFeeOnTransferTokens(
      uint amountIn,
      uint amountOutMin,
      address[] calldata path,
      address to,
      uint deadline
  ) external;
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
  
  function swapExactTokensForTokens(
      uint amountIn,
      uint amountOutMin,
      address[] calldata path,
      address to,
      uint deadline
  ) external returns (uint[] memory amounts);
}

contract PepeCraft is Context, Ownable, IERC20 {
  using SafeMath for uint256;

  uint256 constant public RouterBSCMainnet = 56;
  uint256 constant public RouterBSCTestnet = 97;

  address constant public deadAddress = 0x000000000000000000000000000000000000dEaD;

  string constant private _name        = "PepeCraft";
  string constant private _symbol      = "PECRAFT";
  uint8 constant private _decimals     = 18;
  uint256 constant public _totalSupply = 100000000000 * 10**18;
  
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => uint256) private balance;
  mapping (address => bool) private _isAddrExcludedFromFee;
  mapping (address => bool) private _isExcludedMaxTransactionAmount;

  IRouter02 public swapRouter;
  address public lpPair;

  bool private inSwap;
  bool public swapAndLiquifyEnabled = false;
  bool public tradingActive = false;

  uint256 private minimumTokensBeforeSwap = _totalSupply * 10 / 10000; // 0.1%

  uint256 public maxWallet;

  uint256 public liquidityTokensToSwap;
  uint256 public marketingTokensToSwap;
  uint256 public teamTokensToSwap;

  uint256 public sellLiquidityFee = 2;
  uint256 public sellMarketingFee = 2;
  uint256 public sellTeamFee = 1;

  uint256 public buyLiquidityFee = 2;
  uint256 public buyMarketingFee = 2;
  uint256 public buyTeamFee = 1;

  address payable public teamAddress = payable(0x28c4d8291D8Da17F5b08F3490B6C7edBb28546C7);
  address payable public marketingAddress = payable(0x597c63d007B4EFbefaf34B4514d92cd3F62BA140);
  address payable public liquidityAddress = payable(0x597c63d007B4EFbefaf34B4514d92cd3F62BA140);

  event SwapAndLiquify(
    uint256 tokensSwapped,
    uint256 ethReceived,
    uint256 tokensIntoLiquidity
  );

  modifier inSwapFlag {
    inSwap = true;
    _;
    inSwap = false;
  }

  receive() external payable {}

  constructor () {

    if (block.chainid == RouterBSCMainnet) {
      swapRouter = IRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    } else if (block.chainid == RouterBSCTestnet) {
      swapRouter = IRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
    } else {
      revert("Not valid");
    }

    _isAddrExcludedFromFee[owner()]       = true;
    _isAddrExcludedFromFee[address(this)] = true;
    _isAddrExcludedFromFee[deadAddress]   = true;
    _isAddrExcludedFromFee[address(swapRouter)] = true;

    maxWallet = _totalSupply * 30 / 1000; 

    balance[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);

    lpPair = IFactoryV2(swapRouter.factory()).createPair(swapRouter.WETH(), address(this));

    _isExcludedMaxTransactionAmount[lpPair] = true;
    _isExcludedMaxTransactionAmount[address(swapRouter)] = true;

    _approve(address(this), address(swapRouter), type(uint256).max);
    _approve(address(this), lpPair, type(uint256).max);
  } 

  function totalSupply() external pure override returns (uint256) {
    return _totalSupply; 
  }
  
  function decimals() external pure override returns (uint8) { 
    return _decimals; 
  }

  function symbol() external pure override returns (string memory) { 
    return _symbol; 
  }

  function name() external pure override returns (string memory) { 
    return _name; 
  }

  function getOwner() external view override returns (address) { 
    return owner(); 
  }

  function allowance(address holder, address spender) external view override returns (uint256) { 
    return _allowances[holder][spender]; 
  }
  
  function balanceOf(address account) public view override returns (uint256) {
    return balance[account];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function _approve(address sender, address spender, uint256 amount) internal {
    require(sender != address(0), "ERC20: Zero Address");
    require(spender != address(0), "ERC20: Zero Address");

    _allowances[sender][spender] = amount;
  }

  function isBuy(address fromAddress, address toAddress) internal view returns (bool) {
    bool _isBuy = toAddress != lpPair && lpPair == fromAddress;
    return _isBuy;
  }

  function isSell(address fromAddress, address toAddress) internal view returns (bool) { 
    bool _isSell = toAddress == lpPair && lpPair != fromAddress;
    return _isSell;
  }

  function isTransfer(address fromAddress, address toAddress) internal view returns (bool) { 
    bool _isTransfer = toAddress != lpPair && lpPair != fromAddress;
    return _isTransfer;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    if (_allowances[sender][_msgSender()] != type(uint256).max) {
      _allowances[sender][_msgSender()] -= amount;
    }

    return _transfer(sender, recipient, amount);
  }

  function transfer(address recipient, uint256 amount) public override returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }

  function _transfer(address from, address to, uint256 amount) internal returns (bool) {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");
        
    if(!tradingActive){
      require( _isAddrExcludedFromFee[from] || _isAddrExcludedFromFee[to], "Trading is not currently active.");
    }

    uint256 contractTokenBalance = balanceOf(address(this));
    bool overMinimumTokenBalance = contractTokenBalance >= minimumTokensBeforeSwap;
    bool isExcluded = _isAddrExcludedFromFee[to] || _isAddrExcludedFromFee[from];

    if (isBuy(from, to) && !_isExcludedMaxTransactionAmount[to]) {
      require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded.");
    }

    if (
      overMinimumTokenBalance &&
      isSell(from, to) &&
      !inSwap &&
      swapAndLiquifyEnabled &&
      isExcluded == false
    ) {
      swapBack();
    }

    uint256 amountAfterTaxes = takeFees(from, to, amount);

    balance[from] = balance[from].sub(amount, "Insufficient Balance"); 
    balance[to]   = balance[to].add(amountAfterTaxes);

    emit Transfer(from, to, amountAfterTaxes);

    return true;
  }

  function takeFees(address from, address to, uint256 amount) internal returns (uint256) {
    bool isExcluded = _isAddrExcludedFromFee[to] || _isAddrExcludedFromFee[from];

    uint256 totalFee = 0;
    uint256 totalFeeTokens = 0;
    
    if (isExcluded == false) {
      if (isSell(from, to)) {
        liquidityTokensToSwap += amount.mul(sellLiquidityFee).div(100);
        marketingTokensToSwap += amount.mul(sellMarketingFee).div(100);
        teamTokensToSwap += amount.mul(sellTeamFee).div(100);

        totalFee = sellLiquidityFee + sellMarketingFee + sellTeamFee;
      }
      // is buy or transfer
      else { 
        liquidityTokensToSwap += amount.mul(buyLiquidityFee).div(100);
        marketingTokensToSwap += amount.mul(buyMarketingFee).div(100);
        teamTokensToSwap += amount.mul(buyTeamFee).div(100);

        totalFee = buyLiquidityFee + buyMarketingFee + buyTeamFee;
      }
    }

    if (totalFee > 0) {
      totalFeeTokens = amount.mul(totalFee).div(100);
      balance[address(this)] += totalFeeTokens;
      emit Transfer(from, address(this), totalFeeTokens);
    }
    
    return amount.sub(totalFeeTokens);
  }

  function enableTrading() external onlyOwner {
    tradingActive = true;
    swapAndLiquifyEnabled = true;
  }

  function swapBack() private inSwapFlag {
    uint256 contractBalance = balanceOf(address(this));
    
    uint256 totalTokensToSwap = liquidityTokensToSwap.add(teamTokensToSwap).add(marketingTokensToSwap);
    
    uint256 tokensForLiquidity = liquidityTokensToSwap.div(2);
    uint256 amountToSwapForBNB = contractBalance.sub(tokensForLiquidity);
    
    uint256 initialBNBBalance = address(this).balance;

    swapTokensForBNB(amountToSwapForBNB); 
    
    uint256 bnbBalance = address(this).balance.sub(initialBNBBalance);
    
    uint256 bnbForMarketing = bnbBalance.mul(marketingTokensToSwap).div(totalTokensToSwap);
    uint256 bnbForTeam = bnbBalance.mul(teamTokensToSwap).div(totalTokensToSwap);
    
    uint256 bnbForLiquidity = bnbBalance.sub(bnbForMarketing).sub(bnbForTeam);

    liquidityTokensToSwap = 0;
    marketingTokensToSwap = 0;
    teamTokensToSwap = 0;
    
    (bool success,) = address(teamAddress).call{value: bnbForTeam}("");
    (success,) = address(marketingAddress).call{value: bnbForMarketing}("");
    
    addLiquidity(tokensForLiquidity, bnbForLiquidity);
    emit SwapAndLiquify(amountToSwapForBNB, bnbForLiquidity, tokensForLiquidity);
    
    // send leftover BNB to the marketing wallet so it doesn't get stuck on the contract.
    if(address(this).balance > 1e17){
        (success,) = address(marketingAddress).call{value: address(this).balance}("");
    }
  }

  function swapTokensForBNB(uint256 tokenAmount) private {
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = swapRouter.WETH();
    _approve(address(this), address(swapRouter), tokenAmount);
    swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
      tokenAmount,
      0, // accept any amount of BNB
      path,
      address(this),
      block.timestamp
    );
  }
    
  function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
    _approve(address(this), address(swapRouter), tokenAmount);
    swapRouter.addLiquidityETH{value: ethAmount}(
      address(this),
      tokenAmount,
      0, // slippage is unavoidable
      0, // slippage is unavoidable
      liquidityAddress,
      block.timestamp
    );
  }

  function isExcludedFromFee(address account) external view returns (bool) {
    return _isAddrExcludedFromFee[account];
  }

  function isExcludedFromMaxTransaction(address account) external view returns (bool) {
    return _isExcludedMaxTransactionAmount[account];
  }

  function excludeFromFee(address account) external onlyOwner {
    _isAddrExcludedFromFee[account] = true;
  }

  function includeInFee(address account) external onlyOwner {
    _isAddrExcludedFromFee[account] = false;
  }

  function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {
    _isExcludedMaxTransactionAmount[updAds] = isEx;
  }

  function setmarketingAddress(address _marketingAddress) external onlyOwner {
    require(_marketingAddress != address(0), "marketingAddress address cannot be 0");
    marketingAddress = payable(_marketingAddress);
    _isAddrExcludedFromFee[marketingAddress] = true;
  }

  function setTeamAddress(address _teamAddress) external onlyOwner {
    require(_teamAddress != address(0), "teamAddress address cannot be 0");
    teamAddress = payable(_teamAddress);
    _isAddrExcludedFromFee[teamAddress] = true;
  }

  function setBuyFee(uint256 newBuyLiquidityFee, uint256 newBuyMarketingFee, uint256 newBuyTeamFee) external onlyOwner {
    buyLiquidityFee = newBuyLiquidityFee;
    buyMarketingFee = newBuyMarketingFee;
    buyTeamFee = newBuyTeamFee;
    require(newBuyLiquidityFee + newBuyMarketingFee + newBuyTeamFee <= 9, "Must keep taxes below 9%");
  }

  function setSellFee(uint256 newSellLiquidityFee, uint256 newSellMarketingFee, uint256 newSellTeamFee) external onlyOwner {
    sellLiquidityFee = newSellLiquidityFee;
    sellMarketingFee = newSellMarketingFee;
    sellTeamFee = newSellTeamFee;
    require(newSellLiquidityFee + newSellMarketingFee + newSellTeamFee <= 9, "Must keep taxes below 9%");
  }

  function setMinimumTokensBeforeSwap(uint256 newMinimumTokensBeforeSwap) external onlyOwner {
    minimumTokensBeforeSwap = newMinimumTokensBeforeSwap;
  }

  function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
    swapAndLiquifyEnabled = _enabled;
  }

  function rescueStuckBEP20(address tokenAddress, address to, uint256 amount) public onlyOwner() {
    require(tokenAddress != address(this), "Can't withdraw jungle tokens");
    IERC20(tokenAddress).transfer(to, amount);
  }

  function rescueStuckETH(address to) public onlyOwner() {
    uint ethers = address(this).balance;
    payable(to).transfer(ethers);
  }
}