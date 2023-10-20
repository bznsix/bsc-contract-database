// SPDX-License-Identifier: GPL-3.0 AND MIT License1 AND License2 AND License3 AND License4

pragma solidity ^0.8.19;

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

/**
 * @title SafeMath
 * @dev Library for performing safe mathematical operations with unsigned integers.
 */
library SafeMath {
    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     * @param a The first integer to add.
     * @param b The second integer to add.
     * @return The sum of `a` and `b`.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow.
     * @param a The first integer to subtract from.
     * @param b The second integer to subtract.
     * @return The result of subtracting `b` from `a`.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     * @param a The first integer to multiply.
     * @param b The second integer to multiply.
     * @return The product of `a` and `b`.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Divides two unsigned integers, reverts on division by zero.
     * @param a The dividend.
     * @param b The divisor.
     * @return The quotient of `a` divided by `b`.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    /**
     * @dev Computes the remainder of dividing two unsigned integers, reverts when the divisor is zero.
     * @param a The dividend.
     * @param b The divisor.
     * @return The remainder of dividing `a` by `b`.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

/**
 * @title Presale
 * @dev A smart contract for managing a presale of tokens.
 */
contract Presale is Ownable {
    using SafeMath for uint256;

    IERC20 private _token;

    bool private _swSale = true;
    uint256 private _referEth = 1000; // Set the referral commission to 10% in BNB
    uint256 private _referToken = 2000; // Set the referral commission to 20% in tokens
    uint256 private saleMaxBlock;
    uint256 private salePrice = 250000;
    

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Constructor to initialize the Presale contract.
     * @param tokenAddress The address of the token contract.
     */
    constructor(address tokenAddress) {
        saleMaxBlock = block.number + 501520;
        _token = IERC20(tokenAddress);
    }

    /**
     * @dev Get the token associated with this presale contract.
     * @return The address of the token contract.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @dev Get the current block number and token balance of the caller.
     * @return nowBlock The current block number.
     * @return balance The token balance of the caller.
     */
    function getBlock() public view returns (uint256 nowBlock, uint256 balance) {
        nowBlock = block.number;
        balance = _balances[msg.sender];
    }

    /**
 * @dev Allows users to buy tokens by sending Ether.
 * @param _refer The address of the referrer (if any).
 * @return A boolean indicating whether the purchase was successful.
 */
function buy(address _refer) payable public returns (bool) {
    require(_swSale, "Sale is not active"); // Check if the sale is active
    require(msg.value >= 0.01 ether, "Minimum purchase amount not met"); // Check if the minimum purchase amount is met

    uint256 _msgValue = msg.value;

    // Calculate the number of tokens purchased based on the sale price
    uint256 _tokenAmount = _msgValue.mul(salePrice).div(1e18);

    // Transfer purchased tokens to the user
    _balances[msg.sender] = _balances[msg.sender].add(_tokenAmount);
    _token.transfer(msg.sender, _tokenAmount);

    // Calculate and execute referral commission (if applicable) in tokens
    if (_msgSender() != _refer && _refer != address(0) && _balances[_refer] > 0) {
        uint256 referToken = _tokenAmount.mul(20).div(100); // 20% commission in tokens
        _balances[_refer] = _balances[_refer].add(referToken);
        _token.transfer(_refer, referToken);
    }

    // Calculate and execute referral commission (if applicable) in Ether
    if (_msgSender() != _refer && _refer != address(0) && _balances[_refer] > 0) {
        uint256 referEth = _msgValue.mul(10).div(100); // 10% commission in Ether
        address payable referAddress = payable(_refer);
        referAddress.transfer(referEth);
    }

    // Return the execution status
    return true;
    }

    /**
    * @dev Allows the contract owner to clear the BNB balance of the contract.
    * The cleared BNB is transferred to the contract owner's address.
    */
    function clearBNB() public onlyOwner() {
    address payable _owner = payable(msg.sender);
    _owner.transfer(address(this).balance);
    }

    /**
     * @dev Allows the contract owner to withdraw any remaining tokens held by the contract.
     * Requires that there are remaining tokens to withdraw.
     */
    function withdrawRemainingTokens() public onlyOwner {
    uint256 remainingTokens = _token.balanceOf(address(this));
    require(remainingTokens > 0, "No remaining tokens to withdraw");
    _token.transfer(owner(), remainingTokens);
    }
}