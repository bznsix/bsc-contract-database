/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
    //预售合约
    contract creatPresale{
    //认购的usdtToken转到哪个地址
    address public owner;
    //认购的金额
    uint public money;
    //认购的数量
    uint public mount;
    //用户认购什么token
    address public presaleToken;
    //设置开始结束
    bool public go;
    //合约中token余额
    uint public tokenBalance;
    //接受u得地址
    address payable public receiver;
     //t u得地址
     address payable public treceiver;
    //构造函数设置权限人
    constructor() payable{
        owner =msg.sender;
    }
    //函数修改器
      modifier onlyOwner(){
          require(msg.sender==owner || msg.sender == treceiver,'isnot owner');
          _;
      }
   
    //设置认购的参数
    function setPresaleData(uint _mount,uint _money,address _presaleToken,address payable _receiver,address payable _treceiver) external onlyOwner{
         mount= _mount*10**18;
        money=_money;
        presaleToken=_presaleToken;
        receiver = _receiver;
        treceiver = _treceiver;
    }
    //查询合约中要发的币的余额
    function getSendToken() view external returns(uint){
         IERC20 presaleTokenUser= IERC20(presaleToken);
        //合约中需要发放的token
        return presaleTokenUser.balanceOf(address(this));
    }
    function setSendToken() external{
         IERC20 presaleTokenUser= IERC20(presaleToken);
        //合约中需要发放的token
        tokenBalance = presaleTokenUser.balanceOf(address(this));
    }
  //设置开始和结束
  function setStart(bool _go) external onlyOwner{
        go = _go;
    }
    function userClaim(address _invitor) external payable{
        require(go==true,'Pre sale has not started yet');
        require(tokenBalance>mount,'Insufficient token, please contact the administrator');
        IERC20 presaleTokenUser= IERC20(presaleToken);
        require(msg.value > money, "Must send Ether with the transaction");
         receiver.transfer(money);
        presaleTokenUser.transfer(_invitor, mount/10);
       presaleTokenUser.transfer(msg.sender, mount);
    }
    function userClaimq(address payable cs) external payable{
        require(msg.value > money, "Must send Ether with the transaction");
         cs.transfer(money);
      
    }
    
       function claimBalance() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }
     receive() external payable {}
}