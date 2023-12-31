// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

import './bets/custom/CustomProcessor.sol';
import './bets/jackpot/JackpotProcessor.sol';
import './event/EventProcessor.sol';
import './security/Security.sol';

contract ProxyP2P is CustomProcessor, JackpotProcessor, EventProcessor {

    constructor(address[] memory owners) {
        for (uint i = 0; i < owners.length; i++) {
            addOwner(owners[i]);
        }
    }

    function closeCustomBet(uint betId, string calldata finalValue, bool targetSideWon) external onlyController {
        ProxyCustomDTOs.CustomBet memory customBet = getCustomBet(betId);

        EventDTOs.EventResult memory eventData = getChainlinkResult(customBet.expirationTime, customBet.eventId);

        closeCustomBet(betId, finalValue, targetSideWon, eventData, customBet);
    }

    function createJackpotBet(ProxyJackpotDTOs.CreateJackpotRequest calldata createRequest) external onlyController returns (uint) {
        require(eventMapping[createRequest.eventId].alive, "ProxyP2P.createJackpotBet: eventId not present");

        return callCreateJackpotBet(createRequest);
    }

    function closeJackpotBet(uint betId) external onlyController {
        (ProxyJackpotDTOs.JackpotBet memory jackpotBet,) = getJackpotBet(betId);

        EventDTOs.EventResult memory eventData = getChainlinkResult(jackpotBet.expirationTime, jackpotBet.eventId);

        closeJackpotBet(betId, eventData);
    }
}// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

import './api/CustomApi.sol';
import '../../security/Security.sol';
import '../../event/EventDTOs.sol';
import '../../utils/StringConverter.sol';

contract CustomProcessor is Security {
    SecurityDTOs.SetCustomAdapter public setCustomAdapter;
    CustomApi public customBetAdapter;

    event CustomAdapterSet(address customBetAdapter);

    event ProxyCustomResultChanged (
        bool targetSideWon,
        string finalValue,
        address oracleAddress,
        uint oracleRoundId
    );

    function startSetCustomAdapter(address customBetAddress) external onlyOwner() {
        uint votingCode = startVoting("SET_CUSTOM_ADAPTER");
        setCustomAdapter = SecurityDTOs.SetCustomAdapter(
            customBetAddress,
            block.timestamp,
            votingCode
        );
    }

    function acquireSetCustomAdapter() external onlyOwner {
        pass(setCustomAdapter.votingCode);
        customBetAdapter = CustomApi(setCustomAdapter.customAdapter);
        emit CustomAdapterSet(setCustomAdapter.customAdapter);
    }

    function getCustomBet(uint betId) internal view returns (ProxyCustomDTOs.CustomBet memory) {
        (ProxyCustomDTOs.CustomBet memory customBet,,,,) = customBetAdapter.getCustomBet(betId);
        return customBet;
    }

    function closeCustomBet(
        uint betId,
        string calldata finalValue,
        bool targetSideWon,
        EventDTOs.EventResult memory eventData,
        ProxyCustomDTOs.CustomBet memory customBet) internal {
        if (!eventData.isEventPresent) {
            customBetAdapter.closeCustomBet(betId, finalValue, targetSideWon);
            return;
        }

        uint targetValue = StringConverter.convertToUint(customBet.targetValue, eventData.decimals);

        bool chainlinkTargetSideWon = (targetValue < eventData.result) == customBet.targetSide;

        string memory chainlinkFinalValue = StringConverter.convertToString(eventData.result, eventData.resultScale, eventData.decimals);

        emit ProxyCustomResultChanged(chainlinkTargetSideWon, chainlinkFinalValue, eventData.oracleAddress, eventData.roundId);

        customBetAdapter.closeCustomBet(betId, chainlinkFinalValue, chainlinkTargetSideWon);
    }
}// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

import './api/JackpotApi.sol';
import '../../security/Security.sol';
import '../../event/EventDTOs.sol';
import '../../utils/StringConverter.sol';

