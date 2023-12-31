// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface ITradingCompetitionManager {
       
    
    /// @notice Trading competition timestamp info
    struct TimestampInfo {
        uint startTimestamp;        // when it starts
        uint endTimestamp;          // when it ends

        uint registrationStart;     // when regisitration starts
        uint registrationEnd;       // when registration ends
    }

    /// @notice Competition rules structure
    struct CompetitionRules {
        uint starting_balance;      // if != 0, anyone MUST have this starting_balance. Eg.: starting_balance = 100 * 1e18 --> 100 USDT as start
        address winning_token;      // User with more winning_token wins. must be in TradingTokens. Eg.: usdt
        address[] tradingTokens;    // tokens allowed for trading, at least 2! must contain winning_token. Eg.: usdt - wbnb
    }

    
    /// @notice Trading competition prize structure
    struct Prize {
        bool win_type;              // False == Higher PNL in n° of tokens wins | True == Higher % PNL wins
        uint[] weights;             // weights for each placement. Eg.: weights = [10,70,20] --> sorted then [1st = 70, 2nd = 20, 3rd = 10] 
        uint[] totalPrize;          // total prize to win (counting owner_fee). 
        uint owner_fee;             // the creator fee on the prize. owner_fee <= 250 (25%).
        address[] token;            // prize tokens
    }

    /// @notice Trading competition info structure
    struct TC {
        uint entryFee;              // EntryFee to pay to enter the trading competition. Number of tokens
        uint MAX_PARTICIPANTS;       // Max number of participants

        address owner;              // Creator of the trading competition
        address tradingCompetition; // Trading Competition Contract. This field is filled on deployment, must be init to address(0)
        
        string name;                // Name of the trading competition (can be address(0) on create() )
        string description;         // Description of the trading competition
        
        TimestampInfo timestamp;    // See struct TimestampInfo
        MarketType market;          // See enum MarketType
        Prize prize;                // See struct Prize
        CompetitionRules competitionRules; // See struct CompetitionsRules
    }

    /// @notice Define market types
    enum MarketType {SPOT, PERPETUALS}


    /// @dev functions
    function create(TC calldata _tradingCompetition) external;
    function idToTradingCompetition(uint _id) external view returns (TC memory);
    function router() external view returns(address);
    function idCounter() external view returns(uint);
    
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TradingCompetitionManagerEvents.sol";


interface ITradingCompetitionSpot {
    function _init(ITradingCompetitionManager.TC calldata _tc) external returns(bool);
    function validate_competition() external returns(bool);
    function tradingCompetition() external view returns(ITradingCompetitionManager.TC calldata tc);
}

interface ITradingCompetitionFactory {
    function deployTradingCompetition(address _owner, uint256 id) external returns(address);
}



