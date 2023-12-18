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
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract Mar3KeyV1 is Ownable, Pausable {
    address public protocolFeeDestination;
    uint256 public protocolFeePercent;
    uint256 public creatorFeePercent;
    uint256 private referralFeePercent;
    address private admin;
    mapping(uint256 => Order) private _orders;

    struct Order {
        address userAddress;
        uint256 amount;
    }

    event BuyKey(
        uint256 indexed orderId,
        uint256 keyPrice,
        address creator,
        address referral
    );

    event SellKey(
        uint256 indexed orderId,
        uint256 keyPrice,
        address creator,
        address referral
    );

    constructor(address _protocolFeeDestination, uint256 _protocolFeePercent) {
        protocolFeeDestination = _protocolFeeDestination;
        protocolFeePercent = _protocolFeePercent;
    }

    function setFeeDestination(address _feeDestination) public onlyOwner {
        protocolFeeDestination = _feeDestination;
    }

    function setProtocolFeePercent(uint256 _feePercent) public onlyOwner {
        protocolFeePercent = _feePercent;
    }

    function setCreatorFeePercent(uint256 _feePercent) public onlyOwner {
        creatorFeePercent = _feePercent;
    }

    function setReferralFeePercent(uint256 _feePercent) public onlyOwner {
        referralFeePercent = _feePercent;
    }

    function setAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }

    function buyKey(
        uint256 orderId,
        address sender,
        uint256 totalKeyPrice,
        address creator,
        address referral,
        uint256 expiredAt,
        bytes memory signature
    ) external payable whenNotPaused {
        require(expiredAt > block.timestamp, "Order expired");
        require(totalKeyPrice > 0, "Amount must be more than zero");
        require(orderId > 0, "Invalid orderId");
        require(
            _orders[orderId].userAddress == address(0),
            "Cannot use this order"
        );
        require(
            !isContract(sender) &&
                !isContract(creator) &&
                !isContract(referral),
            "Not EOA"
        );

        bytes32 messageHash = getMessageHash(
            orderId,
            sender,
            totalKeyPrice,
            creator,
            referral,
            expiredAt
        );
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        require(
            recoverSigner(ethSignedMessageHash, signature) == admin,
            "Signature is wrong"
        );
        require(
            msg.value >=
                (totalKeyPrice *
                    (10000 +
                        protocolFeePercent +
                        creatorFeePercent +
                        referralFeePercent)) /
                    10000,
            "Insufficient balance"
        );

        _orders[orderId] = Order(_msgSender(), totalKeyPrice);

        (bool success1, ) = protocolFeeDestination.call{
            value: (totalKeyPrice * protocolFeePercent) / 10000
        }("");
        require(success1, "Unable to send protocol fee");

        (bool success2, ) = creator.call{
            value: (totalKeyPrice * creatorFeePercent) / 10000
        }("");
        require(success2, "Unable to send creator fee");

        if (referral == address(0)) {
            (bool success3, ) = protocolFeeDestination.call{
                value: (totalKeyPrice * referralFeePercent) / 10000
            }("");
            require(success3, "Unable to send referral fee to protocol");
        } else {
            (bool success3, ) = referral.call{
                value: (totalKeyPrice * referralFeePercent) / 10000
            }("");
            require(success3, "Unable to send referral fee");
        }

        emit BuyKey(orderId, totalKeyPrice, creator, referral);
    }

    function sellKey(
        uint256 orderId,
        address sender,
        uint256 totalKeyPrice,
        address creator,
        address referral,
        uint256 expiredAt,
        bytes memory signature
    ) external whenNotPaused {
        require(expiredAt > block.timestamp, "Order expired");
        require(totalKeyPrice > 0, "Amount must be more than zero");
        require(orderId > 0, "Invalid orderId");
        require(
            _orders[orderId].userAddress == address(0),
            "Cannot use this order"
        );
        require(
            !isContract(sender) &&
                !isContract(creator) &&
                !isContract(referral),
            "Not EOA"
        );

        bytes32 messageHash = getMessageHash(
            orderId,
            sender,
            totalKeyPrice,
            creator,
            referral,
            expiredAt
        );
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        require(
            recoverSigner(ethSignedMessageHash, signature) == admin,
            "Signature is wrong"
        );
        require(address(this).balance >= totalKeyPrice, "Insufficient balance");

        _orders[orderId] = Order(_msgSender(), totalKeyPrice);

        (bool success1, ) = sender.call{
            value: (totalKeyPrice *
                (10000 -
                    protocolFeePercent -
                    creatorFeePercent -
                    referralFeePercent)) / 10000
        }("");
        require(success1, "Unable to send funds to seller");
        (bool success2, ) = protocolFeeDestination.call{
            value: (totalKeyPrice * protocolFeePercent) / 10000
        }("");
        require(success2, "Unable to send protocol fee");
        (bool success3, ) = creator.call{
            value: (totalKeyPrice * creatorFeePercent) / 10000
        }("");
        require(success3, "Unable to send creator fee");
        if (referral == address(0)) {
            (bool success4, ) = protocolFeeDestination.call{
                value: (totalKeyPrice * referralFeePercent) / 10000
            }("");
            require(success4, "Unable to send referral fee to protocol");
        } else {
            (bool success4, ) = referral.call{
                value: (totalKeyPrice * referralFeePercent) / 10000
            }("");
            require(success4, "Unable to send referral fee");
        }

        emit SellKey(orderId, totalKeyPrice, creator, referral);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function isContract(address _addr) internal view returns (bool) {
        return _addr.code.length > 0;
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature
    ) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function getMessageHash(
        uint256 _orderId,
        address _sender,
        uint256 _keyPrice,
        address _creator,
        address _referral,
        uint256 _expiredAt
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    _orderId,
                    _sender,
                    _keyPrice,
                    _creator,
                    _referral,
                    _expiredAt
                )
            );
    }

    function getEthSignedMessageHash(
        bytes32 _messageHash
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    _messageHash
                )
            );
    }

    function splitSignature(
        bytes memory sig
    ) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }
}
