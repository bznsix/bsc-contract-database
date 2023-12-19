// Sources flattened with hardhat v2.14.0 https://hardhat.org

// File @openzeppelin/contracts/utils/Context.sol@v4.8.3

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}



/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

 

// import {IERC20VotesUpgradeable} from "./Util.sol";
/// @title  Token Distributor
/// @notice Holds tokens for users to claim.
/// @dev    Unlike a merkle distributor this contract uses storage to record claims rather than a
///         merkle root. This is because calldata on Arbitrum is relatively expensive when compared with
///         storage, since calldata uses L1 gas.
///         After construction do the following
///         1. transfer tokens to this contract
///         2. setRecipients - called as many times as required to set all the recipients
///         3. transferOwnership - the ownership of the contract should be transferred to a new owner (eg DAO) after all recipients have been set
contract Distributor2 is Ownable {
    /// @notice Token to be distributed
    address public token;
    /// @notice amount of tokens that can be claimed by address
    mapping(address => bool) public claimableTokens;
    /// @notice Total amount of tokens claimable by recipients of this contract
    uint256 public totalClaimable = 10000;

    uint256 public claimAmount;
    /// @notice Block number at which claiming starts
    uint256 public claimPeriodStart;
    /// @notice Block number at which claiming ends
    uint256 public claimPeriodEnd;

    mapping(address => uint256) public inviteRewards;
    mapping(address => uint256) public inviteCounts;
    // mapping(address => bool) public whiteList;

    /// @notice recipient has claimed this amount of tokens
    event HasClaimed(address indexed recipient, uint256 amount);
    /// @notice Tokens withdrawn
    event Withdrawal(address indexed recipient, uint256 amount);

    // npx hardhat node --fork https://bsc-mainnet.nodereal.io/v1/1579f014059f49778b29af287eff9745
    constructor(
        address _token
    )  {
        // require(_token != address(0), "TokenDistributor: zero token address");
        claimAmount = _token != address(0) ?  1000000000 * 10 ** IERC20Metadata(_token).decimals() : 0;
        token = _token;
        claimPeriodStart = block.timestamp;
        claimPeriodEnd = claimPeriodStart + 5184000;
    }

    /// @notice Allows owner of the contract to withdraw tokens
    /// @dev A safety measure in case something goes wrong with the distribution
    // function withdraw(uint256 amount) external onlyOwner {
    //     require(IERC20(token).transfer(msg.sender, amount), "TokenDistributor: fail transfer token");
    //     emit Withdrawal(msg.sender, amount);
    // }

    function withdraw() external onlyOwner {
        uint256 amount = IERC20(token).balanceOf(address(this));
        require(IERC20(token).transfer(msg.sender, amount), "TokenDistributor: fail transfer token");
        emit Withdrawal(msg.sender, amount);
    }


    function setToken(address _token) external onlyOwner{
        require(_token != address(0), "TokenDistributor: claim not started");
        token = _token;
        claimAmount =  1000000000 * 10 ** IERC20Metadata(_token).decimals();
    }

    // function startAirdrop()  external onlyOwner {
    //     claimPeriodStart = block.timestamp;
    //     claimPeriodEnd = claimPeriodStart + 2592000;
    // }

    /// @notice Allows a recipient to claim their tokens
    /// @dev Can only be called during the claim period
    function claim(address _ref) public {
        require(_ref != address(0), 'TokenDistributor: is not ref');
        require(_ref != msg.sender, 'TokenDistributor: the same');
        require(block.timestamp >= claimPeriodStart, "TokenDistributor: claim not started");
        require(block.timestamp < claimPeriodEnd, "TokenDistributor: claim ended");
        require(!claimableTokens[msg.sender], "TokenDistributor: nothing to claim");
        require(totalClaimable > 0, "TokenDistributor: end");
        // require(whiteList[msg.sender], "TokenDistributor: is white");

        claimableTokens[msg.sender] = true;
        totalClaimable = totalClaimable - 1;
        // we don't use safeTransfer since impl is assumed to be OZ
        uint256 refAmount = claimAmount * 5 / 100;
        inviteRewards[_ref] = inviteRewards[_ref] + refAmount ;
        inviteCounts[_ref] = inviteCounts[_ref] + 1;
        IERC20(token).transfer(_ref, refAmount);
        IERC20(token).transfer(msg.sender, claimAmount);

        emit HasClaimed(msg.sender, claimAmount);
    }

    // function setWhiteList(address [] memory _whiteList, bool isWhite) public  onlyOwner{
    //     for(uint i = 0; i < _whiteList.length; i++){
    //         whiteList[_whiteList[i]] = isWhite;
    //     }
    // }

    // function setWhite(address _white, bool isWhite) public  onlyOwner{
    //     whiteList[_white] = isWhite;
    // }

}