/// @title Trading Competition Manager
/// @author Prometheus - ThenaFinance
/// @notice Create spot or perpetual trading competition
contract TradingCompetitionManager is Ownable, ReentrancyGuard, TradingCompetitionManagerEvents {

    using SafeERC20 for IERC20;
              
    /*****************************************/
    /*-----         -----**-----        -----*/
    /*              CONSTANTS                */
    /*-----         -----**-----        -----*/
    /*****************************************/

    uint256 public constant PRECISION = 1000;

    uint256 public constant MAX_TOKEN_PRIZE = 3;
    
    /*****************************************/
    /*-----         -----**-----        -----*/
    /*              VARIABLES                */
    /*-----         -----**-----        -----*/
    /*****************************************/

    /// @notice set if trading competition creation is permissionless 
    bool public isPermissionless;

    /// @notice Max time for registration (1h)
    uint256 internal MIN_TIME_REG_LENGTH = 1 hours;    

    /// @notice Max time for registration (1 week)
    uint256 internal MAX_TIME_REG_LENGTH = 1 weeks;   

    /// @notice Min time for competition (1h)
    uint256 internal MIN_TIME_COMP_LENGTH = 1 hours;   

    /// @notice Max time for competition (1 month [28days])
    uint256 internal MAX_TIME_COMP_LENGTH = 4 weeks;   

    /// @notice ID Counter
    uint256 private _idCounter;
    
    /// @notice Max fee owner can take from prize
    uint256 public  MAX_OWNER_FEE = 250;                //25%

    /// @notice Max number of winners
    uint256 public  MAX_PLACEMENTS = 100;

    /// @notice Max number of users
    uint256 public MAX_USERS = 1000;

    /// @notice protocol fee in number of tokens
    uint256 public protocol_fee;     

    /// @notice trading competition spot factory
    address public spotFactory;

    /// @notice trading competition spot factory
    address internal _router;

    /// @notice trading competition perpetual factory
    address public perpetualFactory;

    /// @notice protocol fee treasury
    address public protocol_fee_treasury;
    
    /// @notice protocol fee token
    address public protocol_fee_token;
    
    /// @notice allowed tokens for prize
    address[] public allowedTokenForPrize;

    /// @notice allowed tokens mapping.
    mapping(address => bool) public isAllowedToken;

    /// @notice trading competition per ID
    mapping(uint256 => address) internal _idToTCAddress;

    /// @notice set who's allow to create a trading competition. Early launch limited, then permissionless
    mapping(address => bool) public isAllowedCreator;

    
    /*****************************************/
    /*-----         -----**-----        -----*/
    /*              CONSTRUCTOR              */
    /*-----         -----**-----        -----*/
    /*****************************************/
    
    constructor() {
        protocol_fee_token = address(0x55d398326f99059fF775485246999027B3197955);
        _idCounter = 0;
        protocol_fee_treasury = msg.sender;
        protocol_fee = 50 * 1e18;  // 50 usdt  
        isPermissionless = false; 
    }

    
    /*****************************************/
    /*-----         -----**-----        -----*/
    /*              USER INTERACTION         */
    /*-----         -----**-----        -----*/
    /*****************************************/

    /// @notice Create a new trading competition
    /// @param _tradingCompetition  Trading Competition structure
    function create(TC calldata _tradingCompetition) public nonReentrant  {

        // if isPermissionless == false check allowed creator 
        if(!isPermissionless) require(isAllowedCreator[msg.sender] || msg.sender == owner(), "TCM: not allowed to create");

        // check validity
        _check(_tradingCompetition);

        // create competition
        address _tc = _create(_tradingCompetition);
        require(_tc != address(0), "TCM: Not able to deploy");

        // save it
        _save(_tc);

        // Get Prize and Protocol Fee
        _getPrize(_tradingCompetition, _tc);

        emit Create(_tradingCompetition, msg.sender, block.timestamp);
        
    }



    /*****************************************/
    /*-----         -----**-----        -----*/
    /*              INTERNAL FUNCTIONS       */
    /*-----         -----**-----        -----*/
    /*****************************************/

    
    /// @notice Check if it's a valid TC
    /// @param tc  Trading Competition structure
    function _check(TC calldata tc) internal view {
        // check timestamps
        require(tc.timestamp.registrationStart >= block.timestamp, "TCM: Registration timestamp low");
        require(tc.timestamp.registrationEnd >= tc.timestamp.registrationStart + MIN_TIME_REG_LENGTH, "TCM: MIN_TIME_REG_LENGTH");
        require(tc.timestamp.registrationEnd <= tc.timestamp.registrationStart + MAX_TIME_REG_LENGTH, "TCM: MAX_TIME_REG_LENGTH");
        require(tc.timestamp.startTimestamp >= tc.timestamp.registrationEnd, "TCM: Start before registration end");
        require(tc.timestamp.endTimestamp >= tc.timestamp.startTimestamp + MIN_TIME_COMP_LENGTH, "TCM: MIN_TIME_COMP_LENGTH");
        require(tc.timestamp.endTimestamp <= tc.timestamp.startTimestamp + MAX_TIME_COMP_LENGTH, "TCM: MAX_TIME_COMP_LENGTH");
        require(tc.MAX_PARTICIPANTS <= MAX_USERS && tc.MAX_PARTICIPANTS >= 1, "TCM: MAX_PARTICIPANTS");

        // check prize
        uint256 i = 0;
        uint len = tc.prize.token.length;
        require(len < MAX_TOKEN_PRIZE, "TCM: MAX_TOKEN_PRIZE");
        require(len == tc.prize.totalPrize.length,"TCM: !prizes len");
        for(i = 0; i < len; i++ ){
            require(isAllowedToken[tc.prize.token[i]], "TCM: token prize not allowed");
            require(tc.prize.totalPrize[i] > 0, "TCM: totalPrize too low");
        }
        require(tc.prize.owner_fee <= MAX_OWNER_FEE, "TCM: creator fee too high");
        require(tc.prize.weights.length > 0 &&  tc.prize.weights.length <= MAX_PLACEMENTS, "TCM: MAX_PLACEMENTS");

        uint256 temp_total_weight = 0;
        for(i = 0; i < tc.prize.weights.length; i ++){
            require(tc.prize.weights[i] > 0, "TCM: weights == 0");
            temp_total_weight += tc.prize.weights[i];
        }
        require(temp_total_weight == PRECISION, 'TCM: weight precision');

        // check tradingTokens
        require(tc.competitionRules.tradingTokens.length >= 2, 'TCM: at least 2 tradingTokens');
        bool flag = false;
        for(i = 0; i < tc.competitionRules.tradingTokens.length; i ++) {
            if(tc.competitionRules.winning_token == tc.competitionRules.tradingTokens[i]) flag = true;
            require(isAllowedToken[tc.competitionRules.tradingTokens[i]], "TCM: trading token not allowed");
        }
        for(i = 0; i < tc.competitionRules.tradingTokens.length; i++){
            address _tempToken = tc.competitionRules.tradingTokens[i];
            for(uint k = i + 1; k < tc.competitionRules.tradingTokens.length; k++){
                require(_tempToken != tc.competitionRules.tradingTokens[k], "TCM: equal trading tokens"); 
            }
        }


        require(flag, "TCM: winning token missing");
    }

    
    /// @notice Save new Trading Competition
    /// @param tc  Trading Competition structure
    function _create(TC calldata tc) internal returns(address){
        if(tc.market == ITradingCompetitionManager.MarketType.SPOT){
            require(spotFactory != address(0), 'TCF: SF addr0');
            return ITradingCompetitionFactory(spotFactory).deployTradingCompetition(tc.owner, _idCounter);
        } else {
            require(perpetualFactory != address(0), 'TCF: SF addr0');
            return ITradingCompetitionFactory(perpetualFactory).deployTradingCompetition(tc.owner, _idCounter);
        }
    
    }

    /// @notice Save new Trading Competition
    /// @dev update tradingCompetition
    /// @param _tc  Address of the Trading Competition contract
    function _save(address _tc) internal {       
        // save data
        _idToTCAddress[_idCounter] = _tc;
        unchecked{ _idCounter += 1; }
    }


    /// @notice Get the prize of the trading competition
    /// @param tc  Trading Competition structure
    function _getPrize(TC calldata tc, address _tc) internal {
        uint256 i = 0;
        for(i; i < tc.prize.token.length; i++){
            address _token = tc.prize.token[i];
            uint256 _amount = tc.prize.totalPrize[i];
            IERC20(_token).safeTransferFrom(msg.sender, _tc, _amount);
        }
        if(protocol_fee > 0) IERC20(protocol_fee_token).safeTransferFrom(msg.sender, protocol_fee_treasury, protocol_fee);

        require(ITradingCompetitionSpot(_tc)._init(tc));
    }



    /*****************************************/
    /*-----         -----**-----        -----*/
    /*              ADMIN FUNCTIONS          */
    /*-----         -----**-----        -----*/
    /*****************************************/

    function setTreasury(address _treasury) external onlyOwner {
        require(_treasury != address(0), 'TCM: address(0)');
        address old = protocol_fee_treasury;
        protocol_fee_treasury = _treasury;

        emit SetTreasury(old, _treasury, block.timestamp);
    }

    function setProtocolFee(uint256 amount) external onlyOwner {
        uint256 old = protocol_fee;
        protocol_fee = amount;

        emit SetProtocolFee(old, amount, block.timestamp);
    }

    function setProtocolFeeToken(address token) external onlyOwner {
        require(token != address(0), 'TCM: address(0)');
        address old = protocol_fee_token;
        protocol_fee_token = token;

        emit SetProtocolFeeToken(old, token, block.timestamp);
    }

    function setMaxUsers(uint256 _MAX_USERS) external onlyOwner {
        require(_MAX_USERS > 2, 'TCM: at least 2');
        uint256 old = MAX_USERS;
        MAX_USERS = _MAX_USERS;

        emit SetMaxUsers(old, _MAX_USERS, block.timestamp);
    }

    function setMaxPlacements(uint256 _MAX_PLACEMENTS) external onlyOwner {
        require(_MAX_PLACEMENTS > 0, 'TCM: at least 1');
        uint256 old = MAX_PLACEMENTS;
        MAX_PLACEMENTS = _MAX_PLACEMENTS;

        emit SetMaxPlacements(old, _MAX_PLACEMENTS, block.timestamp);
    }

    function addToken(address[] calldata _token) external onlyOwner {
        for(uint256 i = 0; i < _token.length; i++){
            isAllowedToken[_token[i]] = true;

            emit AddToken(_token[i], block.timestamp);
        }
    }

    
    function removeToken(address[] calldata _token) external onlyOwner {
        for(uint256 i = 0; i < _token.length; i++){
            isAllowedToken[_token[i]] = false;

            emit RemoveToken(_token[i], block.timestamp);
        }
    }
    
    function addCreator(address[] calldata _creator) external onlyOwner {
        for(uint256 i = 0; i < _creator.length; i++){
            isAllowedCreator[_creator[i]] = true;

            emit AddCreator(_creator[i], block.timestamp);
        }
    }

    function removeCreator(address[] calldata _creator) external onlyOwner {
        for(uint256 i = 0; i < _creator.length; i++){
            isAllowedCreator[_creator[i]] = false;

            emit RemoveCreator(_creator[i], block.timestamp);
        }
    }

    function setPermissionlessCreation(bool _type) external onlyOwner {
        isPermissionless = _type;
        emit SetPermissionlessCreation(_type, block.timestamp);
    }

    function setSpotFactory(address _spotFactory) external onlyOwner {
        require(_spotFactory != address(0), 'TCM: address(0)');
        address old = spotFactory;
        spotFactory = _spotFactory;

        emit SetSpotFactory(old, _spotFactory, block.timestamp);
    }

    function setPerpetualFactory(address _perpetualFactory) external onlyOwner {
        require(_perpetualFactory != address(0), 'TCM: address(0)');
        address old = perpetualFactory;
        perpetualFactory = _perpetualFactory;

        emit SetPerpetualFactory(old, _perpetualFactory, block.timestamp);
    }

    function setRouter(address _newRouter) external onlyOwner {
        require(_newRouter != address(0), 'TCM: address(0)');
        address old = _router;
        _router = _newRouter;

        emit SetRouter(old, _newRouter, block.timestamp);
    }



    /*****************************************/
    /*-----         -----**-----        -----*/
    /*              VIEW FUNCTIONS           */
    /*-----         -----**-----        -----*/
    /*****************************************/

    function idToTradingCompetition(uint256 _id) external view returns(TC memory){
        address tc_address = _idToTCAddress[_id];
        return ITradingCompetitionSpot(tc_address).tradingCompetition();
    }

    function idCounter() external view returns(uint256) {
        return _idCounter;
    }

    function router() external view returns(address) {
        return _router;
    }


    /*****************************************/
    /*-----         -----**-----        -----*/
    /*              HELPERS FUNCTIONS        */
    /*-----         -----**-----        -----*/
    /*****************************************/

    function _getLength(string memory _username) internal pure returns (uint256) {
        bytes memory b = bytes(_username);
        uint256 byteLength = b.length;
        uint256 charLength = 0;
        for (uint256 i = 0; i < byteLength; ) {
            charLength++;
        }
        return charLength;
    }
        

}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./ITradingCompetitionManager.sol";

