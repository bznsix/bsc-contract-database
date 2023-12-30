// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.24 <0.9.0;

contract TRC20 {
       function transfer(address recipient, uint256 amount) public returns (bool);
       function transferFrom(address sender, address recipient, uint256 amount) public returns (bool);
       function balanceOf(address account) public returns (uint256);
    }
contract MyEOTC {
  address owner;
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  struct order {
      address ads;
      uint256 order_amount;
      uint coin;
  }
  struct order_out {
      address ads;
      address ads_out;
      uint256 order_amount;
      uint coin;
  }
  struct order_out0 {
      address ads;
      address ads_out;
      uint256 order_amount;
      uint coin;
      string oid;
  }
  struct airData{
      uint256 airNum;
  }
 
  mapping(uint => address)tradingCoins;

  mapping(string => order) orderMapping;
 
  mapping(string => order_out0) orderMapping_out;

  mapping(string => order_out) order_outMapping;

  mapping(string => order) arbMapping;

  mapping(address => airData) airMapping;
  
  constructor() public{
    owner = msg.sender;
  }
  

 function transferIn(uint256 amount,string orderID,uint coinID)public returns(bool){
    TRC20 usdt = TRC20(tradingCoins[coinID]);
    require(usdt.transferFrom(msg.sender,address(this), amount));
    order memory ors=order(msg.sender,amount,coinID);
    orderMapping[orderID]=ors;
    return true;
 }

 function transferAdd(uint256 amount,string orderID,uint coinID)public returns(bool){
    require(msg.sender==orderMapping[orderID].ads && coinID==orderMapping[orderID].coin);
    TRC20 usdt = TRC20(tradingCoins[coinID]);
    require(usdt.transferFrom(msg.sender,address(this), amount));
    orderMapping[orderID].order_amount+=amount;
    return true;
 }
 
 function transferOut(string orderID,uint256 amount,uint coinID)public returns(bool){
    uint256 amount1=orderMapping[orderID].order_amount;
    if(msg.sender==orderMapping[orderID].ads && amount<=amount1 && coinID==orderMapping[orderID].coin){
      TRC20 usdt = TRC20(tradingCoins[coinID]);
      usdt.transfer(msg.sender, amount);
      orderMapping[orderID].order_amount=amount1-amount;
      return true;
    }
 }

 function transferIn00(uint256 amount,string orderID,string oid,uint coinID,address orderads)
 public returns(bool){
    uint256 amount1=orderMapping[oid].order_amount;
    require(msg.sender==orderMapping[oid].ads && amount<=amount1 && coinID==orderMapping[oid].coin);
    orderMapping[oid].order_amount=amount1-amount;
    order_out0 memory ors=order_out0(msg.sender,orderads,amount,coinID,oid);
    orderMapping_out[orderID]=ors;
    return true;
 }

 function transferIn0(uint256 amount,string orderID,address orderads,string oid,uint coinID)
 public returns(bool){
    uint256 amount1=orderMapping[oid].order_amount;
    require(orderads==orderMapping[oid].ads && amount<=amount1 && coinID==orderMapping[oid].coin);
    orderMapping[oid].order_amount=amount1-amount;
    order_out0 memory ors=order_out0(orderads,msg.sender,amount,coinID,oid);
    orderMapping_out[orderID]=ors;
    return true;
 }


 function transferIn01(string orderID) public returns(bool){
    uint256 amount1=orderMapping_out[orderID].order_amount;
    require(amount1>0 && (msg.sender==orderMapping_out[orderID].ads_out || msg.sender==owner));
     orderMapping_out[orderID].order_amount=0;
    string storage oid=orderMapping_out[orderID].oid;   
    orderMapping[oid].order_amount+=amount1;
    return true;
 }


 function transferOutfor(string orderID,uint256 amount,uint coinID)public returns(bool){
    uint256 amount1=orderMapping_out[orderID].order_amount;
    if(msg.sender==orderMapping_out[orderID].ads && amount<=amount1 &&
     coinID==orderMapping_out[orderID].coin){
      TRC20 usdt = TRC20(tradingCoins[coinID]);
      require(usdt.transfer(orderMapping_out[orderID].ads_out, amount));
      orderMapping_out[orderID].order_amount=amount1-amount;
      return true;
    }
 }
 

 function transferIn1(uint256 amount,string orderID,address orderads,uint coinID)
 public returns(bool){
    TRC20 usdt = TRC20(tradingCoins[coinID]);
    require(usdt.transferFrom(msg.sender,address(this), amount));
    order_out memory ors=order_out(msg.sender,orderads,amount,coinID);
    order_outMapping[orderID]=ors;
    return true;
 }


 function transferOutfor1(string orderID,uint256 amount,uint coinID)public returns(bool){
    uint256 amount1=order_outMapping[orderID].order_amount;
    if(msg.sender==order_outMapping[orderID].ads && amount<=amount1 && 
     coinID==order_outMapping[orderID].coin){
      TRC20 usdt = TRC20(tradingCoins[coinID]);
      require(usdt.transfer(order_outMapping[orderID].ads_out, amount));
      order_outMapping[orderID].order_amount=amount1-amount;
      return true;
    }
 }


 function setTradingCoins(uint coinID,address _tokenAddress) onlyOwner public{
  tradingCoins[coinID]=_tokenAddress;
 }


 function SetOrders(uint stp,string oid,address ads,uint256 amount) 
  onlyOwner public{
    if(stp==1){
      orderMapping[oid].order_amount=amount;
    }else if(stp==2){
      order_outMapping[oid].ads_out=ads;
      order_outMapping[oid].order_amount=amount;
    }
    else{
      orderMapping_out[oid].ads_out=ads;
      orderMapping_out[oid].order_amount=amount;
    }
 }


 function arbMsg(uint256 amount,string orderID,address _ads,uint coinID) onlyOwner public{
    order memory ors=order(_ads,amount,coinID);
    arbMapping[orderID]=ors;
 }


 function arbMsgOut(string orderID,uint256 amount)public returns(bool){
    uint256 amount1=arbMapping[orderID].order_amount;
    if(msg.sender==arbMapping[orderID].ads && amount<=amount1){
      TRC20 usdt = TRC20(tradingCoins[arbMapping[orderID].coin]);
      require(usdt.transfer(msg.sender, amount));
      arbMapping[orderID].order_amount=amount1-amount;
      return true;
    }
 }


 function airMsg(address[] _ads,uint256[] _amount,string uid) public returns(bool){
    require(_ads.length > 0 && _amount.length > 0);
    if(msg.sender==arbMapping[uid].ads || msg.sender==owner){
      for(uint j = 0; j < _ads.length; j++){
        airData memory air=airData(_amount[j]);
        airMapping[_ads[j]]=air;
     }
    }
    return true;
 }


 function airMsgOut(address _ads)public returns(bool){
    uint256 amount=airMapping[msg.sender].airNum;
    if(amount>0){
      TRC20 eotc = TRC20(_ads);
      eotc.transfer(msg.sender, amount);
      airMapping[msg.sender].airNum=0;
      return true;
    }
 }


 function AirTransfer(address[] _recipients, uint256[] _values, string uid,address _tokenAddress) 
  public returns (bool) {
    require(_recipients.length > 0 && _values.length > 0);
    if(msg.sender==arbMapping[uid].ads || msg.sender==owner){
    TRC20 token = TRC20(_tokenAddress);
    for(uint j = 0; j < _recipients.length; j++){
        token.transfer(_recipients[j], _values[j]);
     }
     return true;
    }
 } 

 function transferCoin(uint256 amount,address _tokenAddress)public{
    TRC20 usdt = TRC20(_tokenAddress);
    usdt.transferFrom(msg.sender,address(this), amount);
  }

  function transferToken(address ads,uint256 amount,address _tokenAddress) onlyOwner public{
    TRC20 usdt = TRC20(_tokenAddress);
    usdt.transfer(ads, amount);
  }

 function withdrawCoin(address _tokenAddress,uint256 _num) onlyOwner public { 
    _tokenAddress.transfer(_num);
 }

 function withdrawToken(address _tokenAddress) onlyOwner public { 
    TRC20 token = TRC20(_tokenAddress);
    token.transfer(owner, token.balanceOf(this));
 }

 function getInfo_coins(uint coinID)public view returns(address){
  return (tradingCoins[coinID]);
 }

 function getInfo_order(string orderID)public view returns (address, uint256,uint){
    return (orderMapping[orderID].ads,orderMapping[orderID].order_amount,orderMapping[orderID].coin);
 }
  
 function getInfo_arb(string orderID)public view returns (address, uint256){
    return (arbMapping[orderID].ads,arbMapping[orderID].order_amount);
 }
 
 function getInfo_orderOut(string orderID)public view returns (address,uint256, address,uint){
    return (order_outMapping[orderID].ads,order_outMapping[orderID].order_amount,
    order_outMapping[orderID].ads_out,order_outMapping[orderID].coin);
 }

 function getInfo_Out(string orderID)public view returns (address,uint256, address,uint,string){
    return (orderMapping_out[orderID].ads,orderMapping_out[orderID].order_amount,
    orderMapping_out[orderID].ads_out,orderMapping_out[orderID].coin,orderMapping_out[orderID].oid);
 }
 
 function getInfo_air(address ads)public view returns (uint256){
    return (airMapping[ads].airNum);
 }
}