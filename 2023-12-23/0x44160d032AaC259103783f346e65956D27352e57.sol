// SPDX-License-Identifier: MIT

/*
----------------------------------------------------------------------------
Supeer Router | Ethereum, Avalanche, Polygon, BNB
----------------------------------------------------------------------------
Version: 1.0.0
Author: 0xYonga | https://twitter.com/0xYonga | cto@supeer.tech
Note: If you initiate transactions within the contract directly, you may lose your assets. Please use supeer.tech itself for any actions.
----------------------------------------------------------------------------
*/

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: Supeer/SupeerRouter.sol


pragma solidity ^0.8.18;



contract SupeerRouter is ReentrancyGuard {
    /*
    ----------------------------------------------------------------------------
    Supeer Router | Ethereum, Avalanche, Polygon, BNB
    ----------------------------------------------------------------------------
    Version: 1.0.0
    Author: 0xYonga | https://twitter.com/0xYonga | cto@supeer.tech
    Note: If you initiate transactions within the contract directly, you may lose your assets. Please use supeer.tech itself for any actions.
    ----------------------------------------------------------------------------
    */

    using SafeMath for uint256;

    enum ProcessTypes {
        ticketMint,
        ticketMarket,
        gift,
        peerSale,
        exclusivePeerSale,
        adSpace
    }

    struct Percents {
        uint256 sellerPercent;
        uint256 originalOwnerPercent;
        uint256 teamPercent;
        uint256 airdropPercent;
        uint256 referralPercent;
    }

    mapping(ProcessTypes => Percents) public percents;

    address public teamAddress;
    address public airdropAddress;
    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function.");
        _;
    }

    event SentCoin(
        address indexed from,
        address indexed to,
        uint256 amount,
        ProcessTypes processType
    );

    constructor(
        address _teamAddress,
        address _airdropAddress,
        address _admin
    ) {
        teamAddress = _teamAddress;
        airdropAddress = _airdropAddress;
        admin = _admin;

        percents[ProcessTypes.ticketMint] = Percents(90, 0, 7, 2, 1);
        percents[ProcessTypes.ticketMarket] = Percents(90, 5, 4, 0, 1);
        percents[ProcessTypes.gift] = Percents(90, 0, 7, 2, 1);
        percents[ProcessTypes.peerSale] = Percents(60, 0, 40, 0, 0);
        percents[ProcessTypes.exclusivePeerSale] = Percents(90, 0, 10, 0, 0);
        percents[ProcessTypes.adSpace] = Percents(60, 0, 40, 0, 0);
    }

    function sendCoin(
        address payable _recipient,
        address payable _originalOwner,
        address payable _referral,
        ProcessTypes _processType
    ) external payable nonReentrant {
        require(
            _recipient != address(0),
            "You cannot use a zero address for recipient."
        );

        if (_processType == ProcessTypes.ticketMarket) {
            require(
                _originalOwner != address(0),
                "You cannot use a zero address for originalOwner."
            );
        }

        uint256 amount = msg.value;
        Percents memory processPercent = percents[_processType];

        uint256 sellerAmount = amount.mul(processPercent.sellerPercent).div(
            100
        );
        uint256 teamAmount = amount.mul(processPercent.teamPercent).div(100);
        uint256 originalOwnerAmount = amount
            .mul(processPercent.originalOwnerPercent)
            .div(100);
        uint256 airdropAmount = amount.mul(processPercent.airdropPercent).div(
            100
        );
        uint256 referralAmount = amount.mul(processPercent.referralPercent).div(
            100
        );

        // If referral is zero address, add referralAmount to teamAmount
        if (_referral == address(0)) {
            teamAmount = teamAmount.add(referralAmount);
            referralAmount = 0;
        }

        (bool recipientSent, ) = _recipient.call{value: sellerAmount}("");
        require(recipientSent, "Failed to send to recipient.");

        (bool teamSent, ) = teamAddress.call{value: teamAmount}("");
        require(teamSent, "Failed to send to team.");

        if (originalOwnerAmount > 0) {
            (bool originalOwnerSent, ) = _originalOwner.call{
                value: originalOwnerAmount
            }("");
            require(originalOwnerSent, "Failed to send to original owner.");
        }

        if (airdropAmount > 0) {
            (bool airdropSent, ) = airdropAddress.call{value: airdropAmount}(
                ""
            );
            require(airdropSent, "Failed to sent to airdrop.");
        }

        if (referralAmount > 0) {
            (bool referralSent, ) = _referral.call{value: referralAmount}("");
            require(referralSent, "Failed to sent to referral.");
        }

        emit SentCoin(msg.sender, _recipient, amount, _processType);
    }

    function setTeamAddress(address _newTeamAddress) external onlyAdmin {
        teamAddress = _newTeamAddress;
    }

    function setAirdropAddress(address _newAirdropAddress) external onlyAdmin {
        airdropAddress = _newAirdropAddress;
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "New admin cannot be zero address.");
        admin = newAdmin;
    }

    receive() external payable {
        // Refund the Ether back to the sender
        payable(msg.sender).transfer(msg.value);
    }
}