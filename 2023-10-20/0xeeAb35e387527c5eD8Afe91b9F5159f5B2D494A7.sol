// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

/*
    IWalletStorage    = 1
    IUserStorage      = 2
    IDepositeStorage  = 3
    IUnfrozen         = 4
    IFrozenStorage    = 5
    ITeam             = 7
    IReferalFirstLine = 8
    IBanStorage       = 10
    IViewV2           = 11
    EVOMG             = 12
    IGiffter          = 13
    EventEmitter      = 14
*/

import "../interfaces/IController.sol";
import "../interfaces/ContractOwnerV2.sol";
import "../interfaces/storages/IWalletStorage.sol";
import "../interfaces/storages/IUserStorage.sol";
import "../interfaces/storages/ITermsStorage.sol";
import "../interfaces/storages/IDepositeStorage.sol";
import "../interfaces/storages/IFrozenStorage.sol";
import "../interfaces/IBEP20.sol";
import "../interfaces/storages/ITeam.sol";
import "../interfaces/storages/IReferalFirstLine.sol";
import "../interfaces/storages/IUnfrozen.sol";
import "../interfaces/storages/IBanStorage.sol";
import "../interfaces/IViewV2.sol";
import "../interfaces/IGifter.sol";
import "../interfaces/storages/IEventEmitter.sol";

