// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../interfaces/storages/IFrozenStorage.sol";
import "../interfaces/ContractOwnerV2.sol";

contract FrozenStorageV2 is IFrozenStorage, ContractOwnerV2
{
    mapping (uint => uint) private _frozenTokens;
    mapping (uint => uint) private _frozenDate;
    function getFrozenDate(uint id) public  override view returns(uint)
    {
        return _frozenDate[id];
    }
    function getFrozenTokens(uint id) public  override view returns (uint)
    {
        return _frozenTokens[id];
    }
    function setFrozenDate(uint id,uint date)isContractOwner public  override
    {
        _frozenDate[id] = date;
    }
    function setFrozenTokens(uint id, uint tokens)isContractOwner public  override
    {
        _frozenTokens[id] = tokens;
    }
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
pragma solidity ^0.8.12;

interface IFrozenStorage
{
    function getFrozenDate(uint id) external view returns(uint);
    function getFrozenTokens(uint id) external view returns (uint);
    function setFrozenDate(uint id,uint date) external;
    function setFrozenTokens(uint id, uint tokens) external;
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
