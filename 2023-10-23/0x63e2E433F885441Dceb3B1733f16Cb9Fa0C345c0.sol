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
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPetCore {
    function ownerOf(uint256 _tokenId) external view returns (address owner);

    function transfer(address _to, uint256 _tokenId) external;

    function PetIndexToApproved(
        uint256 _tokenId
    ) external view returns (address operator);

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external;

    function getApproved(
        uint256 tokenId
    ) external view returns (address operator);
}

contract MigrationMDP is Ownable {
    struct MigrationInfo {
        uint256 totalv1;
        uint256 totalv2;
    }

    struct TokenInfo {
        address owner;
        bool exists;
    }

    mapping(address => MigrationInfo) public migrationInfo;
    mapping(uint256 => TokenInfo) v1Token;
    mapping(uint256 => TokenInfo) v2Token;

    address private contractV1;
    address private contractV2;
    IPetCore public v1;
    IPetCore public v2;
    uint8 public season;
    uint256 public timeStartMigration;
    uint256 public timeEndMigration;
    uint256 public totalMigration;
    uint256 public v1Migrated;
    uint256 public v2Migrated;

    modifier onlyMigration() {
        require(
            block.timestamp >= timeStartMigration &&
                block.timestamp < timeEndMigration,
            "Can not migration now"
        );
        _;
    }

    event Migration(
        address indexed addr,
        uint256 tokenId,
        address addrContract,
        uint256 season
    );
    event EmergencyReturn(
        address indexed addr,
        uint256 tokenId,
        address addrContract,
        uint256 season
    );

    constructor(address dpetV1, address dpetV2) {
        v1 = IPetCore(dpetV1);
        v2 = IPetCore(dpetV2);
        contractV1 = dpetV1;
        contractV2 = dpetV2;
        timeStartMigration = 1696561200;
        timeEndMigration = 1697684400;
        season = 1;
    }

    function migration(uint256 tokenId, bool isV1) external onlyMigration {
        totalMigration++;
        if (isV1) {
            require(!v1Token[tokenId].exists, "Token has migrated");
            require(
                v1.PetIndexToApproved(tokenId) == address(this),
                "Need Approve Token for this contract"
            );
            v1.transferFrom(msg.sender, address(this), tokenId);
            migrationInfo[msg.sender].totalv1++;
            v1Token[tokenId].owner = msg.sender;
            v1Token[tokenId].exists = true;
            v1Migrated++;
            emit Migration(msg.sender, tokenId, contractV1, season);
        } else {
            require(!v2Token[tokenId].exists, "Token has migrated");
            require(
                v2.getApproved(tokenId) == address(this),
                "Need Approve Token for this contract"
            );
            v2.transferFrom(msg.sender, address(this), tokenId);
            migrationInfo[msg.sender].totalv2++;
            v2Token[tokenId].owner = msg.sender;
            v2Token[tokenId].exists = true;
            v2Migrated++;
            emit Migration(msg.sender, tokenId, contractV2, season);
        }
    }

    function setTimeMigration(
        uint256 _timeStartMigration,
        uint256 _timeEndMigration,
        uint8 _season
    ) external onlyOwner {
        timeStartMigration = _timeStartMigration;
        timeEndMigration = _timeEndMigration;
        season = _season;
    }

    function isReady() public view returns (bool) {
        return (block.timestamp >= timeStartMigration &&
            block.timestamp < timeEndMigration);
    }

    function checkTokenExists(
        uint256 tokenId,
        bool isV1
    ) public view returns (bool) {
        if (isV1) {
            return v1Token[tokenId].exists;
        } else {
            return v2Token[tokenId].exists;
        }
    }

    function emergencyReturnV1(uint256[] memory arrTokenV1) external onlyOwner {
        require(
            arrTokenV1.length > 0 && arrTokenV1.length < 20,
            "Invalid tokenId array"
        );
        for (uint i = 0; i < arrTokenV1.length; i++) {
            uint256 tokenId = arrTokenV1[i];
            require(v1Token[tokenId].exists, "Token not exists");
            v1.transfer(v1Token[tokenId].owner, tokenId);
            v1Token[tokenId].exists = false;
            migrationInfo[v1Token[tokenId].owner].totalv1--;
            v1Migrated--;
            totalMigration--;
            emit EmergencyReturn(
                v1Token[tokenId].owner,
                tokenId,
                contractV1,
                season
            );
        }
    }

    function emergencyReturnV2(uint256[] memory arrTokenV2) external onlyOwner {
        require(
            arrTokenV2.length > 0 && arrTokenV2.length < 20,
            "Invalid tokenId array"
        );
        for (uint i = 0; i < arrTokenV2.length; i++) {
            uint256 tokenId = arrTokenV2[i];
            require(v2Token[tokenId].exists, "Token not exists");
            v2.transferFrom(address(this), v2Token[tokenId].owner, tokenId);
            v2Token[tokenId].exists = false;
            migrationInfo[v2Token[tokenId].owner].totalv2--;
            v2Migrated--;
            totalMigration--;
            emit EmergencyReturn(
                v2Token[tokenId].owner,
                tokenId,
                contractV2,
                season
            );
        }
    }
}
