// SPDX-License-Identifier: MIT
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
// SPDX-License-Identifier: MIT
// contracts/GODRAINIDO.sol

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GODRAINIDO is Ownable {
    uint public constant BASE_DIVIDER = 10000;

    address public usdt;

    address public token;

    address public presaleWallet;

    uint public salePrice;

    uint[] public packages;

    mapping(address => uint) public records;

    mapping (address => uint) public rewards;

    mapping(address => address) public referrers;

    mapping(address => uint) public referrerNum;

    uint[] public referrerProfits;

    event Reward(address indexed owner, uint amount);

    event Referrer(address indexed owner, address referrer);

    event Presale(address indexed owner, uint usdtAmount, uint amount);

    constructor() {
        salePrice = 10000000;
        packages = [
            50 * 10 ** 18,
            100 * 10 ** 18,
            300 * 10 ** 18,
            500 * 10 ** 18
            ];
        referrerProfits = [
                    500,
                    200
            ];
    }

    function presale(address referrer, uint usdtAmount) public {
        require(referrer != address(0), "GODRAINIDO: Invalid referrer");
        require(referrer != address(this), "GODRAINIDO: Invalid referrer");
        require(referrer != _msgSender(), "GODRAINIDO: Invalid referrer");
        require(records[_msgSender()] == 0, "GODRAINIDO: Participated in pre-sale");
        require(_isExistPackages(usdtAmount), "GODRAINIDO: Invalid USDT amount");

        if (referrers[_msgSender()] == address(0)) {
            _setReferrer(referrer);
        } else {
            require(false, "GODRAINIDO: Error referrer");
        }

        uint referrerReward = _reward(usdtAmount);
        uint balance = usdtAmount - referrerReward;
        if (balance > 0) {
            IERC20(usdt).transferFrom(_msgSender(), presaleWallet, balance);
        }

        uint tokenAmount = usdtAmount * salePrice;
        if (tokenAmount > 0) {
            IERC20(token).transfer(_msgSender(), tokenAmount);
            records[_msgSender()] += tokenAmount;
        }

        emit Presale(_msgSender(), usdtAmount, tokenAmount);
    }

    function _reward(uint amount) internal returns (uint) {
        uint total = 0;
        address referrer = _msgSender();
        for (uint i = 0; i < referrerProfits.length; i++) {
            referrer = referrers[referrer];
            if (referrer == address(0)) {
                break;
            }

            uint reward = amount * referrerProfits[i] / BASE_DIVIDER;
            if (reward > 0) {
                IERC20(usdt).transferFrom(_msgSender(), referrer, reward);
                rewards[referrer] += reward;
                total += reward;
                emit Reward(referrer, reward);
            }
        }

        return total;
    }

    function _isExistPackages(uint amount) internal view returns (bool) {
        bool found = false;
        for (uint i = 0; i < packages.length; i++) {
            if (packages[i] == amount) {
                found = true;
                break;
            }
        }

        return found;
    }

    function _setReferrer(address referrer) internal {
        bool result = false;
        address parent = referrer;
        while (true) {
            if (parent == address(0)) {
                result = true;
                break;
            }

            if (parent == _msgSender()) {
                result = false;
                break;
            }
            parent = referrers[parent];
        }

        require(result, "GODRAINIDO: Inviter address find loop");
        referrers[_msgSender()] = referrer;
        referrerNum[referrer]++;
        emit Referrer(_msgSender(), referrer);
    }

    function getPackages() public view returns (uint[] memory) {
        return packages;
    }

    function takeOut(address owner, uint amount) public onlyOwner {
        IERC20(token).transfer(owner, amount);
    }

    function setConfig(address _usdt, address _token, address _wallet) public onlyOwner {
        usdt = _usdt;
        token = _token;
        presaleWallet = _wallet;
    }

    function setSaleConfig(uint _salePrice) public onlyOwner {
        salePrice = _salePrice;
    }

    function setPackages(uint[] memory _packages) public onlyOwner {
        packages = _packages;
    }

    function setReferrerProfits(uint[] memory _profits) public onlyOwner {
        referrerProfits = _profits;
    }
}