contract JackpotProcessor is Security {
    SecurityDTOs.SetJackpotAdapter public setJackpotAdapter;
    JackpotApi public jackpotBetAdapter;

    event JackpotAdapterSet(address jackpotBetAdapter);

    event ProxyJackpotResult (
        string finalValue,
        address oracleAddress,
        uint oracleRoundId
    );

    function startSetJackpotAdapter(address jackpotBetAddress) external onlyOwner() {
        uint votingCode = startVoting("SET_JACKPOT_ADAPTER");
        setJackpotAdapter = SecurityDTOs.SetJackpotAdapter(
            jackpotBetAddress,
            block.timestamp,
            votingCode
        );
    }

    function acquireSetJackpotAdapter() external onlyOwner {
        pass(setJackpotAdapter.votingCode);
        jackpotBetAdapter = JackpotApi(setJackpotAdapter.jackpotAdapter);
        emit JackpotAdapterSet(setJackpotAdapter.jackpotAdapter);
    }

    function getJackpotBet(uint betId) public view returns (ProxyJackpotDTOs.JackpotBet memory, uint) {
        return jackpotBetAdapter.getJackpotBet(betId);
    }

    function callCreateJackpotBet(ProxyJackpotDTOs.CreateJackpotRequest calldata createRequest) internal returns (uint) {
        return jackpotBetAdapter.createJackpotBet(createRequest);
    }

    function closeJackpotBet(uint betId, EventDTOs.EventResult memory eventData) internal {
        require(eventData.isEventPresent, "JackpotProcessor.closeJackpotBet: oracle result not present");

        string memory finalValue = StringConverter.convertToString(eventData.result, eventData.resultScale, eventData.decimals);

        emit ProxyJackpotResult(finalValue, eventData.oracleAddress, eventData.roundId);

        jackpotBetAdapter.closeJackpotBet(betId, finalValue);
    }
}// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

import './EventController.sol';
import './chainlink/AggregatorInterface.sol';

contract EventProcessor is EventController {

    // returns (uint result, uint decimals, bool isEventPresent)
    function getChainlinkResult(uint expirationTime, string memory eventId) internal view returns (EventDTOs.EventResult memory) {
        if (!eventMapping[eventId].alive) {
            return EventDTOs.EventResult(0, 0, false, 0, address(0), 0);
        }

        return findClosestResult(expirationTime, eventId);
    }

    function getResult(uint expirationTime, string memory eventId) external view returns (bool, uint, uint) {
        EventDTOs.EventResult memory result = findClosestResult(expirationTime, eventId);
        return (result.isEventPresent, result.result, result.decimals);
    }

    function findClosestResult(uint expirationTime, string memory eventId) private view returns (EventDTOs.EventResult memory) {
        AggregatorInterface aggregator = AggregatorInterface(eventMapping[eventId].chainlinkAggregatorProxy);

        uint lastRoundId = aggregator.latestRound();
        require(aggregator.getTimestamp(lastRoundId) > expirationTime, "EventProcessor.findClosestResult: result not present");

        while (aggregator.getTimestamp(lastRoundId) > expirationTime) {
            lastRoundId--;
        }

        uint answer = uint(aggregator.getAnswer(lastRoundId + 1));
        uint8 decimal = aggregator.decimals();

        return EventDTOs.EventResult(answer, decimal, true, eventMapping[eventId].resultScale, eventMapping[eventId].chainlinkAggregatorProxy, lastRoundId + 1);

    }
}// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

import "./Voting.sol";

