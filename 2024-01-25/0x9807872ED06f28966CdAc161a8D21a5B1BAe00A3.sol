// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error.
 * This library is used to prevent overflow and underflow errors.
 */
library SafeMath {
    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     * @param a Unsigned integer.
     * @param b Unsigned integer to add to a.
     * @return The sum of a and b.
     */
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on underflow.
     * @param a Unsigned integer.
     * @param b Unsigned integer to subtract from a.
     * @return The difference of a and b.
     */
    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a, "SafeMath: subtraction underflow");
        uint c = a - b;

        return c;
    }

    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     * @param a Unsigned integer.
     * @param b Unsigned integer to multiply with a.
     * @return The product of a and b.
     */
    function mul(uint a, uint b) internal pure returns (uint) {
        // Optimization: if either a or b is 0, return 0 immediately.
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers, reverts on division by zero.
     * @param a Unsigned integer.
     * @param b Unsigned integer to divide by a.
     * @return The quotient of a divided by b.
     */
    function div(uint a, uint b) internal pure returns (uint) {
        // Solidity already throws when dividing by 0.
        // Therefore, no need for a separate check here.
        require(b > 0, "SafeMath: division by zero");
        uint c = a / b;

        return c;
    }

    /**
     * @dev Modulo of two unsigned integers, reverts on modulo by zero.
     * @param a Unsigned integer.
     * @param b Unsigned integer to use for modulo with a.
     * @return The remainder of a divided by b.
     */
    function mod(uint a, uint b) internal pure returns (uint) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
  contract context {

    using SafeMath for uint256;


            constructor () { }

         }


        
      /**
 * @title Ownable
 * @dev This contract has an owner address, and provides basic authorization control
 * functions, simplifying the implementation of "user permissions".
 */
   abstract contract Ownable is context {

    address public _owner;

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }



    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Emitted when ownership is transferred from one owner to another.
     * @param previousOwner Address of the former owner.
     * @param newOwner Address of the new owner.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}




/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard is Ownable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

    contract LotoFoot is ReentrancyGuard  {
        using SafeMath for uint256 ;
    address public Admin;
    uint public participation = 0.0004 ether;
    uint public NumberOfUsers = 1;
     

    mapping(uint => address) public IdToAdresss;
    
    mapping(address => User) public Users;
    mapping(address => address) public referrer;
    mapping(address => uint) public Userid;
    mapping(address => uint) public totalDeposit;
    mapping(address => uint  ) public totalAmountReceive;
    mapping(address => address[]) public referrals;
    mapping(address => uint256) public referralRewards;
    mapping(address=> bool  ) public IsUserRegistered;

    struct User {
        uint id ;
        address userAddress;
        address referrer;
    }


    constructor(address AdminAddress) { 
    Admin = AdminAddress ;
    Userid[_owner] = NumberOfUsers;
    IsUserRegistered[_owner] = true;
    NumberOfUsers = 1;

    IdToAdresss[Userid[_owner]]= _owner;

    }


    modifier OnlyAdmin {
        require(msg.sender == Admin,"Only the Admin can call thiis funvtion");
        _;
    }


    function Registration (address referrerUser) public {
     require(referrerUser != address(0), "Referrer cannot be the zero address");


        Users[msg.sender] = User({
            id: NumberOfUsers,
            userAddress: msg.sender,
            referrer: referrerUser
        });

        NumberOfUsers += 1;

        referrals[referrerUser].push(msg.sender);
        referrer[msg.sender] = referrerUser;
        Userid[msg.sender] = NumberOfUsers;
        IdToAdresss[Userid[msg.sender]] = msg.sender;
       IsUserRegistered[msg.sender] = true ;
    }

        function deposit () public payable {

        require(msg.value == participation,"incorrect participation fees");
        totalDeposit[msg.sender] += msg.value;

        
    }

    function DistributeEarnings(address[] memory winners, uint[] memory amounts) public OnlyAdmin {
    require(winners.length == amounts.length, "Winners and amounts must match in length");

    uint totalAmountNeeded = 0;
    for (uint i = 0; i < amounts.length; i++) {
        uint rewardForReferrer = amounts[i].mul(5).div(100); // 5% pour le parrain
        totalAmountNeeded += amounts[i] + rewardForReferrer;
    }

require(address(this).balance >= totalAmountNeeded, "Insufficient contract balance");

    for (uint i = 0; i < winners.length; i++) {
        address winner = winners[i];
        uint winnerAmount = amounts[i].mul(95).div(100); 
        uint referrerAmount = amounts[i].mul(5).div(100); 

        // Transfert de fonds au gagnant
        payable(winner).transfer(winnerAmount);
        totalAmountReceive[winner] += winnerAmount;

        // Transfert de la commission au parrain
        address referrers = referrer[winner];
        if (referrers != address(0)) {
            payable(referrers).transfer(referrerAmount);
            referralRewards[referrers] += referrerAmount;

        } else {
            // Si pas de parrain, le montant est transféré au propriétaire du contrat
            payable(_owner).transfer(referrerAmount);
        }
    }
}

      function CheckBalance (address payable _To , uint amount) public onlyOwner {

           require(amount <= address(this).balance,"Insufficient contract balance");
           payable(_To).transfer(amount);
      }

   function getTotalReferrals(address user) public view returns (uint) {
    return referrals[user].length;
}

         function GetTotalDeposit () public view returns  (uint256)  {
            return totalDeposit[msg.sender];
         }

         function GetRefferalRewards () public view returns (uint256) {
        return referralRewards[msg.sender];
         }
            function GettotalAmountReceive () public view returns (uint256) {
                return totalAmountReceive[msg.sender];
            }


     function Verification() public view returns (bool) {

         return IsUserRegistered[msg.sender];

}
          function setParticipation (uint newfees) public onlyOwner {
            require(newfees > 0,"incorrect entry");
                  participation = newfees ;
          }

         
               
         }