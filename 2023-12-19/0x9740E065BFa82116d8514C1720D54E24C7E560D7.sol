// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
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

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract Warp {
    address _baseToken;

    constructor(address token){
        _baseToken = token;
    }

	function withdraw() external  returns(bool){
        uint256 amount = IERC20(_baseToken).balanceOf(address(this));
		if(amount > 0){
            IERC20(_baseToken).transfer(msg.sender,amount);
		}
        return true;
	}
}

contract BEP20PayToken is Ownable{
    using SafeMath for uint256;
    address private _uniswapRouterV2Address = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address _baseToken = address(0x55d398326f99059fF775485246999027B3197955);
    address _buyToken = address(0x72B0CF88B95C5035f40BcfdF565def04f5bf5482);
    address _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    address hpzjAddress = address(0x751797a185a19eD32B1549876b158D9C47e8ff35);
    address _topAddress = address(0x9317c44EC0Ac63bdE71e51767F9783905d965FD7);
    address _nodeAddress = address(0x3F185F6Ac274f714a00B5dF834Cdda733a281F0e);
    address[] recvAddress;    
    IUniswapV2Router02 public uniswapV2Router; 
    Warp warp;

    mapping(address => address) inviter;
    mapping(address => bool) buyState;

    event PayToken(address indexed token, address indexed sender, uint amount, uint tokenamount, uint orderid);
    event WithDrawalToken(address indexed token, address indexed sender, uint indexed amount);  
    event swapError(string reason);

    constructor(){

        warp = new Warp(_baseToken);

        uniswapV2Router = IUniswapV2Router02(_uniswapRouterV2Address);

        IERC20(_baseToken).approve(address(_uniswapRouterV2Address), 10**64);

        buyState[_topAddress] = true;
    }

    function random(uint number) public view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp,block.prevrandao,  
            msg.sender))) % number;
    }

    function payToken(address token, uint amount, uint orderid) external returns(bool){

        require(0 < amount, 'Amount: must be > 0');

        address sender = _msgSender();

        if(recvAddress.length != 0){
            IERC20(token).transferFrom(sender, address(this), amount);
            IERC20(token).transfer(recvAddress[random(recvAddress.length)], amount);
        }else{
            IERC20(token).transferFrom(sender, address(this), amount);
        }     

        emit PayToken(token, sender, amount, 0, orderid);

        return true;

    }

    function payToken(uint amount, uint orderid) external returns(bool){

        require(0 < amount, 'Amount: must be > 0');

        address sender = _msgSender();

        IERC20(_baseToken).transferFrom(sender, address(this), amount);
        IERC20(_baseToken).transfer(hpzjAddress, amount.mul(30).div(100));

        uint baseAmount = IERC20(_baseToken).balanceOf(address(this));
        
        swapTokensForUsdt(baseAmount);

        uint buyAmount = IERC20(_buyToken).balanceOf(address(this));
        
        IERC20(_buyToken).transfer(_destroyAddress, buyAmount.mul(60).div(100));
        IERC20(_buyToken).transfer(address(0x621A49b1eb964edcb5d2c00e0E9c73970a6e2Ad0), buyAmount.mul(10).div(100));//节点
        IERC20(_buyToken).transfer(address(0xDa4e55908B9B17999ECe68e90157035FDb3793f3), buyAmount.mul(20).div(100));//直推
        IERC20(_buyToken).transfer(address(0x8864cd48EDB3717333c748aaEAB8A68cB44Ab07b), buyAmount.mul(10).div(100));//生态

        emit PayToken(_baseToken, sender, amount, buyAmount, orderid);

        return true;

    }

    function setInviter(address account) external {
        
        address sender = _msgSender();       

        require(inviter[sender] == address(0), "Recommender bound");

        require(sender != account, "Can't bind myself");

        require(inviter[account] != sender, "Cannot bind to each other");

        inviter[sender] = account;
    }

    function getInviter() external view returns(address){

        return inviter[_msgSender()];

    }

    function buyNode(uint amount, uint orderid) external{

        address sender = _msgSender(); 

        require(amount == 5 * 10**18 || amount == 10 * 10**18 || amount == 20 * 10**18, "Can only be buy 500/1000/2000");   

        require(!buyState[sender], "Can only buy once");

        IERC20(_baseToken).transferFrom(sender, address(this), amount);

        address _inviter = inviter[sender];

        if(_inviter != address(0) && (buyState[_inviter])){

            IERC20(_baseToken).transfer(_inviter, amount.mul(10).div(100));

            IERC20(_baseToken).transfer(_nodeAddress, amount.mul(90).div(100));

        }else{

            IERC20(_baseToken).transfer(_nodeAddress, amount);

        }

        buyState[sender] = true;

        emit PayToken(address(0), sender, amount, 0, orderid);

    }

	function swapTokensForUsdt(uint256 tokenAmount) private {
		address[] memory path = new address[](2);
        path[0] = address(_baseToken);
        path[1] = address(_buyToken);
       try        
            uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(warp),
                block.timestamp
            )            
        {} catch Error(string memory reason){
            emit swapError(reason);
        }
        warp.withdraw();
    }

    function withDrawalToken(address token, address _address, uint amount) external onlyOwner returns(bool){

        IERC20(token).transfer(_address, amount);

        emit WithDrawalToken(token, _address, amount);

        return true;
    }
    
    function setRecvAddress(address[] memory addrs) external onlyOwner {

        recvAddress = addrs;

    } 

    function setBuyTokenAddress(address token) external onlyOwner {

        _buyToken = token;

    }
}