/// @title Event contract
/// @author Prometheus - ThenaFinance
/// @notice Move events here to keep code clean. 

abstract contract TradingCompetitionManagerEvents is ITradingCompetitionManager {

    /*****************************************/
    /*-----         -----**-----        -----*/
    /*              USER EVENT               */
    /*-----         -----**-----        -----*/
    /*****************************************/

    event Create(TC indexed tradingCompetition, address indexed caller, uint blocktimestamp);


    /*****************************************/
    /*-----         -----**-----        -----*/
    /*              RESTRICTED EVENTS        */
    /*-----         -----**-----        -----*/
    /*****************************************/


    /*****************************************/
    /*-----         -----**-----        -----*/
    /*              ADMIN EVENTS             */
    /*-----         -----**-----        -----*/
    /*****************************************/

    /// @notice Emitted when a new treasury is set
    event SetTreasury(address indexed oldTreasury, address newTreasury, uint blocktimestamp);

    /// @notice Emitted when a new protocol fee is set
    event SetProtocolFee(uint indexed oldAmount, uint newAmount, uint blocktimestamp);

    /// @notice Emitted when a new fee token is set
    event SetProtocolFeeToken(address indexed oldtoken, address newToken, uint blocktimestamp);

    /// @notice Emitted when a new max amount of user for the trading competitions is set
    event SetMaxUsers(uint indexed oldAmount, uint newAmount, uint blocktimestamp);

    /// @notice Emitted when a new max amount of placements for the trading competitions is set
    event SetMaxPlacements(uint indexed oldAmount, uint newAmount, uint blocktimestamp);

    /// @notice Emitted when a new token is added 
    event AddToken(address indexed token, uint blocktimestamp);

    /// @notice Emitted when a new token is removed 
    event RemoveToken(address indexed token, uint blocktimestamp);

    /// @notice Emitted when a new creator is added 
    event AddCreator(address indexed creator, uint blocktimestamp);

    /// @notice Emitted when a creator is removed
    event RemoveCreator(address indexed creator, uint blocktimestamp);

    /// @notice Emitted when permissionless creation is set to true or false
    event SetPermissionlessCreation(bool indexed status, uint blocktimestamp);

    /// @notice Emitted when a spot factory is set
    event SetSpotFactory(address indexed old, address newFactory, uint blocktimestamp);

    /// @notice Emitted when a perpetual factory is set
    event SetPerpetualFactory(address indexed old, address newFactory, uint blocktimestamp);

    /// @notice Emitted when a new router for spot trading competition is set
    event SetRouter(address indexed old, address newRouter, uint blocktimestamp);


}// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/IERC20Permit.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Compatible with tokens that require the approval to be set to
     * 0 before setting it to a non-zero value.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
}
