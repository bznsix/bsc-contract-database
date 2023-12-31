// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "IERC20.sol";
import "Ownable.sol";

contract Pool is Ownable {
    constructor(address max_, address signer_) {
        max = IERC20(max_);
        signer = signer_;

        uint256 currentChainId = getChainId();
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                DOMAIN_NAME,
                DOMAIN_VERSION,
                currentChainId,
                this
            )
        );
    }

    struct Seeds {
        uint256 _r;
        uint256 _s;
        uint256 _v;
    }

    struct Record {
        address user;
        uint256 amount;
        bool refunded;
    }

    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256(
            abi.encodePacked(
                "EIP712Domain(",
                "string name,",
                "string version,",
                "uint256 chainId,",
                "address verifyingContract",
                ")"
            )
        );

    function getChainId() public view returns (uint256 id) {
        // no-inline-assembly
        assembly {
            id := chainid()
        }
    }

    event Deposit(uint256 depositId, address owner, uint256 amount);
    event Withdraw(uint256 depositId);
    event Reward(uint256 id, address owner, uint256 amount);

    bytes32 public constant DOMAIN_NAME = keccak256("Pool");
    bytes32 public constant DOMAIN_VERSION = keccak256("1");
    bytes32 public DOMAIN_SEPARATOR;

    bool public inited;
    address public signer;
    IERC20 public max;
    uint256 public min = 100 ether;
    uint256 public total;
    uint256 public depositAcc;
    mapping(uint256 => Record) public deposits;
    mapping(uint256 => bool) public rewardIds;

    function deposit(uint256 amount) external {
        require(inited, "Not Inited");
        require(amount >= min, "Too Small");

        total += amount;
        depositAcc += 1;
        Record storage record = deposits[depositAcc];
        record.user = msg.sender;
        record.amount = amount;

        max.transferFrom(msg.sender, address(this), amount);

        emit Deposit(depositAcc, msg.sender, amount);
    }

    function withdraw(uint256 depositId, Seeds memory seeds) external {
        require(check_withdraw(seeds, depositId), "signature invalid");

        Record storage record = deposits[depositId];
        require(record.amount > 0, "depositId invalid");
        require(record.user == msg.sender, "no permission");
        require(!record.refunded, "already refunded");
        record.refunded = true;
        total -= record.amount;
        max.transfer(msg.sender, record.amount);

        emit Withdraw(depositId);
    }

    function getReward(
        uint256 _rewardId,
        uint256 amount,
        Seeds memory seeds
    ) external {
        require(
            check_getReward(seeds, _rewardId, amount, msg.sender),
            "signature invalid"
        );
        require(!rewardIds[_rewardId], "rewardId Invalid");
        rewardIds[_rewardId] = true;

        max.transfer(msg.sender, amount);
        emit Reward(_rewardId, msg.sender, amount);
    }

    function info() public view returns (uint256, uint256) {
        return (total, max.balanceOf(address(this)));
    }

    function pick(address to, uint256 amount) external onlyOwner {
        max.transfer(to, amount);
    }

    function init() external onlyOwner {
        require(!inited, "Not Inited");
        inited = true;
    }

    function setSigner(address signer_) external onlyOwner {
        signer = signer_;
    }

    function check_withdraw(
        Seeds memory seeds,
        uint256 _depositId
    ) public view returns (bool) {
        uint8 v = uint8(seeds._v);
        bytes32 s = bytes32(seeds._s);
        bytes32 r = bytes32(seeds._r);

        bytes32 hash = keccak256(
            abi.encode(
                keccak256(abi.encodePacked("withdraw(uint256 depositId)")),
                _depositId
            )
        );
        if (getSignatory(hash, v, r, s) == signer) {
            return true;
        } else {
            return false;
        }
    }

    function check_getReward(
        Seeds memory seeds,
        uint256 _rewardId,
        uint256 claimAmount,
        address _owner
    ) public view returns (bool) {
        uint8 v = uint8(seeds._v);
        bytes32 s = bytes32(seeds._s);
        bytes32 r = bytes32(seeds._r);

        bytes32 hash = keccak256(
            abi.encode(
                keccak256(
                    abi.encodePacked(
                        "getReward(uint256 orderId,uint256 claimAmount,address owner)"
                    )
                ),
                _rewardId,
                claimAmount,
                _owner
            )
        );
        if (getSignatory(hash, v, r, s) == signer) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @notice Recover the signatory from a signature
     * @param hash bytes32
     * @param v uint8
     * @param r bytes32
     * @param s bytes32
     */
    function getSignatory(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (address) {
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, hash)
        );
        address signatory = ecrecover(digest, v, r, s);
        // Ensure the signatory is not null
        require(signatory != address(0), "INVALID_SIG");
        return signatory;
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
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "Context.sol";

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