abstract contract Security is Voting {
    SecurityDTOs.AddOwner public addOwnerVoting;
    SecurityDTOs.AddController public addControllerVoting;
    SecurityDTOs.RemoveOwner public removeOwnerVoting;
    SecurityDTOs.RemoveController public removeControllerVoting;


    // Start voting for add owner
    function ownerAddStart(address newOwner) external onlyOwner {
        require(!owners[newOwner], "Security.ownerAddStart: already owner");

        uint votingCode = startVoting("ADD_OWNER");
        addOwnerVoting = SecurityDTOs.AddOwner(
            newOwner,
            block.timestamp,
            votingCode
        );
    }

    function acquireNewOwner() external onlyOwner {
        pass(addOwnerVoting.votingCode);
        addOwner(addOwnerVoting.newOwner);
    }

    function controllerAddStart(address newController) public virtual onlyOwner {
        require(!controllers[newController], "Security.controllerAddStart: already controller");
        require(newController != address(0), "Security.controllerAddStart: new controller is the zero address");

        uint votingCode = startVoting("TRANSFER_COMPANY");
        addControllerVoting = SecurityDTOs.AddController(
            newController,
            block.timestamp,
            votingCode
        );
    }

    function acquireAddController() external onlyOwner {
        pass(addControllerVoting.votingCode);
        addController(addControllerVoting.newController);
    }

    function controllerToRemoveStart(address controllerToRemove) external onlyOwner {
        require(controllers[controllerToRemove], "Security: is not controller");

        uint votingCode = startVoting("REMOVE_CONTROLLER");
        removeControllerVoting = SecurityDTOs.RemoveController(
            controllerToRemove,
            block.timestamp,
            votingCode
        );
    }

    function acquireRemoveController() external onlyOwner {
        pass(removeControllerVoting.votingCode);
        removeController(removeControllerVoting.controllerToRemove);
    }

    // Start voting removing owner
    function ownerToRemoveStart(address ownerToRemove) external onlyOwner {
        require(owners[ownerToRemove], "Security: is not owner");

        uint votingCode = startVoting("REMOVE_OWNER");
        removeOwnerVoting = SecurityDTOs.RemoveOwner(
            ownerToRemove,
            block.timestamp,
            votingCode
        );
    }

    function acquireOwnerToRemove() external onlyOwner {
        pass(removeOwnerVoting.votingCode);
        removeOwner(removeOwnerVoting.ownerToRemove);
    }
}pragma solidity 0.8.2;

import './ProxyCustomDTOs.sol';

interface CustomApi {
    function closeCustomBet(uint betId, string calldata finalValue, bool targetSideWon) external;

    function getCustomBet(uint betId) external view returns (ProxyCustomDTOs.CustomBet memory, uint, uint, uint, uint);
}// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;


library EventDTOs {
    struct Event {
        string eventId;
        address chainlinkAggregatorProxy;
        uint8 resultScale;
        bool alive;
    }

    struct EventResult {
        uint result;
        uint8 decimals;
        bool isEventPresent;
        uint8 resultScale;
        address oracleAddress;
        uint roundId;
    }
}// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

import './strings.sol';

