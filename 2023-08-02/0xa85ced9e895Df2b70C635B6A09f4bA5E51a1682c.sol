// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../interfaces/storages/IUserStorage.sol";
import "../interfaces/ContractOwnerV2.sol";

contract UserStorageV2 is IUserStorage, ContractOwnerV2
{
    struct User
    {
        uint id;
        address userAddress;
        uint referalId;
        uint depositeTeam;
        uint8 currentStatusLevel;
        uint teamCount;
    }
    uint currentId = 1;
    mapping (address => User) private _userByAddress;
    mapping (uint => User) private _userById;
    
/// VIEW
    function isUserExistByAddress(address user) public  override view returns(bool)
    {
        if (_userByAddress[user].id != 0)
        {
            return true;
        }
        return false;
    }
    function isUserExistById(uint id) public  override view returns(bool)
    {
        if (_userById[id].id != 0)
        {
            return true;
        }
        return false;
    }
    function getReferalByAddress(address userAddress) public  override view returns(uint)
    {
        return (_userByAddress[userAddress].referalId);
    }
    function getReferalById(uint id) public  override view returns(uint)
    {
        return (_userById[id].referalId);
    }
    function getUserByAddress(address userAddress) public  override view 
    returns(uint,uint,uint,uint8,uint)
    {
        User memory user = _userByAddress[userAddress];
        return (
            user.id,
            user.referalId,
            user.depositeTeam, 
            user.currentStatusLevel,
            user.teamCount
        );
    }
    function getUserById(uint id) public  override view returns(address,uint,uint,uint8,uint)
    {
        User memory user = _userById[id];
        return (
            user.userAddress, 
            user.referalId,
            user.depositeTeam, 
            user.currentStatusLevel,
            user.teamCount
        );
    }
    function getUserIdByAddress(address acc) public  override view returns(uint)
    {
        return _userByAddress[acc].id;
    }
    function getUserAddressById(uint id) public  override view returns(address)
    {
        return _userById[id].userAddress;
    }
    function getUserDepositeTeam(uint id) public  override view returns(uint)
    {
        return _userById[id].depositeTeam;
    }
    function getUserStatusLVL(uint id) public  override view returns(uint8)
    {
        return _userById[id].currentStatusLevel;
    }
///

/// FUNC
    function addUser(address user, uint referalId)isContractOwner public  override
    {
        User memory newUser = User({
        id  : currentId,
        userAddress : user,
        referalId : referalId,
        depositeTeam : 0,
        currentStatusLevel : 0,
        teamCount : 0
        });
        _userByAddress[user] = newUser;
        _userById[currentId] = newUser;
        currentId++;
    }
    function addReferal (uint referalId) public  override 
    {
        _userById[referalId].teamCount++;
    }
    function updateUserDepositeTeam(uint userId,uint depositeTeam)isContractOwner public  override
    {
        _userById[userId].depositeTeam = depositeTeam;
    }
    function updateUserStatus(uint userId)isContractOwner public  override
    {
        _userById[userId].currentStatusLevel++;
    }
    function updateUserTeamCount(uint userId,uint team)isContractOwner public  override
    {
        _userById[userId].teamCount = team;
    }

    function clone (address _userAddress, uint _referalId,
    uint _depositeTeam, uint8 _currentStatusLevel, uint _teamCount )
    isContractOwner public 
    {
        User memory newUser = User({
        id  : currentId,
        userAddress : _userAddress,
        referalId : _referalId,
        depositeTeam : _depositeTeam,
        currentStatusLevel : _currentStatusLevel,
        teamCount : _teamCount
        });
        _userByAddress[_userAddress] = newUser;
        _userById[currentId] = newUser;
        currentId++;
    }
///
} // SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./OwnableV2.sol";

abstract contract ContractOwnerV2 is OwnableV2
{
    address _contractOwner;

    modifier isContractOwner()
    {
        require(msg.sender == _contractOwner, "no access");
        _;
    }
    function setContractOwner(address contractOwner) onlyOwner public 
    {
        _contractOwner = contractOwner;
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IUserStorage
{
    function isUserExistByAddress(address user) external view returns(bool);
    function isUserExistById(uint id) external view returns(bool);
    function getReferalByAddress(address userAddress) external view returns(uint);
    function getReferalById(uint id) external view returns(uint);
    function getUserByAddress(address userAddress) external view returns(uint,uint,uint,uint8,uint);
    function getUserById(uint id) external view returns(address,uint,uint,uint8,uint);
    function getUserIdByAddress(address acc) external view returns(uint);
    function getUserAddressById(uint id) external view returns(address);
    function getUserDepositeTeam(uint id) external view returns(uint);
    function getUserStatusLVL(uint id) external view returns(uint8);

    //// UPDATE
    function addUser(address user, uint referalId) external;
    function addReferal (uint referalId) external;
    function updateUserDepositeTeam(uint userId,uint depositeTeam) external;
    function updateUserStatus(uint userId) external;
    function updateUserTeamCount(uint userId,uint team) external;
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./Context.sol";

abstract contract OwnableV2 is Context
{
    address _owner;
    address public _newOwner;
    constructor()  
    {
        _owner = payable(msg.sender);
    }

    modifier onlyOwner() 
    {
        require(_msgSender() == _owner, "Only owner");
        _;
    }

    function changeOwner(address newOwner) onlyOwner public
    {
        _newOwner = newOwner;
    }
    function confirm() public
    {
        require(_newOwner == msg.sender);
        _owner = _newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

abstract contract Context 
{
    function _msgSender() internal view virtual returns (address) 
    {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) 
    {
        this; 
        return msg.data;
    }
}
