// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);



    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

  
}

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract IdoPayToken is Ownable{

    using SafeMath for uint256;

    struct RewardsLog { 
        uint rType;
        uint rTime;
        uint256 rValue;
    }

    mapping(address => RewardsLog[]) private _rewardsLogList; 

    address[] recvAddress;

    address _noInviterAddress;

    address _topLevelAddress = address(0x999E93d2613b0C5Daf7Fe36D722C90d454d81fA9);

    address private _usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);

    address public rewardTokenAddress;

    bool bStop = false;

    bool _inviterRewardState = true;

    uint idoAmount = 100 * 10**18;

    uint rewardAmounts = 60_000_000 * 10**18;

    uint totalByuNum; //buy number

    uint totalBuyUser; //buy user size

    mapping(address => address) private _inviter;

    mapping(address => bool) private _buyState;//buy state

    mapping(address => uint) private _buyUserNum;//user buy number

    mapping(address => bool) private _withDrawState;

    mapping(address => uint) private _inviterRewarAmount;

    event IdoLog(address indexed sender, uint amount);

    event WithDrawalToken(address indexed token, address indexed sender, uint indexed amount);

    function random(uint number) public view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp,block.prevrandao,  
            msg.sender))) % number;
    }

    function _addRewardsLog(address _user,uint _type, uint _value) internal {

        _rewardsLogList[_user].push(RewardsLog(_type, block.timestamp, _value));

    }

    function setInviter(address account) external {
        require(msg.sender != address(0), "cannot be set inviter to zero address");
        require(_inviter[msg.sender] == address(0), "Accout is owned inviter");
        require(msg.sender != account, "Accout can't be self"); //A = A
        require(_inviter[account] != msg.sender, "Accout can't be each other"); //A = B B = A
        if(account != _topLevelAddress){
            require(_inviter[account] != address(0), "The recommender has no superior"); 
        }
        _inviter[msg.sender] = account;
    }

    function ido() external returns(bool){

        require(!bStop, "Ido has ended");

        require(recvAddress.length != 0, "error 1");

        address inviter = _inviter[msg.sender];

        require(inviter != address(0), "Accout No recommender");

        IERC20(_usdtAddress).transferFrom(msg.sender, address(this), idoAmount);       

        if(_inviterRewardState && (inviter != address(0)) && (inviter != _topLevelAddress) && _buyState[inviter]){

            IERC20(_usdtAddress).transfer(inviter, idoAmount.mul(20).div(100));

            _inviterRewarAmount[inviter] = _inviterRewarAmount[inviter] + idoAmount.mul(20).div(100);

            _addRewardsLog(msg.sender, 1, idoAmount.mul(20).div(100));

        }else{

            IERC20(_usdtAddress).transfer(_noInviterAddress, idoAmount.mul(20).div(100));

        }

        inviter = (inviter != address(0) ? _inviter[inviter] : address(0));

        if(_inviterRewardState && (inviter != address(0)) && (inviter != _topLevelAddress) && _buyState[inviter]){

            IERC20(_usdtAddress).transfer(inviter, idoAmount.mul(10).div(100));

            _inviterRewarAmount[inviter] = _inviterRewarAmount[inviter] + idoAmount.mul(10).div(100);

            _addRewardsLog(msg.sender, 2, idoAmount.mul(10).div(100));

        }else{

            IERC20(_usdtAddress).transfer(_noInviterAddress, idoAmount.mul(10).div(100));

        }

        IERC20(_usdtAddress).transfer(recvAddress[random(recvAddress.length)], idoAmount.mul(70).div(100));

        if(!_buyState[msg.sender]){

            totalBuyUser++;

        }

        _buyState[msg.sender] = true;

        _buyUserNum[msg.sender]++;

        totalByuNum++;

        emit IdoLog(msg.sender, idoAmount);    

        return true;

    }

    function withdrawRewardToken() external {

        require(bStop, "Ido it's not finished yet");

        require(!_withDrawState[msg.sender], "reward token Extracted");        

        uint amount = getRewardTokenAmount();

        IERC20(rewardTokenAddress).transfer(msg.sender, amount);

        _withDrawState[msg.sender] = true;

    }

    function withDrawalToken(address token, address _address, uint amount) external onlyOwner returns(bool){

        IERC20(token).transfer(_address, amount);

        emit WithDrawalToken(token, _address, amount);

        return true;
    }

    function getInviter()public view returns(address){

        return msg.sender == _topLevelAddress ? _topLevelAddress : _inviter[msg.sender];

    }

    function getCanDraw() public view returns(bool){

        return bStop;

    }

    function getIdoUserSize() public view returns(uint){
        
        return totalBuyUser;

    }

    function getIdoNum() public view returns(uint){
        
        return totalByuNum;

    }

    function getIdoAmount() public view returns(uint){
        
        return totalByuNum.mul(idoAmount);

    }

    function getRewardTokenAmount() public view returns(uint){

        if (_withDrawState[msg.sender]){

            return 0;

        }

        return totalByuNum != 0 ? rewardAmounts.div(totalByuNum).mul(_buyUserNum[msg.sender]) : 0;

    }

    function getInviterRewarAmount() public view returns(uint){
        
        return _inviterRewarAmount[msg.sender];

    }

    function getUserBuyNum() public view returns(uint){

        return _buyUserNum[msg.sender];

    }
        
    function getInviterRewarLog() public view returns (RewardsLog[] memory) {

        return _rewardsLogList[msg.sender];

    }    

    function setIdoAmount(uint amount) external onlyOwner{

        idoAmount = amount;

    }

    function setRecvAddress(address[] memory addrs) external onlyOwner {

        recvAddress = addrs;

    }

    function setNoInviterAddress(address addr) external onlyOwner {

        _noInviterAddress = addr;

    }

    function setTopLevelAddress(address addr) external onlyOwner {

        _topLevelAddress = addr;

    }

    function setRewardTokenAddress(address token) external onlyOwner {

        rewardTokenAddress = token;

    }

    function stopIdo() external onlyOwner{

        bStop = true;

    }

    function setInviterRewardState(bool state) external onlyOwner{

        _inviterRewardState = state;

    }

}