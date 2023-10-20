// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICadinuProfile {
    function nftAddressToLevel(address nft) external view returns (uint256);
}

// Errors
error __errorAccessDenied();
error __errorWrongReferral();
error __errorNoTokenToWithdraw();
error __errorCannotWithdrawCbon();

// Cadinu Referral contract
contract CadinuReferral is Ownable {
    // Global Settings
    uint256 public constant LEVEL_POINT = 1000;
    uint256 public constant REFERRAL_LEVEL_POINT = 100;
    address public constant CBON = 0x6e64fCF15Be3eB71C3d42AcF44D85bB119b2D98b;

    // Events
    event Referral(address referralAddress, address referredAddress);
    event ReferralReward(address user, uint256 amount);
    event ReferralRewardClaimed(address user, uint256 amount);

    struct ReferralData {
        uint256 userNftCount;
        uint256 referralNftCount;
        uint256 nftPoint;
        uint256 withdrawnAmount;
        uint256 availableAmount;
    }

    mapping(address => ReferralData) public referralData;
    mapping(address => address[]) public referralAddress;
    mapping(address => address) public referredTo;
    mapping(address => bool) public isReferred;

    address public cadinuProfile;

    function setCadinuProfileAddress(address _cadinuProfileAddress) external onlyOwner {
        cadinuProfile = _cadinuProfileAddress;
    }

    function addReferral(address _referralAddress, address _referredAddress) external {
        if (ICadinuProfile(cadinuProfile).nftAddressToLevel(_msgSender()) == 0) revert __errorAccessDenied();
        if (_referralAddress == _referredAddress) revert __errorWrongReferral();
        if (!isReferred[_referredAddress]) {
            isReferred[_referredAddress] = true;
            referralAddress[_referralAddress].push(_referredAddress);
            referredTo[_referredAddress] = _referralAddress;
            emit Referral(_referralAddress, _referredAddress);
        }
    }

    function increaseAmount(
        address _buyer,
        address _referral,
        uint256 _nftCount,
        uint256 _referralAmount,
        uint256 _ownerAmount
    ) external {
        if (ICadinuProfile(cadinuProfile).nftAddressToLevel(_msgSender()) == 0) revert __errorAccessDenied();
        referralData[_buyer].userNftCount += _nftCount;
        referralData[_buyer].nftPoint +=
            _nftCount * ICadinuProfile(cadinuProfile).nftAddressToLevel(_msgSender()) * LEVEL_POINT;
        if (_referral != address(0)) {
            referralData[_referral].referralNftCount += _nftCount;
            referralData[_referral].nftPoint +=
                _nftCount * ICadinuProfile(cadinuProfile).nftAddressToLevel(_msgSender()) * REFERRAL_LEVEL_POINT;
            referralData[_referral].availableAmount += _referralAmount;
            referralData[address(this)].availableAmount += _ownerAmount;
            emit ReferralReward(_referral, _referralAmount);
        } else {
            referralData[address(this)].availableAmount += _ownerAmount;
        }
    }

    function withdrawReferralReward() external {
        if (referralData[_msgSender()].availableAmount == 0) revert __errorNoTokenToWithdraw();
        uint256 amount = referralData[_msgSender()].availableAmount;
        referralData[_msgSender()].availableAmount = 0;
        referralData[_msgSender()].withdrawnAmount += amount;
        IERC20(CBON).transfer(_msgSender(), amount);
        emit ReferralRewardClaimed(_msgSender(), amount);
    }

    function withdrawOwnerAmount() external {
        if (referralData[address(this)].availableAmount == 0) revert __errorNoTokenToWithdraw();
        uint256 amount = referralData[address(this)].availableAmount;
        referralData[address(this)].availableAmount = 0;
        referralData[address(this)].withdrawnAmount += amount;
        IERC20(CBON).transfer(owner(), amount);
    }

    function withdrawWrongToken(address _token) external {
        if (_token == CBON) revert __errorCannotWithdrawCbon();
        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(owner(), amount);
    }

    function getNumberOfReferredAddress(address _referral) public view returns (uint256) {
        return referralAddress[_referral].length;
    }

    function getReferredAddress(address _referralAddress, uint256 _start, uint256 _end)
        external
        view
        returns (address[] memory)
    {
        if (_end >= referralAddress[_referralAddress].length) {
            _end = referralAddress[_referralAddress].length - 1;
        }
        uint256 length = _end - _start + 1;
        address[] memory referredAddresses = new address[](length);

        for (uint256 ii = 0; ii <= length; ii++) {
            referredAddresses[ii] = referralAddress[_referralAddress][ii];
        }
        return referredAddresses;
    }

    function getNftPoint(address _user) external view returns (uint256) {
        return referralData[_user].nftPoint;
    }
}
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
