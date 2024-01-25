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
pragma solidity 0.8.21;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract sunlightSwap is Ownable {
    IERC20 public sltToken;
    IERC20 public stablecoin;
    uint256 public sltPrice;
    uint256 immutable stableCoinPrice = 1000;
    uint256 public swapFee;

    event AddedFunds(address tokenAddress, uint256 amount);
    event FundsTransferred(
        address from,
        address to,
        address token,
        uint256 amount
    );
    event RemovedFunds(address tokenAddress, uint256 amount);
    modifier addressCheck() {
        _;
    }

    constructor(
        address _slt,
        address _stablecoin,
        uint256 _sltPrice,
        uint256 _swapFee
    ) {
        sltToken = IERC20(_slt);
        stablecoin = IERC20(_stablecoin);
        sltPrice = _sltPrice;
        swapFee = _swapFee;
    }

    function adminFee(uint256 amount) internal view returns (uint256) {
        uint256 newAmount = ((amount * swapFee) / 100) / 1e3;
        return newAmount;
    }

    function checkMinRequirement(address token1, uint256 amount) internal view {
        if (IERC20(token1) == sltToken) {
            require(
                (sltPrice * amount) / 1e3 >= 1_000_000_000,
                "The minimum amount to withdraw for stable coin is not met."
            );
        } else {
            require(
                amount >= 10000000000000000000,
                "The the minimum amount to withdraw for slt is not met "
            );
        }
    }

    function swappingToken(
        address token1,
        address token2,
        uint256 amount
    ) external {
        require(
            (token1 == address(sltToken) || token1 == address(stablecoin)) &&
                (token2 == address(sltToken) || token2 == address(stablecoin)),
            "Only SLT and Bep-20 tokens are allowed."
        );
        require(
            token1 == address(sltToken)
                ? IERC20(token2).balanceOf(address(this)) > amount
                : IERC20(token2).balanceOf(address(this)) * 1e10 > amount,
            "The contract lacks liquidity for the trade"
        );
        uint256 newAmount = amount - adminFee(amount);
        uint256 amountTokenOut = (
            token1 == address(sltToken)
                ? ((newAmount * sltPrice) / 1e3) * 1e10
                : ((newAmount * 1e3) / sltPrice) / 1e10
        );
        checkMinRequirement(token1, amount);
        require(
            IERC20(token1).transferFrom(_msgSender(), address(this), amount),
            "Error while transferring tokens from the initiators wallet to the smart contract."
        );
        emit FundsTransferred(_msgSender(), address(this), token1, amount);
        require(
            IERC20(token2).transfer(_msgSender(), amountTokenOut),
            "Error while transferring tokens from the smart contract to the initiators wallet."
        );

        emit FundsTransferred(
            address(this),
            _msgSender(),
            token2,
            amountTokenOut
        );
    }

    function addFunds(uint256 amount, address tokenAddress) external {
        require(
            tokenAddress == address(sltToken) ||
                tokenAddress == address(stablecoin),
            "Only SLT and Bep-20 tokens are allowed."
        );
        require(amount > 0, "Amount should be greater than zero.");
        if (tokenAddress == address(sltToken)) {
            require(
                sltToken.transferFrom(_msgSender(), address(this), amount),
                "Error while transferring SLT."
            );
            emit AddedFunds(address(sltToken), amount);
        } else {
            require(
                stablecoin.transferFrom(_msgSender(), address(this), amount),
                "Error while transferring StableCoin."
            );
            emit AddedFunds(address(stablecoin), amount);
        }
    }

    function setSltPrice(uint256 newPrice) external onlyOwner {
        sltPrice = newPrice;
    }

    function setSwapFee(uint256 newSwapFee) external onlyOwner {
        swapFee = newSwapFee;
    }

    function withdrawLiquiditySlt(uint256 amount) external onlyOwner {
        require(
            amount <= sltToken.balanceOf(address(this)),
            "Amount should be less than or equal to the tokens in the Contract"
        );
        require(
            sltToken.transfer(owner(), amount),
            "Error while transferring SLt from the contract"
        );
        emit RemovedFunds(address(sltToken), amount);
    }

    function withdrawLiquidityStableCoin(uint256 amount) external onlyOwner {
        require(
            amount <= stablecoin.balanceOf(address(this)),
            "Amount should be less than or equal to the tokens in the Contract"
        );
        require(
            stablecoin.transfer(owner(), amount),
            "Error while transferring SLt from the contract"
        );
        emit RemovedFunds(address(stablecoin), amount);
    }

    function getSltAndStablecoinBalance()
        external
        view
        returns (uint256, uint256)
    {
        return (
            sltToken.balanceOf(address(this)),
            stablecoin.balanceOf(address(this))
        );
    }
}
