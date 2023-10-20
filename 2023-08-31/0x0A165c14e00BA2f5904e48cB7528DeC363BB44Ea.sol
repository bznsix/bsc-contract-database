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
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IPancakePair {
    function getReserves() external view returns (
        uint112 _reserve0,
        uint112 _reserve1,
        uint32 _blockTimestampLast
    );
}

contract OracleStatic is Ownable {
    uint256 private usdtAmount = 0;
    uint256 private tokenAmount = 0;

    uint256 private minTokenAmount = 78558425;
    uint256 private maxTokenAmount = 96015852;

    address public pairAddress;
    address public stableToken;
    address public tokenAddress;

    constructor(address _pairAddress, address _stableToken, address _tokenAddress) {
        pairAddress = _pairAddress;
        stableToken = _stableToken;
        tokenAddress = _tokenAddress;
    }

    function convertUsdBalanceDecimalToTokenDecimal(uint256 _balanceUsdDecimal) public view returns (uint256) {
        if (tokenAmount > 0 && usdtAmount > 0) {
            uint256 amountTokenDecimal = (_balanceUsdDecimal * tokenAmount) / usdtAmount;
            return amountTokenDecimal;
        }

        (uint256 _reserve0, uint256 _reserve1, ) = IPancakePair(pairAddress).getReserves();
        (uint256 _tokenBalance, uint256 _stableBalance) = address(tokenAddress) < address(stableToken) ? (_reserve0, _reserve1) : (_reserve1, _reserve0);

        uint256 _minTokenAmount = (_balanceUsdDecimal * minTokenAmount) / 1000000;
        uint256 _maxTokenAmount = (_balanceUsdDecimal * maxTokenAmount) / 1000000;

        uint256 _tokenAmount = (_balanceUsdDecimal * _tokenBalance) / _stableBalance;

        if (_tokenAmount < _minTokenAmount) {
            return _minTokenAmount;
        }

        if (_tokenAmount > _maxTokenAmount) {
            return _maxTokenAmount;
        }

        return _tokenAmount;
    }

    function setUsdtAmount(uint256 _usdtAmount) public onlyOwner {
        usdtAmount = _usdtAmount;
    }

    function setTokenAmount(uint256 _tokenAmount) public onlyOwner {
        tokenAmount = _tokenAmount;
    }

    function setMinTokenAmount(uint256 _tokenAmount) public onlyOwner {
        minTokenAmount = _tokenAmount;
    }

    function setMaxTokenAmount(uint256 _tokenAmount) public onlyOwner {
        maxTokenAmount = _tokenAmount;
    }
}
