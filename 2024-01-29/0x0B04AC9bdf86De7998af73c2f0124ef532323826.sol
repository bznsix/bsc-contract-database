/**
 *Submitted for verification at BscScan.com on 2023-08-11
*/

/**
 *Submitted for verification at BscScan.com on 2023-08-09
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.6.0;

interface BEP20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract BuySell{
      
    BEP20 public maintoken;
    BEP20 public swaptoken;       
    
    address private admin;

    uint256 private _totalSupply;

    uint256 public buyRatePerToken;
    uint256 public sellRatePerToken;
    uint256 public rateDiv;
    uint256 public amnt;
    uint256 public Sellstatus;
    uint256 public Buystatus;
    uint256 public buytokenDecimal;
    uint8 public maintokenDecimals;

    modifier onlyActiveStatusForBuy() {
        require(Buystatus != 0, "Function can only be called when status is non-zero");
        _;
    }
    modifier onlyActiveStatusForSell() {
        require(Sellstatus != 0, "Function can only be called when status is non-zero");
        _;
    }

    function setSellStatus(uint256 _status) public onlyOwner returns(bool){
        Sellstatus = _status;
        return true;
    }
    function setBuyStatus(uint256 _status) public onlyOwner returns(bool){
        Buystatus = _status;
        return true;
    }

    
    modifier onlyOwner() {
        require(msg.sender == admin, "Message sender must be the contract's owner.");
        _;
    }

    event Sale(address indexed buyer, uint256 indexed spent, uint256 indexed recieved);
    event Buy(address indexed buyer, uint256 indexed spent, uint256 indexed recieved);
    
    constructor (address _maintoken,address _swaptoken) public {
              
        maintoken = BEP20(_maintoken); 
        swaptoken = BEP20(_swaptoken);
        maintokenDecimals=maintoken.decimals();         
        admin = msg.sender;

        buyRatePerToken = 100;
        sellRatePerToken = 80;
        rateDiv = 1000;
    }

    
    function sale(uint256 amount, BEP20 b_token) public onlyActiveStatusForSell returns (bool) {
       
        _sale(msg.sender, amount, b_token);
        return true;
    }
    
    function buy(uint256 amount , BEP20 token) public onlyActiveStatusForBuy returns (bool) {
       
        _buy(msg.sender, amount, token);
        return true;
    }
    
    function _sale(address sender, uint256 amount, BEP20 b_token) internal {
          
        require(sender != address(0), "BEP20: transfer from the zero address");
        
        require(amount > 0, "BEP20: Amount Should be greater then 0!");   
         require(
        b_token == swaptoken,
        "BEP20: Buy Token is invalid"
        );     
        require(amount <= maintoken.balanceOf(sender), "BEP20: Insufficient Token in your wallet!");   
        
        uint256 usdt =  (amount * sellRatePerToken)/rateDiv;
        require(usdt <= b_token.balanceOf(address(this)), "BEP20: Insufficient fund balance!");
        maintoken.transferFrom(msg.sender, address(this), amount);
        //BEP20(b_token).transfer(msg.sender, tokens);
        b_token.transfer(msg.sender, usdt);
        emit Sale(sender, amount, usdt);
    }


    function _buy(address sender, uint256 amount, BEP20 token) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(token == swaptoken, "BEP20: Buy Token is invalid");
        require(amount > 0, "BEP20: Amount Should be greater then 0!");        
        require(amount <= maintoken.balanceOf(address(this)), "BEP20: Insufficient Token!!");
        uint256 usdt = (amount * buyRatePerToken)/rateDiv;
        require(usdt <= token.balanceOf(sender), "BEP20: Insufficient Fund in Your wallet!!");
        require(token.transferFrom(sender, address(this), usdt), "BEP20: Transfer failed");
        maintoken.transfer(msg.sender, amount);   
        emit Buy(sender, usdt, amount);
    }

    function buygetrate(uint256 rate,uint256 div)public onlyOwner returns(bool){
        buyRatePerToken = rate;
        rateDiv = div;
        return true;
    }
    function salegetrate(uint256 rate,uint256 div)public onlyOwner returns(bool){
        sellRatePerToken = rate;
        rateDiv = div;
        return true;
    }

    function withdraw(BEP20 BUSD, address userAddress, uint256 amt) external onlyOwner() returns(bool){
        require(BUSD.balanceOf(address(this)) >= amt,"ErrAmt");
        BUSD.transfer(userAddress, amt);
        // emit Withdrawn(userAddress, amt);
        return true;
    }

    function shareSingleContribution(address payable  _contributors, uint256 _balances , BEP20 token) public payable {        
           token.transferFrom(msg.sender,_contributors,_balances);      
    }

    function changeMainToken(BEP20 _maintoken)public onlyOwner returns(bool){           
        maintoken = BEP20(_maintoken);   
        maintokenDecimals=maintoken.decimals();   
        return true;
    }

    function changeSwapToken(BEP20 _swaptoken)public onlyOwner returns(bool){           
        swaptoken = BEP20(_swaptoken);   
        return true;
    }
 
}