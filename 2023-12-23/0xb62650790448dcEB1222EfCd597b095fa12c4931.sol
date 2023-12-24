// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Token{
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view returns(uint);
}
interface IUniswapV2Router {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract BulkBRC20Mint {
    	// --- Auth ---
    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "BulkBRC20Mint/not-authorized");
        _;
    }
    bytes public oskt = bytes('data:,{"p":"bsc-20","op":"mint","tick":"oskt","amt":"100"}');
    bytes public fstt = bytes('data:,{"p":"bsc-20","op":"mint","tick":"fstt","amt":"100"}');
    bytes public bsc20;
    mapping (address => bool)        public  permit;
    mapping(address => uint256)      public  amount;
    address                          public  wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address                          public  usdt = 0x55d398326f99059fF775485246999027B3197955;
    address                          public  osk = 0x04fA9Eb295266d9d4650EDCB879da204887Dc3Da;
    address                          public  fist = 0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A;
    address                          public  founder = 0xF371C6000a360FC6059B12e4F8cCF872B27a1f3F;
    mapping (address => address[])   public  path;
    uint256                          public  rate = 10;
    IUniswapV2Router                 public  Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    mapping (uint => orderInfo[])    public  OrderList;
    mapping (address => UserInfo)    public  userInfo;

    struct orderInfo {     
        address user;        
        uint256 count;            
    }
    struct buyInfo { 
        uint256 token;         
        uint256 count;
        address asset; 
        uint256 wad;           
    }
    struct RecommendInfo { 
        address under;
        uint256 token;         
        uint256 count;
        address asset; 
        uint256 wad;           
    }
    struct UserInfo { 
        address    recommender;
        address[]  underline;
        buyInfo[]  depositList;
        RecommendInfo[]  teamList;
    }
    constructor(){
       wards[msg.sender] = 1;
       permit[wbnb] = true;
       permit[usdt] = true;
       permit[osk] = true;
       permit[fist] = true;
       amount[usdt] = 1*1E17;
       amount[wbnb] = 35*1E13;
       amount[osk] = 3*1E17;
       amount[fist] = 16*1E6;

    }
    function setInscription(bytes memory newInscription) public auth{
        bsc20 = newInscription;
    }
    function setPrice(address asset,uint wad) external auth {
        amount[asset] = wad;
    }
    function setAddress(address usr) external auth {
        founder =usr;
    }
    function setBool(address asset) external auth {
        permit[asset] = !permit[asset];
    }
    function setRate(uint newrate) external auth {
        rate = newrate;
    }
    function setPath(address asset,address[] memory paths) external auth {
        path[asset] = paths;
    }
    function setRecommend(address usr,address recommender) external auth {
        userInfo[usr].recommender = recommender;
        userInfo[recommender].underline.push(usr);
    }

    function mint(uint what,uint token,address recommender,address asset,uint count) public payable{
        UserInfo storage user = userInfo[msg.sender];
        if(user.recommender == address(0)) {
            user.recommender = recommender;
            userInfo[recommender].underline.push(msg.sender);
        }
        else recommender = user.recommender;
        require(permit[asset], "Mintbsc20/The asset has not opened NFT mint");
        uint256 price = amount[asset];
        if(price == 0) price = getPrice(asset);
        uint256 wad = price * count;
        if(asset == wbnb) {
            require(msg.value < wad*103/100 && msg.value > wad*97/100,"Mintbsc20/wbnb");
            payable(founder).transfer(msg.value*(1000-rate)/1000);
            if(recommender != address(0)) payable(recommender).transfer(msg.value*rate/1000);
        }
        else {
            Token(asset).transferFrom(msg.sender,address(this),wad);
            Token(asset).transfer(founder,wad*(1000-rate)/1000);
            if(recommender != address(0)) Token(asset).transfer(recommender,wad*rate/1000);
        }
        if(what ==1) {
            bytes memory inscription;
            if(token ==1) inscription = oskt;
            else if(token ==2) inscription = fstt;
            else inscription = bsc20;
            for (uint i = 0; i < count; i++) {
                (bool sent, ) = msg.sender.call(inscription);
                require(sent, "Failed to send");
            }
        }
        orderInfo memory list;
            list.user = msg.sender;
            list.count = count;
        OrderList[token].push(list);
        buyInfo memory list1;
            list1.token = token;         
            list1.count = count;
            list1.asset = asset; 
            list1.wad = wad;
        user.depositList.push(list1);
        RecommendInfo memory list2;
            list2.under = msg.sender;   
            list2.token = token;         
            list2.count = count;
            list2.asset = asset; 
            list2.wad = wad*rate/1000;
        userInfo[recommender].teamList.push(list2);
    }
    function getPrice(address asset) public view returns(uint256 wad){
        uint256 length = path[asset].length;
        uint amountIn = amount[usdt];
        uint256[] memory prices = Router.getAmountsOut(amountIn,path[asset]);
        wad = prices[length-1];
    }
    function getAmount(address asset,uint count) public view returns(uint256 wad){
        uint256 price = amount[asset];
        if(price == 0) price = getPrice(asset);
        wad = price * count;
    }
    function getOrder(uint token) public view returns(orderInfo[] memory){
        return OrderList[token];
    }
    function getUserInfo(address usr) public view returns(UserInfo memory user){
        return userInfo[usr];
    }
    function withdraw(address asset,uint256 wad, address payable usr) public  auth{
        if(asset == wbnb) usr.transfer(wad);
        else Token(asset).transfer(usr,wad);
    }
}