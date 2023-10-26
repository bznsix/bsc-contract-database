// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../interfaces/OwnableV2.sol";
import "../interfaces/IViewV2.sol";

contract ViewApp is IViewV2, OwnableV2
{
    IViewV2 private viewImpliment;
    constructor (address viewImp) {
        viewImpliment = IViewV2(viewImp);
    }
/// USER
    function isUserExist(address acc) public   override view returns(bool)
    {
        return viewImpliment.isUserExist(acc);
    } 
    function isUserExistById(uint id) public   override view returns(bool) 
    {
        return viewImpliment.isUserExistById(id);
    } 
    function getReferalIdById(uint id) public   override view returns(uint)
    {
        return viewImpliment.getReferalIdById(id);
    }
    function getAddressById(uint id) public   override view returns (address)
    {
        return viewImpliment.getAddressById(id);
    }
    function getIdByAddress(address acc)public   override view returns(uint)
    {
        return viewImpliment.getIdByAddress(acc);
    }
    function getUser(uint id)public   override view returns(address,uint,uint,uint8,uint)
    {
        return viewImpliment.getUser(id);
    }
///

/// TEAM   
    function getRefCount(uint id, uint8 lvl) public   override view returns (uint)
    {
        return viewImpliment.getRefCount(id, lvl);
    }
    function getStatsCount(uint id) public   override view returns (uint)
    {
        return viewImpliment.getStatsCount(id);
    }
    function checkUpdate(uint id) public override view returns(bool)
    {
        return viewImpliment.checkUpdate(id);
    }
    function getLine (uint id) public override view returns (uint[] memory)
    {
        return viewImpliment.getLine(id);
    }
    function rewardPass(uint userId, uint8 lvl)public view returns(bool)
    {
        return viewImpliment.rewardPass(userId,lvl);
    }
///

/// WALLET
    function balanceOf(address account) public   override view returns (uint)
    {
        return viewImpliment.balanceOf(account);
    }
    function allowance(address owner, address spender) public   override view returns (uint)
    {
        return viewImpliment.allowance(owner, spender);
    }
///

/// FROZEN
    function getFrozenToken(address acc) public   override view returns(uint)
    {
        return viewImpliment.getFrozenToken(acc);
    }
    function getFrozenDate(address acc) public   override view returns(uint)
    {
        return viewImpliment.getFrozenDate(acc);
    }
    function balanceWithFrozen(address acc) public   override view returns(uint)
    {
        return viewImpliment.balanceWithFrozen(acc);
    }
///

/// Unfrozen
    function getCount() public  view returns (uint) {
        return viewImpliment.getCount();
    }

    function getUnfrozenById(uint userId) public  view returns (address) {
        return viewImpliment.getUnfrozenById(userId);
    }

    function getUnfrozenByAddress(address acc) public  view returns (bool) {
        return viewImpliment.getUnfrozenByAddress(acc);
    }

    function getExtra(uint balance) public  view returns (uint8) {
        return viewImpliment.getExtra(balance);
    }
///

/// SUPPLY
    /// Skolko est v sisteme
    function totalSupply() public   override view returns (uint)
    {
        return viewImpliment.totalSupply();
    }
    /// Skolko mojet bit vipusheno v sistemy
    function getEmission() public   override view returns(uint)
    {
        return viewImpliment.getEmission();
    } 
///

/// DEPOSITE
    function getDeposite(address acc) public   override view returns(uint)
    {
        return viewImpliment.getDeposite(acc);
    }
    function getDepositeDate(address acc) public   override view returns(uint)
    {
        return viewImpliment.getDepositeDate(acc);
    }
    function getDepositeProfit(address acc) public   override view returns(uint)
    {
        return viewImpliment.getDepositeProfit(acc);
    }
    function getClearPercent(uint amount) public view returns(uint)
    {
        return viewImpliment.getClearPercent(amount);
    }
    function findReferalReward(uint amount, uint8 line) public view returns (uint)
    {
        return viewImpliment.findReferalReward(amount,line);
    }
///
    function setImp(address newImp) onlyOwner public {
        viewImpliment = IViewV2(newImp);
    }
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;


import "./IView.sol";
interface IViewV2 is IView
{
    function rewardPass(uint userId, uint8 lvl)external view returns(bool);
    function findReferalReward(uint amount, uint8 line) external view returns (uint);
    function getClearPercent(uint amount) external view returns(uint);
    function getCount() external  view returns (uint);
    function getUnfrozenById(uint userId) external  view returns (address);
    function getUnfrozenByAddress(address acc) external  view returns (bool);
    function getExtra(uint balance) external  view returns (uint8);
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
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IView 
{
    function isUserExist(address acc) external view returns(bool);
    function isUserExistById(uint id) external view returns(bool);
    function getReferalIdById(uint id) external view returns(uint);
    function getAddressById(uint id) external view returns (address);
    function getIdByAddress(address acc)external view returns(uint);
    function getUser(uint id)external view returns(address,uint,uint,uint8,uint);
    function getRefCount(uint id, uint8 lvl) external view returns (uint);
    function getStatsCount(uint id) external view returns (uint);
    function checkUpdate(uint id) external view returns(bool);
    function getLine (uint id) external view returns (uint[] memory);
    function totalSupply() external view returns (uint);
    function getEmission() external view returns(uint);
    function balanceOf(address account) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function getFrozenToken(address acc) external view returns(uint);
    function getFrozenDate(address acc) external view returns(uint);
    function balanceWithFrozen(address acc) external view returns(uint);
    function getDeposite(address acc) external view returns(uint);
    function getDepositeDate(address acc) external view returns(uint);
    function getDepositeProfit(address acc) external view returns(uint);
}