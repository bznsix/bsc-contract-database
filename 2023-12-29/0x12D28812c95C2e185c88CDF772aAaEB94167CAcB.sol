// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

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
    function transfer(address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _grantToSecondOwner(address newOwner) internal {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract DogeDashSwapper is Ownable {
    /* -------------------------------------------------------------------------- */
    /*                                 errors                                 */
    /* -------------------------------------------------------------------------- */
    error AmountExceedsMaxSwapAmountPerPeriod();

    /* -------------------------------------------------------------------------- */
    /*                                 constants                                 */
    /* -------------------------------------------------------------------------- */
    /**
     * @dev one week in seconds
     */
    uint256 private constant ONE_WEEK = 7 days;

    /* -------------------------------------------------------------------------- */
    /*                                 immutable                                 */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice The address of the DogeDash token
     */
    IERC20 public immutable dogeDash;

    /**
     * @notice The address of the Hello token
     */
    IERC20 public immutable helloToken;

    /**
     * @notice The timestamp of the contract deployment
     */
    uint256 public immutable GENESIS_TIMESTAMP;

    /* -------------------------------------------------------------------------- */
    /*                                 state vars                                 */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice The maximum amount of DogeDash that can be swapped per period
     */
    uint256 public maxSwapAmountPerPeriod = 10_000_000 ether;

    /**
     * @notice The amount of DogeDash tokens that can be swapped for 1 Hello token
     */
    uint256 public dogeTokensPerHelloToken = 100;

    /* -------------------------------------------------------------------------- */
    /*                                  mappings                                  */
    /* -------------------------------------------------------------------------- */
    mapping(address => mapping(uint256 => uint256)) public amountSwappedAtWeek;

    /* -------------------------------------------------------------------------- */
    /*                                 constructor                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @param _dogeDash The address of the DogeDash token
     * @param _helloToken The address of the Hello token
     */
    constructor(address _dogeDash, address _helloToken) {
        dogeDash = IERC20(_dogeDash);
        helloToken = IERC20(_helloToken);
        GENESIS_TIMESTAMP = block.timestamp;
    }

    /* -------------------------------------------------------------------------- */
    /*                                    swap                                    */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Swaps DogeDash for Hello tokens
     * @param amount The amount of DogeDash to swap
     */
    function swap(uint256 amount) external {
        uint256 week = currentWeek();
        uint256 amountSwappedAtCurrentWeek = amountSwappedAtWeek[msg.sender][week];
        if (amountSwappedAtCurrentWeek + amount > maxSwapAmountPerPeriod) {
            revert AmountExceedsMaxSwapAmountPerPeriod();
        }
        amountSwappedAtWeek[msg.sender][week] = amountSwappedAtCurrentWeek + amount;
        dogeDash.transferFrom(msg.sender, address(0xdead), amount);
        uint256 amountHelloTokens = amount / dogeTokensPerHelloToken;
        helloToken.transfer(msg.sender, amountHelloTokens);
    }

    /* -------------------------------------------------------------------------- */
    /*                                  setters                                   */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Sets the amount of DogeDash tokens that can be swapped for 1 Hello token per time period
     * @param amount The nax amount of DogeDash tokens that can be swapeped per period for
     */
    function setMaxSwapAmountPerPeriod(uint256 amount) external onlyOwner {
        maxSwapAmountPerPeriod = amount;
    }

    /*-------------------------------------------------------------------------- */
    /*                                 recovery                                   */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Recovers ERC20 tokens sent to the contract
     * @param token The address of the ERC20 token to recover
     * @param amount The amount of tokens to recover
     */
    function recover(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }

    /**
     * @notice Recovers ETH sent to the contract
     */
    function recoverETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    //----------------------------------------------------------------------------*/
    /*                                  getters                                   */
    /* -------------------------------------------------------------------------- */
    /**
     * @notice Returns the current week
     * @return The current week
     */
    function currentWeek() public view returns (uint256) {
        return (block.timestamp - GENESIS_TIMESTAMP) / ONE_WEEK;
    }
}