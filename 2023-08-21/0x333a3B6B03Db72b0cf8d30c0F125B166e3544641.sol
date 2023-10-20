// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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
//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


import "./interfaces/INikaStaking.sol";
import "./interfaces/IOracleSimple.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract IDOPool is Ownable, Pausable {

    /// -----------------------------------
    /// -------- Pool INFORMATION --------
    /// -----------------------------------

    /// @notice The address of oracle
    address public Oracle;

    /// @notice The address of staking contract
    address public nikaStaking;

    /// @notice The token to buy ticket
    address public USDC;

    /// @notice The token being sold
    address public token; 

    /// @notice Address where funds are collected
    address public treasuryAddress;

    /// @notice Amount of token sold
    uint256 public tokenSold = 0;

    /// @notice Min amount when buy through IDO Pool
    uint256 public minAmount;

    /// @notice Amount of usdc user has staked/bought
    mapping(address => uint256) public usdcBought;

    /// @notice ten minutes in secons
    uint32 public constant TEN_MINUTES = 600;
    
    event BuyToken(address indexed _to, uint256 _amount);

    event UsdcBought(address indexed _user, uint256 _amount);
    
    constructor(address _token, address _usdc, address _nikaStaking, address _oracle, address _treasuryAddress) {
        USDC = _usdc;
        token = _token;
        nikaStaking = _nikaStaking;
        Oracle = _oracle;
        treasuryAddress = _treasuryAddress;

        minAmount = 1000 * 1e18;
    }

    /// @dev fallback function
    fallback() external {
        revert();
    }

    
    /// @dev fallback function
    receive() external payable {
        revert();
    }

    /// -----------------------------------
    /// --------- View Function -----------
    /// -----------------------------------

    function getTotalTokenSold() public view returns(uint256) { 

        return tokenSold;
    }

    function getTotalUSDStakedAndBought(address _user) public view returns(uint256) { 

        return usdcBought[_user];
    }

    /// -----------------------------------
    /// --------- Update Function ---------
    /// -----------------------------------

    /// @notice Owner add root to verify.
    /// @param _wallet root of merkle tree
    function updateTreasuryWallet(address _wallet) external onlyOwner {
        treasuryAddress = _wallet;
    }

    
    /// @notice Owner update new token IDO address, Stable Coin Address, NikaStaking Address
    /// @param _token address of IDO token
    /// @param _usdc address of stable coin usdc
    /// @param _nikaStaking address of staking contract 
    /// @param _oracle address of oracle
    function updateAddress(address _token, address _usdc, address _nikaStaking, address _oracle) external onlyOwner {
        token = _token;
        USDC = _usdc;
        nikaStaking = _nikaStaking;
        Oracle = _oracle;
    }

    /// @notice Owner update new token IDO address
    /// @param _token address of IDO token
    function updateTokenAddress(address _token) external onlyOwner {
        token = _token;
    }

    /// @notice Owner update new token USDC address, Stable Coin Address
    /// @param _usdc address of usd token
    function updateUSDAddress(address _usdc) external onlyOwner {
        USDC = _usdc;
    }

    /// @notice Owner update new NikaStaking address
    /// @param _nikaStaking address of NikaStaking 
    function updateNikaStakingAddress(address _nikaStaking) external onlyOwner {
        nikaStaking = _nikaStaking;
    }

    /// @notice Owner update new Oracle address
    /// @param _oracle address of oracle
    function updateOracleAddress(address _oracle) external onlyOwner {
        Oracle = _oracle;
    }

    /// @notice Owner update mint amount
    /// @param _minAmount address of oracle
    function updateMinAmount(uint256 _minAmount) external onlyOwner {
        minAmount = _minAmount;
    }

    /// -----------------------------------
    /// --------- Core Function -----------
    /// -----------------------------------

    function usdcUserBought(address _user, uint256 _amountNika) public whenNotPaused {
        require(Oracle != address(0), "Pool: Oracle Cannot be zero address");
        require(nikaStaking != address(0), "Pool: Staking Contract Cannot be zero address");
        require(msg.sender == nikaStaking, "Pool: Caller not staking address");

        uint32 oracleLastTimeStamp = IOracleSimple(Oracle).getBlockTimestampLast();
        uint32 timeElapsed = uint32(block.timestamp) - oracleLastTimeStamp;

        if (timeElapsed > TEN_MINUTES) { 
            IOracleSimple(Oracle).update();
        }

        uint256 amoutOut = IOracleSimple(Oracle).consult(token, _amountNika);

        usdcBought[_user] +=  amoutOut;

        emit UsdcBought(_user, amoutOut);
    }

    
    /// @notice Buy Ticket To Join IDO pool
    /// @param _amount amount of token neeeded to buy ticket
    function buyToken(
        uint256 _amount,
        address _referrer
    ) public whenNotPaused {
        require(_amount > minAmount, "pool: amount must greater than min amount");
        require(USDC != address(0), "pool: usdc cant not be 0 address");
        require(token != address(0), "Pool: Token Cannot be zero address");
        require(Oracle != address(0), "Pool: Oracle Cannot be zero address");
        require(nikaStaking != address(0), "Pool: Staking Contract Cannot be zero address");

        address ref = _referrer;

        if (INikaStaking(nikaStaking).isReferral(msg.sender) == false) {
            if (_referrer == address(0)) {
                ref = treasuryAddress;
            }
        }

        // calculate amount output of Nika Token
        uint32 oracleLastTimeStamp = IOracleSimple(Oracle).getBlockTimestampLast();
        uint32 timeElapsed = uint32(block.timestamp) - oracleLastTimeStamp;
        
        if (timeElapsed > TEN_MINUTES) { 
            IOracleSimple(Oracle).update();
        }
        
        uint256 amoutOut = IOracleSimple(Oracle).consult(USDC, _amount);
        usdcBought[msg.sender] += _amount;

        _forwardTokenFunds(_amount);
        
        IERC20(token).approve(nikaStaking, amoutOut);
        INikaStaking(nikaStaking).depositIDO(amoutOut, msg.sender, ref);
        _updatePurchasingState(amoutOut);

        emit BuyToken(msg.sender, amoutOut);
        emit UsdcBought(msg.sender, _amount);
    }

    /// @notice Owner can receive their fund in USDC
    /// @dev  Can refund remainning USDC in contract
    function withdrawFundUSDC() external onlyOwner {
        require(USDC != address(0), "Pool: usdc cant not be 0 address");
        require(IERC20(USDC).balanceOf(address(this)) > 0, "Pool::EMPTY_BALANCE");
        require(treasuryAddress != address(0), "Pool::ZERO_ADDRESS");

        uint256 remain = IERC20(USDC).balanceOf(address(this));
        IERC20(USDC).transfer(address(treasuryAddress), remain);
    }

    /// @notice Owner can receive any tokens that stuck in contract
    /// @dev  Can refund remainning token
    function withdrawToken(address _token, uint256 _amount) external onlyOwner {
        require(_token != address(0), "Pool: token cant not be 0 address");
        require(IERC20(_token).balanceOf(address(this)) > 0, "Pool::EMPTY_BALANCE");
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "Pool::INVALID_WITHDRAW_AMOUNTS");
        require(treasuryAddress != address(0), "Pool::ZERO_ADDRESS");

        IERC20(_token).transfer(address(treasuryAddress), _amount);
    }


    /// -----------------------------------
    /// -------- Internal Function --------
    /// -----------------------------------

    
    /// @dev Determines how Token is stored/forwarded on purchases.
    function _forwardTokenFunds(uint256 _amount) internal {
        IERC20(USDC).transferFrom(msg.sender, address(this), _amount);
    }


    /// @dev function update token have been sold
    /// @param _tokens Value of sold tokens
    function _updatePurchasingState(uint256 _tokens) internal {
        tokenSold = tokenSold + _tokens;
    }

}//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface INikaStaking {

    function depositIDO(uint256 amount, address stakeUser, address referrer) external;

    function isReferral(address _user) external view returns(bool);
}//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IOracleSimple {

    function getBlockTimestampLast() external view returns (uint32);

    function consult(address token, uint amountIn) external view returns (uint amountOut);

    function update() external;

}