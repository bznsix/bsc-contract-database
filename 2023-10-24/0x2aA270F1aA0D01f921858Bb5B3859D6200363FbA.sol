// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../interfaces/ContractOwnerV2.sol";
import "../interfaces/storages/IReferalFirstLine.sol";

contract ReferalFirstLineV2 is IReferalFirstLine,ContractOwnerV2
{
    mapping (uint => uint[]) private Referals; /// ID => refIds

    function getReferalsCount(uint refId) public  override view returns (uint)
    {
        return Referals[refId].length;
    }
    function getReferals(uint refId) public  override view returns(uint[] memory)
    {
        return Referals[refId];
    }  
    function addReferal(uint id, uint refId )isContractOwner public  override
    {
        Referals[refId].push(id);
    }    

    function clone(uint id, uint[] memory refs) isContractOwner public
    {
        Referals[id] = refs;
    }  
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IReferalFirstLine
{
/// VIEW
    function getReferalsCount(uint id) external view returns (uint);
    function getReferals(uint id) external view returns(uint[] memory);
///

/// FUNC    
    function addReferal(uint id, uint refId ) external;
///    
}// SPDX-License-Identifier: MIT
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
