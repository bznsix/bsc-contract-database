// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import {AggregatorInterface} from "../../dependencies/chainlink/AggregatorInterface.sol";
import {SID} from "../../dependencies/binance/SID.sol";
import {IPublicResolver} from "../../dependencies/binance/IPublicResolver.sol";
import {ITWAPAggregator} from "./ITWAPAggregator.sol";
import {Ownable} from "../../dependencies/openzeppelin/contracts/Ownable.sol";

contract SNBNBBinanceOracleAggregator is Ownable, AggregatorInterface {
    // for information; refer to https://oracle.binance.com/docs/price-feeds/contract-addresses/bnb-mainnet
    string private constant feedRegistrySID = "snbnb-usd.boracle.bnb";
    bytes32 private constant nodeHash = 0x153896165d7b9a227edd631aead0720dce98d9213dac89cbc36da25457262097;
    address public immutable sidRegistryAddress;
    address public twapAggregatorAddress;

    event SetTWAPAggregatorAddress(address twapAggregatorAddress);

    constructor(address _sidRegistryAddress) {
        sidRegistryAddress = _sidRegistryAddress;
    }

    function setTWAPAggregatorAddress(address _twapAggregatorAddress) external onlyOwner {
        twapAggregatorAddress = _twapAggregatorAddress;
        emit SetTWAPAggregatorAddress(_twapAggregatorAddress);
    }

    function getFeedRegistryAddress() public view returns (address) {
        SID sidRegistry = SID(sidRegistryAddress);
        address publicResolver = sidRegistry.resolver(nodeHash);
        return IPublicResolver(publicResolver).addr(nodeHash);
    }

    function checkBinanceOracleAccess() external view returns (bool) {
        AggregatorInterface feedRegistry = AggregatorInterface(getFeedRegistryAddress());
        try feedRegistry.latestAnswer() returns (int256) {
            return true;
        } catch {
            return false;
        }
    }

    /**
     * @dev Converts an unsigned uint256 into a signed int256.
     *
     * Requirements:
     *
     * - input must be less than or equal to maxInt256.
     */
    function toInt256(uint256 value) internal pure returns (int256) {
        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }

    function getTWAP() internal view returns (int256) {
        return toInt256(ITWAPAggregator(twapAggregatorAddress).getTWAP());
    }

    function latestAnswer() external view returns (int256) {
        AggregatorInterface feedRegistry = AggregatorInterface(getFeedRegistryAddress());
        try feedRegistry.latestAnswer() returns (int256 answer) {
            return answer;
        } catch {
            return getTWAP();
        }
    }

    function latestTimestamp() external view returns (uint256) {
        AggregatorInterface feedRegistry = AggregatorInterface(getFeedRegistryAddress());
        return feedRegistry.latestTimestamp();
    }

    function latestRound() external view returns (uint256) {
        AggregatorInterface feedRegistry = AggregatorInterface(getFeedRegistryAddress());
        return feedRegistry.latestRound();
    }

    function getAnswer(uint256 roundId) external view returns (int256) {
        AggregatorInterface feedRegistry = AggregatorInterface(getFeedRegistryAddress());
        return feedRegistry.getAnswer(roundId);
    }

    function getTimestamp(uint256 roundId) external view returns (uint256) {
        AggregatorInterface feedRegistry = AggregatorInterface(getFeedRegistryAddress());
        return feedRegistry.getTimestamp(roundId);
    }
}
// SPDX-License-Identifier: MIT
// Chainlink Contracts v0.8
pragma solidity ^0.8.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface SID {
  function owner(bytes32 node) external view returns (address);

  function resolver(bytes32 node) external view returns (address);

  function ttl(bytes32 node) external view returns (uint64);

  function recordExists(bytes32 node) external view returns (bool);

  function isApprovedForAll(address owner, address operator)
  external
  view
  returns (bool);
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * A more advanced resolver that allows for multiple records of the same domain.
 */
interface IPublicResolver {
    function addr(bytes32 node) external view returns (address payable);

    function addr(bytes32 node, uint256 coinType) external view returns (bytes memory);

}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.5.0;

interface ITWAPAggregator {
    function getTWAP() external view returns (uint256);
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import './Context.sol';

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
contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), 'Ownable: caller is not the owner');
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
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  function _msgSender() internal view virtual returns (address payable) {
    return payable(msg.sender);
  }

  function _msgData() internal view virtual returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}