contract ControllerV7 is IController, ContractOwnerV2 , IGifter
{
    mapping (uint8 => address) public Contracts;

    modifier isEMG () 
    {
        require(msg.sender == Contracts[12], "no app");
        _;
    }
    modifier isRegister(address userAddress)
    {
       require(IViewV2(Contracts[11]).isUserExist(userAddress), "User not registered");
       _;
    }
    modifier isBanned(address userCheck)
    {
        require(!IBanStorage(Contracts[10]).isBanned(userCheck), "User banned");
       _;
    }


    constructor() {
        Contracts[1] = 0x49B423C4dda814D12dBe56101aAE76d2F3517F1e;
        Contracts[2] = 0x90F784E20641A023f851C56598D28634a3d7B1Ac;
        Contracts[3] = 0x682a45E21f9F781f5090EacFE9797383E1FBDD6F;
        Contracts[4] = 0xa651268e502252b7471a89F7409a5A1Fc5836c83;
        Contracts[5] = 0xfCAbBE556573F1b3a36b5d3010D6B96c748Dc478;
        Contracts[7] = 0xa316b11DEf2f93aDfD3C9CB404c88794c1704430;
        Contracts[8] = 0x2aA270F1aA0D01f921858Bb5B3859D6200363FbA;
        Contracts[10] = 0x0E66dB1e34eCC82D3C822735B646ed2AB822db37;

        Contracts[12] = 0x6eC49a22F6EA8b271d188A92AA6BFd23E5DE5F8f;
        Contracts[13] = 0x956251B44Ca3a1a9b0667ee24B8573AA8360e6A8;
        Contracts[14] = 0xbF7bc136B173E377b0F58a228f3f8A191C4E7dA5;
    }

    function gift(address to, uint amount) public returns(bool)
    {
        require(msg.sender == Contracts[13], "only gifter");
        if (IViewV2(Contracts[11]).balanceOf(msg.sender) >= amount)
        {
            if (!IViewV2(Contracts[11]).getUnfrozenByAddress(to))
            {
                IUnfrozen(Contracts[4]).setUnfrozen(to);
            }
            IWalletStorage(Contracts[1]).subBalance(msg.sender, amount);
            IWalletStorage(Contracts[1]).addBalance(address(this), amount);
            IBEP20(_contractOwner).transfer(to, amount);
            _dep(to,amount);
            return true;
        }
        return false;
    }

/// TOKEN           
    function transfer(address owner, address recipient, uint amount) isContractOwner isBanned(owner) public returns (bool)
    {    
        require(IViewV2(Contracts[11]).balanceWithFrozen(owner)>= amount, "not enougth token");
        _trasfer(owner, recipient, amount);
        return true;
    }
    function approve(address owner, address spender, uint amount)isContractOwner isBanned(owner) public returns (bool)
    {
        IWalletStorage(Contracts[1]).allow(owner,spender,amount);
        return true;
    } 
    function burn(uint amount) isContractOwner public
    {
        require(IViewV2(Contracts[11]).balanceWithFrozen(msg.sender)>= amount,"much to burn");
        _trasfer(msg.sender, payable(address(0x000000000000000000000000000000000000dEaD)), amount);
    }
///

/// USER
    function register(address user, uint refId) isEMG public
    {
        require(!IViewV2(Contracts[11]).isUserExist(user), "Alredy register");
        if(!IViewV2(Contracts[11]).isUserExistById(refId))
        {
            refId = 1;
        }
        IUserStorage(Contracts[2]).addUser(user, refId);
        uint id = IViewV2(Contracts[11]).getIdByAddress(user);
        IReferalFirstLine(Contracts[8]).addReferal(id,refId);
        uint8 rewardLine = 0;
        bool isOwner = false;
        while(rewardLine < 8 && !isOwner)
        {
            ITeam(Contracts[7]).addTeamer(refId,rewardLine);
            IUserStorage(Contracts[2]).addReferal(refId);
            if (refId == 1)
            {
                isOwner = true;
            }
            refId = IViewV2(Contracts[11]).getReferalIdById(refId);
            rewardLine++;
        }
        IEventEmitter(Contracts[14]).onRegister(user,refId);
    }

    function updateStatus(address acc) public
    {
        uint id = IViewV2(Contracts[11]).getIdByAddress(acc);
        require(IViewV2(Contracts[11]).checkUpdate(id));
        uint profit = IViewV2(Contracts[11]).getDepositeProfit(acc);
        if(profit > 0)
        {
            _withdrawProfit(acc);
        }
        IUserStorage(Contracts[2]).updateUserStatus(id);
        IEventEmitter(Contracts[14]).onLevelUp (acc);
    }
///
   
/// Deposite
    function deposite (address user, uint amount) isEMG isRegister(user)  public returns(bool)
    {
        require(IView(Contracts[11]).balanceOf(user) >= amount, "Not enought tokens");
        _dep(user,amount);
        return true;
    }
    function withdrawProfit(address user) isEMG isRegister(user) isBanned(user) public 
    {
        _withdrawProfit(user);
    }
    function withdrawAll(address user) isEMG isRegister(user) isBanned(user) public 
    {
        require(! IViewV2(Contracts[11]).getUnfrozenByAddress(user), "User unfrozened");
        uint userId = IViewV2(Contracts[11]).getIdByAddress(user);   
        uint frozenDate = //IFrozenStorage(Contracts[5]).getFrozenDate(userId);
        IViewV2(Contracts[11]).getFrozenDate(user);
        require(frozenDate == 0, "wait two week");
        uint userDeposite = IViewV2(Contracts[11]).getDeposite(user);
        require(userDeposite > 0, "Not enought tokens");
        uint profit =  IViewV2(Contracts[11]).getDepositeProfit(user);
        _sendClearProfit(user, profit);
        IWalletStorage(Contracts[1]).addBalance(user,userDeposite);
        IDepositeStorage(Contracts[3]).setDepDate(user, block.timestamp);
        IDepositeStorage(Contracts[3]).subDep(user, userDeposite);
        IFrozenStorage(Contracts[5]).setFrozenDate(userId, block.timestamp);
        IFrozenStorage(Contracts[5]).setFrozenTokens(userId, userDeposite);
        UpdateDepositeTeamAll(userId, userDeposite, false);
        IEventEmitter(Contracts[14]).onWithdraw(user,userDeposite);
    }
    function reinvest(address user) isEMG isRegister(user) isBanned(user) public 
    {
        uint id = IViewV2(Contracts[11]).getIdByAddress(user);
        uint profit = IViewV2(Contracts[11]).getDepositeProfit(user);   
        _sendClearProfit(user, profit);
        IWalletStorage(Contracts[1]).subBalance(user, profit);
        IDepositeStorage(Contracts[3]).addDep(user, profit);
        IDepositeStorage(Contracts[3]).setDepDate(user, block.timestamp);
        UpdateDepositeTeamAll(id, profit, true);
        IEventEmitter(Contracts[14]).onReinvest(user,profit,IViewV2(Contracts[11]).getDeposite(user));
    }
///


/// UNFROZEN
    function setUnfrozenUser(address user) isEMG isRegister(user) public 
    {
        require(!IViewV2(Contracts[11]).getUnfrozenByAddress(user));
        _withdrawProfit(user);
        IUnfrozen(Contracts[4]).setUnfrozen(user);
        IEventEmitter(Contracts[14]).onGuilder(user);
    }
///

    
/// OLD API
    function pay(address acc, uint amount) public pure override returns(bool, uint,uint) 
    {
        if (acc != address(0))
        {
            return (false, 0,amount);        
        }
        return (false, 0,amount);
    }
    function destroyToken(address acc, uint amount) public pure
    {
    }
    function addTokenforCoin(address acc, uint amount) public pure
    {
    }
///



/// PRIVATE
    function _trasfer(address owner, address repicient, uint amount) private
    {
        IWalletStorage(Contracts[1]).subBalance(owner, amount);
        IWalletStorage(Contracts[1]).addBalance(repicient, amount);
    }
   
    function _dep(address user, uint amount) private 
    {
        uint userId = IViewV2(Contracts[11]).getIdByAddress(user);
        uint profit = IViewV2(Contracts[11]).getDepositeProfit(user);
        if(profit > 0)
        {
            _withdrawProfit(user);
        }
        IWalletStorage(Contracts[1]).subBalance(user, amount);
        IDepositeStorage(Contracts[3]).setDepDate(user,block.timestamp);
        IDepositeStorage(Contracts[3]).addDep(user,amount);
        UpdateDepositeTeamAll(userId, amount, true);   
        IEventEmitter(Contracts[14]).onDeposite(user,amount);
    }


    function _sendClearProfit(address user, uint profit) private 
    {
        uint thisBalance = IViewV2(Contracts[11]).balanceOf(address(this));
        if ( thisBalance < profit)
        {
            profit = thisBalance;
        }
        if (profit != 0)
        {
            IBEP20(_contractOwner).transfer(user, profit);
            IEventEmitter(Contracts[14]).onClaim (user,profit);
        }
        
    }
    function UpdateDepositeTeamAll(uint id, uint amount, bool isUp) private 
    {
        uint refId = IViewV2(Contracts[11]).getReferalIdById(id);
        uint8 lvl = 0;
        bool isOwner = false;
        while (lvl < 8 && !isOwner)
        {
            uint depositeTeam = IUserStorage(Contracts[2]).getUserDepositeTeam(refId);
            if (isUp)
            {
               depositeTeam += amount;
            } 
            else 
            {
                if (depositeTeam >= amount)
                {
                    depositeTeam -= amount;
                } 
            }
            IUserStorage(Contracts[2]).updateUserDepositeTeam(refId,depositeTeam);    
            if (refId == 1)
            {
                isOwner = true;
            }
            refId = IViewV2(Contracts[11]).getReferalIdById(refId);
            lvl++;
        }
    }
    
    function _withdrawProfit(address acc) private
    {
        uint profit = IViewV2(Contracts[11]).getDepositeProfit(acc);
        require(profit > 0, "No profit");
        uint thisBalance = IViewV2(Contracts[11]).balanceOf(address(this));
        if (thisBalance < profit)
        {
            profit = thisBalance;
        }
        if (profit != 0)
        {
            uint clearProfit = IViewV2(Contracts[11]).getClearPercent(profit);
            uint userId = IViewV2(Contracts[11]).getIdByAddress(acc);
            uint NextReferalId = IViewV2(Contracts[11]).getReferalIdById(userId);
            IBEP20(_contractOwner).transfer(acc, clearProfit);
            IDepositeStorage(Contracts[3]).setDepDate(acc, block.timestamp);
            for (uint8 rewardLine = 0; rewardLine < 10; rewardLine++ )
            {
                address rewardAddress; 
                
                if (IViewV2(Contracts[11]).rewardPass(NextReferalId, rewardLine))
                {
                    rewardAddress =IViewV2(Contracts[11]).getAddressById(NextReferalId);        
                }
                else
                {
                    rewardAddress = IViewV2(Contracts[11]).getAddressById(1);
                }
                uint reward =  IViewV2(Contracts[11]).findReferalReward(profit, rewardLine);
                IBEP20(_contractOwner).transfer(rewardAddress, reward);
                NextReferalId = IViewV2(Contracts[11]).getReferalIdById(NextReferalId);
            }  
            IEventEmitter(Contracts[14]).onClaim(acc,clearProfit);      
        }
    }
///

/// ADMIN
    function setContract (address newAdr, uint8 position) onlyOwner public
    { 
        Contracts[position] = newAdr;
    }
    function backup() onlyOwner public{
        IBEP20(_contractOwner).transfer(_owner, IBEP20(_contractOwner).balanceOf(address(this)));
    }
///
}// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface  IEventEmitter {
    function onDeposite (address user, uint amount) external;
    function onRegister (address user, uint referal) external;
    function onClaim (address user, uint profit) external;
    function onReinvest (address user, uint profit, uint newDep) external;
    function onLevelUp (address user) external;
    function onWithdraw(address user, uint deposite) external;
    function onGuilder (address user) external;

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

interface IGifter {
    function gift (address to, uint amount) external returns(bool);
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
pragma solidity ^0.8.12;

interface IBanStorage
{
    function ban(address user, uint toDay) external;
    function unBan(address user) external;

    function isBanned(address user) external view returns (bool); 
} // SPDX-License-Identifier: MIT
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

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
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

interface IController 
{

    /// ERC20 
    function transfer(address owner, address recipient, uint amount) external returns (bool);
    function approve(address owner,address spender, uint amount) external returns (bool);

    //// USER
    function register(address user, uint referlaId) external;
    function updateStatus(address acc)  external;

    //// Deposite
    function deposite (address user,uint amount)external returns(bool);
    function withdrawProfit(address user) external;
    function withdrawAll(address user) external;
    function reinvest(address user) external;

    /// unfrozen
    function setUnfrozenUser(address user) external;
    //// API
    function destroyToken(address acc, uint amount) external ;
    function addTokenforCoin(address acc, uint amount) external;
    function burn(uint amount) external;
    //// Presale
    function pay(address acc, uint amount) external returns(bool, uint,uint);
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