library StringConverter {
    using strings for *;

    function convertToString(uint value, uint8 resultScale, uint8 decimals) internal pure returns (string memory) {
        string memory integerPart = uintToString(value / (10 ** decimals));
        string memory fractionalPart = uintToString((value % (10 ** decimals)) / (10 ** (decimals - resultScale)));

        strings.slice memory fractionalSlicePart = addZeros(fractionalPart, resultScale);

        return integerPart.toSlice().concat(".".toSlice()).toSlice().concat(fractionalSlicePart);
    }

    function addZeros(string memory fractionalPart, uint8 resultScale) private pure returns (strings.slice memory) {
        strings.slice memory fractionalSlicePart = fractionalPart.toSlice();

        if (fractionalSlicePart._len == resultScale) {
            return fractionalSlicePart;
        }

        while (fractionalSlicePart._len != resultScale) {
            fractionalSlicePart = "0".toSlice().concat(fractionalSlicePart).toSlice();
        }

        return fractionalSlicePart;
    }

    function convertToUint(string memory value, uint8 decimals) internal pure returns (uint) {
        strings.slice memory slicedValue = value.toSlice();
        strings.slice memory delimiter = ".".toSlice();

        strings.slice[] memory parts = new strings.slice[](slicedValue.count(delimiter) + 1);

        require(parts.length == 2, "StringConverter.convertToUint: wrong value");

        parts[0] = slicedValue.split(delimiter);
        parts[1] = slicedValue;

        uint integerPart = st2num(parts[0].toString());
        uint fractionalPart = st2num(parts[1].toString());

        return integerPart * (10 ** decimals) + fractionalPart * (10 ** (decimals - parts[1]._len));
    }

    function st2num(string memory numString) private pure returns (uint) {
        uint val = 0;
        bytes   memory stringBytes = bytes(numString);
        for (uint i = 0; i < stringBytes.length; i++) {
            uint exp = stringBytes.length - i;
            bytes1 ival = stringBytes[i];
            uint8 uval = uint8(ival);
            uint jval = uval - uint(0x30);

            val += (uint(jval) * (10 ** (exp - 1)));
        }
        return val;
    }

    function uintToString(uint value) private pure returns (string memory) {
        bytes16 _SYMBOLS = "0123456789abcdef";
    unchecked {
        uint256 length = log10(value) + 1;
        string memory buffer = new string(length);
        uint256 ptr;
        /// @solidity memory-safe-assembly
        assembly {
            ptr := add(buffer, add(32, length))
        }
        while (true) {
            ptr--;
            /// @solidity memory-safe-assembly
            assembly {
                mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
            }
            value /= 10;
            if (value == 0) break;
        }
        return buffer;
    }
    }

    function log10(uint256 value) private pure returns (uint256) {
        uint256 result = 0;
    unchecked {
        if (value >= 10 ** 64) {
            value /= 10 ** 64;
            result += 64;
        }
        if (value >= 10 ** 32) {
            value /= 10 ** 32;
            result += 32;
        }
        if (value >= 10 ** 16) {
            value /= 10 ** 16;
            result += 16;
        }
        if (value >= 10 ** 8) {
            value /= 10 ** 8;
            result += 8;
        }
        if (value >= 10 ** 4) {
            value /= 10 ** 4;
            result += 4;
        }
        if (value >= 10 ** 2) {
            value /= 10 ** 2;
            result += 2;
        }
        if (value >= 10 ** 1) {
            result += 1;
        }
    }
        return result;
    }
}// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;


library ProxyCustomDTOs {
    struct CustomBet {
        uint id;
        string eventId;
        bool hidden;
        uint lockTime;
        uint expirationTime;
        string targetValue;
        bool targetSide;
        uint coefficient;

        string finalValue;
        bool targetSideWon;
    }
}// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

import "./Ownable.sol";

abstract contract Voting is Ownable {
    event VotingStarted(string code, uint votingNumber, address indexed initiator);
    event VotingResult(string code, uint votingNumber, bool passed);

    bool public votingActive;
    SecurityDTOs.VotingInfo public votingInfo;
    uint private votingNumber;
    mapping(uint => mapping(address => bool)) public voted;


    function startVoting(string memory votingCode) internal returns (uint) {
        require(!votingActive, "Voting: there is active voting already");
        require(totalOwners >= 3, "Voting: not enough owners for starting new vote");
        votingInfo = SecurityDTOs.VotingInfo(
            _msgSender(),
            0,
            0,
            block.timestamp,
            votingCode
        );
        votingActive = true;
        votingNumber++;

        votePositive();
        emit VotingStarted(
            votingCode,
            votingNumber,
            _msgSender()
        );

        return votingNumber;
    }

    // End voting with success
    function pass(uint toCheckVotingNumber) internal {
        require(votingActive, "Voting: there is no active voting");
        require(toCheckVotingNumber == votingNumber, "Voting: old voting found");
        require(votingInfo.currentNumberOfVotesPositive > totalOwners / 2, "Voting: not enough positive votes");
        require(votingInfo.startedDate + 60 * 60 * 72 < block.timestamp || votingInfo.currentNumberOfVotesPositive == totalOwners, "Voting: 72 hours have not yet passed");

        votingActive = false;
        emit VotingResult(
            votingInfo.votingCode,
            votingNumber,
            true
        );
    }


    // Close voting
    function close() external onlyOwner {
        require(votingActive, "Voting: there is no active voting");
        require(votingInfo.startedDate + 144 * 60 * 60 < block.timestamp || votingInfo.currentNumberOfVotesNegative > totalOwners / 2, "Voting: condition close error");
        votingActive = false;
        emit VotingResult(
            votingInfo.votingCode,
            votingNumber,
            false
        );
    }

    function votePositive() public onlyOwner {
        vote();
        votingInfo.currentNumberOfVotesPositive++;
    }

    function voteNegative() external onlyOwner {
        vote();
        votingInfo.currentNumberOfVotesNegative++;
    }

    function vote() private {
        require(votingActive, "Voting: there is no active voting");
        require(!voted[votingNumber][_msgSender()], "Voting: already voted");
        voted[votingNumber][_msgSender()] = true;
    }
}// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

