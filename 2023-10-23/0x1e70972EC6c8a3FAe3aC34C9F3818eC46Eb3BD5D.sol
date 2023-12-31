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
//SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Friend3V1 is Ownable {
    address public protocolFeeDestination;
    uint256 public protocolFeePercent;
    uint256 public subjectFeePercent;

    event Trade(
        address trader,
        address subject,
        bool isBuy,
        uint256 ticketAmount,
        uint256 ethAmount,
        uint256 protocolEthAmount,
        uint256 subjectEthAmount,
        uint256 supply
    );

    mapping(address => mapping(address => uint256)) public ticketsBalance;

    mapping(address => uint256) public ticketsSupply;

    function setFeeDestination(address _feeDestination) public onlyOwner {
        protocolFeeDestination = _feeDestination;
    }

    function setProtocolFeePercent(uint256 _feePercent) public onlyOwner {
        protocolFeePercent = _feePercent;
    }

    function setSubjectFeePercent(uint256 _feePercent) public onlyOwner {
        subjectFeePercent = _feePercent;
    }

    function getPrice(
        uint256 supply,
        uint256 amount
    ) public pure returns (uint256) {
        uint256 sum1 = supply == 0
            ? 0
            : ((supply - 1) * (supply) * (2 * (supply - 1) + 1)) / 6;
        uint256 sum2 = supply == 0 && amount == 1
            ? 0
            : ((supply - 1 + amount) *
                (supply + amount) *
                (2 * (supply - 1 + amount) + 1)) / 6;
        uint256 summation = sum2 - sum1;
        return (summation * 1 ether) / 1600;
    }

    function getBuyPrice(
        address ticketsSubject,
        uint256 amount
    ) public view returns (uint256) {
        return getPrice(ticketsSupply[ticketsSubject], amount);
    }

    function getSellPrice(
        address ticketsSubject,
        uint256 amount
    ) public view returns (uint256) {
        return getPrice(ticketsSupply[ticketsSubject] - amount, amount);
    }

    function getBuyPriceAfterFee(
        address ticketsSubject,
        uint256 amount
    ) public view returns (uint256) {
        uint256 price = getBuyPrice(ticketsSubject, amount);
        uint256 protocolFee = (price * protocolFeePercent) / 1 ether;
        uint256 subjectFee = (price * subjectFeePercent) / 1 ether;
        return price + protocolFee + subjectFee;
    }

    function getSellPriceAfterFee(
        address ticketsSubject,
        uint256 amount
    ) public view returns (uint256) {
        uint256 price = getSellPrice(ticketsSubject, amount);
        uint256 protocolFee = (price * protocolFeePercent) / 1 ether;
        uint256 subjectFee = (price * subjectFeePercent) / 1 ether;
        return price - protocolFee - subjectFee;
    }

    function buyTickets(address ticketsSubject, uint256 amount) public payable {
        uint256 supply = ticketsSupply[ticketsSubject];
        require(
            supply > 0 || ticketsSubject == msg.sender,
            "Only the creator of the ticket can buy the first ticket"
        );
        uint256 price = getPrice(supply, amount);
        uint256 protocolFee = (price * protocolFeePercent) / 1 ether;
        uint256 subjectFee = (price * subjectFeePercent) / 1 ether;
        require(
            msg.value >= price + protocolFee + subjectFee,
            "Insufficient payment"
        );
        ticketsBalance[ticketsSubject][msg.sender] =
            ticketsBalance[ticketsSubject][msg.sender] +
            amount;
        ticketsSupply[ticketsSubject] = supply + amount;
        emit Trade(
            msg.sender,
            ticketsSubject,
            true,
            amount,
            price,
            protocolFee,
            subjectFee,
            supply + amount
        );
        (bool success1, ) = protocolFeeDestination.call{value: protocolFee}("");
        (bool success2, ) = ticketsSubject.call{value: subjectFee}("");
        require(success1 && success2, "Unable to send funds");
    }

    function sellTickets(
        address ticketsSubject,
        uint256 amount
    ) public payable {
        uint256 supply = ticketsSupply[ticketsSubject];
        require(supply > amount, "Cannot sell the last ticket");
        uint256 price = getPrice(supply - amount, amount);
        uint256 protocolFee = (price * protocolFeePercent) / 1 ether;
        uint256 subjectFee = (price * subjectFeePercent) / 1 ether;
        require(
            ticketsBalance[ticketsSubject][msg.sender] >= amount,
            "Insufficient tickets"
        );
        ticketsBalance[ticketsSubject][msg.sender] =
            ticketsBalance[ticketsSubject][msg.sender] -
            amount;
        ticketsSupply[ticketsSubject] = supply - amount;
        emit Trade(
            msg.sender,
            ticketsSubject,
            false,
            amount,
            price,
            protocolFee,
            subjectFee,
            supply - amount
        );
        (bool success1, ) = msg.sender.call{
            value: price - protocolFee - subjectFee
        }("");
        (bool success2, ) = protocolFeeDestination.call{value: protocolFee}("");
        (bool success3, ) = ticketsSubject.call{value: subjectFee}("");
        require(success1 && success2 && success3, "Unable to send funds");
    }
}
