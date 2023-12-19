//SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);
    /*The following function returns the cost of transactions that exist in the token contract.*/
      function TransactionFee() external view returns (uint);
    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(  address from,  address to,  uint256 amount ) external returns (bool);
}
 
//----------------------------------------------
/*@@@@@@This is an interface for calling functions from Oracle Chainlink
Through Oracle, the price of the collateral for the withdrawal of the native token is checked*/
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)  external view returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData() external view returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
//--------------------------------------------------
contract bigbangInterface{
   /*The following function calculates how much native token (BGBT ) can
    be withdrawn by entering a certain amount of a currency as collateral.*/
        function LoanCalculation(address _address , uint _value) public view  returns (uint256);
      //The following function returns the value of native token (BGBT) in this contract..
        function ContractBalance() public view returns (uint);
    /*The following function returns the amount of tokens that are locked as collateral in this contract.
    This function receives two address type parameters as input*/
    //@The first address is the address of the loan owner and the second address is the address of the collateral token.
        function AccountBalanceIsCollateral(address _myaddress , address addressToken) public view returns (uint);
    /*
     The following function returns the amount of native tokens (BGBT) that were borrowed from this contract.
     This function receives two parameters of type address as input
     The first address is the address of the loan holder and the second address is the address of the collateral token.
    */
        function BorrowedAccountBalance(address _myaddress , address addressToken) public view returns (uint);
    /*
     The following function returns the due date of the loan created by the loan owner.
     This function takes two address parameters as input.
      The first parameter is the address of the owner of the loan and the second is the address of the collateral token
     Note that all loans are valid for up to 30 days and after 30 days the loan becomes public.
     When a loan has passed 30 days from the creation date, it can be closed by all BGBT holders, so all BGBT holders can seize
     the collateral and withdraw the collateral from the contract.
    */ 
        function ExpirationDateMyLoan(address _myaddress , address addressToken) public view returns (uint);
   /*
   The following function is for creating and receiving loans.
The address of the borrower as the owner of the collateral will be recorded in the contract
The following function takes two parameters as input.
The first parameter is of the address type and will be the address of the collateral token
And the second parameter receives a numeric value that will be the amount of the collateral.
When this function is executed, it receives a specified amount of token as collateral from the
function executor and immediately removes the native token (BGBT) from this contract and transfers it to the executor's wallet.
This loan is done as an exchange. You can borrow local tokens from the contract by depositing collateral in this contract.
   */
//@@@
/*
  Also, the following function records the date of creation of a loan in this contract
All loans have 30 days to be repaid.
Through the previous function, you can view the due date of a loan
Also, the function below will deduct two amounts as native token transfer fee (BGBT).
This amount will include the contract manager's fee and the native 
token holder's fee (BGBT) as a reward.
*/
/*
@@@@
If the borrower wants to borrow the native token (BGBT) and
 has already done so and the type of collateral is the same, for example Bitcoin, then
  the amount of the new collateral will be added to the previous amount that is locked in the contract, and it is clear that the amount 
  The borrowed native token will also be added to the previous debt amount.
Also, the due date of the loan will be postponed.
*/
        function Borrow(address  _addresstoken, uint _value) public returns (bool success);
  //The following function shows the amount of reward obtained through borrowers.
        function ShowBonus() public view returns (uint256);
   /*
      You can repay your loan through the following function.
The following procedure receives a token address parameter as input.
Note that the function below receives all the native tokens (BGBT) from the
 function executor and immediately returns the collateral to the executor's wallet.
It is clear that only the owner of the loan can execute this function and settle his debt before the loan is due.
   */
        function Repay(address _addresstoken) public returns (bool  success);
   /*
   You can repay your loan through the following function.
The difference between this function and the previous one is that
 you can pay your debt in several steps and postpone the time.
The following method takes a token address parameter as input.
Note that through the following function, you can deposit part of native tokens (BGBT) to pay your debt to 
this contract, and it is clear that the same amount of collateral will be immediately transferred from the contract to the wallet of the function executive.
Obviously, only the owner of the loan can do this and settle the debt before the loan is due.
   */
        function MultiStepRepay(address _addresstoken , uint8 _step ) public returns (bool  success);
/*
The following function receives two address type parameters as input
The first parameter is the address of the loan holder and the second parameter
 is the address of the type of collateral.
 The following function is for collateral seizure.
This function is applied when the loan due date is 30 days past and so it is clear that all native token (BGBT) holders can release and withdraw the 
collateral by paying the amount owed through this function.
If the following function is executed, it will receive all the native tokens (BGBT) as the
 loan debt amount from the function executor and immediately transfer the entire collateral amount to the executor's wallet.

*/
        function confiscate(address _addressOwner ,address addressToken) public returns (bool  success);
/*
The following function is for collateral seizure.
This function is applied when the loan due date is 30 days past and so it is clear that all 
native token (BGBT) holders can release and withdraw the collateral by paying the amount owed through this function.

The following function is used for multi-step seizure of a collateral. It is clear that
 this function is used for collaterals with large amounts.

This function receives three parameters as input. In the third parameter, you can choose how much of the 
loan amount you want to pay, and obviously, the same amount of collateral will be transferred to the wallet of the function operator.
If the following function is executed, it will receive a certain amount of native tokens (BGBT) as the amount owed on the loan from the function executor 
and immediately transfer the same amount of the collateral amount to the executor's wallet.
*/
        function MultiStepconfiscate(address _addressOwner ,address addressToken , uint8 _step  ) public returns (bool  success);
/*
In this contract (Big Bang), you can borrow native token (BGBT) to deposit any collateral.
And for all collaterals, 90% of the loan collateral value will be received by default
But you can change this percentage through the following function.
The following function will be for vote registration
Every time you vote, some native token (BGBT) will be received from the function operator as the right to vote and vote registration.
This function is to register the vote in order to increase the borrowing percentage of the collateral value
Every time voting, the following function checks that if the number of voters' votes is increasing, it will increase the 
percentage of the guarantee from 90% to a higher value.
Obviously, with the increase in borrowing percentage, more native token (BGBT) will be withdrawn from the contract, 
and of course, the price of native token (BGBT) will decrease.
*/
        function VotingIncrease(uint256 _value) public returns (bool  success);
/*
In this contract (Big Bang) you can borrow native token (BGBT) to deposit any collateral.
And for all collateral, 90% of the value of the loan collateral will be received by default
But you can change this percentage through the following function.
The following function will be for vote registration
Every time you vote, some native token (BGBT) is received from the function operator as voting rights and vote registration.
This function is to register a vote in order to reduce the borrowing percentage of the collateral value
At each voting time, the following function checks that if the number of voters' votes increases, it reduces the guarantee percentage from 90% to a lower value.
Obviously, as the loan percentage decreases, less native token (BGBT) will come out of the contract, and of course, 
the price of native token (BGBT) will increase.
*/
        function VotingDecrease(uint256 _value) public returns (bool  success);
   /*
The following function receives an address type parameter as input
The input parameter is the collateral address
The following function returns the type of collateral in accounts whose maturity date is over 30 days
By entering the type of collateral in this function, it is searched whether the desired collateral can be seized or not.
   */
        function  SearchAccount(address _Addresstoken) public view returns (address c);
/*@@@@@
The following function does not have any type of input parameters, but it checks what type of collateral can be seized
The following function returns the collateral type on accounts whose due date is more than 30 days
The difference between this function and the previous function is that it checks the type of collateral that can be seized in the address of the borrowers and 
returns the result as two addresses of the collateral and the owner of the loan.*/

        function SearchAccountToken() public view returns (address A, address B);
/*The following function returns the total assets of this contract
This function receives the price of the total assets of this contract through Oracle and returns it.*/
        function TotalAssets() public view returns (uint);
/*
The following function returns the native token price (BGBT).
The price of native token (BGBT) is calculated based on the total assets in this contract.
The price of native token (BGBT) is calculated based on the total amount of collaterals in this contract divided by the
 total number of native tokens (BGBT) that have been paid as a loan.
*/
        function BigBangPriceEstimate() public view returns (uint);
//The following function returns the total native tokens (BGBT) that have been paid as loans and withdrawn from this contract.
        function TotalTokensUsed() public view returns (uint);
         event Borrowed(address indexed from, address indexed to, uint256 tokens, uint256 Date);
         event Repaid(address indexed _from, address indexed _to, uint256 _tokens , uint256 _Date);
}
contract Bigbanghive is bigbangInterface{

  uint152 private CountToken = 0 ; 
        uint256 private _Votefee = 1 * 10 **18;
        uint80 private LoanLimit = 90 ;
        uint256 private CountMember = 0 ;
        uint256 private BonusCoins = 0 ;
        uint8 private FeeOwner = 16 ;
        uint8 private Feefaucet = 22 ;
        uint8 private TotalCost = 38 ;
        uint136 private LowestPrice = 800;
        uint256 private HighestPrice = 10000044444222;
        address private _AddressBGB ;//0x77D6986f9abefbfE090e848Db241FE81b6dF151d;
        address public LiquidityPool ; 
        address public ContractFaucet  ;
        address public Owner ;
        bool private Check = false ;
        //=======================================================================
          
    struct token{
      address erc20TokenAddress;//This variable stores the contract address of a digital currency .
      IERC20 erc20Token;
      AggregatorV3Interface priceFeed;
      uint256 collateral ;
      uint256 _borrow ;
      uint256 future_date ;
      uint152 Member ;
   }

    mapping (address =>  mapping (address => token)) private _Account ;
   mapping (address => uint) private PriceControl ;
   mapping (address => token) private _Tokens ;
   mapping (uint => address) private AddressCoins ;
   mapping (address => uint) private OwnerShare ;
   mapping (uint  => address ) private CountUser ;
   mapping (address => uint) private _VoteIncrease ;
   mapping (address => uint) private _VoteDecrease ;
//===========================================================
   constructor(address AddressTokenBGBT) public{
      Owner = msg.sender ;
      _AddressBGB = AddressTokenBGBT;
   }
    modifier Im_owner(){
     require(msg.sender == Owner ,"Only the owner of the contract can execute these instructions");
     _;
 }
  
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   //The following function receives an address as input and collects the price of the token from Oracle and returns it.
    function getLatestPrice(address _tokenAddress) public view returns (uint256) {
       require(_tokenAddress != _Tokens[_AddressBGB].erc20TokenAddress); 
       (, int price, , , ) = _Tokens[_tokenAddress].priceFeed.latestRoundData();
        return uint256(price );
    }

     // function TimeEstablishingTheContract() public view returns 
 //The following function returns the amount of (Big Bang) tokens in your wallet
    function BalanceyourWallet(address _addressToken , address _myaddress) public view returns (uint){
        return(_Tokens[ _addressToken].erc20Token.balanceOf(_myaddress));
    }
    //*** 
//The following function receives two parameters as input.
//Address parameter and integer
//This parameter must be the address of a token in the smart contract.
//This function receives the price of a token from Oracle
//This function calculates how much your collateral is worth.
//This function calculates how many native  tokens BGBT the executor can receive.
   function LoanCalculation(address _address , uint _value) public view  returns (uint256){
          uint _Q1 = (getLatestPrice( _address) * _value);// / 10 **  _Tokens[ _address].decimal;
          uint _Q2 = _Q1 / 100 ;
          uint NinetyPercentLoan = (_Q2 * LoanLimit ) ;//The loan limit is usually 90%, but it may change in different currencies
          uint BGB = (NinetyPercentLoan / BigBangPriceEstimate());// * 10 ** 18  ;
          return (BGB);
   }
   /* The following function receives two addresses from the input and attaches the current contract to them
This function can be executed once and no one can change it after execution.*/
    function SetAddressContract(address _addressPool , address _addressFaucet) public returns (bool) {
       require( Check  == false);
          LiquidityPool  = _addressPool ; 
          ContractFaucet = _addressFaucet ; 
          Check = true ;
          return(true);
    }
    function SetApproveContractFaucet(uint _value ) public Im_owner() returns (bool) {
      
        IERC20(_Tokens[_AddressBGB ].erc20TokenAddress).approve(ContractFaucet , _value * 10 ** 18);
         return(true);
    }
    
   /*
/***
/*@The following function takes the address of the executor as an input parameter.
The following function checks if the user's address is already registered*/
     function UserReview(address _addressUser) private view returns (bool ){
       bool User = false;
       uint i = 0 ;
       while ( i <= CountMember){
           i++;
           if(_addressUser ==  CountUser[i]) {
            User = true ;
           }
       }
       return (User);
     }
     /*@The following function takes an address as an input parameter.
The following function displays the account balance that is used as collateral
The value returned by the following function is locked (money cannot be withdrawn)*/
   function AccountBalanceIsCollateral(address _myaddress , address addressToken) public view returns (uint){
          return(_Account [_myaddress][addressToken].collateral) ;
   }

   //**
/*@ The following function receives an address as an input parameter (token address).
The following function will return the borrowed amount if called.
Borrowed will be native token only (BGBT). */
   function BorrowedAccountBalance(address _myaddress , address addressToken) public view returns (uint){
          return(_Account [_myaddress][addressToken]._borrow) ;
   }
/*This function returns the coins of this contract
Note that this function only returns the number of native coins.*/
   function ContractBalance() public view returns (uint){
          return(_Tokens[ _AddressBGB].erc20Token.balanceOf(address(this))) ;
   }
   //**
//-*@
/* @The following function receives an address (token address) as an input parameter
If the following function is called, it will return the expiration date of the loan taken by the executor. */
   function ExpirationDateMyLoan(address _myaddress , address addressToken) public view returns (uint){
          return(_Account [_myaddress][addressToken].future_date) ;
   }
/****
/*
/* The following function returns the total number of users registered in this contract. */
   function TotalUser() public view returns(uint){
      return (CountMember);
   }
/*
The following function returns the number of tokens registered in this contract
*/
   function Count_token() public view returns(uint152){
      return(CountToken) ;
   }
   //**
 /*@
 The following function, if called, returns the borrowing limit
The numerical loan limit is between ten and one hundred
*/
   function Loan_limit() public view returns (uint80){
       return (LoanLimit ) ;
   }

//====================================
 function ShowOwnerShare(address _addressOwner) public view  returns (uint){
          uint balance = OwnerShare[_addressOwner];
          return(balance) ;
   }
   //*
//===
//The following function can only be executed by the administrator
/*@@The owner of this contract can withdraw the obtained fee through the following function
These fees are collected by user transactions.*/
   function WithdrawalOwnerShare(uint _value) public Im_owner() returns (bool success){
          require(OwnerShare[msg.sender]  > 0,"Insufficient inventory");
          require(_value <=  OwnerShare[msg.sender], "Insufficient inventory" );
          require (IERC20(_Tokens[_AddressBGB].erc20TokenAddress).transfer(msg.sender ,_value)) ;
          OwnerShare[msg.sender] -= _value;
          return(true) ;
   }
//====================================================
 /*@The function below has two inputs that it receives in the form of addresses. The first is the token address and the second is the price call address.
 This function can only be executed by the administrator.*/
    function Set_token(address _tokenAddress, address chainlink  ) public Im_owner()  returns (bool success){
      CountToken ++ ;
      token memory _To ;
      _To.erc20TokenAddress = _tokenAddress ; // Sets "erc20TokenAddress"
      _To.erc20Token = IERC20(_To.erc20TokenAddress);
      _To.priceFeed = AggregatorV3Interface(chainlink);
      //_To.decimal  =  _decimal  ;
      _To.collateral = 0 ;
      _To._borrow = 0;
      _To.future_date = 0;
      _To.Member = CountToken ;
      _Tokens[_tokenAddress] = _To ;
       AddressCoins[CountToken] = _tokenAddress;
       return(true);
    }

    /****
/*
The following function can only be executed by the contract owner.
The following function receives the token address as input.
If the following function is executed, it will remove the token address
 from the contract and it will no longer be applicable.
*/
function RemoveToken(address _addressToken) public Im_owner() returns (bool){
         require(_addressToken ==  _Tokens[_addressToken].erc20TokenAddress,"This token does not exist.");
         AddressCoins[ _Tokens[_addressToken].Member] = address(0);
         CountToken -= 1 ;
         token memory _To ;
      _To.erc20TokenAddress = address(0); // Sets "erc20TokenAddress"
      _To.erc20Token = IERC20(_To.erc20TokenAddress);
      _To.priceFeed = AggregatorV3Interface(address(0));
     // _To.decimal  =  0 ;
      _To.collateral = 0 ;
      _To._borrow = 0;
      _To.future_date = 0;
      _To.Member = 0 ;
      _Tokens[_addressToken] = _To ;
       return(true);
    }
     
    //@The following function receives an address as input and replaces it with the manager's address
     function Change_manager(address _newOwner) public Im_owner()returns (bool success)  {
      Owner = _newOwner;
      return(true);
    }
    function SettingCosts(uint8 _feeOwner ,uint8 _feefaucet ,uint256  votefee , uint136 _lowestPrice , uint _highestPrice) public Im_owner() returns (bool success){
       FeeOwner= _feeOwner ;
       Feefaucet = _feefaucet;
       _Votefee = votefee;
       TotalCost = FeeOwner + Feefaucet ;
       LowestPrice = _lowestPrice;
       HighestPrice = _highestPrice;
       return(true);
    }
   //***
   //brief explanation:
   /*@The following function lends the native(BGBT) currency to the executor.
The following function receives the deposit amount from the executor and calculates how much native(BGBT) currency should be transferred.
The following function transfers the collateral currency and the loan currency in one transaction.
*/
     function Borrow(address  _addresstoken, uint _value) public  returns (bool success) {
        require(_addresstoken != _Tokens[_AddressBGB].erc20TokenAddress ,"You cannot place this token as collateral." );
        require(_addresstoken  == _Tokens[_addresstoken].erc20TokenAddress,"This token is not supported");
        require(_value <= _Tokens[_addresstoken].erc20Token.balanceOf(msg.sender) ,"Your account balance is insufficient.");
        require( LoanCalculation(_addresstoken, _value) <= _Tokens[_AddressBGB].erc20Token.balanceOf(address(this)));/*This line checks that the number of Big BangBGBT
         tokens being borrowed must be in the contract so that the borrower can withdraw them from the contract.*/
         address _user = msg.sender ;
           if(UserReview(_user) ==  false){
               CountMember ++ ;
               CountUser[CountMember] = msg.sender ;
           }
        require(IERC20(_Tokens[_addresstoken].erc20TokenAddress).transferFrom(msg.sender, LiquidityPool , _value));
        PriceControl[msg.sender] = LoanCalculation(_addresstoken , _value);
        _Account[msg.sender][_addresstoken]._borrow +=  PriceControl[msg.sender] ;
        _Account[msg.sender][_addresstoken].collateral += _value ;
        _Account[msg.sender][_addresstoken].future_date = (block.timestamp + 2592000);
           uint OneThousandth =  PriceControl[msg.sender]  / 10000 ; 
           uint _d = (10000 - TotalCost );
           require(IERC20(_Tokens[_AddressBGB].erc20TokenAddress).transfer(msg.sender ,( OneThousandth * _d))); 
           OwnerShare[Owner]  += (OneThousandth * FeeOwner );
           BonusCoins += (OneThousandth * Feefaucet ) ;
           emit Borrowed (address(this) , msg.sender , ( OneThousandth * _d) , block.timestamp);
           return(true);
    }
    function ShowBonus() public view returns (uint256){
       return(BonusCoins);
    }
    function Bonus(uint256 _value) public returns (bool success){
       require(_value <= BonusCoins);
       require(msg.sender  == ContractFaucet);
       BonusCoins -= _value ;
       return(true);
    }
    
   
    /*@ The following function receives an identifier:
By receiving the ID, this function recognizes that the executor is the borrower and the debtor.
By executing this function, the number of lent coins is transferred from the performer's wallet to the contract address, and the collateral is immediately released and returned to the performer's wallet.
Note: To execute this function, the time and date recorded in the transaction must not have passed.
This function protects people's collateral and only the owner of the transaction can execute it */
    function Repay(address _addresstoken) public returns (bool  success){
       require (block.timestamp <=_Account [msg.sender][_addresstoken].future_date  );
       require (_Account [msg.sender][_addresstoken]._borrow > 0);
       require (_Account [msg.sender][_addresstoken]._borrow <= _Tokens[_AddressBGB].erc20Token.balanceOf(msg.sender) ,"Your account balance is insufficient.");
       bool R =  IERC20(_Tokens[_AddressBGB].erc20TokenAddress).transferFrom(msg.sender,address(this), _Account [msg.sender][_addresstoken]._borrow );
       if(R == true){
         require( IERC20(_Tokens[_addresstoken].erc20TokenAddress).transferFrom(LiquidityPool , msg.sender, _Account [msg.sender][_addresstoken].collateral));
         emit Repaid(msg.sender ,address(this) , _Account [msg.sender][_addresstoken]._borrow , block.timestamp );
          _Account [msg.sender][_addresstoken]._borrow  = 0;
          _Account[msg.sender][_addresstoken].collateral  = 0 ;
          return(true);
       }
    }
     function MultiStepRepay(address _addresstoken , uint8 _step ) public  returns (bool  success){
       require(_step < 5 && _step > 0 );   
       uint  loanDivision = _Account [msg.sender][_addresstoken]._borrow /  _step; 
       require (block.timestamp <=_Account [msg.sender][_addresstoken].future_date  );
       require (_Account [msg.sender][_addresstoken]._borrow > 0);
       require (loanDivision <= _Tokens[_AddressBGB].erc20Token.balanceOf(msg.sender) ,"Your account balance is insufficient.");
       uint  CollateralDivision =  _Account [msg.sender][_addresstoken].collateral  /  _step;
       bool R =  IERC20(_Tokens[_AddressBGB].erc20TokenAddress).transferFrom(msg.sender,address(this), loanDivision );
       if(R == true){
           require( IERC20(_Tokens[_addresstoken].erc20TokenAddress).transferFrom(LiquidityPool , msg.sender, CollateralDivision));
          _Account [msg.sender][_addresstoken]._borrow  -= loanDivision;
         _Account[msg.sender][_addresstoken].collateral -= CollateralDivision ;
          _Account[msg.sender][_addresstoken].future_date =(block.timestamp + 2592000);
           emit Repaid(msg.sender ,address(this) , loanDivision , block.timestamp );
          return(true);
       }
    }
/*
The following function is for paying public accounts
When people receive a loan, if 30 days pass from the time of registration, their account will be public
This means that all users can pay these loans and release the collateral.
*/
/*The following function is a type of bail seizure function that all users can execute provided that 30 days have passed.
Users can search the history of these types of loans through reading functions and close accounts that are older than 30 days by paying native tokens.
*/
    function confiscate(address _addressOwner ,address addressToken) public returns (bool  success){
        require (block.timestamp > _Account [_addressOwner][addressToken].future_date  );
        require (_Account [_addressOwner][addressToken]._borrow > 0);
        require (_Account [_addressOwner][addressToken]._borrow <= _Tokens[_AddressBGB].erc20Token.balanceOf(msg.sender) ,"Your account balance is insufficient.");
        bool R =  IERC20(_Tokens[_AddressBGB].erc20TokenAddress).transferFrom(msg.sender,address(this),_Account [_addressOwner][addressToken]._borrow );
        if(R == true){
          require( IERC20(_Tokens[addressToken].erc20TokenAddress).transferFrom(LiquidityPool , msg.sender, _Account [_addressOwner][addressToken].collateral));
          emit Repaid(msg.sender ,address(this) , _Account [_addressOwner][addressToken]._borrow , block.timestamp );
          _Account [_addressOwner][addressToken]._borrow  = 0;
          _Account [_addressOwner][addressToken].collateral  = 0;
          return(true);
        }
    }
/*
The following function is also a type of collateral seizure function and all users can execute it provided that 30 days have passed since the date of receiving the loan.
This function is no different from the above function
The only difference of this function is that you can pay a loan in several steps and  apply the collateral with several steps of foreclosure and withdrawal.
*/
/*Through the following function, you can pay the loan in four stages, and it is a public function, and it is obvious that a certain amount of collateral is released at each 
stage of payment (it does not matter if the function operator is the owner of the collateral or other users).*/
    function MultiStepconfiscate(address _addressOwner ,address addressToken , uint8 _step  ) public returns (bool  success){
         require(_step < 5 && _step > 0 );
        uint  loanDivision = _Account [_addressOwner][addressToken]._borrow /  _step;
        require (block.timestamp > _Account [_addressOwner][addressToken].future_date  );
        require (_Account [_addressOwner][addressToken]._borrow > 0);
        require ( loanDivision <= _Tokens[_AddressBGB].erc20Token.balanceOf(msg.sender) ,"Your account balance is insufficient.");
        uint  CollateralDivision =  _Account [_addressOwner][addressToken].collateral  /  _step;
        bool R =  IERC20(_Tokens[_AddressBGB].erc20TokenAddress).transferFrom(msg.sender,address(this), loanDivision);
        if(R == true){
          require( IERC20(_Tokens[addressToken ].erc20TokenAddress).transferFrom(LiquidityPool , msg.sender,  CollateralDivision));
          _Account [_addressOwner][addressToken]._borrow   -= loanDivision;
          _Account[_addressOwner][addressToken ].collateral -= CollateralDivision ;
           emit Repaid(msg.sender ,address(this) , loanDivision, block.timestamp );
          return(true);
        }
    } 
    function VotingIncrease(uint256 _value) public returns (bool  success){
        uint V = _value * _Votefee ;
        require (_value > 0 );
        require (V <= _Tokens[_AddressBGB].erc20Token.balanceOf(msg.sender) ,"Your account balance is insufficient.");
        require(IERC20(_Tokens[_AddressBGB].erc20TokenAddress).transferFrom(msg.sender,address(this), V));   
         address _user = msg.sender ;
           if(UserReview(_user) ==  false){
               CountMember ++ ;
               CountUser[CountMember] = msg.sender ;
           }
            _VoteIncrease [msg.sender] += _value ;
         if(AnalysisOpinions()  == true){
            if(LoanLimit < 96){
                 LoanLimit += 1 ;
            }
          }else if(AnalysisOpinions()  == false){
            if(LoanLimit > 20){
                LoanLimit -= 1 ;
            }
          }
           return(true);
    }

      function VotingDecrease(uint256 _value) public returns (bool  success){
        uint V = _value * _Votefee ;
        require (_value > 0 );
        require (V <= _Tokens[_AddressBGB].erc20Token.balanceOf(msg.sender) ,"Your account balance is insufficient.");
        require(IERC20(_Tokens[_AddressBGB].erc20TokenAddress).transferFrom(msg.sender,address(this), V));   
         address _user = msg.sender ;
           if(UserReview(_user) ==  false){
               CountMember ++ ;
               CountUser[CountMember] = msg.sender ;
           }
            _VoteDecrease [msg.sender] += _value ;
          if(AnalysisOpinions()  == true){
            if(LoanLimit < 97){
                 LoanLimit += 1 ;
            }
          }else if(AnalysisOpinions()  == false){
            if(LoanLimit > 20){
                LoanLimit -= 1 ;
            }
          }
           return(true);
    }
    function IncreaseVotes() public view returns (uint){
       uint VoteNumberIncrease = 0;
       for (uint i = 0 ; i <=CountMember; i++) {
            VoteNumberIncrease +=   _VoteIncrease [CountUser[i]];
        }
        return (VoteNumberIncrease);
    }
    function DecreaseVotes() public view returns (uint){
       uint VoteNumberDecrease = 0;
       for (uint i = 0 ; i <=CountMember; i++) {
            VoteNumberDecrease +=   _VoteDecrease [CountUser[i]];
        }
        return (VoteNumberDecrease);
    }
    function AnalysisOpinions() private view returns (bool){
      if(IncreaseVotes() > DecreaseVotes()){
         return(true);
      }else if(DecreaseVotes() > IncreaseVotes()){
          return(false );
      }else if(IncreaseVotes() == DecreaseVotes())
        return (false);
    }
  
     function  SearchAccount(address _Addresstoken) public view returns (address c){
       for (uint i = 0 ; i <= CountMember ;i ++){
         
          if( _Account [CountUser[i]][_Addresstoken]._borrow  > 0 && block.timestamp > _Account [CountUser[i]][_Addresstoken].future_date  ){
              return(CountUser[i]);
          }
       }
    }
    function SearchAccountToken() public view returns (address A, address B){
           for (uint x = 0 ; x <= CountMember ; x ++){
            for(uint i = 0 ; i <= CountToken; i++){
                 if(_Account [CountUser[x]][ AddressCoins[i]]._borrow > 0 && block.timestamp > _Account [CountUser[x]][AddressCoins[i]].future_date){
                  return(CountUser[x] ,AddressCoins[i] );
                 }
            }
        }
    }
 /*The following function calculates and returns all assets of this contract in dollars*/
   function TotalAssets() public view returns (uint){

        uint TA = 0;
        for (uint x = 0 ; x <= CountMember ; x ++){
            for(uint i = 0 ; i <= CountToken; i++){
                 if(_Account [CountUser[x]][ AddressCoins[i]].collateral > 0){
                    TA += (getLatestPrice(AddressCoins[i]) * _Account [CountUser[x]][ AddressCoins[i]].collateral);// / 10   ** _Tokens[AddressCoins[i]].decimal)  ;
                 }
            }
        }
       return (TA ) ;
    }
   /*
***
The following function returns all the native tokens of this contract (Big Bang) that were paid as loans and withdrawn from the contract.
This function is very efficient and shows how many tokens are distributed in the market
*/
    function TotalTokensUsed() public view returns (uint){
        uint TBGB = 0;
       for (uint x = 0 ; x <= CountMember ; x ++){
            for(uint i = 0 ; i <= CountToken; i++){
                 if(_Account [CountUser[x]][ AddressCoins[i]]._borrow  > 0){
                    TBGB += _Account [CountUser[x]][ AddressCoins[i]]._borrow; // / 10 ** 18;
                 }
            }
        }
       return (TBGB ) ;
    }
////////*
/*
***The following function returns the price of the native token (Big Bang). The calculation of the price has a direct relationship with the value of the assets in this contract.
Regarding the price of the Big Bang token , read the documentation available on the project site.
*/
    function BigBangPriceEstimate() public view returns (uint){
       if(TotalTokensUsed()  == 0){
          return(100000000);
       }else{
            uint BigbangPrice = (TotalAssets() / TotalTokensUsed());
            if(BigbangPrice < LowestPrice){
               return(8000);
            }else if(BigbangPrice > HighestPrice){
               return (HighestPrice) ;
            }else{
               return (BigbangPrice) ;
            }
              
       }
    } 

}