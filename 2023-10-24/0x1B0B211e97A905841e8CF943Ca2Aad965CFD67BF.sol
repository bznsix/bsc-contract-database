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
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20Detailed is IERC20 {
    function decimals() external view returns (uint8);

    function mint(address _to, uint256 _amount) external;
}

contract PrivateSale is Ownable {
    uint256 public constant DENOMINATOR = 100_00;

    uint256 public releasePercent = 10_00;

    IERC20Detailed public token;
    IERC20Detailed public paymentToken;

    bool public enabled;
    uint256 public privatesalePrice;
    bool public claimEnabled;

    uint256 public maxRaiseToken;
    uint256 public raisedToken;
    uint256 public refPercent;

    mapping(address => uint256) public boughtAmount;
    mapping(address => uint256) public claimedAmount;
    mapping(address => address) public referrers; // (buyer => referrer)

    uint256 public startSaleAt;
    uint256 public endSaleAt;

    address public fundReceiver;

    event Claimed(address claimer, uint256 tokenAmount);
    event Bought(address buyer, uint256 tokenAmount);

    constructor(IERC20Detailed _token, IERC20Detailed _paymentToken) {
        enabled = false;
        claimEnabled = false;
        token = _token;
        paymentToken = _paymentToken;
        privatesalePrice = (125 * 10 ** _paymentToken.decimals()) / 10 ** 4; // $0.0125 per token, 6 decimals
        maxRaiseToken = 150_000_000 * 10 ** _token.decimals(); // 150M tokens
        refPercent = 10_00; // 10%
        fundReceiver = msg.sender;
    }

    function setToken(IERC20Detailed _token) external onlyOwner {
        token = _token;
    }

    function setFundReceiver(address _fundReceiver) external onlyOwner {
        fundReceiver = _fundReceiver;
    }

    function setPaymentToken(IERC20Detailed _paymentToken) external onlyOwner {
        paymentToken = _paymentToken;
    }

    function setMaxRaiseToken(uint256 _maxRaiseToken) external onlyOwner {
        maxRaiseToken = _maxRaiseToken;
    }

    function setReleasePercent(uint256 _releasePercent) external onlyOwner {
        require(
            _releasePercent <= DENOMINATOR,
            "Release percent must be less than or equal to 10000"
        );
        require(
            _releasePercent >= releasePercent,
            "Cannot decrease release percent"
        );
        releasePercent = _releasePercent;
    }

    function setRefPercent(uint256 _refPercent) external onlyOwner {
        require(
            _refPercent <= DENOMINATOR,
            "Ref percent must be less than or equal to 10000"
        );
        refPercent = _refPercent;
    }

    function setEnabled(bool _enabled) external onlyOwner {
        enabled = _enabled;
    }

    function setClaimEnabled(bool _claimEnabled) external onlyOwner {
        claimEnabled = _claimEnabled;
    }

    function setPrivatesalePrice(uint256 _privatesalePrice) external onlyOwner {
        privatesalePrice = _privatesalePrice;
    }

    function getAmountsOut(
        uint256 amountPaymentIn
    ) public view returns (uint256) {
        return (amountPaymentIn * 10 ** token.decimals()) / privatesalePrice;
    }

    function setSaleTime(
        uint256 _startSaleAt,
        uint256 _endSaleAt
    ) external onlyOwner {
        require(
            _startSaleAt < _endSaleAt,
            "Start sale must be less than end sale"
        );
        startSaleAt = _startSaleAt;
        endSaleAt = _endSaleAt;
    }

    function buy(uint256 paymentAmount, address ref) external {
        require(enabled, "Private sale is not enabled");
        require(
            block.timestamp >= startSaleAt && block.timestamp <= endSaleAt,
            "Private sale is not active"
        );

        if (ref != address(0) && referrers[msg.sender] == address(0)) {
            if (boughtAmount[ref] > 0) {
                referrers[msg.sender] = ref;
            } else {
                referrers[msg.sender] = msg.sender;
            }
        }
        require(paymentAmount > 0, "Amount must be greater than 0");

        uint256 refAmount = 0;
        if (
            referrers[msg.sender] != address(0) &&
            referrers[msg.sender] != msg.sender &&
            boughtAmount[referrers[msg.sender]] > 0
        ) {
            refAmount = (paymentAmount * refPercent) / DENOMINATOR;
        }
        if(refAmount > 0) {
            require(
                paymentToken.transferFrom(
                    msg.sender,
                    referrers[msg.sender],
                    refAmount
                ),
                "Ref transfer failed"
            );
        }
        require(
            paymentToken.transferFrom(
                msg.sender,
                fundReceiver,
                paymentAmount - refAmount
            ),
            "Payment transfer failed"
        );
        uint256 amountTokenReceive = getAmountsOut(paymentAmount);
        require(
            raisedToken + amountTokenReceive <= maxRaiseToken,
            "Max raise token reached"
        );
        boughtAmount[msg.sender] += amountTokenReceive;
        raisedToken += amountTokenReceive;
        emit Bought(msg.sender, amountTokenReceive);
    }

    function getClaimableAmount(address _addr) public view returns (uint256) {
        return
            (boughtAmount[_addr] * releasePercent) /
            DENOMINATOR -
            claimedAmount[_addr];
    }

    function claim() external {
        require(claimEnabled, "Privatesale is not claimable");
        require(boughtAmount[msg.sender] > 0, "You have not bought any token");
        uint256 amountToTransfer = getClaimableAmount(msg.sender);
        require(amountToTransfer > 0, "Nothing to claim");
        claimedAmount[msg.sender] += amountToTransfer;
        require(token.transfer(msg.sender, amountToTransfer), "Claim failed");
        emit Claimed(msg.sender, amountToTransfer);
    }

    function withdrawToken() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }

    function withdrawPaymentToken() public onlyOwner {
        uint256 balance = paymentToken.balanceOf(address(this));
        paymentToken.transfer(msg.sender, balance);
    }
}
