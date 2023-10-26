// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

import {Context} from "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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
// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.20;

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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IFO is Ownable {
    bool public open = false;
    uint256 public price = 100 * 10**18;
    // Payment address
    address public receiver = 0xC88B54202C03b9d21b41a4c20063D07c1d78C085;
    // Payment token
    address public buyToken = 0x55d398326f99059fF775485246999027B3197955; //usdt
    // Reward token
    address public sellToken = 0x2842D791a3c834f2606996D66D920e5aD213e6e6; //swapToken
    // Whether it has been mint
    mapping(address => bool) public _isMint;
    // mint count
    uint256 public mintCount = 0;

    address root = 0x321C095dacC681909E1cb498fF8b20A8B50D6b53;
    // Recommended relationship
    mapping(address => address) public share;

    mapping(address => address[]) public direct;

    constructor(address initialOwner) Ownable(initialOwner) {
        share[root] = msg.sender;
        _isMint[root] = true;
    }

    // Withdraw funds from the contract
    function drawCoins(address _contract) public onlyOwner {
        require(_contract != address(0), "_contract is the zero address");
        IERC20 coin = IERC20(_contract);
        uint256 amount = coin.balanceOf(address(this));
        coin.transfer(msg.sender, amount);
    }

    //  Set the sales open status
    function setOpen() external onlyOwner {
        open = !open;
    }

    // Set selling price
    function setPrice(uint256 _price) external onlyOwner {
        require(_price >= 1 * 10**18, "less than minimum quantity");
        price = _price;
    }

    // Set payment address
    function setReceiver(address _receiver) external onlyOwner {
        receiver = _receiver;
    }

    function setContracts(address _buyContract, address _sellContract)
        external
        onlyOwner
    {
        require(_buyContract != address(0), "Is not the zero address");
        require(_sellContract != address(0), "Is not the zero address");
        buyToken = _buyContract;
        sellToken = _sellContract;
    }

    function getDirect(address _address)
        public
        view
        returns (address[] memory)
    {
        require(_address != address(0), "_contract is the zero address");
        address[] storage mem = direct[_address];
        return mem;
    }

    function reg(address _pAddress) public {
        require(_pAddress != address(0), "_contract is the zero address");
        require(_pAddress != owner(), "root address");
        require(
            share[_pAddress] != address(0),
            "Shared address does not exist"
        );
        require(share[msg.sender] == address(0), "Registered");
        share[msg.sender] = _pAddress;
        address[] storage mem = direct[_pAddress];
        mem.push(msg.sender);
        direct[_pAddress] = mem;
    }

    function mint() public {
        require(open == true, "Not Started");
        require(_isMint[msg.sender] == false, "Already mint");
        require(
            share[msg.sender] != address(0),
            "Shared address does not exist"
        );
        IERC20 buyCoin = IERC20(buyToken);
        mintCount++;
        _isMint[msg.sender] = true;
        buyCoin.transferFrom(msg.sender, receiver, (price * 90) / 100);
        buyCoin.transferFrom(msg.sender, share[msg.sender], (price * 5) / 100);
        buyCoin.transferFrom(
            msg.sender,
            share[share[msg.sender]],
            (price * 5) / 100
        );
    }
}