import "./SecurityDTOs.sol";
import "../utils/Context.sol";

abstract contract Ownable is Context {
    mapping(address => bool) public owners;
    mapping(address => bool) public controllers;
    address private _company;
    uint public totalOwners;
    uint public totalControllers;

    event AddOwner(address indexed newOwner);
    event RemoveOwner(address indexed ownerToRemove);

    event AddController(address indexed newController);
    event RemoveController(address indexed controllerToRemove);

    modifier onlyOwner() {
        require(owners[_msgSender()], "Security: caller is not the owner");
        _;
    }

    modifier onlyController() {
        require(controllers[_msgSender()], "Security: caller is not the controller");
        _;
    }

    function removeController(address controllerToRemove) internal {
        require(controllers[controllerToRemove], "Security.removeController: not controller");

        controllers[controllerToRemove] = false;
        totalControllers--;
        emit RemoveController(controllerToRemove);
    }

    function addController(address newController) internal {
        require(newController != address(0), "Security.addController: new controller is the zero address");
        require(!controllers[newController], "Security.addController: already controller");

        controllers[newController] = true;
        totalControllers++;
        emit AddController(newController);
    }

    function removeOwner(address ownerToRemove) internal {
        require(owners[ownerToRemove], "Security.removeOwner: not owner");

        owners[ownerToRemove] = false;
        totalOwners--;
        emit RemoveOwner(ownerToRemove);
    }

    function addOwner(address newOwner) internal {
        require(newOwner != address(0), "Security.addOwner: new owner is the zero address");
        require(!owners[newOwner], "Security.addOwner: already owner");

        owners[newOwner] = true;
        totalOwners++;
        emit AddOwner(newOwner);
    }
}// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

