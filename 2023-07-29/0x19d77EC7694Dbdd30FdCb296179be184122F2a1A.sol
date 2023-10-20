// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface Token{
    function transferFrom(address,address,uint) external;
    function transfer(address,uint) external;
    function balanceOf(address) external view returns(uint);
}
interface NFT{
    function mint(address,uint) external;
}
interface IUniswapV2Router {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract MintNFT  {

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "MintNFT/not-authorized");
        _;
    }

    constructor() {
        wards[msg.sender] = 1;
    }

    mapping (address => uint256)     public  totalForcontract;
    uint256                          public  rati = 1000;
    mapping (address => bool)        public  permit;
    mapping (address => mapping(address => uint256))     public  amount;
    mapping (address => uint256)     public  maxForcontract;
    mapping (address => uint256)     public  basis;
    address                          public  wbnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address                          public  usdt = 0x55d398326f99059fF775485246999027B3197955;
    address[]                        public  menu;
    mapping (address => address[])   public  under;
    mapping (address => address[])   public  path;
    mapping (address => address)     public  upline;
    IUniswapV2Router                 public  Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    function file(uint what, uint256 data, address ust) external auth {
        //if (what == 1) amount[ust] = data;
        if (what == 2) permit[ust] = !permit[ust];
        if (what == 3) basis[ust] = data;
        if (what == 4) maxForcontract[ust] = data;
        if (what == 5) rati = data;
        if (what == 6) Router = IUniswapV2Router(ust);
    }
    function setPrice(address nftcontract,address asset,uint wad) external auth {
        amount[nftcontract][asset] = wad;
    }
    function setPath(address asset,address[] memory paths) external auth {
        path[asset] = paths;
    }
    function setMenu(address[] memory assets) external auth {
        menu = assets;
    }
    function addMenu(address asset) external auth {
        menu.push(asset);
    }
    function setRecommend(address usr,address recommender) external auth {
        upline[usr] = recommender;
        under[recommender].push(usr);
    }
    function mint(address nftcontract, address asset, address to) public payable returns (uint256) {
        require(permit[asset], "MintNFT/The asset has not opened NFT mint");
        require(totalForcontract[nftcontract] < maxForcontract[nftcontract], "MintNFT/The total NFT has been synthesized");
        uint256 wad = amount[nftcontract][asset];
        if(wad == 0) wad = getPrice(nftcontract,asset);
        if(asset == wbnb) require(msg.value < wad*103/100 && msg.value > wad*97/100,"MintNFT/wbnb");
        else Token(asset).transferFrom(msg.sender,address(this),wad);
        totalForcontract[nftcontract] += 1;
        uint256 tokenId = basis[nftcontract]+totalForcontract[nftcontract];
        NFT(nftcontract).mint(to, tokenId);
        return tokenId;
    }
    function mints(address nftcontract, uint number, address to) public auth {
        for(uint i=0; i<number;++i){
            totalForcontract[nftcontract] += 1;
            uint256 tokenId = basis[nftcontract]+totalForcontract[nftcontract];
            NFT(nftcontract).mint(to, tokenId);
        }
    }
    function withdraw(address asset,uint256 wad, address payable usr) public  auth{
        if(asset == wbnb) usr.transfer(wad);
        else Token(asset).transfer(usr,wad);
    }
    function recommend(address upaddress,address nftcontract, address asset, address to) public payable returns(uint256 tokenId){
        if(upline[msg.sender] == address(0) && upaddress != address(0) && upline[upaddress] != address(0)){
           upline[msg.sender] = upaddress;
           under[upaddress].push(msg.sender);
        }
        tokenId = mint(nftcontract,asset,to);
        uint256 wad = amount[nftcontract][asset]*rati/10000;
        address payable usr = payable(upline[msg.sender]);
        if(usr != address(0)) {
           if(asset == wbnb) usr.transfer(wad);
           else Token(asset).transfer(usr,wad);
        }
    }
    function getUnder(address usr) public view returns(address[] memory){
        return under[usr];
    }
    function getPath(address asset) external view returns(address[] memory) {
        return path[asset];
    }
    function getMenu() external view returns(address[] memory) {
        return menu;
    }
    function getInfo(address usr,uint i) public view returns(address[] memory dropdown,address upliner,uint256 price,uint256 max,uint256 minted,uint tokenId){
        dropdown = menu;
        address nftcontract = menu[i];
        upliner = upline[usr];
        price = amount[nftcontract][usdt];
        max = maxForcontract[nftcontract];
        minted = totalForcontract[nftcontract];
        tokenId = basis[nftcontract]+totalForcontract[nftcontract]+1;
    }
    function getPrice(address nftcontract,address asset) public view returns(uint256 wad){
        uint256 length = path[asset].length;
        uint amountIn = amount[nftcontract][usdt];
        uint256[] memory prices = Router.getAmountsOut(amountIn,path[asset]);
        wad = prices[length-1];
    }
}