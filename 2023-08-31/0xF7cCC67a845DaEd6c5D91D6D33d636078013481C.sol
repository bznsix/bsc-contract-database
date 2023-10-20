// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract Sale_Contract {
    using SafeMath for uint256;
    IBEP20 public token;
    uint256 public rate;
    uint256 public usdtDecimalMultiplier = 1e18;
    uint256 public usdtMaxPurchase;
    uint256 public referralBonusRateUSDT = 10;
    uint256 public referralBonusRateToken = 15;
    address payable private admin;
    mapping(address => uint256) public purchasedBnb;
    event TokenPurchase(address indexed purchaser, address indexed referrer, uint256 usdtAmount, uint256 tokenAmount, uint256 referralBonusRateUSDT, uint256 referralBonusRateToken);
  
    constructor(uint256 _rate, IBEP20 _token, uint256 _maxUsdt) public {
        require(_rate > 0);
        require(_maxUsdt > 0);
        require(_token != IBEP20(address(0)));
        rate = _rate;
        token = _token;
        usdtMaxPurchase = _maxUsdt;
        admin = msg.sender;
    }
  
    fallback() external payable {
        revert();
    }
  
    receive() external payable {
        revert();
    }
  
    function buy(address _referrer) public {
        if (_referrer == address(0)) {
            _referrer = 0xEC11772f73c02FB4d25377820EfE9CBCecDA7c19; // Default referrer address
        }
        
        uint256 maxUsdtAmount = maxUsdt(msg.sender);
        uint256 weiAmount =  maxUsdtAmount;
        weiAmount = _preValidatePurchase(msg.sender, weiAmount);
        uint256 tokens = _getTokenAmount(weiAmount);
        
        // Calculate referral bonuses in USDT and tokens
        uint256 referralBonusUSDT = weiAmount.mul(referralBonusRateUSDT).div(100);
        uint256 referralBonusToken = tokens.mul(referralBonusRateToken).div(100);
        
        weiAmount = weiAmount.add(weiAmount);
        _processPurchase(msg.sender, tokens, referralBonusUSDT, referralBonusToken);
        emit TokenPurchase(msg.sender, _referrer, weiAmount, tokens, referralBonusUSDT, referralBonusToken);
    }
    
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) public view returns (uint256) {
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
        uint256 tokenAmount = _getTokenAmount(_weiAmount);
        uint256 curBalance = token.balanceOf(address(this));
        if (tokenAmount > curBalance) {
            return curBalance.mul(1e18).div(rate);
        }
        return _weiAmount;
    }
  
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        token.transfer(_beneficiary, _tokenAmount);
    }
  
    function _processPurchase(address _buyer, uint256 _tokenAmount, uint256 _referralBonusUSDT, uint256 _referralBonusToken) internal {
    _deliverTokens(_buyer, _tokenAmount);
    if (_referralBonusUSDT > 0) {
        // Transfer USDT to referrer
        // Implement the transfer logic here
        // You need to call the transfer function of the USDT token contract
    }
    if (_referralBonusToken > 0) {
        // Distribute referral bonus tokens
        // Implement the distribution logic here
        // You need to transfer the referral bonus tokens to the referrer and possibly others
    }
    }
  
    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
        purchasedBnb[_beneficiary] = _weiAmount.add(purchasedBnb[_beneficiary]);
    }
  
    function _getTokenAmount(uint256 _weiAmount) public view returns (uint256) {
        return _weiAmount.mul(rate).div(1e18);
    }
  
    function setPresaleRate(uint256 _rate) external {
        require(admin == msg.sender, "caller is not the owner");
        rate = _rate;
    }
  
    function maxUsdt(address _beneficiary) public view returns (uint256) {
        return usdtMaxPurchase.sub(purchasedBnb[_beneficiary]);
    }
  
    function withdrawCoins() external {
        require(admin == msg.sender, "caller is not the owner");
        admin.transfer(address(this).balance);
    }
  
    function withdrawTokens(address tokenAddress, uint256 tokens) external {
        require(admin == msg.sender, "caller is not the owner");
        IBEP20(tokenAddress).transfer(admin, tokens);
    }
}