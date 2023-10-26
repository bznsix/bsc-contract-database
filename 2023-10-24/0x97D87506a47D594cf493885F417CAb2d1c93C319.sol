// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "../interfaces/storages/IUserStorage.sol";
import "../interfaces/storages/IWalletStorage.sol";
import "../interfaces/storages/IDepositeStorage.sol";
import "../interfaces/storages/IFrozenStorage.sol";
import "../interfaces/storages/ISupplyStorage.sol";
import "../interfaces/storages/ITeam.sol";
import "../interfaces/storages/IReferalFirstLine.sol";
import "../interfaces/storages/IUnfrozen.sol";

import "../interfaces/OwnableV2.sol";
import "../interfaces/IViewV2.sol";

contract ViewImplimentV1 is IViewV2, OwnableV2
{

    /// OLD
    IUserStorage private userStorage = IUserStorage(0x90F784E20641A023f851C56598D28634a3d7B1Ac);
    IWalletStorage private walletStorage = IWalletStorage(0x49B423C4dda814D12dBe56101aAE76d2F3517F1e); 
    IUnfrozen private unfrozenStorage = IUnfrozen(0xa651268e502252b7471a89F7409a5A1Fc5836c83); 
    IDepositeStorage private depositeStorage = IDepositeStorage(0x682a45E21f9F781f5090EacFE9797383E1FBDD6F); 
    IFrozenStorage private frozenStorage = IFrozenStorage(0xfCAbBE556573F1b3a36b5d3010D6B96c748Dc478);
    ITeam private team = ITeam(0xa316b11DEf2f93aDfD3C9CB404c88794c1704430);
    IReferalFirstLine private firstLineStorage = IReferalFirstLine(0x2aA270F1aA0D01f921858Bb5B3859D6200363FbA);
    address private controller = 0xeeAb35e387527c5eD8Afe91b9F5159f5B2D494A7;
    uint private _day = 86400;
    uint private _twoWeek = 1209600;
    uint8 private _transitionWithGuild = 0;
    uint private _stapHalfing = 25000000 ether;
    struct StatusTerms
    {
        // Bonuses
        uint8 levelsOpened;

        // Terms
        uint personalStacking;
        uint teamStacking;

        uint8 firstLineStatusLevelCount;
    }
    uint private fullReferalPercent = 15;
    StatusTerms[]  private  _terms;
    uint8[] private refPercents = [4,3,1,1,1,1,1,1,1,1];
    mapping(uint8 => uint8[]) private _halfingsToLvlPercent;
   
    constructor()
    {
        _terms.push(StatusTerms(  0,  0,             0,            0));
        _terms.push(StatusTerms(  2,  1000 ether,   3000 ether,    3));
        _terms.push(StatusTerms(  4,  1000 ether,   12000 ether,   3));
        _terms.push(StatusTerms(  6,  3000 ether,   50000 ether,   3));
        _terms.push(StatusTerms(  7,  5000 ether,   150000 ether,  3));
        _terms.push(StatusTerms(  8,  10000 ether,  300000 ether,  3));
        _terms.push(StatusTerms(  9,  20000 ether,  600000 ether,  3));
        _terms.push(StatusTerms(  10, 30000 ether,  1200000 ether, 3));
        
        _halfingsToLvlPercent[20] = [100,110,120,150,170,200,200,200];
        _halfingsToLvlPercent[19] = _halfingsToLvlPercent[20];
        _halfingsToLvlPercent[18] = _halfingsToLvlPercent[20];
        
        _halfingsToLvlPercent[17] = [70,80,90,100,110,120,130,140];
        
        _halfingsToLvlPercent[16] = [60,70,75,80,90,100,110,120];

        _halfingsToLvlPercent[15] = [50,60,65,70,80,90,100,110];

        _halfingsToLvlPercent[14] = [45,50,55,60,70,80,90,100];

        _halfingsToLvlPercent[13] = [40,45,50,55,60,70,80,90];

        _halfingsToLvlPercent[12] = [35,40,45,50,55,60,70,80];

        _halfingsToLvlPercent[11] = [30,35,40,45,50,55,60,70];
        _halfingsToLvlPercent[10] = _halfingsToLvlPercent[11];

        _halfingsToLvlPercent[9] = [25,30,35,40,45,50,55,60];
        _halfingsToLvlPercent[8] = _halfingsToLvlPercent[9];

        _halfingsToLvlPercent[7] = [20,25,30,35,40,45,50,55];
        _halfingsToLvlPercent[6] = _halfingsToLvlPercent[7];

        _halfingsToLvlPercent[5] = [15,20,25,30,35,40,45,50];
        _halfingsToLvlPercent[4] = _halfingsToLvlPercent[5];

        _halfingsToLvlPercent[3] = [10,15,20,25,30,35,40,45];
        _halfingsToLvlPercent[2] = _halfingsToLvlPercent[3];

        _halfingsToLvlPercent[1] = [5,10,15,20,25,30,35,40];
        _halfingsToLvlPercent[0] = _halfingsToLvlPercent[1];
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
        uint[] memory inviters = firstLineStorage.getReferals(id);
        for (uint u = 0; u < inviters.length;u++)
        {  
            address refererAddress = userStorage.getUserAddressById(inviters[u]);
            if (userStorage.getUserStatusLVL(inviters[u]) >= statusLevel &&
                unfrozenStorage.getUnfrozenByAddress(refererAddress))
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
            if (!unfrozenStorage.getUnfrozenByAddress(userAddress))
            {
                return false;
            }
        }
        if (statusLevel >= _terms.length-1)
        {
            return false;
        }
        
        uint personalStacking = depositeStorage.getDeposite(userAddress);
        uint teamStacking = userStorage.getUserDepositeTeam(id);
        
        uint firstLineStatusLevel = getStatsCount(id);
        if (personalStacking >= _terms[statusLevel+1].personalStacking &&
            teamStacking >= _terms[statusLevel+1].teamStacking &&
            firstLineStatusLevel >= _terms[statusLevel+1].firstLineStatusLevelCount)
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
        return firstLineStorage.getReferals(id);
    }
    function rewardPass(uint userId, uint8 lvl)public view returns(bool)
    {
        uint8 userStatusLvl = userStorage.getUserStatusLVL(userId);
        uint8 linesOpened = _terms[userStatusLvl].levelsOpened;
        if (linesOpened >= lvl+1)
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
        return unfrozenStorage.getCount();
    }

    function getUnfrozenById(uint userId) public  view returns (address) {
        return unfrozenStorage.getUnfrozenById(userId);
    }

    function getUnfrozenByAddress(address acc) public  view returns (bool) {
        if (getEmission() == 0)
        {
            return false;
        }
        return unfrozenStorage.getUnfrozenByAddress(acc);
    }

    function getExtra(uint balance) public  view returns (uint8) {
        return unfrozenStorage.getExtra(balance);
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
        uint8 userPercent = getPercent(userStorage.getUserStatusLVL(userId));
        if (unfrozenStorage.getUnfrozenByAddress(acc))
        {
            userPercent += (unfrozenStorage.getExtra(userDeposite)*10);
        }
        uint secPassed = block.timestamp - depDate;
        uint profit = secPassed * ((userDeposite * userPercent / 1000) / 30 / _day); 
        if (profit > sup) {
            profit = sup;
        }
        return profit;
    }
    function getClearPercent(uint amount) public view returns(uint)
    {
        return amount - (amount /100 * fullReferalPercent);
    }
    function findReferalReward(uint amount, uint8 line) public view returns (uint)
    {
        uint percent =  refPercents[line];
        return ((amount * percent) / 100);
    }






    function getPercent(uint8 lvl) private view returns(uint8)
    {
        uint sup = walletStorage.getBalance(controller);
        if (sup == 0 ether)
        {
            return 0;
        }
        uint8 halfingLvl = uint8(sup/_stapHalfing);
        return _halfingsToLvlPercent[halfingLvl][lvl];
    }




///

/// ADMIN

    function setGuildStats (uint8 _value) onlyOwner public {
        _transitionWithGuild = _value;
    }
    function setUnfrozen(address newAdr) onlyOwner public {
        unfrozenStorage = IUnfrozen(newAdr);
    }
    function setWallet(address newAdr) onlyOwner public 
    {
        walletStorage = IWalletStorage(newAdr);
    }
    function setUser (address newAdr) onlyOwner public
    {
        userStorage = IUserStorage(newAdr);
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
        firstLineStorage = IReferalFirstLine(newAdr);
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