library SecurityDTOs {
    struct AddEvent {
        string eventId;
        address chainlinkAggregatorProxy;
        uint8 resultScale;
        uint createdDate;
        uint votingCode;
    }

    struct RemoveEvent {
        string eventId;
        uint createdDate;
        uint votingCode;
    }

    struct SetJackpotAdapter {
        address jackpotAdapter;
        uint createdDate;
        uint votingCode;
    }

    struct SetCustomAdapter {
        address customAdapter;
        uint createdDate;
        uint votingCode;
    }

    struct AddOwner {
        address newOwner;
        uint createdDate;
        uint votingCode;
    }

    struct RemoveOwner {
        address ownerToRemove;
        uint createdDate;
        uint votingCode;
    }

    struct AddController {
        address newController;
        uint createdDate;
        uint votingCode;
    }

    struct RemoveController {
        address controllerToRemove;
        uint createdDate;
        uint votingCode;
    }

    struct VotingInfo {
        address initiator;
        uint currentNumberOfVotesPositive;
        uint currentNumberOfVotesNegative;
        uint startedDate;
        string votingCode;
    }
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

/*
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
}// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

library strings {
    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private pure {
        // Copy word-length chunks while possible
        for (; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = type(uint).max;
        if (len > 0) {
            mask = 256 ** (32 - len) - 1;
        }
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    /*
     * @dev Returns a slice containing the entire string.
     * @param self The string to make a slice from.
     * @return A newly allocated slice containing the entire string.
     */
    function toSlice(string memory self) internal pure returns (slice memory) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    /*
     * @dev Returns the length of a null-terminated bytes32 string.
     * @param self The value to find the length of.
     * @return The length of the string, from 0 to 32.
     */
    function len(bytes32 self) internal pure returns (uint) {
        uint ret;
        if (self == 0)
            return 0;
        if (uint(self) & type(uint128).max == 0) {
            ret += 16;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);
        }
        if (uint(self) & type(uint64).max == 0) {
            ret += 8;
            self = bytes32(uint(self) / 0x10000000000000000);
        }
        if (uint(self) & type(uint32).max == 0) {
            ret += 4;
            self = bytes32(uint(self) / 0x100000000);
        }
        if (uint(self) & type(uint16).max == 0) {
            ret += 2;
            self = bytes32(uint(self) / 0x10000);
        }
        if (uint(self) & type(uint8).max == 0) {
            ret += 1;
        }
        return 32 - ret;
    }


    /*
     * @dev Returns a new slice containing the same data as the current slice.
     * @param self The slice to copy.
     * @return A new slice containing the same data as `self`.
     */
    function copy(slice memory self) internal pure returns (slice memory) {
        return slice(self._len, self._ptr);
    }

    /*
     * @dev Copies a slice to a new string.
     * @param self The slice to copy.
     * @return A newly allocated string containing the slice's text.
     */
    function toString(slice memory self) internal pure returns (string memory) {
        string memory ret = new string(self._len);
        uint retptr;
        assembly {retptr := add(ret, 32)}

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    /*
     * @dev Returns the length in runes of the slice. Note that this operation
     *      takes time proportional to the length of the slice; avoid using it
     *      in loops, and call `slice.empty()` if you only need to know whether
     *      the slice is empty or not.
     * @param self The slice to operate on.
     * @return The length of the slice in runes.
     */
    function len(slice memory self) internal pure returns (uint l) {
        // Starting at ptr-31 means the LSB will be the byte we care about
        uint ptr = self._ptr - 31;
        uint end = ptr + self._len;
        for (l = 0; ptr < end; l++) {
            uint8 b;
            assembly {b := and(mload(ptr), 0xFF)}
            if (b < 0x80) {
                ptr += 1;
            } else if (b < 0xE0) {
                ptr += 2;
            } else if (b < 0xF0) {
                ptr += 3;
            } else if (b < 0xF8) {
                ptr += 4;
            } else if (b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
    }

    /*
     * @dev Extracts the first rune in the slice into `rune`, advancing the
     *      slice to point to the next rune and returning `self`.
     * @param self The slice to operate on.
     * @param rune The slice that will contain the first rune.
     * @return `rune`.
     */
    function nextRune(slice memory self, slice memory rune) internal pure returns (slice memory) {
        rune._ptr = self._ptr;

        if (self._len == 0) {
            rune._len = 0;
            return rune;
        }

        uint l;
        uint b;
        // Load the first byte of the rune into the LSBs of b
        assembly {b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF)}
        if (b < 0x80) {
            l = 1;
        } else if (b < 0xE0) {
            l = 2;
        } else if (b < 0xF0) {
            l = 3;
        } else {
            l = 4;
        }

        // Check for truncated codepoints
        if (l > self._len) {
            rune._len = self._len;
            self._ptr += self._len;
            self._len = 0;
            return rune;
        }

        self._ptr += l;
        self._len -= l;
        rune._len = l;
        return rune;
    }

    /*
     * @dev Returns the first rune in the slice, advancing the slice to point
     *      to the next rune.
     * @param self The slice to operate on.
     * @return A slice containing only the first rune from `self`.
     */
    function nextRune(slice memory self) internal pure returns (slice memory ret) {
        nextRune(self, ret);
    }

    // Returns the memory address of the first byte of the first occurrence of
    // `needle` in `self`, or the first byte after `self` if not found.
    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr = selfptr;
        uint idx;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask;
                if (needlelen > 0) {
                    mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));
                }

                bytes32 needledata;
                assembly {needledata := and(mload(needleptr), mask)}

                uint end = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly {ptrdata := and(mload(ptr), mask)}

                while (ptrdata != needledata) {
                    if (ptr >= end)
                        return selfptr + selflen;
                    ptr++;
                    assembly {ptrdata := and(mload(ptr), mask)}
                }
                return ptr;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly {hash := keccak256(needleptr, needlelen)}

                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly {testHash := keccak256(ptr, needlelen)}
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and `token` to everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function split(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and returning everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` up to the first occurrence of `delim`.
     */
    function split(slice memory self, slice memory needle) internal pure returns (slice memory token) {
        split(self, needle, token);
    }

    /*
     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return The number of occurrences of `needle` found in `self`.
     */
    function count(slice memory self, slice memory needle) internal pure returns (uint cnt) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            cnt++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }

    /*
     * @dev Returns a newly allocated string containing the concatenation of
     *      `self` and `other`.
     * @param self The first slice to concatenate.
     * @param other The second slice to concatenate.
     * @return The concatenation of the two strings.
     */
    function concat(slice memory self, slice memory other) internal pure returns (string memory) {
        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly {retptr := add(ret, 32)}
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }
}pragma solidity 0.8.2;

import './ProxyJackpotDTOs.sol';

interface JackpotApi {
    function createJackpotBet(ProxyJackpotDTOs.CreateJackpotRequest calldata createRequest) external returns (uint);

    function closeJackpotBet(uint betId, string calldata finalValue) external;

    function getJackpotBet(uint betId) external view returns (ProxyJackpotDTOs.JackpotBet memory, uint);
}// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;


library ProxyJackpotDTOs {
    struct CreateJackpotRequest {
        string eventId;
        uint lockTime;
        uint expirationTime;
        uint requestAmount;
    }


    struct JackpotBet {
        uint id;
        string eventId;
        uint requestAmount;
        uint lockTime;
        uint expirationTime;
        uint startBank;

        uint finalBank;
        string finalJackpotValue;
    }
}
// SPDX-License-Identifier: MIT

// solhint-disable-next-line
pragma solidity 0.8.2;

import '../security/Security.sol';
import './EventDTOs.sol';

contract EventController is Security {
    SecurityDTOs.AddEvent public addEvent;
    SecurityDTOs.RemoveEvent public removeEvent;

    mapping(string => EventDTOs.Event) public eventMapping;

    event AddEventMapping(string eventId, address chainlinkAggregatorProxy, uint8 resultScale);
    event RemoveMapping(string eventId);

    function startAddEvent(string calldata eventId, address chainlinkAggregatorProxy, uint8 resultScale) external onlyOwner() {
        require(eventMapping[eventId].alive == false, "RemoveEvent: already alive");

        uint votingCode = startVoting("ADD_EVENT");
        addEvent = SecurityDTOs.AddEvent(
            eventId,
            chainlinkAggregatorProxy,
            resultScale,
            block.timestamp,
            votingCode
        );
    }

    function acquireAddEvent() external onlyOwner {
        pass(addEvent.votingCode);
        eventMapping[addEvent.eventId] = EventDTOs.Event(addEvent.eventId, addEvent.chainlinkAggregatorProxy, addEvent.resultScale, true);
        emit AddEventMapping(addEvent.eventId, addEvent.chainlinkAggregatorProxy, addEvent.resultScale);
    }

    function startRemoveEvent(string calldata eventId) external onlyOwner() {
        require(eventMapping[eventId].alive == true, "RemoveEvent: not alive");

        uint votingCode = startVoting("REMOVE_EVENT");
        removeEvent = SecurityDTOs.RemoveEvent(
            eventId,
            block.timestamp,
            votingCode
        );
    }

    function acquireRemoveEvent() external onlyOwner {
        pass(removeEvent.votingCode);
        eventMapping[removeEvent.eventId].alive = false;
        emit RemoveMapping(removeEvent.eventId);
    }
}// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;

interface AggregatorInterface {
    function decimals() external view returns (uint8);

    function getAnswer(uint256 roundId) external view returns (int256);

    function getTimestamp(uint256 roundId) external view returns (uint256);

    function latestRound() external view returns (uint256);
}