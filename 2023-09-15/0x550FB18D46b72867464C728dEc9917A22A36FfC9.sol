// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DecentralizedLottery {

  IERC20 dLot;

  mapping(uint256=>address) public owners;

  mapping(uint256=>address) public participants;
  mapping(uint256=>address) public winers;
  mapping(uint256=>uint256) public randoms;


  bool public pause = false;
  bool internal nextRoundpause = false;

  uint256 public participantCount;
  uint256 public poolMaxAmount;
  uint256 public ticketPrice ;
  uint256 public randomNumber;
  uint256 public round ;


  
  modifier checkMax(uint256 amount){
    require(amount+participantCount <= poolMaxAmount,"Pool Max Error!");
    _;
  }
  modifier checkEqualAmount(uint256 amount){
    require(amount * ticketPrice   == msg.value , "Ether send Error!" );
    _;
  }
  modifier notPause(){
    require(!nextRoundpause , "Contract is paused by owner!" );
    _;
  }
  modifier onlyOwner() {
    
    require(msg.sender == owners[1] || msg.sender == owners[2] ,"You are not owner" );
    _;

  }

  constructor(uint256 _max,uint256 _tokenPrice,IERC20 _dLot)
  {
    participantCount =0;
    randomNumber=0;
    round=1;
    poolMaxAmount =_max;
    ticketPrice=_tokenPrice;
    dLot= _dLot;
    owners[1] = msg.sender;
  }



  function buyTicket(uint256 amount) public payable checkMax(amount) checkEqualAmount(amount) notPause{
      
      //bool result =  payable(address(this)).send(msg.value);
      //require(result,"There are some thing wrongs on send ether");

      uint256 _participantCount=participantCount;
      uint256 firstTicket= _participantCount;
      uint256 lastTicket = _participantCount+amount;

      for(uint256 i= _participantCount;  i<  _participantCount+amount ; i++ ){
          participants[i+1]=msg.sender;
          dLot.transfer(msg.sender, 1 ether);
          participantCount++;
      }

      emit BuyTicket(msg.sender,round, firstTicket+1, lastTicket  ,  ticketPrice  );
      
      if(participantCount == poolMaxAmount ) {
        spreadReward();
      }

  
  }



  function spreadReward() public {
      require( participantCount == poolMaxAmount ,"Pool does not rich to max");
      
      setRandomNumber();
      uint256 contractBalance = address(this).balance  ;
      bool result =  payable(participants[randomNumber]).send( (contractBalance * 90) / 100  );
      bool result2 =  payable( owners[1] ).send(  (contractBalance * 5) / 100  );
      bool result3 =  payable( owners[2] ).send(  (contractBalance * 5) / 100  );

      randoms[round]=randomNumber;
      winers[round]=participants[randomNumber];

      require(result && result2 && result3 , "Transfer error");
      


      emit SpreadReward(round,participants[randomNumber],randomNumber , ticketPrice, poolMaxAmount  );

      for(uint256 i= 1;  i<  poolMaxAmount ; i++ ){

          participants[i]=address(0);
      }

      nextRoundpause=pause;
      
      randomNumber=0;
      participantCount=0;
      round++;
      

  }

  function setRandomNumber() internal {
    
    uint256 random_number = (uint256(keccak256(abi.encodePacked(msg.sender,block.timestamp, block.prevrandao))) % poolMaxAmount ) + 1;

    randomNumber= random_number;
      //block.timestamp * poolMaxAmount;  
  }
  function setPause(bool act) public onlyOwner{
      pause=act;
      if(!act){
        nextRoundpause = act;
      }
  }
  function setOwner(uint256 index,address owner) public onlyOwner{
    
    require(owners[index] != msg.sender , "owner_credentical_error");

    owners[index]=owner;

  }

  function getRandomByRound(uint256 _round) public view returns (uint256){
      return randoms[_round];
  }
  function getWinerByRound(uint256 _round) public view returns (address){
      return winers[_round];
  }

  //random 
 
    //end random
  event BuyTicket(address indexed user, uint256 indexed round,uint256 firstTicket ,uint256 lastTicket,uint256 price);
  event SpreadReward(uint256 indexed round , address indexed user, uint256 random , uint256 tokenPrice, uint256 poolMaxAmount);

}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
