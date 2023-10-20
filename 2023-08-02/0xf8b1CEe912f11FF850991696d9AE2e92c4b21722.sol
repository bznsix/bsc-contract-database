// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../interfaces/storages/IUserStorage.sol";
import "../interfaces/storages/IWalletStorage.sol";
import "../interfaces/storages/ITermsStorage.sol";
import "../interfaces/storages/IPresale.sol";
import "../interfaces/storages/IDepositeStorage.sol";
import "../interfaces/storages/IFrozenStorage.sol";
import "../interfaces/storages/ISupplyStorage.sol";
import "../interfaces/storages/ITeam.sol";
import "../interfaces/storages/IReferalFirstLine.sol";
import "../interfaces/storages/IUnfrozen.sol";
import "../interfaces/storages/IPresale.sol";

import "../interfaces/OwnableV2.sol";
import "../interfaces/IViewV2.sol";

contract ViewV3 is IViewV2, OwnableV2
{

    /// OLD
    IUserStorage private userStorage = IUserStorage(0xEec6B20c9298fBCF787Bbc6aEDEe1028BB0D06D5);
    IWalletStorage private walletStorage = IWalletStorage(0x49B423C4dda814D12dBe56101aAE76d2F3517F1e); 
    IUnfrozen private unfrozen = IUnfrozen(0xa651268e502252b7471a89F7409a5A1Fc5836c83); 
    IDepositeStorage private depositeStorage = IDepositeStorage(0x682a45E21f9F781f5090EacFE9797383E1FBDD6F); 
    IFrozenStorage private frozenStorage = IFrozenStorage(0x921A21547b394C2FA696BE8f81AE7CFf8c288e09);
    ITeam private team = ITeam(0xa316b11DEf2f93aDfD3C9CB404c88794c1704430);
    IReferalFirstLine private firstLine = IReferalFirstLine(0x512646bEef87433ab7F275f2bB62d1A6E62698fF);
    ITermsStorage private terms = ITermsStorage(0x75f1e7da1375bc77499314DE7971aC50d63320c4); 
    address controller;
    uint private _day = 86400;
    uint private _twoWeek = 1209600;
    uint8 private _transitionWithGuild = 2;  
    uint8[] private maxPercents = [
             2,    // 0
             4,    // 1
             6,    // 2
             8,    // 3
             10,   // 4
             12,   // 5
             14,   // 6
             16,   // 7
             18,   // 8
             20,   // 9
             20    // 10
             ];
    constructor(address contr) {
        controller = contr;
    }

/// USER
    function isUserExist(address acc) public   override view returns(bool)
    {
        return userStorage.getUserIdByAddress(acc) != 0;
    } 
    function isUserExistById(uint id) public   override view returns(bool) 
    {
        return userStorage.getUserAddressById(id) != address(0);
    } 
    function getReferalIdById(uint id) public   override view returns(uint)
    {
        return userStorage.getReferalById(id);
    }
    function getAddressById(uint id) public   override view returns (address)
    {
        return userStorage.getUserAddressById(id);
    }
    function getIdByAddress(address acc)public   override view returns(uint)
    {
        return userStorage.getUserIdByAddress(acc);
    }
    function getUser(uint id)public   override view returns(address,uint,uint,uint8,uint)
    {
        return userStorage.getUserById(id);
    }
///

/// TEAM   
    function getRefCount(uint id, uint8 lvl) public   override view returns (uint)
    {
        return team.getTeamCountLVL(id, lvl);
    }
    function getStatsCount(uint id) public   override view returns (uint)
    {
        uint8 statusLevel = userStorage.getUserStatusLVL(id);
        uint count = 0;
        uint[] memory inviters = firstLine.getReferals(id);
        for (uint u = 0; u < inviters.length;u++)
        {  
            if (userStorage.getUserStatusLVL(inviters[u]) >= statusLevel)
            {
                count ++;
            }
        }
        return count;
    }
    function checkUpdate(uint id) public override view returns(bool)
    {
        uint8 statusLevel = userStorage.getUserStatusLVL(id);
        address userAddress = userStorage.getUserAddressById(id);
        if (statusLevel >= _transitionWithGuild)
        {
            if (!unfrozen.getUnfrozenByAddress(userAddress))
            {
                return false;
            }
        }
        if (statusLevel >= terms.getTermsLength()-1)
        {
            return false;
        }
        
        uint personalStacking = depositeStorage.getDeposite(userAddress);
        uint teamStacking = userStorage.getUserDepositeTeam(id);
        uint firstLineCount = team.getTeamCountLVL(id, statusLevel);
        uint firstLineStatusLevel = getStatsCount(id);
        if (firstLineCount >= terms.getFirstLineCount(statusLevel+1) &&
            personalStacking >= terms.getPersonalStacking(statusLevel+1) &&
            teamStacking >= terms.getTeamStacking(statusLevel+1) &&
            firstLineStatusLevel >= terms.getFirstLineStatusLevelCount(statusLevel+1)
                )
            {
               return true;
            }
        else 
        {
            return false;
        }
    }
    function getLine (uint id) public override view returns (uint[] memory)
    {
        return firstLine.getReferals(id);
    }
    function rewardPass(uint userId, uint8 lvl)public view returns(bool)
    {
        uint8 userStatusLvl = userStorage.getUserStatusLVL(userId);
        uint8 linesOpened = terms.getOpenedLevel(userStatusLvl);
        if (linesOpened >= lvl)
        {
            return true;
        }
        return false;
    }
///

/// WALLET
    function balanceOf(address account) public   override view returns (uint)
    {
        return balanceWithFrozen(account);
    }
    function allowance(address owner, address spender) public   override view returns (uint)
    {
        return walletStorage.getAllow(owner, spender);
    }
///

/// FROZEN
    function getFrozenToken(address acc) public   override view returns(uint)
    {
        uint id = userStorage.getUserIdByAddress(acc);
        if (frozenStorage.getFrozenDate(id)+ _twoWeek < block.timestamp )
        {
            return 0;
        }
        return frozenStorage.getFrozenTokens(id);
    }
    function getFrozenDate(address acc) public   override view returns(uint)
    {
        uint id = userStorage.getUserIdByAddress(acc);
        uint frozenDate = frozenStorage.getFrozenDate(id);
        if (frozenDate + _twoWeek < block.timestamp)
        {
            return 0;
        }
        return frozenDate;
    }
    function balanceWithFrozen(address acc) public   override view returns(uint)
    {
        uint balance = walletStorage.getBalance(acc);
        uint userId = userStorage.getUserIdByAddress(acc);
        if (frozenStorage.getFrozenDate(userId)+ _twoWeek > block.timestamp )
        {
            balance -= frozenStorage.getFrozenTokens(userId);
        }
        return balance; 
    }
///

/// Unfrozen
    function getCount() public  view returns (uint) {
        return unfrozen.getCount();
    }

    function getUnfrozenById(uint userId) public  view returns (address) {
        return unfrozen.getUnfrozenById(userId);
    }

    function getUnfrozenByAddress(address acc) public  view returns (bool) {
        if (getEmission() == 0)
        {
            return false;
        }
        return unfrozen.getUnfrozenByAddress(acc);
    }

    function getExtra(uint balance) public  view returns (uint8) {
        return unfrozen.getExtra(balance);
    }
///

/// SUPPLY
    /// Skolko est v sisteme
    function totalSupply() public   override view returns (uint)
    {
        return 500000000 ether - walletStorage.getBalance(controller);
    }
    /// Skolko mojet bit vipusheno v sistemy
    function getEmission() public   override view returns(uint)
    {
        return walletStorage.getBalance(controller);
    } 
///

/// DEPOSITE
    function getDeposite(address acc) public   override view returns(uint)
    {
        return depositeStorage.getDeposite(acc);
    }
    function getDepositeDate(address acc) public   override view returns(uint)
    {
        return depositeStorage.getDepDate(acc);
    }
    function getDepositeProfit(address acc) public   override view returns(uint)
    {
        uint sup = walletStorage.getBalance(controller);
        uint userId = getIdByAddress(acc);
        uint depDate = getDepositeDate(acc);
        uint userDeposite = getDeposite(acc);
        uint8 maxPercent = maxPercents[sup/50000000 ether];
        uint8 userPercent = terms.getDepositePercent(userStorage.getUserStatusLVL(userId));
        userPercent = userPercent > maxPercent ? maxPercent : userPercent;
        if (unfrozen.getUnfrozenByAddress(acc))
        {
            userPercent += unfrozen.getExtra(getDeposite(acc));
        }
        uint secPassed = block.timestamp - depDate;
        uint profit = secPassed * ((userDeposite * userPercent / 100) / 30 / _day); 
        if (profit > sup) {
            profit = sup;
        }
        return profit;
    }
    function getClearPercent(uint amount) public view returns(uint)
    {
        return amount - (amount /100 * terms.getFullReferalPercent());
    }
    function findReferalReward(uint amount, uint8 line) public view returns (uint)
    {
        uint percent =  terms.getReferalPercent(line);
        return ((amount * percent) / 100);
    }
///




/// ADMIN

    function setGuildStats (uint8 _value) onlyOwner public {
        _transitionWithGuild = _value;
    }
    function setUnfrozen(address newAdr) onlyOwner public {
        unfrozen = IUnfrozen(newAdr);
    }
    function setWallet(address newAdr) onlyOwner public 
    {
        walletStorage = IWalletStorage(newAdr);
    }
    function setUser (address newAdr) onlyOwner public
    {
        userStorage = IUserStorage(newAdr);
    }
    function setTerms(address newAdr) onlyOwner public 
    {
        terms = ITermsStorage(newAdr);
    }
    function setDeposite(address newAdr) onlyOwner public 
    {
        depositeStorage = IDepositeStorage(newAdr);
    }    
    function setFrozen(address newAdr) onlyOwner public 
    {
        frozenStorage = IFrozenStorage(newAdr);
    }
    function setTeam(address newAdr) onlyOwner public 
    {
        team = ITeam(newAdr);
    }
    function setFirstLine(address newAdr) onlyOwner public 
    {
        firstLine = IReferalFirstLine(newAdr);
    }
    function setController (address _contr) onlyOwner public 
    {
        controller = _contr;
    }
///
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
pragma solidity ^0.8.12;

interface IPresale
{
    function getPresaleCount() external view returns(uint);
    function getPrice() external view returns(uint);
    function getPresaleStart() external view returns (bool);
    function getPresaleStartDate() external view returns(uint);
    function getPresaleEndDate() external view returns(uint);
    function subCount(uint amount) external;
    function getPresaleNumber() external view returns(uint8);
    function getUserLimit(address acc) external view returns(uint);
    function getMaxToken() external view returns(uint);
    function buyTokenOnPresale(address acc, uint amount) external;
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;


interface IUnfrozen
{
    function getCount() external view returns (uint);
    function getUnfrozenById(uint userId) external view returns (address);
    function getUnfrozenByAddress(address acc) external view returns (bool);
    function getExtra(uint balance) external view returns (uint8);
    function setUnfrozen (address acc) external;
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

interface ITeam
{
    function getTeamCountLVL(uint id, uint8 lvl) external view returns (uint);
    function getTeamCountStats(uint id) external view returns (uint);
    function addTeamer (uint id, uint8 lvl) external;
    function addTeameStatus (uint id) external;
    function clearTeameStatus (uint id)  external;
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface ISupplyStorage
{
    function getSupply() external view returns(uint, uint);
    function subTokenSupply(uint amount)  external;
    function addTokenSupply(uint amount)  external;
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IFrozenStorage
{
    function getFrozenDate(uint id) external view returns(uint);
    function getFrozenTokens(uint id) external view returns (uint);
    function setFrozenDate(uint id,uint date) external;
    function setFrozenTokens(uint id, uint tokens) external;
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IDepositeStorage
{
    function getDeposite(address acc) external view returns (uint);
    function getDepDate (address acc) external view returns(uint);
    function addDep(address acc, uint amount) external;
    function subDep(address acc, uint amount) external;
    function setDepDate(address acc, uint date) external;
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;


interface ITermsStorage
{
    function getTermsLength() external view returns(uint);
    function getDepositePercent(uint8 lvl) external view returns(uint8);
    function getFullReferalPercent() external view returns(uint);
    function getOpenedLevel(uint lvl) external view returns(uint8);
    function getReferalPercent(uint lvl) external view returns(uint);
    function getFirstLineCount(uint lvl) external view returns(uint);
    function getPersonalStacking(uint lvl) external view returns(uint);
    function getTeamStacking(uint lvl) external view returns(uint);
    function getFirstLineStatusLevelCount(uint lvl) external view returns(uint);
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IWalletStorage
{
    function getBalance(address acc) external view returns(uint);
    function getAllow(address acc, address spender) external view returns (uint);
    function addBalance(address acc, uint amount) external;
    function subBalance(address acc, uint amount) external;
    function allow(address acc, address rec, uint amount) external;
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