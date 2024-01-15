// File: @openzeppelin/contracts@4.8.1/utils/Context.sol


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

// File: @openzeppelin/contracts@4.8.1/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts@4.8.1/token/ERC20/IERC20.sol


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

// File: AMC_DailyRelease.sol


pragma solidity 0.8.18;



contract AMCDailyRelease is Ownable {
    // AMC contract address
    address private constant AMC_TOKEN_ADDRESS =
        0x299142a6370e1912156E53fBD4f25D7ba49DdcC5;

    IERC20 private AMCToken;

    struct User {
        bool authorized;
    }

    // Authorized user lists
    mapping(address => User) private authorizedUsers;

    address[] private authorizedUserAddresses;

    uint256 private lastReleaseTime;

    // Interval between each execution
    uint256 private constant RELEASE_INTERVAL = 1 days;

    // Only authorized user can call releaseAMC()
    modifier onlyAuthorized() {
        require(authorizedUsers[msg.sender].authorized, "Unauthorized user");
        _;
    }

    constructor() {
        AMCToken = IERC20(AMC_TOKEN_ADDRESS);
    }

    // The event of Release
    event dailyRelease(
        address indexed sender,
        address[] recipients,
        uint256[] amounts
    );

    // Distribute a fixed number of AMCs to 3 addresses at regular intervals each day
    function releaseAMC() external onlyAuthorized {
        require(
            block.timestamp > lastReleaseTime + RELEASE_INTERVAL,
            "Release can only be executed once per day"
        );
        lastReleaseTime = block.timestamp - 30;

        require(
            AMCToken.balanceOf(address(this)) >= 100000 * 10**18,
            "Insufficient AMC balance"
        );

        address[] memory recipients = new address[](3);
        uint256[] memory amounts = new uint256[](3);

        recipients[0] = 0x5cbcd0896043a488d8df5138c2038f4A8Cc9d6f5;
        amounts[0] = 60000 * 10**18;

        recipients[1] = 0xd67E358163285789Ea10E5c1004Cfc4FfE1D3986;
        amounts[1] = 30000 * 10**18;

        recipients[2] = 0x93f08719e39915aCD1c3bceEDFE02733bdDad50C;
        amounts[2] = 10000 * 10**18;

        for (uint256 i = 0; i < recipients.length; i++) {
            require(
                AMCToken.transfer(recipients[i], amounts[i]),
                "AMC transfer failed"
            );
        }

        emit dailyRelease(msg.sender, recipients, amounts);
    }

    function extractAMC(uint256 amount) external onlyOwner {
        require(
            AMCToken.balanceOf(address(this)) >= amount * 10**18,
            "Insufficient AMC balance"
        );
        AMCToken.transfer(owner(), amount * 10**18);
    }

    // Cannot be renounceOwnership()
    function renounceOwnership() public view override onlyOwner {
        revert("Ownership cannot be renounced");
    }

    // Cannot be transferOwnership()
    function transferOwnership(address) public view override onlyOwner {
        revert("Ownership cannot be transferred");
    }

    function authorize_user(address approve_address) external onlyOwner {
        require(
            !authorizedUsers[approve_address].authorized,
            "User is already authorized"
        );
        authorizedUsers[approve_address].authorized = true;
        authorizedUserAddresses.push(approve_address);
    }

    function revoke_user(address revoke_address) external onlyOwner {
        require(
            authorizedUsers[revoke_address].authorized,
            "User is not authorized"
        );
        authorizedUsers[revoke_address].authorized = false;
        removeAuthorizedUser(revoke_address);
    }

    function removeAuthorizedUser(address userAddress) private {
        for (uint256 i = 0; i < authorizedUserAddresses.length; i++) {
            if (authorizedUserAddresses[i] == userAddress) {
                if (i != authorizedUserAddresses.length - 1) {
                    authorizedUserAddresses[i] = authorizedUserAddresses[
                        authorizedUserAddresses.length - 1
                    ];
                }
                authorizedUserAddresses.pop();
                break;
            }
        }
    }

    function getAuthorizedUsers()
        external
        view
        onlyOwner
        returns (address[] memory)
    {
        return authorizedUserAddresses;
    }

    function setLastDistributionTimeToMidnight() external onlyOwner {
        lastReleaseTime = block.timestamp - (block.timestamp % 1 days);
    }

    function getLastReleaseTime() external view onlyOwner returns (uint256) {
        return lastReleaseTime;
    }
}