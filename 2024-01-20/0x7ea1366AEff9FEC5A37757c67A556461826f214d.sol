// SPDX-License-Identifier: MIT
pragma solidity 0.8.0; 

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }
}

 
contract owned {
    address  public owner;
    address  internal newOwner;

modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
   
}

interface tokenInterface
 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
    function balanceOf(address _user) external view returns(uint);
 }

contract Tycoon_coin_exchange is owned {

    address public tokenAddress;
    address public USDTAddress;

    mapping(address => uint) public userTokenAmount;


    constructor(){
        owner = msg.sender;
    }

    function topupFund(address _USDTAddress, address _tokenAddress, uint initialUSDT, uint initialToken) public onlyOwner returns(bool)
    {
        require(initialToken > 0 && initialUSDT > 0, "invalid initial");
        owner = msg.sender;
        tokenInterface(_tokenAddress).transferFrom(msg.sender,address(this),initialToken);
        tokenInterface(_USDTAddress).transferFrom(msg.sender,address(this),initialUSDT);
        USDTAddress = _USDTAddress;
        tokenAddress = _tokenAddress;
        userTokenAmount[msg.sender] = initialToken;
        return true;
    }


    //current rate is with divisor 1000000000000000000 , to adjust fractional values
    function currentRate() public view returns(uint)
    {
        uint usdtBalance = tokenInterface(USDTAddress).balanceOf(address(this)); 
        uint tBalance = tokenInterface(tokenAddress).balanceOf(address(this));
        uint curRate =  usdtBalance * (10 ** 18 ) / tBalance;
        return curRate;
    }

    function TYCO_COIN_Locked_Token(address token, uint256 values) public onlyOwner {     
        tokenInterface(token).transfer(owner, values);       
    }

    event tokenBoughtEv(address _user, uint usdt, uint token);
    function buyTokens(uint _amountUSDT) public {
       
        tokenInterface(USDTAddress).transferFrom(msg.sender, address(this), _amountUSDT);
        
        uint tokenAmount = _amountUSDT * ( 10 ** 18 ) / currentRate();                 // calculates the tokenAmount
        tokenInterface(tokenAddress).transfer(msg.sender, tokenAmount);
        userTokenAmount[msg.sender]+= tokenAmount;
        emit tokenBoughtEv(msg.sender, _amountUSDT, tokenAmount);
    }

    event tokenSoldEv(address _soldBy,uint receivedUSDT, uint _soldAmount);
    function sellTokens(uint256 amountToken) public {
        require(userTokenAmount[msg.sender] >= amountToken, "low balance");
        tokenInterface(tokenAddress).transferFrom(msg.sender,address(this), amountToken);

        userTokenAmount[msg.sender] -= amountToken;

        uint256 usdtAmount = amountToken * currentRate() /(10 ** 18);
        usdtAmount = usdtAmount;
        require(tokenInterface(USDTAddress).balanceOf(address(this)) >= usdtAmount,"insufficient usdt available");   // checks if the contract has enough usdt to buy

        tokenInterface(USDTAddress).transfer(msg.sender,usdtAmount);
        emit tokenSoldEv(msg.sender, usdtAmount, amountToken);
    }

}