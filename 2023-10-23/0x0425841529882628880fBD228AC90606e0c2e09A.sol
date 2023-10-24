// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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
// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

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
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract OnchainGateway {
    address public immutable onchainSwap;

    modifier onlyOnchainSwap() {
        require(onchainSwap == msg.sender, "Symb: caller is not the onchainSwap");
        _;
    }

    constructor(address _onchainSwap) {
        onchainSwap = _onchainSwap;
    }

    function claimTokens(
        address _token,
        address _from,
        uint256 _amount
    ) external onlyOnchainSwap {
        IERC20(_token).transferFrom(_from, onchainSwap, _amount );
    }
}
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./OnchainGateway.sol";
import '@openzeppelin/contracts/access/Ownable.sol';



contract OnchainSwapV3  is Context, Ownable{

    uint256 public fee = 0.05 ether;

    event ClaimedTokens(address to, uint256 balance);
    event OnchainSwap(address token, uint256 amount, uint256 fee);

    OnchainGateway public onchainGateway;

    constructor() {
        onchainGateway = new OnchainGateway(address(this));
    }

    modifier hasFee() {
        require(msg.value >= fee);
        _;
    }

    function onswap(
        address token,
        uint256 amount,
        address dex,
        address dexgateway,
        bytes memory calldata_
    ) external payable hasFee {

        if(token!=address(0)) {
            onchainGateway.claimTokens(
                token,
                _msgSender(),
                amount
            );

            if (dexgateway == address(0)) {
                forceApprove(token, dex, amount);
            } else {
                forceApprove(token, dexgateway, amount);
            }
        }

        require(dex != address(onchainGateway), "OnchainSwap: call to onchain gateway");

        {
            uint256 size;
            address toCheck = dex;

            assembly {
                size := extcodesize(toCheck)
            }

            require(size != 0, "OnchainSwap: call for a non-contract account");
        }


        (bool swapPassed, ) = dex.call{value: msg.value - fee}(
            calldata_
        );

        require(swapPassed, "OnchainSwap: Fail to call");
        emit OnchainSwap(token, amount, fee);
    }

    function changeFee(uint256 _newFee) public onlyOwner {
        fee = _newFee;
    }

    function claimTokens(address _to) public onlyOwner {
        uint256 balance = address(this).balance;
        (bool sent, ) = _to.call{value: balance}("");
        require(sent, "Failed to send Ether");
        emit ClaimedTokens(_to, balance);
    }

    function forceApprove(address _token, address _recipient, uint256 _value) internal {
        IERC20 erc20token = IERC20(_token);
        if (erc20token.allowance(address(this), _recipient) < _value) {
            erc20token.approve(_recipient, 0);
            erc20token.approve(_recipient, type(uint256).max);
        }
    }
}