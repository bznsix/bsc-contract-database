// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
     function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    // don't need to define other functions, only using `transfer()` in this case
}

contract COINSTEC_SWAP {

       IERC20 coinstec_token = IERC20(address(0x007B4F5CD1696DCE7Eb698f84bD226B83D481281));
       IERC20 usdt = IERC20(address(0x55d398326f99059fF775485246999027B3197955));

        uint public bnbRatio = 1704;
        uint public usdtRatio = 8;
        address public _owner;
    

    constructor()
    {
       _owner = msg.sender;
    }
     


        receive() external payable
        {
            
        uint calculatedAmount = msg.value * (bnbRatio / 100);
        uint256 amount = calculatedAmount - (calculatedAmount * 2/10000);
        coinstec_token.transfer(msg.sender, amount);
   
        }




     function BuyToken(uint amount) public
     {

              require(amount > 0, "Amount must be greater than 0");

       
                 require(usdt.balanceOf(msg.sender) >= amount, "Insufficient balance");
                  // Transfer tokens from sender to contract
                 usdt.transferFrom(msg.sender, address(this), amount);

                 uint sendToken = (amount * usdtRatio) / 100;
                 uint calculatedSell = sendToken - (sendToken * 2/10000);
                  // Send Ether to sender
                 coinstec_token.transfer(msg.sender,calculatedSell);
       
     }  




     function SellToken(uint amount,string memory paymentType) public
     {


         
          string memory usdtVar = "USDT";
        

    
          require(amount > 0, "Amount must be greater than 0");


           if(keccak256(abi.encodePacked((paymentType))) == keccak256(abi.encodePacked((usdtVar))))
          {
            require(coinstec_token.balanceOf(msg.sender) >= amount, "Insufficient balance");
            // Transfer tokens from sender to contract
            coinstec_token.transferFrom(msg.sender, address(this), amount);

            uint sendToken = (amount / usdtRatio) / 100;
            uint calculatedSell = sendToken - (sendToken * 3/10000);
            // Send Ether to sender
          usdt.transfer(msg.sender,calculatedSell);    

          }
          else{

               require(coinstec_token.balanceOf(msg.sender) >= amount, "Insufficient balance");
        // Transfer tokens from sender to contract
        coinstec_token.transferFrom(msg.sender, address(this), amount);
        uint sendBNB = (amount / bnbRatio) / 100;
        uint calculatedSell = sendBNB - (sendBNB * 3/10000);
        // Send Ether to sender
        payable(msg.sender).transfer(calculatedSell);

          }
         
       }  



      function checkBalance(address account,string memory coinType) view external returns (uint256) {
        
          string memory usdtVar = "USDT";
        
        
          if(keccak256(abi.encodePacked((coinType))) == keccak256(abi.encodePacked((usdtVar))))
          {
              return usdt.balanceOf(account);
          }
           else 
          {
               return coinstec_token.balanceOf(account);
          }
        
      }

     


      function sendBNBOwner() public   onlyOwner
      {
      require(msg.sender == _owner, "BEP20: only owner can call this function");
      uint balance = address(this).balance;
      payable(_owner).transfer(balance); 
      }

       function sendUSDTOwner() public  onlyOwner
      {
      require(msg.sender == _owner, "BEP20: only owner can call this function");
      uint balance = usdt.balanceOf(address(this));
      usdt.transfer(_owner,balance); 
      }


    

         function sendTokenOwner() public onlyOwner
         {
          require(msg.sender == _owner, "BEP20: only owner can call this function");
          uint tokenBalance = coinstec_token.balanceOf(address(this));
          coinstec_token.transfer(_owner, tokenBalance);
         }




        modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
        }

         

         function transferOwnership(address newOwner) public onlyOwner 
          {
             _owner = newOwner;
          }


             function changeCoinRatio(uint _usdtRatio,uint _bnbRatio) public onlyOwner
            {
                bnbRatio = _bnbRatio;
                usdtRatio = _usdtRatio;
              
            }
          

}