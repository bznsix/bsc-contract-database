// SPDX-License-Identifier: Unlicensed

// Deployed with the Atlas IDE
// https://app.atlaszk.com

pragma solidity ^0.8.0;

import './IERC20Upgradeable.sol';

contract SwapContract {
 
    address payable public owner;    
    IERC20Upgradeable public BBC; 
    IERC20Upgradeable public USDT; 
    uint256 public BBC_DECIMALS = 18; 
    uint256 public USDT_DECIMALS = 18;  
    uint256 public rateToBBC = 1;     // 1 BBC = 50 USDT
    uint256 public rateToUSDT = 50;   // 1 USDT = 1 / 50 BBC = 0.02 BBC 
    uint256 public feeRate = 10;  // 手续费率,单位为%


    event Swap(address indexed inputToken, uint256 inputAmount, address indexed outputToken, uint256 outputAmount, address indexed recipient);

    // Define the addresses of the tokens 
    constructor() {        
        owner = payable(msg.sender); 
        BBC = IERC20Upgradeable(0xfd332080C56273bdA14E9C8250b5d6Bcc43dB4D5);        
        USDT = IERC20Upgradeable(0x55d398326f99059fF775485246999027B3197955); 
    } 

    modifier onlyOwner() {        
        require(msg.sender == owner, "Not the contract owner"); 
        _;    
    } 
    
    function transferOwnership(address payable  newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address.");
        owner = newOwner;
    }

  function swap(address payable _inputToken,  uint256 _inputAmount, address payable _outputToken, address payable _to) public returns (uint256) {
    require(_inputToken != address(0), "Invalid input token address");
    require(_outputToken != address(0), "Invalid output token address");
    require(_to != address(0), "Invalid recipient address");

    IERC20Upgradeable inputToken = IERC20Upgradeable(_inputToken);
    IERC20Upgradeable outputToken = IERC20Upgradeable(_outputToken);
 

    require(inputToken != outputToken, "Input and output tokens must be different");
    // 检查输入代币余额是否足够
    require(inputToken.balanceOf(msg.sender) >= _inputAmount, "Insufficient input token balance");


   if(inputToken == USDT) {
        // 计算可兑换BBC数量
        uint256 amountOut = convert(_inputAmount, true);   // toBBC = true
        // 检查BBC余额是否足够
        require(BBC.balanceOf(address(this)) >= amountOut, "Insufficient BBC balance in the contract");

        inputToken.transferFrom(msg.sender, address(this), _inputAmount);
        outputToken.transfer(_to, amountOut);

        // 触发Swap事件
        emit Swap(_inputToken, _inputAmount, _outputToken, amountOut, _to);
        return amountOut;
    } else if(inputToken == BBC) {
        // 计算可兑换USDT数量
        uint amountOut = convert(_inputAmount, false);   // toBBC = false
        // 检查USDT余额是否足够
        require(USDT.balanceOf(address(this)) >= amountOut, "Insufficient USDT balance in the contract");

        inputToken.transferFrom(msg.sender, address(this), _inputAmount); 
        outputToken.transfer(_to, amountOut);

        // 触发Swap事件
        emit Swap(_inputToken, _inputAmount, _outputToken, amountOut, _to);
        return amountOut;
    } else {
        revert("Invalid token");
    }
    
  }

    function convert(uint256 inputAmount, bool toBBC) public view returns (uint256) {
        uint256 decRate;
        require(toBBC ? rateToBBC != 0 : rateToUSDT != 0, "Invalid rate");

        if (toBBC) {
            // 计算比率：(1/50) => 1 BBC = 50 USDT
            decRate =  (10**(BBC_DECIMALS + USDT_DECIMALS)) * rateToBBC / rateToUSDT; 
         } else {
           // 计算比率： (1/50) => 0.02 BBC = 1 USDT 
           decRate =   (10**(BBC_DECIMALS + USDT_DECIMALS)) * rateToUSDT / rateToBBC;
         }
 
        // 计算输出金额
        uint256 _amountOut = inputAmount * decRate / (10**(USDT_DECIMALS + BBC_DECIMALS));
 
        // 计算手续费
        uint256 _feeAmount = (_amountOut * feeRate) / 100;
 
        // 检查手续费是否超过输入数量
        require(_feeAmount <= _amountOut, "Invalid fee amount");

        _amountOut = _amountOut - _feeAmount;
 
        return _amountOut;
    }

  

 

    //函数设置手续费率
    function setFeeRate(uint _feeRate) external onlyOwner {
        feeRate = _feeRate;
    }

    function setRateToBBC(uint256 _rateToBBC) external onlyOwner {
        rateToBBC = _rateToBBC;
    }

    function setRateToUSDT(uint256 _rateToUSDT) external onlyOwner {
        rateToUSDT = _rateToUSDT;
    }

    // 提取 ERC20 Token 
    function withdrawTokens(address tokenAddress, uint256 amount) external onlyOwner {        
        IERC20Upgradeable(tokenAddress).transfer(owner, amount); 
    }

    // 提取 ETH
    function withdrawEther() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // 存入 USDT
    function depositUSDT(uint amount) external onlyOwner {
        USDT.transferFrom(msg.sender, address(this), amount);
    }

    // 存入 BBC 
    function depositBBC(uint amount) external onlyOwner {
        BBC.transferFrom(msg.sender, address(this), amount); 
    }

    // 替换BBC地址
    function setBbcToken(address _bbcToken) external onlyOwner {
        BBC = IERC20Upgradeable(_bbcToken);
    }
    // 替换USDT地址
    function setUsdtToken(address _usdtToken) external onlyOwner {
        USDT = IERC20Upgradeable(_usdtToken);
    }

   // 替换 USDT 精度
    function setUsdtDecimals(uint256 _decimals) external onlyOwner {
        USDT_DECIMALS = _decimals;
    }

   // 替换 BBC 精度
    function setBbcDecimals(uint256 _decimals) external onlyOwner {
        BBC_DECIMALS = _decimals;
    }

    function getUSDTBalance(address _address) public view returns (uint) {
        return USDT.balanceOf(_address);
    }

    function getBBCBalance(address _address) public view returns (uint) {
        return BBC.balanceOf(_address);
    }



}// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

interface IERC20Upgradeable {
  function decimals() external view returns (uint8);
  function transferFrom(address from, address to, uint amount) external;
  function transfer(address payable to, uint amount) external;
  function balanceOf(address account) external view returns (uint256); 
  function allowance(address owner, address spender) external view returns (uint256);
}