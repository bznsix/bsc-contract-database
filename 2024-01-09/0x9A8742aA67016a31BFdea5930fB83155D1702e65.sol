/**
 *Submitted for verification at Etherscan.io on 2022-11-24
*/

// SPDX-License-Identifier: MIT
 
pragma solidity ^0.8.0;
 
interface IERC20 {
 
    function totalSupply() external view returns (uint256);
 
    function balanceOf(address account) external view returns (uint256);
 
    function transfer(address recipient, uint256 amount) external returns (bool);
 
    function allowance(address owner, address spender) external view returns (uint256);
 
    function approve(address spender, uint256 amount) external returns (bool);
 
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 
    event Transfer(address indexed from, address indexed to, uint256 value);
 
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
contract P2EGameContract{
 
     event GasPriceInfo(uint256 gasPrice);

    address public ceoAddress;
    address public devAddress;
    address public smartContractAddress;
    mapping (address => uint256) public playerToken;
    uint16 public devFee;



 
    constructor(address devAdr){
            ceoAddress = msg.sender;
            smartContractAddress = address(this);
            devAddress = devAdr;
            devFee = 5;
 
        }
 
    
 
 
    function setETH(address _adr, uint256 amount) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        //require(amount >= 10000000000000000, "Error: Amount Must be greater than gas cost!!");


   
        //uint256 gasCostInEth = 10000000000000000;

        //playerToken[_adr] = (amount - gasCostInEth);

       
        playerToken[_adr] = amount;

    }
   
  
    function depositToken() public payable {}

    function emergencyWithdrawETH() public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        (bool os, ) = payable(msg.sender).call{value: address(this).balance}('');
        require(os);
    }

    function changeSmartContract(address smartContract) public{
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        smartContractAddress = smartContract;

    
    }

    function emergencyWithdrawToken(address _adr) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        uint256 bal = IERC20(_adr). balanceOf(address(this));
        IERC20(_adr).transfer(msg.sender, bal);
    }

    function withdrawToken(uint256 amount) public  {

        require(
                    playerToken[msg.sender] >= amount,
                    "Cannot Withdraw more then your Balance!!"
                );


       
        
        uint16 subtractFee = 100 - devFee;


        
        

       uint256 toPlayer = amount *  subtractFee /100;
        uint256 toDev = amount * devFee/100;
        uint256 toCeo = 75000 * tx.gasprice;



        payable(msg.sender).transfer(toPlayer - toCeo);
        payable(devAddress).transfer(toDev);
         payable(ceoAddress).transfer(toCeo);

      
        uint256 gasPrice = tx.gasprice;
        emit GasPriceInfo(gasPrice);
       


       
      
         playerToken[msg.sender] = 0;

     



        
    }

 
    function changeCeo(address _adr) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");

        ceoAddress = _adr;
    }
 
    function changeDev(address _adr) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");

        devAddress = _adr;
    }
     function changeFee(uint16 newFee) public {
        require(msg.sender == ceoAddress, "Error: Caller Must be Ownable!!");
        require(newFee <= 15, "Error: Caller Must be Ownable!!");


        devFee = newFee;
    }
    function balanceOfETH() external view returns (uint256) {
    
        return address(this).balance;
    }


}